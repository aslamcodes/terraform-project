locals {
  wildcard = "0.0.0.0/0"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    createdby = "aslam's-terraform"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.private_subnets_CIDRs, count.index)
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public_subnets" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnet_CIDRs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.eip.id
}

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rtb-private" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "rtb-asso-public" {
  count          = var.subnet_count
  route_table_id = aws_route_table.rtb-public.id
  subnet_id      = element(aws_subnet.public_subnets, count.index).id
}

resource "aws_route_table_association" "rtb-asso-private" {
  count          = var.subnet_count
  route_table_id = aws_route_table.rtb-private.id
  subnet_id      = element(aws_subnet.private_subnets, count.index).id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.rtb-public.id
  destination_cidr_block = local.wildcard
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.rtb-private.id
  destination_cidr_block = local.wildcard
  nat_gateway_id         = aws_nat_gateway.nat.id
}
