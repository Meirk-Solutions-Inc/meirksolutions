provider "aws" {
  region = "us-east-1"
  
}

variable "cidr" {
  default = "10.0.0.0/16"
  
}

resource "aws_key_pair" "test" {
  key_name   = "terraform-demo-meir"  # Replace with your desired key name
  public_key = file("C:/Users/muisi/.ssh/meirk-key.pub")  # Replace with the path to your public key file
  
}
resource "aws_vpc" "meirk-vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "meirk-subnet" {
  vpc_id                  = aws_vpc.meirk-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone      = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "meirk-igw" {
  vpc_id = aws_vpc.meirk-vpc.id
}

resource "aws_route_table" "meirk-RT" {
  vpc_id = aws_vpc.meirk-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.meirk-igw.id
  }
}
resource "aws_route_table_association" "meirk-rta1" {
  subnet_id      = aws_subnet.meirk-subnet.id
  route_table_id = aws_route_table.meirk-RT.id
}

resource "aws_security_group" "meirk-webSg" {
  name   = "web"
  vpc_id = aws_vpc.meirk-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "TestApp"
    }
}
resource "aws_instance" "meirk-test-app" {
    ami           = "ami-084568db4383264d4"  # Ubuntu AMI
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.meirk-subnet.id
    key_name      = aws_key_pair.test.key_name
    vpc_security_group_ids = [aws_security_group.meirk-webSg.id]
    
    tags = {
        Name = "TestApp"
    }

    provisioner "file" {
        source      = "app.py"
        destination = "/home/ubuntu/app.py"
    
        connection {
            type        = "ssh"
            host        = self.public_ip
            user        = "ubuntu"
            private_key = file("C:/Users/muisi/.ssh/meirk-key")  # Replace with the path to your private key file
            timeout     = "5m"
    }
    }

    provisioner "remote-exec" {
        inline = [
            "echo 'Hello Meirk Solutions Inc.'",
            "sudo apt update",
            "sudo apt-get install -y python3-pip",
            "cd /home/ubuntu",
            "sudo pip3 install flask",
            "sudo python3 app.py &" # Run the app in the background
        ]
        connection {
            type        = "ssh"
            host        = self.public_ip
            user        = "ubuntu"
            private_key = file("C:/Users/muisi/.ssh/meirk-key")  # Replace with the path to your private key file
            timeout     = "5m"
        }
    }
}