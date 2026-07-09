output "secret_arn" {
  description = "The ARN of the secret storing the RDS database credentials"
  value       = aws_secretsmanager_secret.app_secrets.arn
}