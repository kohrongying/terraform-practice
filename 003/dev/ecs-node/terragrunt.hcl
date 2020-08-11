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

dependency "cluster" {
  config_path = "../ecs-cluster"
}

dependency "flask" {
  config_path = "../ecs-flask"
}

terraform {
  source = "${path_relative_from_include()}//${local.service_vars.locals.name}/modules/ecs-service-node"
}

inputs = {
  subnet_ids = dependency.vpc.outputs.subnets["private"]
  vpc_id = dependency.vpc.outputs.vpc_id
  cluster_id = dependency.cluster.outputs.cluster_id
  execution_role_arn = dependency.iam.outputs.task_execution_arn
  base_url_env_variable = dependency.flask.outputs.lb_dns
  sg_ingress_cidr_blocks = dependency.vpc.outputs.cidr_blocks["private"]
}