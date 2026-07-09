variable "domain_name" {
  description = "The domain name for the DNS zone"
  type        = string
}
variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
