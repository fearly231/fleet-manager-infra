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
        description = "Allow PostgreSQL access from within the VPC"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = [data.aws_vpc.selected.cidr_block]
    }
    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}
resource "aws_db_instance" "main" {
  identifier              = "${var.environment}-fleet-db-instance"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "18.4"
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.main.id]
  multi_az                = var.multi_az
  skip_final_snapshot     = true
  tags = {
    Name = "${var.environment}-fleet-db-instance"
  }
}
