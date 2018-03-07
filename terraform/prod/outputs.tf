output "AWS availability zones in use" {
  value = "${aws_subnet.tf_test_subnet.*.availability_zone}"
}

output "HAProxy nodes" {
  value = "${formatlist("%s, private IP: %s, public IP: %s, AZ: %s", aws_instance.haproxy_node.*.id, aws_instance.haproxy_node.*.private_ip, aws_instance.haproxy_node.*.public_ip, aws_instance.haproxy_node.*.availability_zone)}"
}

output "Web node private IPs" {
  value = "${formatlist("%s, private IP: %s, public IP: %s, AZ: %s", aws_instance.web_node.*.id, aws_instance.web_node.*.private_ip, aws_instance.web_node.*.public_ip, aws_instance.web_node.*.availability_zone)}"
}

output "Socket node private IPs" {
  value = "${formatlist("%s, private IP: %s, public IP: %s, AZ: %s", aws_instance.socket_node.*.id, aws_instance.socket_node.*.private_ip, aws_instance.socket_node.*.public_ip, aws_instance.socket_node.*.availability_zone)}"
}

output "ALB DNS address" {
  value = "${aws_lb.haproxy_alb.dns_name}"
}

output "ALB target group" {
  value = "${aws_instance.haproxy_node.*.id}"
}

output "HAProxy backend server list" {
  value = "${join("\n", formatlist("    server app-%v %v:80 cookie app-%v check", aws_instance.web_node.*.id, aws_instance.web_node.*.private_ip, aws_instance.web_node.*.id))}"
}
