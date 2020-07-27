provider "aws" {
  profile    = "default"
  region     = var.region
}

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

### Attempt 1: Using default vpc and a pre-created SG

resource "aws_instance" "this" {
  count = 1

  ami           = var.ec2_ami
  instance_type = var.ec2_instance

  security_groups = ["http"]
  user_data = local.install_docker_data

  tags = {
    Name = "EC2 Instance running docker nginx"
  }
}


### Attempt 2: Using Modules

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.44.0"
  
  name = "simple-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = "user"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  ami = var.ec2_ami
  associate_public_ip_address = true
  instance_type = var.ec2_instance
  name = "another"

  vpc_security_group_ids = [module.security_group.this_security_group_id]
  subnet_id = module.vpc.public_subnets[0]
  user_data = local.install_docker_data
}