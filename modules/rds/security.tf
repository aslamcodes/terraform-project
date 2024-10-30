resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id
  name        = "rds_sg"
  description = "database security group"
}

resource "aws_security_group_rule" "allow_ec2" {
  description       = "Allow's CIDRs of ${var.ingress_cidrs[*]}"
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  # source_security_group_id = var.server_sg_id
  cidr_blocks = var.ingress_cidrs
}


resource "aws_security_group_rule" "allow_all_egress" {
  description       = "Allows all egress"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.ingress_cidrs
  security_group_id = aws_security_group.rds_sg.id
}
