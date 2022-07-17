# vpc
resource "aws_vpc" "training_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env}-training-vpc"
  }
}

# subnet
resource "aws_subnet" "training_subnet_a" {
  vpc_id                  = aws_vpc.training_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.env}-training-subnet-a"
  }
}

# internet gateway
resource "aws_internet_gateway" "training_igw" {
  vpc_id = aws_vpc.training_vpc.id

  tags = {
    Name = "training-igw"
  }
}

# route table
resource "aws_route_table" "training_route_table" {
  vpc_id = aws_vpc.training_vpc.id

  tags = {
    Name = "${local.env}-training-route-table"
  }
}

# route
resource "aws_route" "training_route" {
  route_table_id         = aws_route_table.training_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.training_igw.id
}

# route tabel attatch
resource "aws_route_table_association" "training_route_table_a" {
  route_table_id = aws_route_table.training_route_table.id
  subnet_id      = aws_subnet.training_subnet_a.id
}
