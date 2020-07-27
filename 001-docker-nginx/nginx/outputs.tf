output "aws_instance_ip" {
  value = "${aws_instance.this.*.public_ip}"
}

output "module_aws_instance_ip" {
  value = "${module.ec2-instance.public_ip}"
}