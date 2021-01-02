provider "aws" {
  region = "ap-southeast-1"
}


module "vpc_ingress" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name = "spike-vpc"
  cidr = "10.0.0.0/26"
  enable_dns_hostnames = true

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
  vpc_tags = {
    Name = "vpc-ingress"
  }

}

locals {
   //TODO to change
  rdgw_vpc = "vpc-0887e78b609ba61ab"
  rdgw_vpc_cidr = "10.0.2.0/24"
  my_ip = ""
}

data "aws_vpc" "mgmt" {
  id = local.rdgw_vpc
}

data "aws_subnet_ids" "private" {
  vpc_id = local.rdgw_vpc
  tags = {
    Type = "Private"
  }
}
resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id   = module.vpc_ingress.vpc_id
  vpc_id        = data.aws_vpc.mgmt.id
}

resource "aws_route" "route_to_vpc_peering_1" {
  count = length(module.vpc_ingress.public_route_table_ids)

  route_table_id = module.vpc_ingress.public_route_table_ids[count.index]
  destination_cidr_block = local.rdgw_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
