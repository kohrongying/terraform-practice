include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "iam" {
  config_path = "../iam"
}

dependencies {
  paths = ["../vpc", "../iam"]
}

inputs = {
  resource_tag = "prac-003"
  environment = "dev"
  subnet_ids = dependency.vpc.outputs.subnets["private"]
  security_groups = dependency.vpc.outputs.sg_http
  iam_instance_profile = dependency.iam.outputs.ssm_instance_profile
}