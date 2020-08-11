include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_vars                 = read_terragrunt_config(find_in_parent_folders("service.hcl"))

  modules_related_path = "${path_relative_from_include()}/${local.service_vars.locals.name}/modules"
}

terraform {
  source = "${local.modules_related_path}/ecs-cluster"
}

inputs = {
  name = "ecs-cluster"
}