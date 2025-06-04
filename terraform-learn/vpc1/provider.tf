terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.99.1"
      region = "us-east-1"
    }
  }
backend "s3" {
  bucket         = "meirk-terraform-test-bucket"
  region         = "us-east-1"
  key            = "meirk/vpc1/terraform.tfstate"
  encrypt        = true
}
}