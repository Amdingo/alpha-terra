output "default_vpc_id" {
  value = "${data.aws_vpc.default.id}"
}

output "old_vpc_id" {
  value = "${data.aws_vpc.old.id}"
}

output "old_route_table_id" {
  value = "${data.aws_route_table.old_vpc_route_table.id}"
}

output "route53_id" {
  value = "${data.aws_route53_zone.as_zone.id}"
}

output "certificate_arn" {
  value = "${data.aws_acm_certificate.alphastack.arn}"
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
