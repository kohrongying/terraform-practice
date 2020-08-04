provider "aws" {
  profile    = "default"
  region     = var.region
}

## DECLARE VARIABLES

variable "region" {}
variable "environment" {}
variable "resource_tag" {}
variable "subnet_id" {}
variable "security_groups" {}


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

  vpc_security_group_ids = var.security_groups
  subnet_id = var.subnet_id

  user_data = local.install_docker_data
  associate_public_ip_address = true
  key_name = "aws-test"

  tags = {
    Name = "${var.resource_tag} - ${var.environment}"
  }
}