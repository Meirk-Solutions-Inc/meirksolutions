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