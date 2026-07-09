output "db_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}
output "db_security_group_id" {
  description = "The ID of the security group associated with the RDS instance"
  value       = aws_db_instance.main.vpc_security_group_ids
}
output "db_name" {
  description = "The name of the RDS database"
  value       = aws_db_instance.main.db_name
}