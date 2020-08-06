resource "aws_cloudwatch_log_group" "web" {
  name = var.web_service_name
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = var.nginx_service_name
}