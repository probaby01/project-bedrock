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
      version = "6.28.0"
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

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)
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

module "monitoring" {
  source = "./modules/monitoring"
  
  project_name       = var.project_name
  cluster_name       = module.eks.eks_cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.cluster_oidc_issuer_url
  
  depends_on = [module.eks]
}

module "iam" {
  source = "./modules/iam"

  s3_bucket_arn = module.storage.s3_bucket_arn

}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
}

