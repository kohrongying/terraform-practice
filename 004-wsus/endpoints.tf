module "vpce_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "vpce-sgrp"
  description = "Security group for VPC endpoints"
  vpc_id      = data.aws_vpc.mgmt.id

  ingress_cidr_blocks = ["10.0.2.0/24"]
  ingress_rules       = ["https-443-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = data.aws_vpc.mgmt.id
  service_name      = "com.amazonaws.ap-southeast-1.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = tolist(data.aws_subnet_ids.private.ids)
  security_group_ids = [
    module.vpce_security_group.this_security_group_id
  ]

  private_dns_enabled = true
}


resource "aws_vpc_endpoint" "ec2message" {
  vpc_id            = data.aws_vpc.mgmt.id

  service_name      = "com.amazonaws.ap-southeast-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = tolist(data.aws_subnet_ids.private.ids)

  security_group_ids = [
    module.vpce_security_group.this_security_group_id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = data.aws_vpc.mgmt.id

  service_name      = "com.amazonaws.ap-southeast-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = tolist(data.aws_subnet_ids.private.ids)

  security_group_ids = [
    module.vpce_security_group.this_security_group_id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessage" {
  vpc_id            = data.aws_vpc.mgmt.id

  service_name      = "com.amazonaws.ap-southeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = tolist(data.aws_subnet_ids.private.ids)

  security_group_ids = [
    module.vpce_security_group.this_security_group_id
  ]

  private_dns_enabled = true
}