include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  resource_tag = "prac-003"
  environment = "dev"
  subnet_id = dependency.vpc.outputs.subnets["public"][0]
  security_groups = dependency.vpc.outputs.sg_http
}