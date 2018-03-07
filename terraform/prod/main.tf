provider "aws" {
  region = "${var.aws_region}"
}

data "aws_availability_zones" "all" {}

resource "aws_vpc" "alphastack_default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "haproxy_test_vpc"
  }
}

resource "aws_subnet" "tf_test_subnet" {
  count                   = "${var.aws_az_count}"
  vpc_id                  = "${aws_vpc.alphastack_default.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.alphastack_default.cidr_block, 8, count.index)}"
  availability_zone       = "${data.aws_availability_zones.all.names[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "haproxy_test_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.alphastack_default.id}"

  tags {
    Name = "haproxy_test_ig"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.alphastack_default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "aws_route_table"
  }
}

resource "aws_route_table_association" "a" {
  count          = "${var.aws_az_count}"
  subnet_id      = "${element(aws_subnet.tf_test_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_security_group" "instance_sg1" {
  name        = "instance_sg1"
  description = "Instance (haproxy/Web node) SG to pass tcp/22 by default"
  vpc_id      = "${aws_vpc.alphastack_default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
}

resource "aws_security_group" "instance_sg2" {
  name        = "instance_sg2"
  description = "Instance (haproxy/Web node) SG to pass ELB traffic  by default"
  vpc_id      = "${aws_vpc.alphastack_default.id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.instance_sg1.id}", "${aws_security_group.alb.id}"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.instance_sg1.id}", "${aws_security_group.alb.id}"]
  }
}

resource "aws_security_group" "alb" {
  name        = "alb_sg"
  description = "Used in the terraform"

  vpc_id = "${aws_vpc.alphastack_default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_lb" "haproxy_alb" {
  name = "haproxy-test-alb"

  internal = false

  subnets         = ["${aws_subnet.tf_test_subnet.*.id}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Name = "haproxy_alb"
  }
}

resource "aws_lb_target_group" "haproxy_alb_target" {
  name = "haproxy-test-alb-tg"

  vpc_id = "${aws_vpc.alphastack_default.id}"

  port     = 80
  protocol = "HTTP"

  health_check {
    interval            = 30
    path                = "/haproxy_status"
    port                = 8080
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200,202"
  }

  tags {
    Name = "haproxy_alb_tg"
  }
}

resource "aws_lb_listener" "haproxy_alb_listener" {
  load_balancer_arn = "${aws_lb.haproxy_alb.arn}"

  port     = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.haproxy_alb_target.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "haproxy_alb_target_att" {
  count = "${var.haproxy_cluster_size * var.aws_az_count}"

  target_group_arn = "${aws_lb_target_group.haproxy_alb_target.arn}"
  target_id        = "${element(aws_instance.haproxy_node.*.id, count.index)}"

  port = 80
}

resource "aws_instance" "web_node" {
  count = "${var.web_cluster_size * var.aws_az_count}"

  instance_type = "${var.aws_web_instance_type}"

  ami = "${lookup(var.alphastack_server_amis, var.aws_region)}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.instance_sg1.id}", "${aws_security_group.instance_sg2.id}"]
  subnet_id              = "${element(aws_subnet.tf_test_subnet.*.id, count.index / var.web_cluster_size)}"
  # user_data              = "${file("web-userdata.sh")}"

  tags {
    Name = "web_node_${count.index}"
  }
}

resource "aws_instance" "socket_node" {
  count = "${var.socket_cluster_size * var.aws_az_count}"

  instance_type = "${var.aws_socket_instance_type}"

  ami = "${lookup(var.socket_aws_amis, var.aws_region)}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.instance_sg1.id}", "${aws_security_group.instance_sg2.id}"]
  subnet_id              = "${element(aws_subnet.tf_test_subnet.*.id, count.index / var.web_cluster_size)}"
  # user_data              = "${file("web-userdata.sh")}"

  tags {
    Name = "web_node_${count.index}"
  }
}

data "template_file" "haproxy-userdata" {
  template = "${file("haproxy-userdata.sh.tpl")}"

  vars {
    serverlist = "${join("\n", formatlist("    server app-%v %v:8000 cookie app-%v check", aws_instance.web_node.*.id, aws_instance.web_node.*.private_ip, aws_instance.web_node.*.id))}"
  }
}

resource "aws_instance" "haproxy_node" {
  count = "${var.haproxy_cluster_size * var.aws_az_count}"

  instance_type = "${var.aws_haproxy_instance_type}"

  ami = "${lookup(var.haproxy_aws_amis, var.aws_region)}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.instance_sg1.id}", "${aws_security_group.instance_sg2.id}"]
  subnet_id              = "${element(aws_subnet.tf_test_subnet.*.id, count.index / var.haproxy_cluster_size)}"
  user_data              = "${data.template_file.haproxy-userdata.rendered}"

  tags {
    Name = "haproxy_node_${count.index}"
  }
}
