# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "terraform_remote_state" "backbone" {
  backend = "atlas"
  config {
    name         = "AlphaStack/backbone"
    access_token = "${var.tf_access_token}"
  }
}

data "aws_lb" "lb" {
  id = "${var.alb_id}"
}

resource "aws_instance" "websocket_server" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "alphastack"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.instance_type}"

  # Lookup the correct AMI based on the region
  # we specified
  # ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami = "${var.ws_ami}"

  # The name of our SSH keypair we created above.
  key_name = "${var.key_pair_id}"

  # Our Security group to allow SSH access
  vpc_security_group_ids = ["${var.security_group_id}"]

  # Launches the instance into the default subnet
  subnet_id = "${var.subnet_id}"

  # Name it in the tags
  tags {
    Name        = "AlphaStack Production Bastion Server"
    AppVersion  = "Beta"
  }
}
