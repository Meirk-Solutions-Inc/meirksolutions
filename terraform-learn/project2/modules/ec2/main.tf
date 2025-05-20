provider "aws" {    
  region = "us-east-1"
}

resource "aws_instance" "try-app" {
  ami           = var.ami_value
  instance_type = var.instance_type_value
  subnet_id     = var.subnet_id_value

  tags = {
    Name = "terraform_Demo1"
  }
  
}