terraform {
  backend "s3" {
    encrypt = true
    bucket = "ry-terraform-state-test"
    region = "us-east-1"
    key = "terraform.tfstate"

    dynamodb_table = "terraform-state-locks"
  }
}