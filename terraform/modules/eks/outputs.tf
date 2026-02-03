output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.pb_eks_cluster.name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.pb_eks_cluster.endpoint
}