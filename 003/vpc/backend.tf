# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    dynamodb_table = "ry-terraform-prac"
    encrypt        = true
    key            = "003/vpc/terraform.tfstate"
    region         = "ap-southeast-1"
    bucket         = "ry-terraform-prac"
  }
}
