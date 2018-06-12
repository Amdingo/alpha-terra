output "bastion_security_group_ids" {
  value = ["${aws_security_group.bastion-dev-kops-alphastack-com.id}"]
}

output "bastions_role_arn" {
  value = "${aws_iam_role.bastions-dev-kops-alphastack-com.arn}"
}

output "bastions_role_name" {
  value = "${aws_iam_role.bastions-dev-kops-alphastack-com.name}"
}

output "cluster_name" {
  value = "dev.kops.alphastack.com"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-dev-kops-alphastack-com.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-dev-kops-alphastack-com.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-dev-kops-alphastack-com.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-dev-kops-alphastack-com.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.us-east-1b-dev-kops-alphastack-com.id}", "${aws_subnet.us-east-1c-dev-kops-alphastack-com.id}", "${aws_subnet.us-east-1d-dev-kops-alphastack-com.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-dev-kops-alphastack-com.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-dev-kops-alphastack-com.name}"
}

output "region" {
  value = "us-east-1"
}

output "vpc_id" {
  value = "${aws_vpc.dev-kops-alphastack-com.id}"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_autoscaling_attachment" "bastions-dev-kops-alphastack-com" {
  elb                    = "${aws_elb.bastion-dev-kops-alphastack-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.bastions-dev-kops-alphastack-com.id}"
}

resource "aws_autoscaling_attachment" "master-us-east-1b-masters-dev-kops-alphastack-com" {
  elb                    = "${aws_elb.api-dev-kops-alphastack-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-east-1b-masters-dev-kops-alphastack-com.id}"
}

resource "aws_autoscaling_attachment" "master-us-east-1c-masters-dev-kops-alphastack-com" {
  elb                    = "${aws_elb.api-dev-kops-alphastack-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-east-1c-masters-dev-kops-alphastack-com.id}"
}

resource "aws_autoscaling_attachment" "master-us-east-1d-masters-dev-kops-alphastack-com" {
  elb                    = "${aws_elb.api-dev-kops-alphastack-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-east-1d-masters-dev-kops-alphastack-com.id}"
}

