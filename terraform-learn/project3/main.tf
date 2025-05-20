provider "aws" {
  region = "us-east-1"
  
}

resource "aws_instance" "test-app" {
    ami           = "ami-084568db4383264d4"
    instance_type = "t2.micro"
    subnet_id     = "subnet-001c70e2e772fe224"

  tags = {
    Name = "TestApp"
  }
}

resource "aws_s3_bucket" "test-bucket" {
  bucket = "meirk-terraform-test-bucket"

  tags = {
    Name  = "TestBucket"
      }
}   

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "LockID"
    
  attribute {
    name = "LockID"
    type = "S"
  }
  
}