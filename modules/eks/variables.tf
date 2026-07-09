variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "subnet_ids" {
  description = "A list of IDs for the subnets"
  type        = list(string)
}
variable "node_instance_type" {
  description = "The instance type for the EKS worker nodes"
  type        = string
}
variable "scaling_desired_size" {
  description = "The desired number of worker nodes"
  type        = number
}
variable "scaling_min_size" {
  description = "The minimum number of worker nodes"
  type        = number
}
variable "scaling_max_size" {
  description = "The maximum number of worker nodes"
  type        = number
}