output "rds_endpoint" {
    description = "The endpoint of the RDS instance"
    value       = module.rds.db_endpoint
}
output "eks_cluster_name" {
    description = "The name of the EKS cluster"
    value       = module.eks.cluster_name
}
output "eks_cluster_endpoint" {
    description = "The endpoint of the EKS cluster"
    value       = module.eks.cluster_endpoint
}
output "how_to_connect_to_eks" {
    description = "Instructions on how to connect to the EKS cluster"
    value       = "To connect to the EKS cluster, run: aws eks --region <region> update-kubeconfig --name ${module.eks.cluster_name}"
}