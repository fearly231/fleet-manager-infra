variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
variable "public_subnets" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
}
variable "private_subnets" {
  description = "A list of CIDR blocks for the private subnets"
  type        = list(string)
}
variable "availability_zones" {
  description = "A list of availability zones for the subnets"
  type        = list(string)
}
variable "allowed_admin_cidrs" {
  description = "A list of CIDR blocks allowed to access the EKS cluster API"
  type        = list(string)
}
variable "capacity_type" {
  description = "The capacity type for the EKS worker nodes (e.g., ON_DEMAND, SPOT)"
  type        = string
  default     = "ON_DEMAND"
}
variable "domain_name" {
  description = "The domain name for the application"
  type        = string
}
variable "base_domain" {
  description = "The base domain name of the Route53 Hosted Zone"
  type        = string
}
