# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create the infrastructure resources
# https://www.terraform.io/docs/configuration/variables.html

# Tags
variable "prefix" {
  description = "This prefix will be included in the name of the resources."
  default     = "aws-msk-eks-demo"
}

variable "env" {
  description = "The Deployment Environment."
  default     = "dev"
}

variable "owner" {
  description = "This owner name tag will be included in the owner of the resources."
  default     = "Saurav-Mitra"
}

variable "region" {
  description = "The AWS Region Name."
  default     = "eu-central-1"
}


# VPC
variable "vpc_cidr_block" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "The VPC ID."
}

variable "public_subnet_id" {
  description = "The public subnets ID."
}

variable "private_subnet_id" {
  description = "The private subnets ID."
}

variable "openvpn_access_server" {
  description = "OpenVPN Access Server URL."
}

variable "route53_zone_id" {
  description = "The Route53 Domain Zone ID."
}

variable "route53_domain" {
  description = "The Route53 Domain Name."
}

variable "acm_certificate_arn" {
  description = "The ACM Certificate ARN."
}


# EKS Cluster Details
variable "cluster_name" {
  description = "EKS cluster Name."
  default     = "aws-eks-k8s-demo-eks-cluster"
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
}

variable "kubeconfig_ca_data" {
  description = "certificate-authority-data for EKS cluster."
}

variable "eks_oidc_provider_arn" {
  description = "OIDC Provider ARN for EKS cluster."
}

variable "eks_oidc_provider_url" {
  description = "OIDC Provider URL for EKS cluster."
}

variable "eks_sg_id" {
  description = "EKS Security Group Id."
}

variable "eks_node_role_arn" {
  description = "EKS Node Role ARN."
}
