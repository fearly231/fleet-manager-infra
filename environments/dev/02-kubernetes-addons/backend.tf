terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    bucket       = "fleet-manager-terraform-state-adam" #
    key          = "dev/02-kubernetes-addons/fleet-manager.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Project     = "fleet-manager"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Kubernetes-Addons"
    }
  }
}
