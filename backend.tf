terraform {
  backend "s3" {
    bucket         = "my-tf-dev-backend"
    key            = "state/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-dev-locks"
    encrypt        = true
  }
}
