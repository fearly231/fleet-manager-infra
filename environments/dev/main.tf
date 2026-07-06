module "vpc" {
  source = "../../modules/vpc"
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  availability_zones    = var.availability_zones
}
module "rds" {
  source = "../../modules/rds"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_class = "db.t3.micro"
  multi_az = false
  db_name = "fleet_db"
  db_username = "fleet_admin"
  db_password = var.db_password 
}
module "eks" {
  source = "../../modules/eks"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  scaling_desired_size = 2
  node_instance_type = "c7i-flex.large"
  scaling_min_size = 1
  scaling_max_size = 3
  depends_on = [ module.vpc ]
}