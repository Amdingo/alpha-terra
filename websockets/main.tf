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
    address = "app.terraform.io"
    name    = "AlphaStack/backbone"
  }
}

locals {
  alb_subnets = [
    "${data.terraform_remote_state.alpha_stack_backbone.public_subnet_1_id}",
    "${data.terraform_remote_state.alpha_stack_backbone.public_subnet_2_id}"
  ]
  default_vpc = "${data.terraform_remote_state.alpha_stack_backbone.default_vpc_id}"
  aws_certificate_arn = "${data.terraform_remote_state.alpha_stack_backbone.certificate_arn}"
}

resource "aws_security_group" "ws_alb" {
  name        = "as_ws_dev_alb"
  description = "WebSocket ALB Group: 80, 443, 4000"
  vpc_id      = "${var.vpc}"

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

  ingress {
    from_port = 4000
    protocol  = "TCP"
    to_port   = 4000
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

# Application Load Balancer for Socket Server
resource "aws_lb" "ws" {
  name            = "AlphaStack-SocketServer-LB"
  internal        = false
  subnets         = ["${local.alb_subnets}"]
  security_groups = ["${aws_security_group.ws_alb.id}"]

  tags {
    Name = "AlphaStack websocket ALB"
    AppVersion = "Beta"
  }
}

# HTTPS
resource "aws_lb_listener" "ws_https" {
  load_balancer_arn = "${aws_lb.ws.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${local.aws_certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.ws.arn}"
    type             = "forward"
  }
}

# HTTP This points to an NGINX instance that redirs to HTTPS
resource "aws_lb_listener" "ws_http" {
  load_balancer_arn = "${aws_lb.ws.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.ws.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "ws_https_4000" {
  load_balancer_arn = "${aws_lb.ws.arn}"
  port              = "4000"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${local.aws_certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.ws.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ws" {
  name = "web-ws-lb-target-group"
  port = "4000"
  protocol = "HTTP"
  vpc_id = "${local.default_vpc}"

  tags {
    Name = "AlphaStack Production HTTPS"
    AppVersion = "Beta"
  }
}

resource "aws_instance" "websocket_server" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "alphastack"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.instance_type}"

  # Lookup the correct AMI based on the region
  # we specified
  # ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami = "${var.ws_ami}"

  # The name of our SSH keypair we created above.
  key_name = "${var.key_pair_id}"

  # Our Security group to allow SSH access
  vpc_security_group_ids = ["${var.security_group_id}"]

  # Launches the instance into the default subnet
  subnet_id = "${var.instance_subnet}"

  # Name it in the tags
  tags {
    Name        = "AlphaStack Production Websocket Server"
    AppVersion  = "Beta"
  }
}

resource "aws_lb_target_group_attachment" "ws" {
  target_group_arn = "${aws_lb_target_group.ws.arn}"
  target_id = "${aws_instance.websocket_server.id}"
  port = "4000"
}

resource "aws_route53_record" "ws_subdomain" {
  name = "${var.ws_sub_domain_name}"
  type = "A"
  zone_id = "${data.terraform_remote_state.alpha_stack_backbone.as_route53_id}"

  alias {
    evaluate_target_health = false
    name = "${aws_lb.ws.dns_name}"
    zone_id = "${aws_lb.ws.zone_id}"
  }
}
