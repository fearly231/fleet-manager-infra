variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "db_endpoint" {
  description = "The endpoint of the RDS database"
  type        = string
}
variable "db_username" {
  description = "The username for the RDS database"
  type        = string
}
variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}
variable "db_port" {
  description = "The port of the RDS database"
  type        = number
}
variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}
variable "admin_password" {
  description = "The default admin password for the application"
  type        = string
  sensitive   = true
}
variable "grafana_password" {
  description = "The default admin password for Grafana"
  type        = string
  sensitive   = true
}
