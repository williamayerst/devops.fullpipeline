output "elb_dns_name" {
  value = "${aws_elb.elb1.dns_name}"
}
