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
variable "as_dev_ami" {}

variable "bastion_ami" {
  description = "ami for the bastion image"
  default     = "ami-cb0df5b6"
}

# route 53
variable "domain_name" {default = "alphastack"}
variable "sub_domain_name" {default = "terraform"}

# launch configuration
variable "lc_instance_type" {
  description = "The instance type used for the AlphaStack launch configuration"
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
