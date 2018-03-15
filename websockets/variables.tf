variable "public_key" {}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  description = "same as parent provider"
}

variable "instance_type" {
  description = "Type of instance to launch, must be minimum of 2 vcpu"
  default = "t2.medium"
}

variable "ws_ami" {
  description = "The current websocket AMI"
}

variable "key_pair_id" {}

variable "instance_subnet" {
  type        = "string"
  description = "subnet for the websocket instance to be placed into"
}

variable "security_group_id" {
  description = "private security group id"
}

variable "tf_access_token" {}

variable "vpc" {}


