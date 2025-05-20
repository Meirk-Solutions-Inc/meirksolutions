/*terraform {
  backend "s3" {
    bucket = "terratest-bucket"
    region = "us-east-1"
    key = "meirk/terraform.tfstate"
    encrypt = true
    dynamodb_table = "terraform-lock"
    profile = "meirk"    
  }
}*/