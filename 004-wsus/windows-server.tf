
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.16.0"

  instance_count = 1
  associate_public_ip_address = false
  name          = "windows-client"
  ami           = "ami-0ea1b666a75da32ca" //Windows 2019
  instance_type = "t3.medium"
  subnet_id     = tolist(data.aws_subnet_ids.private.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 100
    },
  ]
  key_name = "aws-ry-pem"
  iam_instance_profile = aws_iam_instance_profile.this.name
}

resource "aws_iam_instance_profile" "this" {
  name = "windows-client-profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = "windows-client-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "windows-client-sgrp"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.mgmt.id

  ingress_cidr_blocks = [local.my_ip]
  ingress_rules       = ["rdp-tcp"]
  egress_rules        = ["all-all"]
}

//10.0.1.12
//Administrator
//6q8IJIjROeE-ZD@NZe@lcAr&jNQuSDro