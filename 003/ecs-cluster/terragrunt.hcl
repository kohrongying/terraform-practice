include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../003-modules/ecs-cluster"
}

inputs = {
  name = "ecs-cluster"
}