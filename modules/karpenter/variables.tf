variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN for EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC Issuer URL for EKS cluster"
  type        = string
}

variable "node_role_name" {
  description = "IAM role name for Karpenter nodes"
  type        = string
}

variable "node_profile_name" {
  description = "IAM instance profile name for Karpenter nodes"
  type        = string
}
