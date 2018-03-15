variable "public_key" {}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  description = "same as parent provider"
}

variable "alb_id" {
  description = "application load balancer that will forward traffic"
}

variable "instance_type" {
  description = "Type of instance to launch, must be minimum of 2 vcpu"
  default = "t2.medium"
}

variable "ws_ami" {
  description = "The current websocket AMI"
}

variable "key_pair_id" {}

variable "subnet_id" {}

variable "security_group_id" {
  description = "private security group id"
}

variable "tf_access_token" {}
