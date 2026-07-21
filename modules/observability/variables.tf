variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Grafana"
  type        = string
}

variable "grafana_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}
