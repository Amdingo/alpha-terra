variable "aws_region" {}
variable "aws_profile" {}
data "aws_availability_zones" "available" {}
variable "devips" {}
variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}

variable "alb_name" {}
variable "alb_path" {}
# variable "alb_subnets" {}
# variable "alb_security_groups" {}
variable "asg_max" {}
variable "asg_min" {}
variable "asg_grace" {}
variable "asg_hct" {}
variable "asg_cap" {}
variable "aws_lb_target_group_name" {}
variable "internal_alb" {}
variable "idle_timeout" {}
variable "db_instance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}
variable "key_name" {}
variable "public_key_path" {}
variable "domain_name" {}
variable "sub_domain_name" {}
variable "svc_port" {}
variable "dev_instance_type" {}
variable "dev_ami" {}
variable "elb_healthy_threshold" {}
variable "elb_unhealthy_threshold" {}
variable "elb_timeout" {}
variable "elb_interval" {}
variable "lc_instance_type" {}
variable "delegation_set" {}
variable "s3_bucket" {}
# variable "vpc_id" {}
variable "target_group_name" {}
variable "target_group_sticky" {}
variable "target_group_path" {}
variable "target_group_port" {}
