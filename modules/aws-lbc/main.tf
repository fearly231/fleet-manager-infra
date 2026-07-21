locals {
  oidc_url_no_https = replace(var.cluster_oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "aws_lbc_assume_role_policy" {
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
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_no_https}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "aws_lbc_policy" {
  name        = "${var.environment}-AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role" "aws_lbc_role" {
  name               = "${var.environment}-aws-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_lbc_policy_attachment" {
  role       = aws_iam_role.aws_lbc_role.name
  policy_arn = aws_iam_policy.aws_lbc_policy.arn
}

resource "helm_release" "aws_lbc" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.9.2"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_lbc_role.arn
    type  = "string"
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }
}
