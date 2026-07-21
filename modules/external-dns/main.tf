locals {
  oidc_url_no_https = replace(var.cluster_oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "external_dns_assume_role_policy" {
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
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}

data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    effect    = "Allow"
    resources = ["arn:aws:route53:::hostedzone/${var.route53_zone_id}"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "${var.environment}-ExternalDNSPolicy"
  description = "IAM policy for External DNS"
  policy      = data.aws_iam_policy_document.external_dns_policy.json
}

resource "aws_iam_role" "external_dns_role" {
  name               = "${var.environment}-external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "external_dns_attachment" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "1.14.3"

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.zoneType"
    value = "public"
  }

  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns_role.arn
    type  = "string"
  }
}
