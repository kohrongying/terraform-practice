variable "resource_tag" {}
variable "environment" {}

module "vpc" {
  source = "../../003-modules/vpc"
  resource_tag = var.resource_tag
  environment = var.environment
}

output "subnets" {
  value = module.vpc.subnets
}

output "sg_http" {
  value = module.vpc.security_groups["http"]
}

output "sg_ssh" {
  value = module.vpc.security_groups["ssh"]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}