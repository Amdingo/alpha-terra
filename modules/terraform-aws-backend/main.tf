data "terraform_remote_state" "backbone" {
  backend = "atlas"
  config {
    name         = "exampleapp/backbone"
    access_token = "2JCkLM3YbJMXnw.atlasv1.HqlNxgwQMB7HcuJsKoNiSNsGGJZc8phkvZpizyEhrqJioMLlNySBbsBlLVtBAyvuqos"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "${var.sub_domain}_backend_instance"
  description = "${var.sub_domain} backend instance sg"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port   = 8888
    protocol    = "TCP"
    to_port     = 8888
    cidr_blocks = ["10.20.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A security group for the ALB so its accessible via HTTP and HTTPS
resource "aws_security_group" "alb" {
  name        = "${var.sub_domain}_backend_alb"
  description = "${var.sub_domain} alb security group"
  vpc_id      = "${var.vpc}"

  tags {
    Name        = "${var.sub_domain} backend ALB group"
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
    protocol  = "TCP"
    to_port   = 443
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

resource "aws_lb" "backend" {
  name            = "${title(var.sub_domain)}-backend"
  internal        = false
  subnets         = ["${var.aws_lb_subnets}"]
  security_groups = ["${aws_security_group.alb.id}"]
  idle_timeout    = 410

  tags {
    Name       = "${title(var.sub_domain)} backend Production ALB"
    AppVersion = "Beta"
  }
}

# HTTPS
resource "aws_lb_listener" "backend_https" {
  load_balancer_arn = "${aws_lb.backend.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.exampleapp_net_certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.backend.arn}"
    type             = "forward"
  }
}

# HTTP This will hopefully point to an NGINX instance that redirs to HTTPS
resource "aws_lb_listener" "backend_http" {
  load_balancer_arn = "${aws_lb.backend.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.backend.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "backend" {
  name = "${var.sub_domain}-https-backend-lb-tg"
  port = 8888
  protocol = "HTTP"
  vpc_id = "${var.vpc}"

  health_check {
    path = "/login.cfm"
  }

  tags {
    Name = "Dev-AS HTTPS"
    AppVersion = "Dev"
  }
}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = "${aws_lb_target_group.backend.arn}"
  target_id = "${aws_instance.backend.id}"
}

resource "aws_instance" "backend" {

  connection {
    user = "exampleapp"
  }

  key_name               = "${var.key_name}"
  ami                    = "${var.backend_ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet}"
  vpc_security_group_ids = ["${aws_security_group.backend_sg.id}"]
  tags {
    Name        = "${title(var.sub_domain)} backend Server"
    AppVersion  = "Beta"
  }

  depends_on = ["aws_security_group_rule.backend_to_rds"]
}

resource "aws_security_group_rule" "backend_to_rds" {
  from_port                = 3306
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.backend_sg.id}"
  security_group_id        = "${var.rds_security_group}"
  to_port                  = 3306
  type                     = "ingress"
}

resource "aws_route53_record" "net_sub_domain" {
  zone_id = "${data.terraform_remote_state.backbone.as_net_route53_id}"
  name    = "${var.sub_domain}-a-s.db.exampleapp.net"
  type    = "A"

  alias {
    evaluate_target_health = false
    name    = "${aws_lb.backend.dns_name}"
    zone_id = "${aws_lb.backend.zone_id}"
  }
}
