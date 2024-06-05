# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create the infrastructure resources
# https://www.terraform.io/docs/configuration/variables.html

# Tags
variable "prefix" {
  description = "This prefix will be included in the name of the resources."
  default     = "aws-eks-k8s-demo"
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


# VPC CIDR
variable "vpc_cidr_block" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

# Subnet CIDR
variable "private_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the private subnet."
  default = {
    eu-central-1a = "10.0.1.0/24"
    eu-central-1b = "10.0.2.0/24"
    eu-central-1c = "10.0.3.0/24"
  }
}

variable "public_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the public subnet."
  default = {
    eu-central-1a = "10.0.4.0/24"
    eu-central-1b = "10.0.5.0/24"
    eu-central-1c = "10.0.6.0/24"
  }
}


# OpenVPN Access Server
variable "openvpn_server_owners" {
  description = "The OpenVPN Access Server Owners."
  default     = ["444663524611"]
}

variable "openvpn_server_ami_name" {
  description = "The OpenVPN Access Server AMI Name."
  default     = "OpenVPN Access Server Community Image"
  # default     = "ami-0269405596354b6a4"
}

variable "openvpn_server_instance_type" {
  description = "The OpenVPN Access Server Instance Type."
  default     = "t2.micro"
}

variable "vpn_admin_user" {
  description = "The OpenVPN Admin User."
  default     = "openvpn"
}

variable "vpn_admin_password" {
  description = "The OpenVPN Admin Password."
}

# AWS EC2 KeyPair
variable "keypair_name" {
  description = "The AWS Key pair name."
}


# EKS Variables
variable "eks_version" {
  description = "The EKS Version."
  default     = "1.29"
}

variable "node_group_scaling_config" {
  description = "Scaling Configuration of the EKS Node Group."
  default = {
    capacity_type  = "ON_DEMAND"
    disk_size      = 30
    instance_types = ["t3.large"]
    desired_size   = 2
    max_size       = 3
    min_size       = 1
  }
}
