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

terraform {
  source = "../../003-modules/web"
}

inputs = {
  my_count = 1
  resource_tag = "prac-003"
  environment = "dev"
  security_groups = [dependency.vpc.outputs.security_groups["http"]]
  subnet_ids = dependency.vpc.outputs.subnets["private"]
  user_data = templatefile("./user_data.sh", {})
  iam_instance_profile = dependency.iam.outputs.ssm_instance_profile
}