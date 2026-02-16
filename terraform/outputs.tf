output "vpc_name" {
  description = "The name of the VPC"
  value       = module.networking.pb_vpc_name
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       =module.eks.cluster_endpoint

}

output "iam_username" {
  description = "The name of the IAM user"
  value       = module.iam.iam_username
}

output "secret_key" {
  description = "The secret access key for the IAM user"
  value       = module.iam.secret_key
  sensitive   = true
}

output "access_key_id" {
  description = "The access key ID for the IAM user"
  value       = module.iam.access_key_id
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}

output "lambda_function_name" {
  description = "Name of the Lambda function for asset processing"
  value       = module.storage.lambda_function_name
}



output "eks_cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_cluster_oidc_thumbprint" {
  value = module.eks.cluster_oidc_thumbprint
}
