provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#data "aws_availability_zones" "available" {}
data "aws_acm_certificate" "alphastack_ssl_cert" {
  domain      = "*.alphastack.com"
  statuses    = ["ISSUES"]
  types       = ["AMAZON_ISSUES"]
  most_recent = true
}

#------------IAM----------------

#S3_access

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
  },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
}
EOF
}

#-------------VPC-----------

resource "aws_vpc" "as_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "as_vpc"
  }
}

#internet gateway

resource "aws_internet_gateway" "as_internet_gateway" {
  vpc_id = "${aws_vpc.as_vpc.id}"

  tags {
    Name = "as_igw"
  }
}

# Route tables

resource "aws_route_table" "as_public_rt" {
  vpc_id = "${aws_vpc.as_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.as_internet_gateway.id}"
  }

  tags {
    Name = "as_public"
  }
}

resource "aws_default_route_table" "as_private_rt" {
  default_route_table_id = "${aws_vpc.as_vpc.default_route_table_id}"

  tags {
    Name = "as_private"
  }
}

resource "aws_subnet" "as_public1_subnet" {
  vpc_id                  = "${aws_vpc.as_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "as_public1"
  }
}

resource "aws_subnet" "as_public2_subnet" {
  vpc_id                  = "${aws_vpc.as_vpc.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "as_public2"
  }
}

resource "aws_subnet" "as_private1_subnet" {
  vpc_id                  = "${aws_vpc.as_vpc.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "as_private1"
  }
}

resource "aws_subnet" "as_private2_subnet" {
  vpc_id                  = "${aws_vpc.as_vpc.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "as_private2"
  }
}

#create S3 VPC endpoint
resource "aws_vpc_endpoint" "as_private-s3_endpoint" {
  vpc_id       = "${aws_vpc.as_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = ["${aws_vpc.as_vpc.main_route_table_id}",
    "${aws_route_table.as_public_rt.id}",
  ]

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY
}

/* resource "aws_subnet" "as_rds1_subnet" {
  vpc_id                  = "${aws_vpc.as_vpc.id}"
  cidr_block              = "${var.cidrs["rds1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "as_rds1"
  }
}

resource "aws_subnet" "as_rds2_subnet" {
  vpc_id                  = "${aws_vpc.as_vpc.id}"
  cidr_block              = "${var.cidrs["rds2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "as_rds2"
  }
}

resource "aws_subnet" "as_rds3_subnet" {
  vpc_id                  = "${aws_vpc.as_vpc.id}"
  cidr_block              = "${var.cidrs["rds3"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "as_rds3"
  }
} */

# Subnet Associations

resource "aws_route_table_association" "as_public_assoc" {
  subnet_id      = "${aws_subnet.as_public1_subnet.id}"
  route_table_id = "${aws_route_table.as_public_rt.id}"
}

resource "aws_route_table_association" "as_public2_assoc" {
  subnet_id      = "${aws_subnet.as_public2_subnet.id}"
  route_table_id = "${aws_route_table.as_public_rt.id}"
}

resource "aws_route_table_association" "as_private1_assoc" {
  subnet_id      = "${aws_subnet.as_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.as_private_rt.id}"
}

resource "aws_route_table_association" "as_private2_assoc" {
  subnet_id      = "${aws_subnet.as_private2_subnet.id}"
  route_table_id = "${aws_default_route_table.as_private_rt.id}"
}

/* resource "aws_db_subnet_group" "as_rds_subnetgroup" {
  name = "as_rds_subnetgroup"

  subnet_ids = ["${aws_subnet.as_rds1_subnet.id}",
    "${aws_subnet.as_rds2_subnet.id}",
    "${aws_subnet.as_rds3_subnet.id}",
  ]

  tags {
    Name = "as_rds_sng"
  }
} */

#Security groups

