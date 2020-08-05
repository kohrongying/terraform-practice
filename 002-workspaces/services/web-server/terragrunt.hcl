terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy"]

    arguments = [
      "-var-file=../../common.tfvars"
    ]
  }
}

locals {
  vpc_path = "../../vpc"
  iam_path = "../../iam"
}

dependency "vpc" {
  config_path = local.vpc_path
}

dependency "iam" {
  config_path = local.iam_path
}

dependencies {
  paths = [local.vpc_path, local.iam_path]
}

inputs = {
  resource_tag = "prac-002"
  environment = "dev"
  public_subnet_ids = dependency.vpc.outputs.subnets["public"]
  private_subnet_ids = dependency.vpc.outputs.subnets["private"]
  security_groups = values(dependency.vpc.outputs.security_groups)
  iam_instance_profile = dependency.iam.outputs.ssm_instance_profile
  vpc_id = dependency.vpc.outputs.vpc_id
}

include {
  path = find_in_parent_folders()
}