data "aws_caller_identity" "current" {}

locals {
  github_oidc_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  # Build list of repo patterns for trust policy
  repo_patterns = [for repo in var.github_repos : "repo:${repo}:*"]
}

# Rola dla wybranego środowiska
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity",
        Effect    = "Allow",
        Principal = { Federated = local.github_oidc_arn },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : local.repo_patterns
          },
          StringEquals = { "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com" }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

