# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "ry-terraform-state-test"
    dynamodb_table = "ry-terraform-state-locks"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "us-east-1"
  }
}
