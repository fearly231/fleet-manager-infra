environment         = "prod"
vpc_cidr            = "10.1.0.0/16"
public_subnets      = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnets     = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
allowed_admin_cidrs = ["84.10.23.45/32"]
capacity_type       = "ON_DEMAND"
domain_name         = "chorogra.me"
