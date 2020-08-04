variable "region" {}
variable "resource_tag" {}

module "vpc" {
  source = "../../002-modules/vpc"
  region = var.region
  resource_tag = var.resource_tag
  environment = terraform.workspace
}