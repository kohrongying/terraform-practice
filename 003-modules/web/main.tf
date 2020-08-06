## DECLARE VARIABLES

variable "environment" {
  default = "dev"
}
variable "resource_tag" {
  default = "prac-003"
}
variable "subnet_ids" {}
variable "security_groups" {}
variable "user_data" {}
variable "iam_instance_profile" {}
variable "my_count" {
  default = 1
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
  count = var.my_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = var.security_groups
  subnet_id = var.subnet_ids[count.index]

  user_data = var.user_data
  associate_public_ip_address = true

  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "${var.resource_tag} - ${var.environment}"
  }
}