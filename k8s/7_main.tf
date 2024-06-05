# Name: main.tf
# Owner: Saurav Mitra
# Description: This terraform config will deploy various Kubernetes Objects in EKS Cluster


# Kubernetes Objects
module "kubernetes" {
  source                = "./1_kubernetes"
  prefix                = var.prefix
  env                   = var.env
  owner                 = var.owner
  region                = var.region
  vpc_id                = var.vpc_id
  route53_zone_id       = var.route53_zone_id
  cluster_name          = var.cluster_name
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  eks_oidc_provider_url = var.eks_oidc_provider_url
  eks_node_role_arn     = var.eks_node_role_arn
  route53_domain        = var.route53_domain
  acm_certificate_arn   = var.acm_certificate_arn
}


# Kubernetes Cluster Testing
module "kubernetes_testing" {
  source              = "./2_kubernetes_testing"
  prefix              = var.prefix
  env                 = var.env
  owner               = var.owner
  region              = var.region
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_id              = var.vpc_id
  private_subnet_id   = var.private_subnet_id
  eks_sg_id           = var.eks_sg_id
  suffix              = local.suffix
  route53_domain      = var.route53_domain
  acm_certificate_arn = var.acm_certificate_arn

  depends_on = [
    module.kubernetes
  ]
}
