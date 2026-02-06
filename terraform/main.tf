terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket       = "project-bedrock-state-bucket-1570"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
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

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  cidr_block   = var.cidr_block

}

module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  pb_sg_id           = module.networking.pb_sg_id
  public_subnet_ids  = module.networking.pb_public_subnet_ids
  private_subnet_ids = module.networking.pb_private_subnet_ids
  instance_type      = var.instance_type

}

module "iam" {
  source = "./modules/iam"

}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
}

#



