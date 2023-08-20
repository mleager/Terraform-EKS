output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "oidc" {
  value = aws_eks_cluster.eks_cluster.identity
}
