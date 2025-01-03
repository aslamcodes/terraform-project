resource "aws_db_subnet_group" "rds_sb_grp" {
  name       = "rds-subnet-group-2"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "aslam-rds" {
  identifier                 = "aslam-db"
  allocated_storage          = 10
  db_name                    = "mydb"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.micro"
  username                   = "foo"
  password                   = "foobarbaz"
  parameter_group_name       = "default.mysql8.0"
  skip_final_snapshot        = true
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  deletion_protection        = true
  db_subnet_group_name       = aws_db_subnet_group.rds_sb_grp.name
  multi_az                   = true
  auto_minor_version_upgrade = true

}

output "rds_endpoint" {
  value = aws_db_instance.aslam-rds.endpoint
}

output "rds_arn" {
  value = aws_db_instance.aslam-rds.arn
}
