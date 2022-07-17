
#######################################################################################
# VPC
#######################################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#######################################################################################
# SubnetGroup
#######################################################################################

resource "aws_subnet" "db" {
  for_each          = { for sb in var.db_subnets : sb.name => sb }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.project}-db-subnet"
  }
}

resource "aws_subnet" "private" {
  for_each          = { for sb in var.private_subnets : sb.name => sb }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.project}-private-subnet"
  }
}

#######################################################################################
# RouteTable
#######################################################################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.project
  }
}

resource "aws_route_table_association" "private" {
  for_each       = { for sb in var.private_subnets : sb.name => sb }
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

#######################################################################################
# SecurityGroup
#######################################################################################

resource "aws_security_group" "main" {
  name        = "${var.prefix}-ecs-sg"
  description = "Allow HTTPS inbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Inbound from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

#######################################################################################
# VPC Endpoint
#######################################################################################

data "aws_iam_policy_document" "vpc_endpoint" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each     = toset(var.interface_services)
  vpc_id       = aws_vpc.main.id
  service_name = each.value
  subnet_ids = [
    for sb in aws_subnet.private : sb.id
  ]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.main.id]
  policy              = data.aws_iam_policy_document.vpc_endpoint.json
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "gateway" {
  for_each          = toset(var.gateway_services)
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  policy            = data.aws_iam_policy_document.vpc_endpoint.json
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "s3_route_ass" {
  for_each        = toset(var.gateway_services)
  vpc_endpoint_id = aws_vpc_endpoint.gateway[each.value].id
  route_table_id  = aws_route_table.private.id
}

