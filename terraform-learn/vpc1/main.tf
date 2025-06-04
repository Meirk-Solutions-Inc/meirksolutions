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
  