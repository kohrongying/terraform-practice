provider "aws" {
  profile    = "default"
  region     = var.region
}

variable "region" {}

data "aws_instance" "web" {
  instance_tags = {
    Name = "prac-002"
  }
}


data "aws_vpc" "main" {
  tags = {
    Name = "prac-002"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Type = "public"
  }
}


data "aws_security_groups" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]ye
  }
}


## AUTO SCALING GROUP

resource "aws_ami_from_instance" "web_ami" {
  name               = "main_web"
  source_instance_id = data.aws_instance.web.id
}

resource "aws_launch_configuration" "main" {
  name          = "web_config"
  image_id      = aws_ami_from_instance.web_ami.id
  instance_type = "t2.micro"
  key_name = "aws-test"
  security_groups = data.aws_security_groups.main.*.ids[0]

  user_data = <<-EOF
              #!/bin/bash
              sudo docker restart docker-nginx
              EOF
}

resource "aws_autoscaling_group" "main" {
  name = "web autoscaling"
  max_size = 3
  min_size = 2
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier = data.aws_subnet_ids.public.*[0]["ids"]
  load_balancers = [aws_elb.main.name]

  depends_on = [
    aws_launch_configuration.main
  ]
}


# ELB
resource "aws_elb" "main" {
  name = "web-loadbalancer"
  subnets = data.aws_subnet_ids.public.*[0]["ids"]
  
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
}

