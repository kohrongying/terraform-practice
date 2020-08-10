resource "aws_cloudwatch_log_group" "web" {
  name = local.service2_name
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = local.service1_name
}