variable "environment" {
  description = "Environment name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "URL of the EKS OIDC provider"
  type        = string
}
