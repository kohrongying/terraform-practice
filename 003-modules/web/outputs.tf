output "public_ip" {
  value = aws_instance.web.*.id
}