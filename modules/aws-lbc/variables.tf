variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
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