resource "aws_autoscaling_group" "bastions-dev-kops-alphastack-com" {
  name                 = "bastions.dev.kops.alphastack.com"
  launch_configuration = "${aws_launch_configuration.bastions-dev-kops-alphastack-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.utility-us-east-1b-dev-kops-alphastack-com.id}", "${aws_subnet.utility-us-east-1c-dev-kops-alphastack-com.id}", "${aws_subnet.utility-us-east-1d-dev-kops-alphastack-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "bastions.dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "bastions"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/bastion"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master-us-east-1b-masters-dev-kops-alphastack-com" {
  name                 = "master-us-east-1b.masters.dev.kops.alphastack.com"
  launch_configuration = "${aws_launch_configuration.master-us-east-1b-masters-dev-kops-alphastack-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-east-1b-dev-kops-alphastack-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-east-1b.masters.dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-east-1b"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master-us-east-1c-masters-dev-kops-alphastack-com" {
  name                 = "master-us-east-1c.masters.dev.kops.alphastack.com"
  launch_configuration = "${aws_launch_configuration.master-us-east-1c-masters-dev-kops-alphastack-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-east-1c-dev-kops-alphastack-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-east-1c.masters.dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-east-1c"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master-us-east-1d-masters-dev-kops-alphastack-com" {
  name                 = "master-us-east-1d.masters.dev.kops.alphastack.com"
  launch_configuration = "${aws_launch_configuration.master-us-east-1d-masters-dev-kops-alphastack-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-east-1d-dev-kops-alphastack-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-east-1d.masters.dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-east-1d"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-dev-kops-alphastack-com" {
  name                 = "nodes.dev.kops.alphastack.com"
  launch_configuration = "${aws_launch_configuration.nodes-dev-kops-alphastack-com.id}"
  max_size             = 3
  min_size             = 3
  vpc_zone_identifier  = ["${aws_subnet.us-east-1b-dev-kops-alphastack-com.id}", "${aws_subnet.us-east-1c-dev-kops-alphastack-com.id}", "${aws_subnet.us-east-1d-dev-kops-alphastack-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.dev.kops.alphastack.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "b-etcd-events-dev-kops-alphastack-com" {
  availability_zone = "us-east-1b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev.kops.alphastack.com"
    Name                 = "b.etcd-events.dev.kops.alphastack.com"
    "k8s.io/etcd/events" = "b/b,c,d"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "b-etcd-main-dev-kops-alphastack-com" {
  availability_zone = "us-east-1b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev.kops.alphastack.com"
    Name                 = "b.etcd-main.dev.kops.alphastack.com"
    "k8s.io/etcd/main"   = "b/b,c,d"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "c-etcd-events-dev-kops-alphastack-com" {
  availability_zone = "us-east-1c"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev.kops.alphastack.com"
    Name                 = "c.etcd-events.dev.kops.alphastack.com"
    "k8s.io/etcd/events" = "c/b,c,d"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "c-etcd-main-dev-kops-alphastack-com" {
  availability_zone = "us-east-1c"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev.kops.alphastack.com"
    Name                 = "c.etcd-main.dev.kops.alphastack.com"
    "k8s.io/etcd/main"   = "c/b,c,d"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "d-etcd-events-dev-kops-alphastack-com" {
  availability_zone = "us-east-1d"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev.kops.alphastack.com"
    Name                 = "d.etcd-events.dev.kops.alphastack.com"
    "k8s.io/etcd/events" = "d/b,c,d"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "d-etcd-main-dev-kops-alphastack-com" {
  availability_zone = "us-east-1d"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "dev.kops.alphastack.com"
    Name                 = "d.etcd-main.dev.kops.alphastack.com"
    "k8s.io/etcd/main"   = "d/b,c,d"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_eip" "us-east-1b-dev-kops-alphastack-com" {
  vpc = true
}

resource "aws_eip" "us-east-1c-dev-kops-alphastack-com" {
  vpc = true
}

resource "aws_eip" "us-east-1d-dev-kops-alphastack-com" {
  vpc = true
}

resource "aws_elb" "api-dev-kops-alphastack-com" {
  name = "api-dev-kops-alphastack-c-r6d70e"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-dev-kops-alphastack-com.id}"]
  subnets         = ["${aws_subnet.utility-us-east-1b-dev-kops-alphastack-com.id}", "${aws_subnet.utility-us-east-1c-dev-kops-alphastack-com.id}", "${aws_subnet.utility-us-east-1d-dev-kops-alphastack-com.id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "api.dev.kops.alphastack.com"
  }
}

resource "aws_elb" "bastion-dev-kops-alphastack-com" {
  name = "bastion-dev-kops-alphasta-8p6i6k"

  listener = {
    instance_port     = 22
    instance_protocol = "TCP"
    lb_port           = 22
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.bastion-elb-dev-kops-alphastack-com.id}"]
  subnets         = ["${aws_subnet.utility-us-east-1b-dev-kops-alphastack-com.id}", "${aws_subnet.utility-us-east-1c-dev-kops-alphastack-com.id}", "${aws_subnet.utility-us-east-1d-dev-kops-alphastack-com.id}"]

  health_check = {
    target              = "TCP:22"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "bastion.dev.kops.alphastack.com"
  }
}

resource "aws_iam_instance_profile" "bastions-dev-kops-alphastack-com" {
  name = "bastions.dev.kops.alphastack.com"
  role = "${aws_iam_role.bastions-dev-kops-alphastack-com.name}"
}

resource "aws_iam_instance_profile" "masters-dev-kops-alphastack-com" {
  name = "masters.dev.kops.alphastack.com"
  role = "${aws_iam_role.masters-dev-kops-alphastack-com.name}"
}

resource "aws_iam_instance_profile" "nodes-dev-kops-alphastack-com" {
  name = "nodes.dev.kops.alphastack.com"
  role = "${aws_iam_role.nodes-dev-kops-alphastack-com.name}"
}

resource "aws_iam_role" "bastions-dev-kops-alphastack-com" {
  name               = "bastions.dev.kops.alphastack.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_bastions.dev.kops.alphastack.com_policy")}"
}

resource "aws_iam_role" "masters-dev-kops-alphastack-com" {
  name               = "masters.dev.kops.alphastack.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.dev.kops.alphastack.com_policy")}"
}

resource "aws_iam_role" "nodes-dev-kops-alphastack-com" {
  name               = "nodes.dev.kops.alphastack.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.dev.kops.alphastack.com_policy")}"
}

