variable "aws_region" {}
variable "aws_profile" {}
variable "localip" {}

# DB
variable "db_instance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}

# Security
variable "key_name" {}
variable "public_key_path" {}

# S3
variable "domain_name" {}

# EC2
variable "dev_alphastack_instance_type" {}
variable "dev_alphastack_ami" {}
