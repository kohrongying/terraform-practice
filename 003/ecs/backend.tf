# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    encrypt        = true
    key            = "003/ecs/terraform.tfstate"
    region         = "ap-southeast-1"
    bucket         = "ry-terraform-prac"
    dynamodb_table = "ry-terraform-prac"
  }
}
