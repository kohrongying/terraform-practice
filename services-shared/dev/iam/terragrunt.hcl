include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${path_relative_from_include()}/services-shared/modules/iam"
}