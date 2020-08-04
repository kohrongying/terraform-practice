data "aws_vpc" "main" {
  tags = {
    Name = "${var.resource_tag} - prod"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Type = "public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Type = "private"
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
  subnet_id = tolist(data.aws_subnet_ids.public.*[0]["ids"])[0]
  security_groups = data.aws_security_groups.main.*.ids[0]
  environment = "prod"
}

module "high-availability" {
  source = "../../../002-modules/availability"
  region = var.region
  resource_tag = var.resource_tag
  instance_id = module.instance.id
  public_subnet_ids = data.aws_subnet_ids.public.*[0]["ids"]
  private_subnet_ids = data.aws_subnet_ids.private.*[0]["ids"]
  security_groups = data.aws_security_groups.main.*.ids[0]
  environment = "prod"
}

