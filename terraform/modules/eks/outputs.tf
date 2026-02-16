output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.pb_eks_cluster.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.pb_eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Cluster certificate authority data"
  value       = aws_eks_cluster.pb_eks_cluster.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = aws_eks_cluster.pb_eks_cluster.identity[0].oidc[0].issuer
}

output "cluster_oidc_thumbprint" {
  description = "OIDC thumbprint"
  value       = data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
}