resource "aws_iam_role_policy" "bastions-dev-kops-alphastack-com" {
  name   = "bastions.dev.kops.alphastack.com"
  role   = "${aws_iam_role.bastions-dev-kops-alphastack-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_bastions.dev.kops.alphastack.com_policy")}"
}

resource "aws_iam_role_policy" "masters-dev-kops-alphastack-com" {
  name   = "masters.dev.kops.alphastack.com"
  role   = "${aws_iam_role.masters-dev-kops-alphastack-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.dev.kops.alphastack.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-dev-kops-alphastack-com" {
  name   = "nodes.dev.kops.alphastack.com"
  role   = "${aws_iam_role.nodes-dev-kops-alphastack-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.dev.kops.alphastack.com_policy")}"
}

resource "aws_internet_gateway" "dev-kops-alphastack-com" {
  vpc_id = "${aws_vpc.dev-kops-alphastack-com.id}"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "dev.kops.alphastack.com"
  }
}

resource "aws_key_pair" "kubernetes-dev-kops-alphastack-com-9d2dd662012751c8a38b57cabfa985d7" {
  key_name   = "kubernetes.dev.kops.alphastack.com-9d:2d:d6:62:01:27:51:c8:a3:8b:57:ca:bf:a9:85:d7"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.dev.kops.alphastack.com-9d2dd662012751c8a38b57cabfa985d7_public_key")}"
}

