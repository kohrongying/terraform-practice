# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "ry-terraform-state-test"
    dynamodb_table = "ry-terraform-state-locks"
    encrypt        = true
    key            = "vpc/terraform.tfstate"
  }
}