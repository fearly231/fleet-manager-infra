# OIDC Provider dla całego konta AWS
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612", "6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Rola dla wybranego środowiska
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = { Federated = aws_iam_openid_connect_provider.github_actions.arn },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:${var.github_repo}:*"
          },
          StringEquals = { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
