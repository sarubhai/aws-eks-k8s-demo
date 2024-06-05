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

# Subnet CIDR
variable "private_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the private subnet."
}

variable "public_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the public subnet."
}


# OpenVPN Access Server
variable "openvpn_server_owners" {
  description = "The OpenVPN Access Server Owners."
}

variable "openvpn_server_ami_name" {
  description = "The OpenVPN Access Server AMI Name."
}

variable "openvpn_server_instance_type" {
  description = "The OpenVPN Access Server Instance Type."
}

variable "vpn_admin_user" {
  description = "The OpenVPN Admin User."
}

variable "vpn_admin_password" {
  description = "The OpenVPN Admin Password."
}

# AWS EC2 KeyPair
variable "keypair_name" {
  description = "The AWS Key pair name."
}
