variable "public_key" {}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "key_name" {
  default = "alphastack"
  description = "Name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC to use for terraform build"
  default     = "vpc-4b16b330"
}

variable "old_vpc" {
  description = "The old main VPC, this will go away soon"
  default     = "vpc-c1c690a4"
}

variable "old_vpc_route_table" {
  description = "The old VPC's route table to add the peering connection to"
  default     = "rtb-98517cfd"
}

variable "cidr_prefix" {
  description = "Probably the first two octects of ur VPC"
  default     = "10.20"
}

variable "route_table_id" {
  description = "The main route table associated with var.vpc_id"
  default     = "rtb-a223eade"
}

variable "igw_id" {
  description = "The igw attached to the main route table"
  default     = "igw-5a6bac22"
}

# amis
variable "bastion_ami" {
  description = "ami for the bastion image"
  default     = "ami-cb0df5b6"
}

variable "bastion_eip_id" {
  default = "eipalloc-e8bf7de1"
}

# route 53
variable "domain_name" {default = "alphastack"}
