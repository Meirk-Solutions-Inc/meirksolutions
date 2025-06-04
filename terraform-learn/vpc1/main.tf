resource "aws_vpc" "test-vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test-subnet"{
  for_each = var.subnet_cidr_block
  cidr_block      = each.value.cidr
  vpc_id          = aws_vpc.test-vpc.id
  availability_zone = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "test-subnet-${each.key}"
  }
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-igw"
  }
}

resource "aws_route_table" "test-rt" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id # Use the correct internet gateway ID
  }
  tags = {
    Name = "test-rt"
  }
}

resource "aws_route_table_association" "test-rta" {
  for_each = var.subnet_cidr_block
  subnet_id      = aws_subnet.test-subnet[each.key].id
  route_table_id = aws_route_table.test-rt.id

}

resources "aws_security_group" "test-sg" {
  name        = "test-sg"
  description = "Security group for test instances"
  vpc_id = aws_vpc.test-vpc.id 

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test-sg"
  }
}
resource "aws_s3_bucket" "test-bucket" {
  bucket = "meirk-terraform-testproject-bucket"
  depends_on = [ 
    aws_s3_bucket_ownership_controls.test-bucket-ownership-controls,
    aws_s3_bucket_public_access_block.test-bucket-public-access-block,
    ]
  
  bucket = "meirk-terraform-testproject-bucket"
  acl    = "public-read"

  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket_ownership_controls" "test-bucket-ownership-controls" {
  bucket = aws_s3_bucket.test-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "test-bucket-public-access-block" {
  bucket = aws_s3_bucket.test-bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  block_public_policy     = false
}
resource "aws_ec2instance" "testinstance" {

    ami                    = var.ami
    instance_type          = var.ec2_instance_type["dev"]
    subnet_id              = aws_subnet.test-subnet["subnet1"].id
    vpc_security_group_ids = [aws_security_group.test-sg.id]
    tags                   = var.instance_tags
    userdata               = base64encode(file("userdata.sh"))
}
  
resource "aws_ec2_instance" "testinstance2" {
  ami                    = var.ami
  instance_type          = var.ec2_instance_type["staging"]
  subnet_id              = aws_subnet.test-subnet["subnet2"].id
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  tags                   = var.instance_tags
  user_data              = base64encode(file("userdata1.sh"))
}


