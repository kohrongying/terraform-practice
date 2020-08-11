include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_vars                 = read_terragrunt_config(find_in_parent_folders("service.hcl"))
  env_vars                     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  modules_related_path = "${path_relative_from_include()}/${local.service_vars.locals.name}/modules"
  services_shared_modules_relative_path = "${path_relative_from_include()}/services-shared/${local.env_vars.locals.name}"
}

dependency "vpc" {
  config_path = "${local.services_shared_modules_relative_path}/vpc"
}

dependency "iam" {
  config_path = "${local.services_shared_modules_relative_path}/iam"
}

terraform {
  source = "${local.modules_related_path}/web"
}

inputs = {
  my_count = 1
  resource_tag = local.service_vars.locals.name
  environment = local.env_vars.locals.name
  security_groups = [dependency.vpc.outputs.security_groups["http"]]
  subnet_ids = dependency.vpc.outputs.subnets["private"]
  user_data = templatefile("./user_data.sh", {})
  iam_instance_profile = dependency.iam.outputs.ssm_instance_profile
}