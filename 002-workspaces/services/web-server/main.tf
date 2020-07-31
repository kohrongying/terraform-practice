provider "aws" {
  profile    = "default"
  region     = var.region
}

variable "region" {}
variable "resource_tag" {}


data "aws_vpc" "main" {
  tags = {
    Name = "${var.resource_tag} - ${terraform.workspace}"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Type = "public"
  }
}

data "aws_security_groups" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}


module "instance" {
  source = "../../../002-modules/web-server"
  region = var.region
  resource_tag = var.resource_tag
  public_subnet_ids = tolist(data.aws_subnet_ids.public.*[0]["ids"])
  security_groups = data.aws_security_groups.main.*.ids[0]
  environment = terraform.workspace
}

module "high-availability" {
  source = "../../../002-modules/availability"
  region = var.region
  resource_tag = var.resource_tag
  instance_id = module.instance.id
  public_subnet_ids = data.aws_subnet_ids.public.*[0]["ids"]
  security_groups = data.aws_security_groups.main.*.ids[0]
  environment = terraform.workspace
}

