variable "domain_name" {
  description = "The domain name for the DNS zone"
  type        = string
}

variable "base_domain" {
  description = "The base domain name of the Route53 Hosted Zone"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
