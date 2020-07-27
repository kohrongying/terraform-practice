variable "region" {
  default = "us-east-1"
}

variable "terraform_state_bucket" {
  default = "ry-terraform-state-test"
}

variable "terraform_state_bucket_key" {
  default = "terraform.tfstate"
}