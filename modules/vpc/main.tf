# CREATE A VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "sprints-VPC"
  }
}

# CREATE AN INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "sprints-IGW"
  }
}

# CREATE ELASTIC IP
resource "aws_eip" "eip" {
  domain   = "vpc"
}

# CREATE NAT IN THE FIRST PUBLIC SUBNET
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.nat_subnet_id
  tags = {
    Name = "sprints-NAT"
  }
  # To ensure proper ordering, i will add an explicit dependency on the Internet Gateway.
  depends_on = [aws_internet_gateway.igw]
}