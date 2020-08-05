provider "aws" {
  profile    = "default"
  region = "us-east-1"
}


resource "aws_cognito_user_pool" "pool" {
  name = "dropbox"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client"
  generate_secret     = false
  user_pool_id = aws_cognito_user_pool.pool.id
}