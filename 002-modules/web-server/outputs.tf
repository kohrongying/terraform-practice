output "public_ip" {
  value = "${aws_instance.web.public_ip}"
}

output "id" {
  value = "${aws_instance.web.id}"
}