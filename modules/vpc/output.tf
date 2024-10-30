output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_rtb_id" {
  value = aws_route_table.rtb-public.id
}

output "private_rtb-id" {
  value = aws_route_table.rtb-private.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "cidr" {
  value = aws_vpc.vpc.cidr_block
}
