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