resource "aws_security_group" "as_dev_sg" {
  name        = "as_dev_sg"
  description = "Used for access to the dev instance"
  vpc_id      = "${aws_vpc.as_vpc.id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.devips}"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.devips}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTPS

  ingress {
    from_port   = 443
    to_port     = 443
    protocol = "tcp"
    cidr_blocks = ["${var.devips}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Public Security group

resource "aws_security_group" "as_public_sg" {
  name        = "as_public_sg"
  description = "Used for public and private instances for load balancer access"
  vpc_id      = "${aws_vpc.as_vpc.id}"

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTPS

  ingress {
    from_port   = 443
    to_port     = 443
    protocol = "tcp"
    cidr_blocks = ["${var.devips}"]
  }

  #Outbound internet access

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private Security Group

resource "aws_security_group" "as_private_sg" {
  name        = "as_private_sg"
  description = "Used for private instances"
  vpc_id      = "${aws_vpc.as_vpc.id}"

  # Access from other security groups

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#RDS Security Group
/* resource "aws_security_group" "as_rds_sg" {
  name        = "as_rds_sg"
  description = "Used for DB instances"
  vpc_id      = "${aws_vpc.as_vpc.id}"

  # SQL access from public/private security group

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = ["${aws_security_group.as_dev_sg.id}",
      "${aws_security_group.as_public_sg.id}",
      "${aws_security_group.as_private_sg.id}",
    ]
  }
} */

#S3 code bucket

resource "random_id" "as_code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket        = "${var.domain_name}_${random_id.as_code_bucket.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "code bucket"
  }
}

#---------compute-----------

/* resource "aws_db_instance" "as_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.6.27"
  instance_class         = "${var.db_instance_class}"
  name                   = "${var.dbname}"
  username               = "${var.dbuser}"
  password               = "${var.dbpassword}"
  db_subnet_group_name   = "${aws_db_subnet_group.as_rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.as_rds_sg.id}"]
  skip_final_snapshot    = true
} */

#key pair

resource "aws_key_pair" "as_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#dev server

resource "aws_instance" "as_dev" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"

  tags {
    Name = "as_dev"
  }

  key_name               = "${aws_key_pair.as_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.as_dev_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.as_public1_subnet.id}"

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts
[dev]
${aws_instance.as_dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
domain=${var.domain_name}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.as_dev.id} --profile superhero && ansible-playbook -i aws_hosts wordpress.yml"
  }
}

#load balancer

/* resource "aws_elb" "as_elb" {
  name = "${var.domain_name}-elb"

  subnets = ["${aws_subnet.as_public1_subnet.id}",
    "${aws_subnet.as_public2_subnet.id}",
  ]

  security_groups = ["${aws_security_group.as_public_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port = 443
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
  }

  health_check {
    healthy_threshold   = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout             = "${var.elb_timeout}"
    target              = "TCP:80"
    interval            = "${var.elb_interval}"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "as_${var.domain_name}-elb"
  }
} */

resource "aws_alb" "as_alb" {
  name            = "${var.alb_name}"
  subnets         = ["${aws_subnet.as_public1_subnet.id}", "${aws_subnet.as_public2_subnet.id}"]
/*  security_groups = ["${split(",",var.alb_security_groups)}"] */
  security_groups = ["${aws_security_group.as_dev_sg.id}"]
  internal        = "${var.internal_alb}"
  idle_timeout    = "${var.idle_timeout}"
  tags {
    Name  = "${var.alb_name}"
  }
  access_logs {
    bucket = "${var.s3_bucket}"
    prefix = "ELB-logs"
  }
}

resource "aws_alb_listener_rule" "as_listener_rule" {
  depends_on = ["aws_lb_target_group.as_front_end"]
  listener_arn = "${aws_alb_listener.as_alb_listener.arn}"
  priority = 0
  "action" {
    target_group_arn = "${aws_lb_target_group.as_front_end.arn}"
    type = "forward"
  }
  "condition" {
    field = "path-pattern"
    values = ["${var.alb_path}"]
  }
}

resource "aws_lb_target_group" "as_front_end" {
  name = "${var.aws_lb_target_group_name}"
  port     = "${var.svc_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.as_vpc.id}"
  tags {
    name = "${var.target_group_name}"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = "${var.target_group_sticky}"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "${var.target_group_path}"
    port                = "${var.target_group_port}"
  }
}

resource "aws_alb_listener" "as_alb_listener" {
  load_balancer_arn = "${aws_alb.as_alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.alphastack_ssl_cert.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.as_front_end.arn}"
    type             = "forward"
  }
}

#AMI

resource "random_id" "golden_ami" {
  byte_length = 8
}

resource "aws_ami_from_instance" "as_golden" {
  name               = "as_ami-${random_id.golden_ami.b64}"
  source_instance_id = "${aws_instance.as_dev.id}"

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF > userdata
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/' >> /var/spool/cron/root
EOF
EOT
  }
}

#launch configuration

resource "aws_launch_configuration" "as_lc" {
  name_prefix          = "as_lc-"
  image_id             = "${var.dev_ami_id}"
  instance_type        = "${var.lc_instance_type}"
  security_groups      = ["${aws_security_group.as_private_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  key_name             = "${aws_key_pair.as_auth.id}"
  user_data            = "${file("userdata")}"

  lifecycle {
    create_before_destroy = true
  }
}

#ASG

#resource "random_id" "rand_asg" {
# byte_length = 8
#}

resource "aws_autoscaling_group" "as_asg" {
  name                      = "asg-${aws_launch_configuration.as_lc.id}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace}"
  health_check_type         = "${var.asg_hct}"
  desired_capacity          = "${var.asg_cap}"
  force_delete              = true
  load_balancers            = ["${aws_alb.as_alb.id}"]

  vpc_zone_identifier = ["${aws_subnet.as_private1_subnet.id}",
    "${aws_subnet.as_private2_subnet.id}",
  ]

  launch_configuration = "${aws_launch_configuration.as_lc.name}"

  tag {
    key                 = "Name"
    value               = "as_asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#---------Route53-------------

#primary zone

resource "aws_route53_zone" "primary" {
  name              = "${var.domain_name}.com"
  delegation_set_id = "${var.delegation_set}"
}

#www

resource "aws_route53_record" "sub_domain" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.sub_domain_name}.${var.domain_name}.com"
  type    = "A"

  alias {
    name                   = "${aws_alb.as_alb.dns_name}"
    zone_id                = "${aws_alb.as_alb.zone_id}"
    evaluate_target_health = false
  }
}

#dev

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "dev.${var.domain_name}.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.as_dev.public_ip}"]
}

#secondary zone

resource "aws_route53_zone" "secondary" {
  name   = "${var.domain_name}.com"
  vpc_id = "${aws_vpc.as_vpc.id}"
}

#db

/* resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.secondary.zone_id}"
  name    = "${var.sub_domain_name}-a-s.db.${var.domain_name}.net"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.as_db.address}"]
} */
