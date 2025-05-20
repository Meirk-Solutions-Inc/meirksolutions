terraform {
    backend "s3" {
    bucket = "meirk-terraform-test-bucket"
    region = "us-east-1"
    key = "meirk/vpc/terraform.tfstate"
    encrypt = true
            
  }
}