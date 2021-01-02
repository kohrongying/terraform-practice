
module "wsus" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.16.0"

  instance_count = 1
  associate_public_ip_address = true
  name          = "wsus"
  ami           = "ami-0ea1b666a75da32ca"
  instance_type = "t3.medium"
  subnet_id     = module.vpc_ingress.public_subnets[0]
  vpc_security_group_ids      = [module.security_group2.this_security_group_id]
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 150
    },
  ]
  key_name = "aws-ry-pem"
}


module "security_group2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "wsus-sgrp"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc_ingress.vpc_id

  ingress_cidr_blocks = [locals.my_ip]
  ingress_rules       = ["rdp-tcp"]
  egress_rules        = ["all-all"]
}