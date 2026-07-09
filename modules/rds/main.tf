resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-fleet-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.environment}-fleet-db-subnet-group"
  }  
}
resource "aws_security_group" "main" {
  name        = "${var.environment}-fleet-db-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id
    ingress {
        description = "Allow PostgreSQL access from EKS nodes"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [var.eks_nodes_security_group_id]
    }
    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.environment}-fleet-db-sg"
    }
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}
resource "aws_db_instance" "main" {
  identifier              = "${var.environment}-fleet-db-instance"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  
  multi_az                = var.environment == "prod" ? true : false
  skip_final_snapshot     = var.environment != "prod" ? true : false
  final_snapshot_identifier = var.environment == "prod" ? "${var.environment}-fleet-db-final-snapshot" : null
  publicly_accessible     = false
  storage_encrypted       = true
  deletion_protection     = var.environment == "prod" ? true : false
  tags = {
    Name = "${var.environment}-fleet-db-instance"
  }
}
