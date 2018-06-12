output "default_vpc_id" {
  value = "${data.aws_vpc.default.id}"
}

output "old_vpc_id" {
  value = "${data.aws_vpc.old.id}"
}

output "old_route_table_id" {
  value = "${data.aws_route_table.old_vpc_route_table.id}"
}

output "as_route53_id" {
  value = "${data.aws_route53_zone.as_zone.id}"
}

output "as_net_route53_id" {
  value = "${data.aws_route53_zone.as_net_zone.id}"
}

output "certificate_arn" {
  value = "${data.aws_acm_certificate.example-app.arn}"
}

output "public_subnet_1_id" {
  value = "${aws_subnet.default.id}"
}

output "public_subnet_2_id" {
  value = "${aws_subnet.default_2.id}"
}

output "private_subnet_1_id" {
  value = "${aws_subnet.private_1.id}"
}

output "private_subnet_2_id" {
  value = "${aws_subnet.private_2.id}"
}

output "alb_security_group_id" {
  value = "${aws_security_group.alb.id}"
}

output "aws_key_pair_id" {
  value = "${aws_key_pair.auth.id}"
}

output "aws_key_pair_name" {
  value = "${aws_key_pair.auth.key_name}"
}

output "bastion_security_group_id" {
  value = "${aws_security_group.bastion.id}"
}

output "private_security_group_id" {
  value = "${aws_security_group.as_private_sg.id}"
}
