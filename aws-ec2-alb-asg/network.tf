####################################
# VPC
####################################

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.env}-vpc"
  }
}

####################################
# Internet Gateway
####################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.env}-igw"
  }
}

####################################
# Route Table
####################################

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${local.env}-route-table"
  }
}

resource "aws_main_route_table_association" "this" {
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.this.id
}

####################################
# Subnet
####################################

resource "aws_subnet" "public_1" {
  # count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "${local.env}public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  # count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "${local.env}-public-subnet-2"
  }
}
