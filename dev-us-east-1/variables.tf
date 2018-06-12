variable "public_key" {}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "key_name" {
  default = "exampleapp"
  description = "Name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC to use for terraform build"
}

variable "old_vpc" {
  description = "The old main VPC, this will go away soon"
}

variable "old_vpc_route_table" {
  description = "The old VPC's route table to add the peering connection to"
}

variable "cidr_prefix" {
  description = "Probably the first two octects of ur VPC"
  default     = "10.20"
}

variable "route_table_id" {
  description = "The main route table associated with var.vpc_id"
}

variable "igw_id" {
  description = "The igw attached to the main route table"
}

# amis
variable "as_dev_ami" {}

variable "bastion_ami" {
  description = "ami for the bastion image"
}

variable "bastion_eip_id" {
}

# route 53
variable "domain_name" {
  default = "exampleapp"
}

variable "sub_domain_name" {
  default = "terraform"
}

# launch configuration
variable "lc_instance_type" {
  description = "The instance type used for the exampleapp launch configuration"
  default     = "t2.medium"
}

# auto-scaling group
variable "asg_max" {
  description = "Count of maximum servers for the auto-scaling group"
  default     = "3"
}

variable "asg_min" {
  description = "Count of minimum servers for the auto-scaling group"
  default     = "2"
}

variable "asg_grace_period" {
  description = "Time after instance comes into service before checking health"
  default     = "300"
}

variable "asg_hct" {
  description = "Type of Health Check (ELB or EC2)"
  default     = "EC2"
}

variable "asg_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group prior to terraform finishing apply."
  default     = "2"
}

variable "tf_access_token" {}

variable "backend_ami" {}

variable "backend_sub_domain" {}

variable "rds_security_group" {}

variable "exampleapp_net_certificate_arn" {}

variable "backend_instance_type" {}
