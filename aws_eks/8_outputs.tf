# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the VPC, Subnet, EKS ARNs
# https://www.terraform.io/docs/configuration/outputs.html

# VPC
output "vpc_cidr_block" {
  value       = var.vpc_cidr_block
  description = "The address space that is used by the virtual network."
}

output "vpc_id" {
  value       = module.vpc_vpn.vpc_id
  description = "The VPC ID."
}

output "public_subnet_id" {
  value       = module.vpc_vpn.public_subnet_id
  description = "The public subnets ID."
}

output "private_subnet_id" {
  value       = module.vpc_vpn.private_subnet_id
  description = "The private subnets ID."
}

# OpenVPN Access Server
output "openvpn_access_server" {
  value       = module.vpc_vpn.openvpn_access_server
  description = "OpenVPN Access Server URL."
}


# EKS
output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster Name."
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint for EKS control plane."
}

output "kubeconfig_ca_data" {
  value       = module.eks.kubeconfig_ca_data
  description = "certificate-authority-data for EKS cluster"
}

output "eks_oidc_provider_arn" {
  value       = module.eks.eks_oidc_provider_arn
  description = "OIDC Provider ARN for EKS cluster"
}

output "eks_oidc_provider_url" {
  value       = module.eks.eks_oidc_provider_url
  description = "OIDC Provider URL for EKS cluster"
}

output "eks_sg_id" {
  value       = module.eks.eks_sg_id
  description = "EKS Security Group Id."
}

output "eks_node_role_arn" {
  value       = module.eks.eks_node_role_arn
  description = "EKS Node Role ARN."
}
