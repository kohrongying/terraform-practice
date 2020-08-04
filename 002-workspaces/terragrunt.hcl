remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "skip"
  }
  config = {
    bucket = "ry-terraform-state-002-workspaces"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ry-terraform-state-locks-002-workspaces"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "skip"
  contents = <<EOF
provider "aws" {
  region = var.region
}
EOF
}