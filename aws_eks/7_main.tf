# Name: main.tf
# Owner: Saurav Mitra
# Description: This terraform config will provision vpc, vpn & eks cluster


# VPC & VPN
module "vpc_vpn" {
  source                       = "./1_vpc_vpn"
  prefix                       = var.prefix
  env                          = var.env
  owner                        = var.owner
  region                       = var.region
  vpc_cidr_block               = var.vpc_cidr_block
  private_subnets              = var.private_subnets
  public_subnets               = var.public_subnets
  openvpn_server_owners        = var.openvpn_server_owners
  openvpn_server_ami_name      = var.openvpn_server_ami_name
  openvpn_server_instance_type = var.openvpn_server_instance_type
  vpn_admin_user               = var.vpn_admin_user
  vpn_admin_password           = var.vpn_admin_password
  keypair_name                 = var.keypair_name
}


# EKS
module "eks" {
  source                    = "./2_eks"
  prefix                    = var.prefix
  env                       = var.env
  owner                     = var.owner
  region                    = var.region
  vpc_cidr_block            = var.vpc_cidr_block
  vpc_id                    = module.vpc_vpn.vpc_id
  private_subnet_id         = module.vpc_vpn.private_subnet_id
  kms_eks_alias             = local.kms_eks_alias
  eks_version               = var.eks_version
  node_group_scaling_config = var.node_group_scaling_config
}
