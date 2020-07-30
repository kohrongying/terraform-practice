provider "aws" {
  profile    = "default"
  region     = var.region
}

variable "region" {}

locals {
  install_docker_data = <<-EOF
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

data "aws_vpc" "main" {
  tags = {
    Name = "prac-002"
  }
}

data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "public 0"
  }
}


data "aws_security_groups" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

## WEB SERVER 

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

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = data.aws_security_groups.main.*.ids[0]
  subnet_id = data.aws_subnet.public.id

  user_data = local.install_docker_data
  associate_public_ip_address = true
  key_name = "aws-test"

  tags = {
    Name = "prac-002"
  }
}