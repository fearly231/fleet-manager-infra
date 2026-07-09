resource "aws_iam_role" "cluster_role" {
    name = "${var.environment}-fleet-eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "eks.amazonaws.com"
            }
        }
        ]
    })
}
resource "aws_iam_role_policy_attachment" "cluster_policy" {
    role       = aws_iam_role.cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_eks_cluster" "main" {
    name     = "${var.environment}-fleet-eks-cluster"
    role_arn = aws_iam_role.cluster_role.arn
    version  = "1.35"
    vpc_config {
        subnet_ids = var.subnet_ids
        endpoint_private_access = true
        endpoint_public_access  = true
    }
    enabled_cluster_log_types = ["api", "audit", "authenticator"]
    depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}
data "tls_certificate" "eks_cluster_cert" {
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks_cluster_cert.certificates[0].sha1_fingerprint]
}
resource "aws_iam_role" "node_role" {
    name = "${var.environment}-fleet-eks-node-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        }
        ]
    })
}
resource "aws_iam_role_policy_attachment" "node_policy" {
    role       = aws_iam_role.node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "cni_policy" {
    role       = aws_iam_role.node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "ecr_policy" {
    role       = aws_iam_role.node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_eks_node_group" "main" {
    cluster_name    = aws_eks_cluster.main.name
    version = "1.35"
    node_group_name = "${var.environment}-fleet-eks-node-group"
    node_role_arn   = aws_iam_role.node_role.arn
    subnet_ids      = var.subnet_ids
    instance_types  = [var.node_instance_type]
    capacity_type  = "ON_DEMAND"
    scaling_config {
        desired_size = var.scaling_desired_size
        max_size     = var.scaling_max_size
        min_size     = var.scaling_min_size
    }
    depends_on = [
        aws_iam_role_policy_attachment.node_policy,
        aws_iam_role_policy_attachment.cni_policy,
        aws_iam_role_policy_attachment.ecr_policy
    ] 
}