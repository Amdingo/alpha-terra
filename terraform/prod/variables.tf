variable "aws_region" {
  description = "Home AWS region"
  default     = "us-east-1"
}

variable "aws_az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "aws_haproxy_instance_type" {
  description = "Default AWS instance type for haproxy nodes"
  default     = "t2.medium"
}

variable "aws_socket_instance_type" {
  description = "Default AWS instance type for socket nodes"
  default     = "t2.medium"
}

variable "aws_web_instance_type" {
  description = "Default AWS instance type for Web nodes"
  default     = "t2.medium"
}

variable "key_name" {
  description = "SSH key pair to use in AWS"
  default     = "haproxy-test"
}

variable "haproxy_cluster_size" {
  description = "Size of haproxy nodes cluster"
  default     = "1"
}

variable "socket_cluster_size" {
  description = "Size of socket nodes cluster"
  default     = "1"
}

variable "web_cluster_size" {
  description = "Size of Web nodes cluster"
  default     = "1"
}

# haproxy 1.7r1 Ubuntu Xenial 16.04 (20171024)
variable "haproxy_aws_amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-c58174b8"
  }
}

# websocket AMI based on 16.04
variable "socket_aws_amis" {
  type = "map"
  description = "The current alphastocket ami"
  default = {
    "us-east-1" = "ami-968a7feb"
  }
}

# alphastack AMI based on 16.04
variable "alphastack_server_amis" {
  type = "map"
  description = "The current alphastack ami"
  default = {
    "us-east-1" = "ami-360de74b"
  }
}
