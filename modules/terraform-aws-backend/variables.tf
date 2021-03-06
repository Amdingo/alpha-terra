variable "backend_ami" {
  description = "the ami to use for backend"
}

variable "public_key" {
  description = "public key ssh-rsa"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "subnet" {
  description = "id of subnet for backend instance"
}

variable "aws_lb_subnets" {
  type = "list"
  description = "ids of at least two subnets in list form [\"<subnetId_1>\", \"<subnetId_2>\"]"
}

variable "sub_domain" {
  type = "string"
  description = "<sub_domain>-a-s.<example>.net"
}

variable "rds_security_group" {
  type = "string"
  description = "id of the rds security group that "
}

variable "vpc" {
  description = "ID of the VPC to place the backend instance in"
}

variable "instance_type" {
  description = "instance type to use for backend server"
  default = "c4.xlarge"
}

variable "key_name" {
  type = "string"
  description = "keypair used to connect to the backend instance"
}

variable "exampleapp_net_certificate_arn" {}
