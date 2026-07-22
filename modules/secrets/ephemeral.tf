# ============================================================================
# Ephemeral Secrets for PR environments
# ============================================================================
# Creates a SEPARATE secret in AWS SecretsManager for ephemeral PR environments.
# This ensures PR environments never have access to dev/prod secrets.
# ============================================================================

resource "random_password" "ephemeral_jwt_secret" {
  length  = 32
  special = false
}

resource "random_password" "ephemeral_admin_password" {
  length  = 16
  special = false
}

resource "random_password" "ephemeral_pg_password" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "ephemeral_secrets" {
  name                    = "ephemeral-fleet-app-secrets"
  description             = "Isolated secrets for ephemeral PR environments — NOT shared with dev/prod"
  recovery_window_in_days = 0 # Ephemeral — no recovery needed

  tags = {
    Purpose = "ephemeral-pr-environments"
  }
}

resource "aws_secretsmanager_secret_version" "ephemeral_secrets_version" {
  secret_id = aws_secretsmanager_secret.ephemeral_secrets.id
  secret_string = jsonencode({
    jwt_secret     = random_password.ephemeral_jwt_secret.result
    admin_password = random_password.ephemeral_admin_password.result
    pg_password    = random_password.ephemeral_pg_password.result
  })
}