resource "aws_launch_configuration" "bastions-dev-kops-alphastack-com" {
  name_prefix                 = "bastions.dev.kops.alphastack.com-"
  image_id                    = "ami-b0c6ccca"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.kubernetes-dev-kops-alphastack-com-9d2dd662012751c8a38b57cabfa985d7.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastions-dev-kops-alphastack-com.id}"
  security_groups             = ["${aws_security_group.bastion-dev-kops-alphastack-com.id}"]
  associate_public_ip_address = true

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 32
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "master-us-east-1b-masters-dev-kops-alphastack-com" {
  name_prefix                 = "master-us-east-1b.masters.dev.kops.alphastack.com-"
  image_id                    = "ami-b0c6ccca"
  instance_type               = "m5.large"
  key_name                    = "${aws_key_pair.kubernetes-dev-kops-alphastack-com-9d2dd662012751c8a38b57cabfa985d7.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-dev-kops-alphastack-com.id}"
  security_groups             = ["${aws_security_group.masters-dev-kops-alphastack-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-east-1b.masters.dev.kops.alphastack.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "master-us-east-1c-masters-dev-kops-alphastack-com" {
  name_prefix                 = "master-us-east-1c.masters.dev.kops.alphastack.com-"
  image_id                    = "ami-b0c6ccca"
  instance_type               = "m5.large"
  key_name                    = "${aws_key_pair.kubernetes-dev-kops-alphastack-com-9d2dd662012751c8a38b57cabfa985d7.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-dev-kops-alphastack-com.id}"
  security_groups             = ["${aws_security_group.masters-dev-kops-alphastack-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-east-1c.masters.dev.kops.alphastack.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "master-us-east-1d-masters-dev-kops-alphastack-com" {
  name_prefix                 = "master-us-east-1d.masters.dev.kops.alphastack.com-"
  image_id                    = "ami-b0c6ccca"
  instance_type               = "m5.large"
  key_name                    = "${aws_key_pair.kubernetes-dev-kops-alphastack-com-9d2dd662012751c8a38b57cabfa985d7.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-dev-kops-alphastack-com.id}"
  security_groups             = ["${aws_security_group.masters-dev-kops-alphastack-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-east-1d.masters.dev.kops.alphastack.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-dev-kops-alphastack-com" {
  name_prefix                 = "nodes.dev.kops.alphastack.com-"
  image_id                    = "ami-b0c6ccca"
  instance_type               = "m5.large"
  key_name                    = "${aws_key_pair.kubernetes-dev-kops-alphastack-com-9d2dd662012751c8a38b57cabfa985d7.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-dev-kops-alphastack-com.id}"
  security_groups             = ["${aws_security_group.nodes-dev-kops-alphastack-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.dev.kops.alphastack.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "us-east-1b-dev-kops-alphastack-com" {
  allocation_id = "${aws_eip.us-east-1b-dev-kops-alphastack-com.id}"
  subnet_id     = "${aws_subnet.utility-us-east-1b-dev-kops-alphastack-com.id}"
}

resource "aws_nat_gateway" "us-east-1c-dev-kops-alphastack-com" {
  allocation_id = "${aws_eip.us-east-1c-dev-kops-alphastack-com.id}"
  subnet_id     = "${aws_subnet.utility-us-east-1c-dev-kops-alphastack-com.id}"
}

resource "aws_nat_gateway" "us-east-1d-dev-kops-alphastack-com" {
  allocation_id = "${aws_eip.us-east-1d-dev-kops-alphastack-com.id}"
  subnet_id     = "${aws_subnet.utility-us-east-1d-dev-kops-alphastack-com.id}"
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.dev-kops-alphastack-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dev-kops-alphastack-com.id}"
}

resource "aws_route" "private-us-east-1b-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-us-east-1b-dev-kops-alphastack-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.us-east-1b-dev-kops-alphastack-com.id}"
}

resource "aws_route" "private-us-east-1c-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-us-east-1c-dev-kops-alphastack-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.us-east-1c-dev-kops-alphastack-com.id}"
}

resource "aws_route" "private-us-east-1d-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-us-east-1d-dev-kops-alphastack-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.us-east-1d-dev-kops-alphastack-com.id}"
}

resource "aws_route53_record" "api-dev-kops-alphastack-com" {
  name = "api.dev.kops.alphastack.com"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-dev-kops-alphastack-com.dns_name}"
    zone_id                = "${aws_elb.api-dev-kops-alphastack-com.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z18FEC8SHK1DB"
}

resource "aws_route53_record" "bastion-dev-kops-alphastack-com" {
  name = "bastion.dev.kops.alphastack.com"
  type = "A"

  alias = {
    name                   = "${aws_elb.bastion-dev-kops-alphastack-com.dns_name}"
    zone_id                = "${aws_elb.bastion-dev-kops-alphastack-com.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z18FEC8SHK1DB"
}

resource "aws_route_table" "dev-kops-alphastack-com" {
  vpc_id = "${aws_vpc.dev-kops-alphastack-com.id}"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "dev.kops.alphastack.com"
  }
}

resource "aws_route_table" "private-us-east-1b-dev-kops-alphastack-com" {
  vpc_id = "${aws_vpc.dev-kops-alphastack-com.id}"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "private-us-east-1b.dev.kops.alphastack.com"
  }
}

resource "aws_route_table" "private-us-east-1c-dev-kops-alphastack-com" {
  vpc_id = "${aws_vpc.dev-kops-alphastack-com.id}"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "private-us-east-1c.dev.kops.alphastack.com"
  }
}

