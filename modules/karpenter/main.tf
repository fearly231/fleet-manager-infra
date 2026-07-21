locals {
  oidc_url_no_https = replace(var.cluster_oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "karpenter_assume_role_policy" {
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
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_no_https}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "karpenter_policy_doc" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ec2:DescribeImages",
      "ec2:RunInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateTags",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:DescribeSpotPriceHistory",
      "pricing:GetProducts",
      "ec2:TerminateInstances"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = ["iam:PassRole"]
    effect  = "Allow"
    resources = ["arn:aws:iam::*:role/${var.node_role_name}"]
  }
}

resource "aws_iam_policy" "karpenter_policy" {
  name        = "${var.environment}-KarpenterControllerPolicy"
  description = "IAM policy for Karpenter Controller"
  policy      = data.aws_iam_policy_document.karpenter_policy_doc.json
}

resource "aws_iam_role" "karpenter_role" {
  name               = "${var.environment}-karpenter-controller-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_attachment" {
  role       = aws_iam_role.karpenter_role.name
  policy_arn = aws_iam_policy.karpenter_policy.arn
}

resource "helm_release" "karpenter_crd" {
  name             = "karpenter-crd"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter-crd"
  namespace        = "karpenter"
  create_namespace = true
  version          = "1.0.1"
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  version          = "1.0.1"

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_role.arn
    type  = "string"
  }

  depends_on = [helm_release.karpenter_crd]
}

resource "helm_release" "karpenter_config" {
  name      = "karpenter-config"
  chart     = "${path.module}/karpenter-config"
  namespace = "karpenter"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "nodeRoleName"
    value = var.node_role_name
  }

  depends_on = [helm_release.karpenter]
}
