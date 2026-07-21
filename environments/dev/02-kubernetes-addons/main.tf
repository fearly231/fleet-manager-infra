data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "fleet-manager-terraform-state-adam"
    key    = "dev/01-infrastructure/fleet-manager.tfstate"
    region = "eu-central-1"
  }
}

locals {
  eks_cluster_name     = data.terraform_remote_state.infra.outputs.eks_cluster_name
  eks_cluster_endpoint = data.terraform_remote_state.infra.outputs.eks_cluster_endpoint
  eks_cluster_ca_data  = data.terraform_remote_state.infra.outputs.eks_cluster_certificate_authority_data
  vpc_id               = data.terraform_remote_state.infra.outputs.vpc_id
  oidc_provider_arn    = data.terraform_remote_state.infra.outputs.eks_oidc_provider_arn
  cluster_oidc_issuer  = data.terraform_remote_state.infra.outputs.eks_cluster_oidc_issuer
  route53_zone_id      = data.terraform_remote_state.infra.outputs.route53_zone_id
  acm_certificate_arn  = data.terraform_remote_state.infra.outputs.acm_certificate_arn
  node_role_name       = data.terraform_remote_state.infra.outputs.eks_node_role_name
  node_profile_name    = data.terraform_remote_state.infra.outputs.eks_node_profile_name
  grafana_password     = data.terraform_remote_state.infra.outputs.grafana_password
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name]
      command     = "aws"
    }
  }
}

module "argocd" {
  source      = "../../../modules/argocd"
  environment = var.environment
}

resource "null_resource" "argocd_apps_cleanup" {
  triggers = {
    cluster_name = local.eks_cluster_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "=== Rozpoczynam czyszczenie aplikacji przed destroy ==="
      aws eks update-kubeconfig --region eu-central-1 --name $${self.triggers.cluster_name}
      kubectl delete applications --all -n argocd --wait=true --timeout=5m || true
      kubectl delete nodepools --all --wait=true || true
      kubectl delete nodeclaims --all --wait=true || true
      sleep 30
      echo "=== Czyszczenie zakonczone ==="
    EOT
  }

  depends_on = [module.argocd]
}

module "eso" {
  source                  = "../../../modules/eso"
  environment             = var.environment
  oidc_provider_arn       = local.oidc_provider_arn
  cluster_oidc_issuer_url = local.cluster_oidc_issuer
}

module "aws_lbc" {
  source                  = "../../../modules/aws-lbc"
  environment             = var.environment
  cluster_name            = local.eks_cluster_name
  vpc_id                  = local.vpc_id
  oidc_provider_arn       = local.oidc_provider_arn
  cluster_oidc_issuer_url = local.cluster_oidc_issuer
}

module "karpenter" {
  source                  = "../../../modules/karpenter"
  environment             = var.environment
  cluster_name            = local.eks_cluster_name
  cluster_endpoint        = local.eks_cluster_endpoint
  oidc_provider_arn       = local.oidc_provider_arn
  cluster_oidc_issuer_url = local.cluster_oidc_issuer
  node_role_name          = local.node_role_name
  node_profile_name       = local.node_profile_name
}

module "external_dns" {
  source                  = "../../../modules/external-dns"
  environment             = var.environment
  cluster_name            = local.eks_cluster_name
  oidc_provider_arn       = local.oidc_provider_arn
  cluster_oidc_issuer_url = local.cluster_oidc_issuer
  route53_zone_id         = local.route53_zone_id
}

module "ingress_nginx" {
  source          = "../../../modules/ingress-nginx"
  environment     = var.environment
  certificate_arn = local.acm_certificate_arn
  depends_on      = [module.aws_lbc]
}

module "observability" {
  source           = "../../../modules/observability"
  environment      = var.environment
  domain_name      = "dev-grafana.$${var.domain_name}"
  grafana_password = local.grafana_password
  depends_on       = [module.ingress_nginx]
}