resource "aws_route_table" "private-us-east-1d-dev-kops-alphastack-com" {
  vpc_id = "${aws_vpc.dev-kops-alphastack-com.id}"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "private-us-east-1d.dev.kops.alphastack.com"
  }
}

resource "aws_route_table_association" "private-us-east-1b-dev-kops-alphastack-com" {
  subnet_id      = "${aws_subnet.us-east-1b-dev-kops-alphastack-com.id}"
  route_table_id = "${aws_route_table.private-us-east-1b-dev-kops-alphastack-com.id}"
}

resource "aws_route_table_association" "private-us-east-1c-dev-kops-alphastack-com" {
  subnet_id      = "${aws_subnet.us-east-1c-dev-kops-alphastack-com.id}"
  route_table_id = "${aws_route_table.private-us-east-1c-dev-kops-alphastack-com.id}"
}

resource "aws_route_table_association" "private-us-east-1d-dev-kops-alphastack-com" {
  subnet_id      = "${aws_subnet.us-east-1d-dev-kops-alphastack-com.id}"
  route_table_id = "${aws_route_table.private-us-east-1d-dev-kops-alphastack-com.id}"
}

resource "aws_route_table_association" "utility-us-east-1b-dev-kops-alphastack-com" {
  subnet_id      = "${aws_subnet.utility-us-east-1b-dev-kops-alphastack-com.id}"
  route_table_id = "${aws_route_table.dev-kops-alphastack-com.id}"
}

resource "aws_route_table_association" "utility-us-east-1c-dev-kops-alphastack-com" {
  subnet_id      = "${aws_subnet.utility-us-east-1c-dev-kops-alphastack-com.id}"
  route_table_id = "${aws_route_table.dev-kops-alphastack-com.id}"
}

resource "aws_route_table_association" "utility-us-east-1d-dev-kops-alphastack-com" {
  subnet_id      = "${aws_subnet.utility-us-east-1d-dev-kops-alphastack-com.id}"
  route_table_id = "${aws_route_table.dev-kops-alphastack-com.id}"
}

resource "aws_security_group" "api-elb-dev-kops-alphastack-com" {
  name        = "api-elb.dev.kops.alphastack.com"
  vpc_id      = "${aws_vpc.dev-kops-alphastack-com.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "api-elb.dev.kops.alphastack.com"
  }
}

resource "aws_security_group" "bastion-dev-kops-alphastack-com" {
  name        = "bastion.dev.kops.alphastack.com"
  vpc_id      = "${aws_vpc.dev-kops-alphastack-com.id}"
  description = "Security group for bastion"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "bastion.dev.kops.alphastack.com"
  }
}

resource "aws_security_group" "bastion-elb-dev-kops-alphastack-com" {
  name        = "bastion-elb.dev.kops.alphastack.com"
  vpc_id      = "${aws_vpc.dev-kops-alphastack-com.id}"
  description = "Security group for bastion ELB"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "bastion-elb.dev.kops.alphastack.com"
  }
}

resource "aws_security_group" "masters-dev-kops-alphastack-com" {
  name        = "masters.dev.kops.alphastack.com"
  vpc_id      = "${aws_vpc.dev-kops-alphastack-com.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "masters.dev.kops.alphastack.com"
  }
}

