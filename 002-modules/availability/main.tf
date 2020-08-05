## DECLARE VARIABLES 
variable "environment" {}
variable "resource_tag" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "security_groups" {}
variable "vpc_id" {}
variable "iam_instance_profile" {}

## AUTO SCALING GROUP
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "main" {
  name          = "web_config_${var.resource_tag}-${var.environment}"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  security_groups = var.security_groups
  iam_instance_profile = var.iam_instance_profile
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
              sudo apt update
              sudo apt -y install docker-ce
              sudo docker pull nginx
              sudo docker run -d --name docker-nginx -p 80:80 nginx
              EOF
}

resource "aws_autoscaling_group" "main" {
  name = "web_autoscaling_${var.resource_tag}-${var.environment}"
  max_size = 2
  min_size = 1
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier = var.private_subnet_ids
  
  // for application loadbalancer
  target_group_arns = [aws_lb_target_group.default.arn]

  tag {
    key = "Name"
    value = "${var.resource_tag} - ${var.environment}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# LB application
resource "aws_lb" "main" {
  name = "lb-${var.resource_tag}-${var.environment}"
  load_balancer_type = "application"
  security_groups = var.security_groups
  subnets = var.public_subnet_ids
}

resource "aws_lb_target_group" "default" {
  name  = "web-target-group"
  port  = "80"
  protocol = "HTTP"
  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

