terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

backend "s3" {
    bucket         = "fleet-manager-terraform-state-adam"
    key            = "dev/fleet-manager.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
    }
}
provider "aws" {
    region = "eu-central-1"
    default_tags {
        tags = {
            Project     = "fleet-manager"
            Environment = var.environment
            ManagedBy   = "Terraform"
        }
    }
}