resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.environment}-fleet-app-secrets"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0
}
resource "aws_secretsmanager_secret_version" "app_secrets_version" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    DATABASE_URL           = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}:${var.db_port}/${var.db_name}"
    SECRET_KEY             = random_password.jwt_secret.result
    DEFAULT_ADMIN_PASSWORD = var.db_password
  })
}