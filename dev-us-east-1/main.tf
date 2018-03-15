# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "terraform_remote_state" "backbone" {
  backend = "atlas"
  config {
    name         = "AlphaStack/backbone"
    access_token = "2JCkLM3YbJMXnw.atlasv1.HqlNxgwQMB7HcuJsKoNiSNsGGJZc8phkvZpizyEhrqJioMLlNySBbsBlLVtBAyvuqos"
  }
}

# Uses a VPC provided via variables
data "aws_vpc" "default" {
  id = "${data.terraform_remote_state.backbone.aws_vpc.default.id}"
}

# The old VPC to peer to
data "aws_vpc" "old" {
  id = "${data.terraform_remote_state.backbone.aws_vpc.old.id}"
}

# A security group for the ALB so its accessible via HTTP and HTTPS
resource "aws_security_group" "alb" {
  name        = "terraform_dev_alb"
  description = "Used in the dev terraform example"
  vpc_id      = "${data.aws_vpc.default.id}"

  tags {
    Name        = "AlphaStack ALB Group"
    AppVersion  = "Beta"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    protocol = "TCP"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the public instances over SSH
resource "aws_security_group" "bastion" {
  name        = "as_prod_bastion"
  description = "Terraform Bastion Security Group"
  vpc_id      = "${data.aws_vpc.default.id}"

  tags {
    Name        = "AlphaStack Bastion Group"
    AppVersion  = "Beta"
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our private security group to access
# the public instances over SSH and HTTP
resource "aws_security_group" "as_private_sg" {
  name        = "AlphaStack Private Security Group"
  description = "private security group used in the dev terraform example"
  vpc_id      = "${data.aws_vpc.default.id}"

  tags {
    Name        = "AlphaStack Private Group"
    AppVersion  = "Beta"
  }

  # HTTP access from the vpc
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${var.cidr_prefix}.0.0/16"]
  }

  # 8000 access from the vpc
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "TCP"
    cidr_blocks = ["${var.cidr_prefix}.0.0/16"]
  }

  # 4000 access from the vpc
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "TCP"
    cidr_blocks = ["${var.cidr_prefix}.0.0/16"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol = "TCP"
    cidr_blocks = ["${var.cidr_prefix}.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer for Web Server
resource "aws_lb" "web" {
  name            = "Beta-AlphaStack-Production"
  internal        = false
  subnets         = ["${data.terraform_remote_state.backbone.public_subnet_1_id}", "${data.terraform_remote_state.backbone.public_subnet_2_id}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Name = "AlphaStack Production ALB"
    AppVersion = "Beta"
  }
}

# HTTPS
resource "aws_lb_listener" "web_https" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.terraform_remote_state.backbone.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.web_https.arn}"
    type             = "forward"
  }
}

# HTTP This points to an NGINX instance that redirs to HTTPS
resource "aws_lb_listener" "web_http" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.web_http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "web_https" {
  name = "web-https-lb-target-group"
  port = 8000
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.default.id}"

  tags {
    Name = "AlphaStack Production HTTPS"
    AppVersion = "Beta"
  }
}

resource "aws_lb_target_group" "web_http" {
  name = "web-http-lb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.default.id}"

  health_check {
    path = "/login"
    port = 8000
  }

  tags {
    Name = "AlphaStack Production HTTP"
    AppVersion = "Beta"
  }
}

//resource "aws_lb_target_group_attachment" "web_https" {
//  target_group_arn = "${aws_lb_target_group.web_https.arn}"
//  target_id = "${aws_instance.web.id}"
//}
//
//resource "aws_lb_target_group_attachment" "web_http" {
//  target_group_arn = "${aws_lb_target_group.web_http.arn}"
//  target_id = "${aws_instance.web.id}"
//}

resource "aws_alb_listener_rule" "as_https_listener_rule" {
  listener_arn = "${aws_lb_listener.web_https.arn}"
  "condition" {
    field = "host-header"
    values = ["terraform.alphastack.com"]
  }
  "action" {
    target_group_arn = "${aws_lb_target_group.web_https.arn}"
    type = "forward"
  }
  priority = 100
}

resource "aws_alb_listener_rule" "as_http_listener_rule" {
  listener_arn = "${aws_lb_listener.web_http.arn}"
  "condition" {
    field = "host-header"
    values = ["terraform.alphastack.com"]
  }
  "action" {
    target_group_arn = "${aws_lb_target_group.web_http.arn}"
    type = "forward"
  }
  priority = 100
}

//resource "aws_elb" "web" {
//  name = "terraform-dev-elb"
//
//  subnets         = ["${data.terraform_remote_state.backbone.private_subnet_1_id}"]
//  security_groups = ["${aws_security_group.elb.id}"]
//  instances       = ["${aws_instance.web.id}"]
//
//  listener {
//    instance_port     = 8000
//    instance_protocol = "TCP"
//    lb_port           = 80
//    lb_protocol       = "TCP"
//  }
//}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

resource "aws_instance" "bastion" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  # ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami = "${var.bastion_ami}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow SSH access
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  # Launches the instance into the default subnet
  subnet_id = "${data.terraform_remote_state.backbone.private_subnet_1_id}"

  # Name it in the tags
  tags {
    Name        = "AlphaStack Production Bastion Server"
    AppVersion  = "Beta"
  }

}

#launch configuration

resource "aws_launch_configuration" "as_web_lc" {
  name_prefix          = "as_web_lc-"
  image_id             = "${var.as_dev_ami}"
  instance_type        = "${var.lc_instance_type}"
  security_groups      = ["${aws_security_group.as_private_sg.id}"]
  key_name             = "${aws_key_pair.auth.id}"
//  user_data            = "${file("userdata")}"

  lifecycle {
    create_before_destroy = true
  }
}

#ASG

#resource "random_id" "rand_asg" {
# byte_length = 8
#}

resource "aws_autoscaling_group" "as_asg" {
  name                      = "asg-${aws_launch_configuration.as_web_lc.id}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace_period}"
  health_check_type         = "${var.asg_hct}"
  desired_capacity          = "${var.asg_capacity}"
  force_delete              = true
  target_group_arns         = ["${aws_lb_target_group.web_http.arn}",
    "${aws_lb_target_group.web_https.arn}"
  ]

  vpc_zone_identifier = ["${data.terraform_remote_state.backbone.private_subnet_1_id}",
    "${data.terraform_remote_state.backbone.private_subnet_2_id}",
  ]

  launch_configuration = "${aws_launch_configuration.as_web_lc.name}"

  tags = [
    {
      key                 = "Name"
      value               = "AlphaStack Production Web/API Instance"
      propagate_at_launch = true
    },
    {
      key                 = "AppVersion"
      value               = "Beta"
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Route53
#terraform
resource "aws_route53_record" "sub_domain" {
  zone_id = "${data.terraform_remote_state.backbone.route53_id}"
  name    = "${var.sub_domain_name}.${var.domain_name}.com"
  type    = "A"

  alias {
    name                   = "${aws_lb.web.dns_name}"
    zone_id                = "${aws_lb.web.zone_id}"
    evaluate_target_health = false
  }
}

