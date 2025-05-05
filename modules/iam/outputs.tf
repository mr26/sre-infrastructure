output "cluster_role_arn" {
  value = aws_iam_role.cluster_role.arn
  description = "IAM Role ARN for EKS Cluster."
}

output "node_role_arn" {
    value = aws_iam_role.node_role.arn
}