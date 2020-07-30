provider "aws" {
  profile    = "default"
  region     = "us-east-1"
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

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1c"]
  type        = list
  description = "List of availability zones"
}
 

## VPC, Subnets, RT and IGW
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

## Public subnets, RT, IGW
resource "aws_subnet" "public" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public ${count.index}"
  }
}

resource "aws_security_group" "http" {
  name = "allow web"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0", "::/0"]
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ssh" {
  name = "allow ssh"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0", "::/0"]
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_subnet" "private" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private ${count.index}"
  }
}

resource "aws_route_table" "private" {
  count = 2
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private" {
  count = 2

  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main[count.index].id
}


resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_eip" "nat" {
  count = 2

  vpc = true
}

resource "aws_nat_gateway" "main" {
  depends_on = [aws_internet_gateway.main]

  count = 2

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

## AUTO SCALING GROUP

resource "aws_ami_from_instance" "web_ami" {
  name               = "main_web"
  source_instance_id = aws_instance.web[0].id
}

resource "aws_launch_configuration" "main" {
  name          = "web_config"
  image_id      = aws_ami_from_instance.web_ami.id
  instance_type = "t2.micro"
  key_name = "aws-test"
  security_groups = [aws_security_group.http.id, aws_security_group.ssh.id]

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
  vpc_zone_identifier = aws_subnet.public.*.id
  load_balancers = [aws_elb.main.name]

  depends_on = [
    aws_launch_configuration.main
  ]
}


# ELB
resource "aws_elb" "main" {
  name = "web-loadbalancer"
  subnets = aws_subnet.public.*.id
  
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
  count = 1

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.ssh.id]
  subnet_id = aws_subnet.public[0].id
  user_data = local.install_docker_data
  associate_public_ip_address = true
  key_name = "aws-test"
}