# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    region         = "ap-southeast-1"
    bucket         = "ry-terraform-prac"
    dynamodb_table = "ry-terraform-prac"
    encrypt        = true
    key            = "003/iam/terraform.tfstate"
  }
}
