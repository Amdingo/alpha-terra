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
variable "bastion_ami" {
  description = "ami for the bastion image"
}

variable "bastion_eip_id" {
}

# route 53
variable "domain_name" {
  default = "exampleapp"
}
