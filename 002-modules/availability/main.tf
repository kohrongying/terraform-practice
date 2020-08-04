provider "aws" {
  profile    = "default"
  region     = var.region
}


## DECLARE VARIABLES 

variable "region" {}
variable "environment" {}
variable "resource_tag" {}
variable "instance_id" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "security_groups" {}


## AUTO SCALING GROUP

resource "aws_ami_from_instance" "web_ami" {
  name               = "${var.resource_tag}-${var.environment}"
  source_instance_id = var.instance_id
}

resource "aws_launch_configuration" "main" {
  name          = "web_config_${var.resource_tag}-${var.environment}"
  image_id      = aws_ami_from_instance.web_ami.id
  instance_type = "t2.micro"
  key_name = "aws-test"
  security_groups = var.security_groups

  user_data = <<-EOF
              #!/bin/bash
              sudo docker restart docker-nginx
              EOF
}

resource "aws_autoscaling_group" "main" {
  name = "web_autoscaling_${var.resource_tag}-${var.environment}"
  max_size = 3
  min_size = 2
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier = var.private_subnet_ids
  load_balancers = [aws_elb.main.name]

  tag {
    key = "Name"
    value = "${var.resource_tag} - ${var.environment}"
    propagate_at_launch = true
  }
}


# ELB
resource "aws_elb" "main" {
  name = "web-loadbalancer-${var.resource_tag}-${var.environment}"
  subnets = var.public_subnet_ids
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  depends_on = [aws_launch_configuration.main]
}

