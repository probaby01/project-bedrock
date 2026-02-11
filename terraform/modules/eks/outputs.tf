output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.pb_eks_cluster.name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.pb_eks_cluster.endpoint
}

output "cluster_ca" {
  description = "Base64 encoded certificate authority data for the EKS cluster"
  value = aws_eks_cluster.pb_eks_cluster.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer (without https://)"
  value       = aws_eks_cluster.pb_eks_cluster.identity[0].oidc[0].issuer
}