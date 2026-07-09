resource "random_password" "db_password" {
  length  = 20
  special = false
}

module "vpc" {
  source             = "../../modules/vpc"
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  cluster_name       = "${var.environment}-fleet-eks-cluster"
}

module "rds" {
  source                      = "../../modules/rds"
  environment                 = var.environment
  vpc_id                      = module.vpc.vpc_id
  private_subnet_ids          = module.vpc.private_subnet_ids
  instance_class              = "db.t3.micro"
  multi_az                    = false
  db_name                     = "fleet_db"
  db_username                 = "fleet_admin"
  db_password                 = random_password.db_password.result
  eks_nodes_security_group_id = module.eks.cluster_security_group_id
}

module "eks" {
  source               = "../../modules/eks"
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  scaling_desired_size = 2
  node_instance_type   = "c7i-flex.large"
  scaling_min_size     = 1
  scaling_max_size     = 3
  allowed_admin_cidrs  = var.allowed_admin_cidrs
  capacity_type        = var.capacity_type
}

module "secrets" {
  source      = "../../modules/secrets"
  environment = var.environment
  db_username = "fleet_admin"
  db_password = random_password.db_password.result
  db_port     = 5432
  db_endpoint = module.rds.db_endpoint
  db_name     = "fleet_db"
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = var.environment
}

module "dns" {
  source      = "../../modules/dns"
  environment = var.environment
  domain_name = var.domain_name
}