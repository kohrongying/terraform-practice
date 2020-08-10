include {
  path = find_in_parent_folders()
}

locals {
  vpc_path = "../vpc"
  iam_path = "../iam"
  ecs_cluster_path = "../ecs-cluster"
}

dependency "vpc" {
  config_path = local.vpc_path
}

dependency "iam" {
  config_path = local.iam_path
}

dependency "cluster" {
  config_path = local.ecs_cluster_path
}

dependencies {
  paths = [local.vpc_path, local.iam_path, local.ecs_cluster_path]
}

terraform {
  source = "../..//003-modules/ecs-service-flask"
}

inputs = {
  subnet_ids = dependency.vpc.outputs.subnets["private"]
  vpc_id = dependency.vpc.outputs.vpc_id
  cluster_id = dependency.cluster.outputs.cluster_id
  execution_role_arn = dependency.iam.outputs.task_execution_arn
}