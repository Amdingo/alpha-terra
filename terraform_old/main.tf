provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}


### IAM Role for S3
resource "aws_iam_instance_profile" "s3_access" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access.id}"
  policy = "${file("./policies/policy-s3-bucket-admin.json")}"
}

resource "aws_iam_role" "s3_access" {
  name = "s3_access"
  assume_role_policy = "${file("./policies/assume-role-policy.json")}"
}

### VPC and Networking
# VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.1.0.0/16"

  tags {
    Name = "dev_vpc"
    Environment = "development"
  }
}

# IGW
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = "${aws_vpc.dev_vpc.id}"

  tags {
    Environment = "development"
  }
}

# Public Route Table
resource "aws_route_table" "dev_public" {
  vpc_id = "${aws_vpc.dev_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.dev_igw.id}"
  }

  tags {
    Name = "public"
    Environment = "development"
  }
}

# Private Route Table
resource "aws_default_route_table" "dev_private" {
  default_route_table_id = "${aws_vpc.dev_vpc.default_route_table_id}"

  tags {
    Name = "private"
    Environment = "development"
  }
}

### Subnets
# Public
resource "aws_subnet" "public" {
  cidr_block = "10.1.1.0/24"
  vpc_id = "${aws_vpc.dev_vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1d"

  tags {
    Name = "public"
    Environment = "development"
  }
}

# Private
resource "aws_subnet" "private" {
  cidr_block = "10.1.2.0/24"
  vpc_id = "${aws_vpc.dev_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"

  tags {
    Name = "private"
    Environment = "development"
  }
}

#S3 VPC Endpoint
resource "aws_vpc_endpoint" "dev_private_s3" {
  vpc_id = "${aws_vpc.dev_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = ["${aws_vpc.dev_vpc.main_route_table_id}", "${aws_route_table.dev_public.id}"]
  policy = "${file("./policies/policy-admin-all.json")}"
}

# RDS 1
resource "aws_subnet" "rds1" {
  cidr_block = "10.1.3.0/24"
  vpc_id = "${aws_vpc.dev_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"

  tags {
    Name = "rds"
    Environment = "development"
  }
}

# RDS 2
resource "aws_subnet" "rds2" {
  cidr_block = "10.1.4.0/24"
  vpc_id = "${aws_vpc.dev_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1c"

  tags {
    Name = "rds"
    Environment = "development"
  }
}

# Subnet Associations
resource "aws_route_table_association" "dev_public_assoc" {
  route_table_id = "${aws_route_table.dev_public.id}"
  subnet_id = "${aws_subnet.public.id}"
}

resource "aws_db_subnet_group" "dev_rds_subnet_group" {
  name = "dev_rds_subnet_group"
  subnet_ids = ["${aws_subnet.rds1.id}", "${aws_subnet.rds2.id}"]

  tags {
    Name = "rds_sng"
    Environment = "development"
  }
}

### Security Groups
# Public
resource "aws_security_group" "dev_public" {
  name = "dev_sg_public"
  description = "Used for public and private load balancer access"
  vpc_id = "${aws_vpc.dev_vpc.id}"

  #SSH
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${var.localip}"]
  }

  #HTTP
  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTPS ?
}

# Private
resource "aws_security_group" "dev_private" {
  name = "dev_sg_private"
  description = "Used for private instances"
  vpc_id = "${aws_vpc.dev_vpc.id}"

  #Access from other SGs
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

# RDS
resource "aws_security_group" "dev_sg_rds" {
  name = "dev_sg_rds"
  description = "Used for DB instances"
  vpc_id = "${aws_vpc.dev_vpc.id}"

  #SQL Access from public/private sgs
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    security_groups = ["${aws_security_group.dev_public.id}", "${aws_security_group.dev_private.id}"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

# S3 Bucket ?
resource "aws_s3_bucket" "dev_bucket" {
  bucket = "${var.domain_name}_dev_code_232786"
  acl = "private"
  force_destroy = true

  tags {
    Name = "code bucket"
    Environment = "development"
  }
}
  # Static ?

### Compute Resources
# Keypair
resource "aws_key_pair" "dev_auth" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# AS Dev Server
resource "aws_instance" "alphastack_dev" {
  ami = "${var.dev_alphastack_ami}"
  instance_type = "${var.dev_alphastack_instance_type}"

  tags {
    Name = "dev alphastack server"
    Environment = "development"
  }

  key_name = "${aws_key_pair.dev_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.dev_public.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access.id}"
  subnet_id = "${aws_subnet.public.id}"
}
  # Docker
# Clairity Server
# RDS
resource "aws_db_instance" "dev_clairity_db" {
  name = "${var.dbname}"
  username = "${var.dbuser}"
  password = "${var.dbpassword}"
  instance_class = "${var.db_instance_class}"
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.6.27"
  db_subnet_group_name = "${aws_db_subnet_group.dev_rds_subnet_group.name}"
  vpc_security_group_ids = ["${aws_security_group.dev_sg_rds.id}"]
}
# ALB
# AMI
# Launch Configuration
# ASG

### Route 53
# Primary Zone
# www record (to ALB)
# dev (to dev public IP)
# db cname (to rds)
