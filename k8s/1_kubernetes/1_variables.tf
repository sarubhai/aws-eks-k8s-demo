# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create the infrastructure resources
# https://www.terraform.io/docs/configuration/variables.html

# Tags
variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "env" {
  description = "The Deployment Environment."
}

variable "owner" {
  description = "This owner name tag will be included in the owner of the resources."
}

variable "region" {
  description = "The AWS Region Name."
}


# VPC CIDR
variable "vpc_id" {
  description = "The VPC ID."
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


# EKS Variables
variable "cluster_name" {
  description = "EKS cluster Name."
}

variable "eks_oidc_provider_arn" {
  description = "OIDC Provider ARN for EKS cluster."
}

variable "eks_oidc_provider_url" {
  description = "OIDC Provider URL for EKS cluster."
}

variable "eks_node_role_arn" {
  description = "EKS Node Role ARN."
}
