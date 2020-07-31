terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy"]

    arguments = [
      "-var-file=../common.tfvars"
    ]
  }
}

include {
  path = find_in_parent_folders()
}