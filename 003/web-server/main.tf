variable "resource_tag" {}
variable "environment" {}
variable "security_groups" {}
variable "subnet_id" {}

module "instance" {
  source = "../../003-modules/web"
  resource_tag = var.resource_tag
  environment = var.environment
  security_groups = [var.security_groups]
  subnet_id = var.subnet_id
  user_data = templatefile("${path.module}/user_data.sh", {})
}