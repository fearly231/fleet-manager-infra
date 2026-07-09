output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}
output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}
output "cluster_security_group_id" {
  description = "The ID of the security group associated with the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}
output "cluster_oidc_issuer" {
  description = "The OIDC issuer URL of the EKS cluster"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}
