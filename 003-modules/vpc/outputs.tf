output "subnets" {
  value = {
    "public" = aws_subnet.public.*.id
    "private" = aws_subnet.private.*.id
  }
}

output "security_groups" {
  value = {
    "http" = aws_security_group.http.id,
    "default" = data.aws_security_group.default.id
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}