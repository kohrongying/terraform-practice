module "ssm" {
  source = "../../003-modules/ssm"
}

output "ssm_instance_profile" {
  value = module.ssm.iam_instance_profile
}