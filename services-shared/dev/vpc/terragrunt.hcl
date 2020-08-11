include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_vars                 = read_terragrunt_config(find_in_parent_folders("service.hcl"))
  env_vars                     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${path_relative_from_include()}/services-shared/modules/vpc"
}

inputs = {
  environment = local.env_vars.locals.name
  resource_tag = local.service_vars.locals.name
}