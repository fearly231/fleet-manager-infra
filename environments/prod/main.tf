resource "random_password" "db_password" {
  length  = 20
  special = false
}

resource "random_password" "admin_password" {
  length  = 20
  special = false
}

resource "random_password" "grafana_password" {
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
  instance_class              = "db.t3.medium"
  multi_az                    = true
  db_name                     = "fleet_db_prod"
  db_username                 = "fleet_admin"
  db_password                 = random_password.db_password.result
  eks_nodes_security_group_id = module.eks.cluster_security_group_id
}

module "eks" {
  source               = "../../modules/eks"
  environment          = var.environment
  subnet_ids           = module.vpc.private_subnet_ids
  scaling_desired_size = 3
  node_instance_type   = "c7i-flex.large"
  scaling_min_size     = 2
  scaling_max_size     = 5
  allowed_admin_cidrs  = var.allowed_admin_cidrs
  capacity_type        = var.capacity_type
}

module "secrets" {
  source           = "../../modules/secrets"
  environment      = var.environment
  db_username      = "fleet_admin"
  db_password      = random_password.db_password.result
  admin_password   = random_password.admin_password.result
  grafana_password = random_password.grafana_password.result
  db_port          = 5432
  db_endpoint      = module.rds.db_endpoint
  db_name          = "fleet_db_prod"
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

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

module "argocd" {
  source      = "../../modules/argocd"
  environment = var.environment
  depends_on  = [module.eks]
}

module "eso" {
  source                  = "../../modules/eso"
  environment             = var.environment
  oidc_provider_arn       = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer
  depends_on              = [module.eks]
}

module "aws_lbc" {
  source                  = "../../modules/aws-lbc"
  environment             = var.environment
  cluster_name            = module.eks.cluster_name
  vpc_id                  = module.vpc.vpc_id
  oidc_provider_arn       = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer
  depends_on              = [module.eks]
}

module "karpenter" {
  source                  = "../../modules/karpenter"
  environment             = var.environment
  cluster_name            = module.eks.cluster_name
  cluster_endpoint        = module.eks.cluster_endpoint
  oidc_provider_arn       = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer
  node_role_name          = module.eks.node_role_name
  node_profile_name       = module.eks.node_profile_name
  depends_on              = [module.eks]
}

module "external_dns" {
  source                  = "../../modules/external-dns"
  environment             = var.environment
  cluster_name            = module.eks.cluster_name
  oidc_provider_arn       = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer
  route53_zone_id         = module.dns.route53_zone_id
  depends_on              = [module.eks]
}

module "ingress_nginx" {
  source          = "../../modules/ingress-nginx"
  environment     = var.environment
  certificate_arn = module.dns.acm_certificate_arn
  depends_on      = [module.eks, module.aws_lbc]
}

module "observability" {
  source           = "../../modules/observability"
  environment      = var.environment
  domain_name      = "grafana.${var.domain_name}"
  grafana_password = random_password.grafana_password.result
  depends_on       = [module.eks, module.ingress_nginx]
}
