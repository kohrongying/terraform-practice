module "vpc-dev" {
  source = "../../002-modules/vpc"
  region = var.region
  resource_tag = var.resource_tag
  environment = "dev"
}