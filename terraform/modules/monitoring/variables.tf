variable "project_name" {
  description = "Name of the project for all resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from EKS"
  type        = string
}

variable "oidc_thumbprint" {
  description = "OIDC thumbprint for EKS"
  type        = string
}
