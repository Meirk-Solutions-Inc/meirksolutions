variable "cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  
}

variable "subnet_cidr_block" {
    description = "CIDR block for the subnet"
    type = map(object({
        cidr   = string
        az     = string
        public = bool
    }))

    default = {
        subnet1 = {
            cidr = "10.0.0.0/24"
            az = "us-east-1a"
            public = true
        }
        subnet2 = {
            cidr = "10.0.1.0/24"
            az = "us-east-1b"
            public = true
        }
    }
}

variable "ec2_instance_type" {
    description = "Details of the EC2 instance type"
    type = map(string)
    default = {
        "dev"     = "t2.micro"
        "staging" = "t2.medium"
        "prod"    = "t2.xlarge"
    }
}
variable "ami" {
    description = "AMI for the EC2 instance"
    type        = string
    default     = "ami-084568db4383264d4"  # Example AMI, replace with your own
}
variable "instance_tags" {
    description = "Tags for the EC2 instance"
    type        = map(string)
    default     = {
        Name = "meirkmobileapp"
    }
}