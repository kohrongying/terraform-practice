variable "resource_tag" {}
variable "environment" {}
variable "security_groups" {
  type = list(string)
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "iam_instance_profile" {}
variable "vpc_id" {}

module "high-availability" {
  source = "../../../002-modules/availability"
  resource_tag = var.resource_tag
  environment = terraform.workspace
  security_groups = var.security_groups
  public_subnet_ids = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids
  iam_instance_profile = var.iam_instance_profile
  vpc_id = var.vpc_id
}