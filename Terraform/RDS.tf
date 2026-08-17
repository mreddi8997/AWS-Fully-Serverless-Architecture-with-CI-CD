resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS storage and Secrets Manager encryption"
  deletion_window_in_days = 10
}






resource "aws_db_instance" "mysql-db" {
  allocated_storage    = 10
  max_allocated_storage = 20
  storage_type         = "gp2"
  db_name              = "sqldb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  port                 = 3306
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.sqldb_subnet_group.name
  username             = "admin"
  manage_master_user_password = true
  master_user_secret_kms_key_id = aws_kms_key.rds_kms_key.id
  parameter_group_name = "default.mysql80"
  skip_final_snapshot  = true
  storage_encrypted     = true
    vpc_security_group_ids = [aws_security_group.rds-sg.id]

  backup_retention_period    = 0
  auto_minor_version_upgrade = true
  deletion_protection        = false
  copy_tags_to_snapshot      = true
  kms_key_id                 = aws_kms_key.rds_kms_key.arn

  depends_on = [aws_db_subnet_group.sqldb_subnet_group, aws_security_group.rds-sg, aws_vpc.app_vpc]
}

resource "aws_db_subnet_group" "sqldb_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.app_database_subnet_1.id, aws_subnet.app_database_subnet_2.id]


  tags = {
    Name = "sqldb-subnet-group"
    environment = "production"
  }
}
