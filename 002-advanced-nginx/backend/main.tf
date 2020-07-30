provider "aws" {
  profile    = "default"
  region     = var.region
}

### DECLARE VARIABLES
### WILL BE SUPPLIED FROM COMMONS.TFVARS
variable "region" {}
variable "terraform_state_bucket" {}
variable "terraform_state_dynamo_db" {}

resource "aws_s3_bucket" "state" {
  bucket = var.terraform_state_bucket

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "S3 Remote Terraform State Store"
  }      
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.terraform_state_dynamo_db
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
