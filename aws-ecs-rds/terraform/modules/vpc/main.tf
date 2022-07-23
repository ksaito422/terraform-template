################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

################################################################################
# subnet
################################################################################

resource "aws_subnet" "public" {

  count = length(var.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true
  tags = {
    Name = format("${var.env}-public-subnet-%s", element(var.azs, count.index))
  }
}

resource "aws_subnet" "private" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("${var.env}-private-subnet-%s", element(var.azs, count.index))
  }
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.main.id
  tags = {
    Name = format("${var.env}-public-rtb-%s", element(var.azs, count.index))
  }
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets)

  route_table_id         = element(aws_route_table.public[*].id, count.index)
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "pubic" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, count.index)
}

################################################################################
# Private routes
################################################################################

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id
  tags = {
    Name = format("${var.env}-private-rtb-%s", element(var.azs, count.index))
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

