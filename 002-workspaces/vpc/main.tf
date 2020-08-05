variable "resource_tag" {}

module "vpc" {
  source = "../../003-modules/vpc"
  resource_tag = var.resource_tag
  environment = terraform.workspace
}

output "subnets" {
  value = module.vpc.subnets
}

output "security_groups" {
  value = module.vpc.security_groups
}

output "vpc_id" {
  value = module.vpc.vpc_id
}