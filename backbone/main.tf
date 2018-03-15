# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

# Provide the alphastack.com zone for reference later
data "aws_route53_zone" "as_zone" {
  name = "alphastack.com"
  private_zone = false
}

# Provides the AWS Certificate for use by the ALB
data "aws_acm_certificate" "alphastack" {
  domain   = "*.alphastack.com"
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

# Uses a VPC provided via variables
data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

# The old VPC to peer to
data "aws_vpc" "old" {
  id = "${var.old_vpc}"
}

# The old VPC's route table that we'll attach the peering route to
data "aws_route_table" "old_vpc_route_table" {
  route_table_id = "${var.old_vpc_route_table}"
}

# Sets up the peering connection
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = "${data.aws_vpc.old.id}"
  vpc_id      = "${data.aws_vpc.default.id}"
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name = "Old to Prod VPC Connection"
  }
}

resource "aws_route" "old-to-new-peer" {
  route_table_id            = "${data.aws_route_table.old_vpc_route_table.id}"
  destination_cidr_block    = "10.20.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
}

# Provides the default route table for the VPC as a resource
resource "aws_default_route_table" "rt" {
  default_route_table_id = "${var.route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.as_gw.id}"
  }

  tags {
    Name = "Alpha|Stack Default Route Table"
  }
}

# Create an internet gateway to give our subnet access to the outside world
data "aws_internet_gateway" "default" {
  internet_gateway_id = "${var.igw_id}"
}

# Create an EIP for the NAT Gateway that's going to be provided to the private subnets
resource "aws_eip" "nat" {
  tags {
    name = "EIP for NAT GW for TF Subnets"
  }
}

# And allocate it to the bastion server
resource "aws_eip_association" "bastion" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${var.bastion_eip_id}"
}

# Create the NAT Gateway
resource "aws_nat_gateway" "as_gw" {
  depends_on = ["data.aws_internet_gateway.default"]
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.default.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${data.aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${data.aws_internet_gateway.default.id}"
  }

  route {
    cidr_block = "172.31.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  }

  tags {
    Name = "Alpha|Stack Public Route Table"
  }
}

# Grant the VPC internet access on its main route table

# Create dem subnets to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${data.aws_vpc.default.id}"
  cidr_block              = "${var.cidr_prefix}.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags {
    Name = "A|S Public 1"
  }
}

resource "aws_route_table_association" "pu1" {
  subnet_id = "${aws_subnet.default.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "default_2" {
  vpc_id                  = "${data.aws_vpc.default.id}"
  cidr_block              = "${var.cidr_prefix}.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags {
    Name = "A|S Public 2"
  }
}

resource "aws_route_table_association" "pu2" {
  subnet_id = "${aws_subnet.default_2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private_1" {
  cidr_block              = "${var.cidr_prefix}.3.0/24"
  vpc_id                  = "${data.aws_vpc.default.id}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags {
    Name = "A|S Private 1"
  }
}

resource "aws_route_table_association" "pr1" {
  route_table_id = "${aws_default_route_table.rt.id}"
  subnet_id = "${aws_subnet.private_1.id}"
}

resource "aws_subnet" "private_2" {
  cidr_block              = "${var.cidr_prefix}.4.0/24"
  vpc_id                  = "${data.aws_vpc.default.id}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags {
    Name = "A|S Private 2"
  }
}

resource "aws_route_table_association" "pr2" {
  route_table_id = "${aws_default_route_table.rt.id}"
  subnet_id = "${aws_subnet.private_2.id}"
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
  description = "allows traffic from within the VPC"
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
    from_port   = 8888
    to_port     = 8888
    protocol    = "TCP"
    cidr_blocks = ["${var.cidr_prefix}.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
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
  name            = "AlphaStack-WebServer-LB"
  internal        = false
  subnets         = ["${aws_subnet.default.id}", "${aws_subnet.default_2.id}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Name = "AlphaStack WebServer ALB"
    AppVersion = "Beta"
  }
}

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
  subnet_id = "${aws_subnet.default.id}"

  # Name it in the tags
  tags {
    Name        = "AlphaStack Production Bastion Server"
    AppVersion  = "Beta"
  }

}



