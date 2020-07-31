data "aws_vpc" "main_dev" {
  tags = {
    Name = "${var.resource_tag} - dev"
  }
}

data "aws_subnet_ids" "public_dev" {
  vpc_id = data.aws_vpc.main_dev.id
  tags = {
    Type = "public"
  }
}

data "aws_security_groups" "main_dev" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_dev.id]
  }
}


module "instance_dev" {
  source = "../../../002-modules/web-server"
  region = var.region
  resource_tag = var.resource_tag
  public_subnet_ids = tolist(data.aws_subnet_ids.public_dev.*[0]["ids"])
  security_groups = data.aws_security_groups.main_dev.*.ids[0]
  environment = "dev"
}

module "high-availability-dev" {
  source = "../../../002-modules/availability"
  region = var.region
  resource_tag = var.resource_tag
  instance_id = module.instance_dev.id
  public_subnet_ids = data.aws_subnet_ids.public_dev.*[0]["ids"]
  security_groups = data.aws_security_groups.main_dev.*.ids[0]
  environment = "dev"
}

