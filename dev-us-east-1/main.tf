# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

//--------------------------------------------------------------------
// Workspace Data
data "terraform_remote_state" "alpha_stack_backbone" {
  backend = "atlas"
  config {
    name    = "AlphaStack/backbone"
    access_token = "${var.tf_access_token}"
  }
}

// Modules
module "clairity" {
  source  = "app.terraform.io/AlphaStack/clairity/aws"
  version = "0.1.7-alpha"

  aws_lb_subnets = ["${data.terraform_remote_state.alpha_stack_backbone.public_subnet_1_id}", "${data.terraform_remote_state.alpha_stack_backbone.public_subnet_2_id}"]
  aws_region = "us-east-1"
  clairity_ami = "${var.clairity_ami}"
  instance_type = "t2.medium"
  key_name = "alphastack"
  public_key = "${var.public_key}"
  rds_security_group = "${var.rds_security_group}"
  sub_domain = "${var.clairity_sub_domain}"
  subnet = "${data.terraform_remote_state.alpha_stack_backbone.private_subnet_1_id}"
  vpc = "${data.terraform_remote_state.alpha_stack_backbone.default_vpc_id}"
  alphastack_net_arn = "${var.alphastack_net_certificate_arn}"
}

# Uses a VPC provided via variables
data "aws_vpc" "default" {
  id = "${data.terraform_remote_state.alpha_stack_backbone.default_vpc_id}"
}

# The old VPC to peer to
data "aws_vpc" "old" {
  id = "${data.terraform_remote_state.alpha_stack_backbone.old_vpc_id}"
}

data "aws_security_group" "alb" {
  id = "${data.terraform_remote_state.alpha_stack_backbone.alb_security_group_id}"
}

data "aws_security_group" "private" {
  id = "${data.terraform_remote_state.alpha_stack_backbone.private_security_group_id}"
}

data "aws_security_group" "bastion" {
  id = "${data.terraform_remote_state.alpha_stack_backbone.bastion_security_group_id}"
}

# Application Load Balancer for Web Server
resource "aws_lb" "web" {
  name            = "Dev-AS"
  internal        = false
  subnets         = ["${data.terraform_remote_state.alpha_stack_backbone.public_subnet_1_id}", "${data.terraform_remote_state.alpha_stack_backbone.public_subnet_2_id}"]
  security_groups = ["${data.terraform_remote_state.alpha_stack_backbone.alb_security_group_id}"]

  tags {
    Name = "Dev-AS ALB"
    AppVersion = "Dev"
  }
}

# HTTPS
resource "aws_lb_listener" "web_https" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.terraform_remote_state.alpha_stack_backbone.certificate_arn}"

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
    Name = "Dev-AS HTTPS"
    AppVersion = "Dev"
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
    Name = "Dev-AS HTTP"
    AppVersion = "Dev"
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

#launch configuration

resource "aws_launch_configuration" "as_web_lc" {
  name_prefix          = "as_web_lc-"
  image_id             = "${var.as_dev_ami}"
  instance_type        = "${var.lc_instance_type}"
  security_groups      = ["${data.aws_security_group.private.id}"]
  key_name             = "${data.terraform_remote_state.alpha_stack_backbone.aws_key_pair_id}"
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

  vpc_zone_identifier = ["${data.terraform_remote_state.alpha_stack_backbone.private_subnet_1_id}",
    "${data.terraform_remote_state.alpha_stack_backbone.private_subnet_2_id}",
  ]

  launch_configuration = "${aws_launch_configuration.as_web_lc.name}"

  tags = [
    {
      key                 = "Name"
      value               = "Dev-AS Web/API Instance"
      propagate_at_launch = true
    },
    {
      key                 = "AppVersion"
      value               = "Dev"
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
  zone_id = "${data.terraform_remote_state.alpha_stack_backbone.as_route53_id}"
  name    = "${var.sub_domain_name}.${var.domain_name}.com"
  type    = "A"

  alias {
    name                   = "${aws_lb.web.dns_name}"
    zone_id                = "${aws_lb.web.zone_id}"
    evaluate_target_health = false
  }
}
