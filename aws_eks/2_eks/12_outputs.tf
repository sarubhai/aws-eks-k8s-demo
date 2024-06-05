# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the EKS URL
# https://www.terraform.io/docs/configuration/outputs.html

# EKS
output "cluster_name" {
  value       = aws_eks_cluster.demo_eks_cluster.id
  description = "EKS cluster Name."
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.demo_eks_cluster.endpoint
  description = "Endpoint for EKS control plane."
}

output "kubeconfig_ca_data" {
  value       = aws_eks_cluster.demo_eks_cluster.certificate_authority[0].data
  description = "certificate-authority-data for EKS cluster"
}

output "eks_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.oidc_provider_demo_eks_cluster.arn
  description = "OIDC Provider ARN for EKS cluster"
}

output "eks_oidc_provider_url" {
  value       = aws_iam_openid_connect_provider.oidc_provider_demo_eks_cluster.url
  description = "OIDC Provider URL for EKS cluster"
}

output "eks_sg_id" {
  value       = aws_security_group.eks_sg.id
  description = "EKS Security Group Id."
}

output "eks_node_role_arn" {
  value       = aws_iam_role.eks_node_role.arn
  description = "EKS Node Role ARN."
}
