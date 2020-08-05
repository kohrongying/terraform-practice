variable "resource_tag" {}
variable "environment" {}
variable "security_groups" {}
variable "subnet_ids" {
  type = list(string)
}
variable "iam_instance_profile" {}

module "instance" {
  source = "../../003-modules/web"

  my_count = 2
  resource_tag = var.resource_tag
  environment = var.environment
  security_groups = [var.security_groups]
  subnet_ids = var.subnet_ids
  user_data = templatefile("${path.module}/user_data.sh", {})
  iam_instance_profile = var.iam_instance_profile
}