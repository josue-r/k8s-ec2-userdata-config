terraform {
  required_version = ">= 1.3.7, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.45.0"
    }
  }
}