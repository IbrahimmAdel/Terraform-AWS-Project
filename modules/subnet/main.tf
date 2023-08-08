# CREATE PUBLIC SUBNETS
resource "aws_subnet" "public_subnets" {
  count             = length(var.pub_subnets)
  vpc_id            = var.vpc_id
  cidr_block        = var.pub_subnets[count.index].subnets_cidr
  availability_zone = var.pub_subnets[count.index].availability_zone
  tags = {
    Name = "sprints_public_subnet_${count.index}"
  }
}

# CREATE PUBLIC ROUTE TABLE 
resource "aws_route_table" "public-rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

# ASSIGN THE PUBLIC ROUTE TABLE TO ALL PUBLIC SUBNETS
resource "aws_route_table_association" "public-rta" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

# CREATE PRIVATE SUBNETS
resource "aws_subnet" "private_subnets" {
  count             = length(var.priv_subnets)
  vpc_id            = var.vpc_id
  cidr_block        = var.priv_subnets[count.index].subnets_cidr
  availability_zone = var.priv_subnets[count.index].availability_zone
  tags = {
    Name = "sprints_private_subnet_${count.index}"
  }
}
# CREATE PRIVATE ROUTE TABLE 
resource "aws_route_table" "private-rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_id
  }
}

# ASSIGN THE PRIVATE ROUTE TABLE TO ALL PRIVATE SUBNETS
resource "aws_route_table_association" "private-rta" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id   
  route_table_id = aws_route_table.private-rt.id
}





