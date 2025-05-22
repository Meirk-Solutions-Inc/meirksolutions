provider "aws" {
  region = "us-east-1"
  
}

variable "ami" {
    description = "value"
    type = string
    }

variable "instance_type" {
    description = "value"
    type = map(string)

    default = {
        "dev"   = "t2.micro"
        "staging" = "t2.medium"
        "prod"  = "t2.xlarge"
    }
}

module "ec2-instance" {
    source = "./modules/ec2-instance"
    ami = var.ami
    instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
}