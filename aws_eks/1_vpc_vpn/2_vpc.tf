# Name: vpc.tf
# Owner: Saurav Mitra
# Description: This terraform config will create a AWS VPC with following resources:
#   3 Private Subnets
#   3 Public Subnets
#   1 Internet Gateway (with routes to it for Public Subnets)
#   1 NAT Gateways for outbound internet access (with routes to it for Private Subnets)
#   1 Elastic IP for NAT Gateways
#   2 Routing tables (for Public and Private subnet for routing the traffic)

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "${var.prefix}-vpc"
    Env   = var.env
    Owner = var.owner
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(values(var.public_subnets), count.index)
  availability_zone       = element(keys(var.public_subnets), count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.prefix}-public-subnet-${count.index}"
    Env                      = var.env
    Owner                    = var.owner
    "kubernetes.io/role/elb" = 1
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(values(var.private_subnets), count.index)
  availability_zone = element(keys(var.private_subnets), count.index)

  tags = {
    Name                              = "${var.prefix}-private-subnet-${count.index}"
    Env                               = var.env
    Owner                             = var.owner
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "${var.prefix}-igw"
    Env   = var.env
    Owner = var.owner
  }
}

# EIP
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name  = "${var.prefix}-nat-eip"
    Env   = var.env
    Owner = var.owner
  }

  # The EIP depends on the Internet Gateway
  depends_on = [aws_internet_gateway.igw]
}

# NAT
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name  = "${var.prefix}-natgw"
    Env   = var.env
    Owner = var.owner
  }

  # The NAT Gateway depends on the Elastic IP
  depends_on = [aws_internet_gateway.igw]
}

# Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name  = "${var.prefix}-public-rt"
    Env   = var.env
    Owner = var.owner
  }
}

# Public RT Association
resource "aws_route_table_association" "public_rta" {
  count          = length(var.public_subnets)
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Private RT
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name  = "${var.prefix}-private-rt"
    Env   = var.env
    Owner = var.owner
  }
}

# Private RT Association
resource "aws_route_table_association" "private_rta" {
  count          = length(var.private_subnets)
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
