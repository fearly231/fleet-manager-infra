locals {
  oidc_url_no_https = replace(var.cluster_oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "eso_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_no_https}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
  }
}

resource "aws_iam_role" "eso_role" {
  name               = "${var.environment}-fleet-eso-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role_policy.json
}

data "aws_iam_policy_document" "eso_policy_doc" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "eso_policy" {
  name   = "${var.environment}-fleet-eso-policy"
  role   = aws_iam_role.eso_role.id
  policy = data.aws_iam_policy_document.eso_policy_doc.json
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.9.13"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.eso_role.arn
    type  = "string"
  }
}
