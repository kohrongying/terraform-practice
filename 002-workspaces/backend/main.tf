provider "aws" {
  profile    = "default"
  region     = var.region
}

### DECLARE VARIABLES
### WILL BE SUPPLIED FROM COMMONS.TFVARS
variable "region" {}

resource "aws_s3_bucket" "state" {
  bucket = "ry-terraform-state-002-workspaces"

  versioning {
    enabled = true
  }

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
  name         = "ry-terraform-state-locks-002-workspaces"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
