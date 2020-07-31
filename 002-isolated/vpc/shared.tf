provider "aws" {
  profile    = "default"
  region     = var.region
}

variable "region" {}
variable "resource_tag" {}