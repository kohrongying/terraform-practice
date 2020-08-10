module "ssm" {
  source = "../../003-modules/iam"
}

output "ssm_instance_profile" {
  value = module.ssm.ssm_instance_profile
}