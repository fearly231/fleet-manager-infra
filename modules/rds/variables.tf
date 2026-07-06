variable "environment" {
    description = "The environment name (e.g., dev, staging, prod)"
    type        = string
}
variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}
variable "private_subnet_ids" {
    description = "A list of IDs for the private subnets"
    type        = list(string)
}
variable "instance_class" {
    description = "The instance class for the RDS instance"
    type        = string
}
variable "multi_az" {
    description = "Whether to create a Multi-AZ RDS instance"
    type        = bool
    default    = false
}
variable "db_name" {
    description = "The name of the database to create when the DB instance is created"
    type        = string
}
variable "db_username" {
    description = "The username for the database"
    type        = string
}
variable "db_password" {
    description = "The password for the database"
    type        = string
    sensitive   = true
}