resource "aws_security_group" "nodes-dev-kops-alphastack-com" {
  name        = "nodes.dev.kops.alphastack.com"
  vpc_id      = "${aws_vpc.dev-kops-alphastack-com.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "nodes.dev.kops.alphastack.com"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-dev-kops-alphastack-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion-dev-kops-alphastack-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion-elb-dev-kops-alphastack-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-to-master-ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.bastion-dev-kops-alphastack-com.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "bastion-to-node-ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.bastion-dev-kops-alphastack-com.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-dev-kops-alphastack-com.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.api-elb-dev-kops-alphastack-com.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.nodes-dev-kops-alphastack-com.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-elb-to-bastion" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.bastion-dev-kops-alphastack-com.id}"
  source_security_group_id = "${aws_security_group.bastion-elb-dev-kops-alphastack-com.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "ssh-external-to-bastion-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion-elb-dev-kops-alphastack-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-east-1b-dev-kops-alphastack-com" {
  vpc_id            = "${aws_vpc.dev-kops-alphastack-com.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "us-east-1b"

  tags = {
    KubernetesCluster                               = "dev.kops.alphastack.com"
    Name                                            = "us-east-1b.dev.kops.alphastack.com"
    "kubernetes.io/cluster/dev.kops.alphastack.com" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_subnet" "us-east-1c-dev-kops-alphastack-com" {
  vpc_id            = "${aws_vpc.dev-kops-alphastack-com.id}"
  cidr_block        = "172.20.64.0/19"
  availability_zone = "us-east-1c"

  tags = {
    KubernetesCluster                               = "dev.kops.alphastack.com"
    Name                                            = "us-east-1c.dev.kops.alphastack.com"
    "kubernetes.io/cluster/dev.kops.alphastack.com" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_subnet" "us-east-1d-dev-kops-alphastack-com" {
  vpc_id            = "${aws_vpc.dev-kops-alphastack-com.id}"
  cidr_block        = "172.20.96.0/19"
  availability_zone = "us-east-1d"

  tags = {
    KubernetesCluster                               = "dev.kops.alphastack.com"
    Name                                            = "us-east-1d.dev.kops.alphastack.com"
    "kubernetes.io/cluster/dev.kops.alphastack.com" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_subnet" "utility-us-east-1b-dev-kops-alphastack-com" {
  vpc_id            = "${aws_vpc.dev-kops-alphastack-com.id}"
  cidr_block        = "172.20.0.0/22"
  availability_zone = "us-east-1b"

  tags = {
    KubernetesCluster                               = "dev.kops.alphastack.com"
    Name                                            = "utility-us-east-1b.dev.kops.alphastack.com"
    "kubernetes.io/cluster/dev.kops.alphastack.com" = "owned"
    "kubernetes.io/role/elb"                        = "1"
  }
}

resource "aws_subnet" "utility-us-east-1c-dev-kops-alphastack-com" {
  vpc_id            = "${aws_vpc.dev-kops-alphastack-com.id}"
  cidr_block        = "172.20.4.0/22"
  availability_zone = "us-east-1c"

  tags = {
    KubernetesCluster                               = "dev.kops.alphastack.com"
    Name                                            = "utility-us-east-1c.dev.kops.alphastack.com"
    "kubernetes.io/cluster/dev.kops.alphastack.com" = "owned"
    "kubernetes.io/role/elb"                        = "1"
  }
}

resource "aws_subnet" "utility-us-east-1d-dev-kops-alphastack-com" {
  vpc_id            = "${aws_vpc.dev-kops-alphastack-com.id}"
  cidr_block        = "172.20.8.0/22"
  availability_zone = "us-east-1d"

  tags = {
    KubernetesCluster                               = "dev.kops.alphastack.com"
    Name                                            = "utility-us-east-1d.dev.kops.alphastack.com"
    "kubernetes.io/cluster/dev.kops.alphastack.com" = "owned"
    "kubernetes.io/role/elb"                        = "1"
  }
}

resource "aws_vpc" "dev-kops-alphastack-com" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                               = "dev.kops.alphastack.com"
    Name                                            = "dev.kops.alphastack.com"
    "kubernetes.io/cluster/dev.kops.alphastack.com" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "dev-kops-alphastack-com" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "dev.kops.alphastack.com"
    Name              = "dev.kops.alphastack.com"
  }
}

resource "aws_vpc_dhcp_options_association" "dev-kops-alphastack-com" {
  vpc_id          = "${aws_vpc.dev-kops-alphastack-com.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dev-kops-alphastack-com.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
