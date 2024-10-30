resource "aws_vpc_peering_connection" "vpc_peer" {
  provider    = aws.east
  vpc_id      = var.vpc_id
  peer_vpc_id = var.peer_vpc_id
  peer_region = var.peer_region
}

resource "aws_vpc_peering_connection_accepter" "accept_req" {
  depends_on                = [aws_vpc_peering_connection.vpc_peer]
  provider                  = aws.west
  auto_accept               = true
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_route" "peering_route" {
  provider                  = aws.west
  depends_on                = [aws_vpc_peering_connection.vpc_peer]
  route_table_id            = var.peering_rtb_id
  destination_cidr_block    = var.main_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_route" "main_peering_route" {
  provider                  = aws.east
  depends_on                = [aws_vpc_peering_connection.vpc_peer]
  route_table_id            = var.main_rtb_id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}
