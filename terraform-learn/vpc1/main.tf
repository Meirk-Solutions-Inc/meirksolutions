resource "aws_vpc" "test-vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test-subnet" {
  for_each                = var.subnet_cidr_block
  cidr_block              = each.value.cidr
  vpc_id                  = aws_vpc.test-vpc.id
  availability_zone       = each.value.az
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
  for_each       = var.subnet_cidr_block
  subnet_id      = aws_subnet.test-subnet[each.key].id
  route_table_id = aws_route_table.test-rt.id

}

resource "aws_security_group" "test-sg" {
  name        = "test-sg"
  description = "Security group for test instances"
  vpc_id      = aws_vpc.test-vpc.id

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
  tags = {
    Name = "Testvpc1-Bucket"
  }
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

  depends_on = [
    aws_s3_bucket_ownership_controls.test-bucket-ownership-controls,
  ]
}
resource "aws_instance" "testinstance" {

  ami                    = var.ami
  instance_type          = var.ec2_instance_type["dev"]
  subnet_id              = aws_subnet.test-subnet["subnet1"].id
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  tags                   = var.instance_tags
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "testinstance2" {
  ami                    = var.ami
  instance_type          = var.ec2_instance_type["staging"]
  subnet_id              = aws_subnet.test-subnet["subnet2"].id
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  tags                   = var.instance_tags
  user_data              = base64encode(file("userdata1.sh"))
}

resource "aws_lb" "test-lb" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test-sg.id]
  subnets            = [aws_subnet.test-subnet["subnet1"].id, aws_subnet.test-subnet["subnet2"].id]

  enable_deletion_protection = false

  tags = {
    Name = "test-lb"
  }
}

resource "aws_lb_target_group" "test-tg" {
  name     = "test-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test-vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = "traffic-port"

  }
}

resource "aws_lb_target_group_attachment" "test-tg-attachment" {
  for_each = {
    instance1 = aws_instance.testinstance
    instance2 = aws_instance.testinstance2
  }

  target_group_arn = aws_lb_target_group.test-tg.arn
  target_id        = each.value.id
  port             = 80
}
resource "aws_lb_listener" "test-listener" {
  load_balancer_arn = aws_lb.test-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg.arn
  }
}
