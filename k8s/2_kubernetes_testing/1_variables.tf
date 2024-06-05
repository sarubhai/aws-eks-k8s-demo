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
variable "vpc_cidr_block" {
  description = "The address space that is used by the virtual network."
}

variable "vpc_id" {
  description = "The VPC ID."
}

variable "private_subnet_id" {
  description = "The private subnets ID."
}

variable "route53_domain" {
  description = "The Route53 Domain Name."
}

variable "acm_certificate_arn" {
  description = "The ACM Certificate ARN."
}


# EKS Variables
variable "eks_sg_id" {
  description = "EKS Security Group Id."
}


variable "suffix" {
  description = "Random Suffix for Unique Secret Name."
}
