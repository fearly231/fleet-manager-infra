terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_route53_zone" "main" {
  name = "chorogra.me"
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}
