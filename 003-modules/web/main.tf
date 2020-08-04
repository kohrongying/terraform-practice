## DECLARE VARIABLES
variable "environment" {
  default = "dev"
}
variable "resource_tag" {
  default = "prac"
}
variable "subnet_id" {}
variable "security_groups" {}
variable "user_data" {}

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

  user_data = var.user_data
  associate_public_ip_address = true
  # key_name = "aws-test"

  tags = {
    Name = "${var.resource_tag} - ${var.environment}"
  }
}