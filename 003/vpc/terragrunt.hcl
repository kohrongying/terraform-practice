inputs = {
  resource_tag = "prac-003"
  environment = "dev"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../003-modules/vpc"
}