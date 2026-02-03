terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "starttech-state-bucket"
    key            = "starttech/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "starttech-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
  }
}

provider "aws" {
  region = var.aws_region
}



