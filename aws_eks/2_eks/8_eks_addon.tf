# Name: eks_addon.tf
# Owner: Saurav Mitra
# Description: This terraform config will create EKS Cluster Addon
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

# Uses the permissions assigned to the node IAM role
# service_account_role_arn = aws_iam_role.eks_node_role.arn

# CoreDNS
resource "aws_eks_addon" "coredns_addon" {
  # aws eks describe-addon-versions --addon-name coredns
  cluster_name                = aws_eks_cluster.demo_eks_cluster.id
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.9"
  resolve_conflicts_on_create = "OVERWRITE"

  configuration_values = jsonencode({
    replicaCount = 4
    resources = {
      limits = {
        cpu    = "100m"
        memory = "150Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "150Mi"
      }
    }
  })
}

# VPC CNI
resource "aws_eks_addon" "vpc_cni_addon" {
  # aws eks describe-addon-versions --addon-name vpc-cni
  cluster_name                = aws_eks_cluster.demo_eks_cluster.id
  addon_name                  = "vpc-cni"
  addon_version               = "v1.18.1-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
}

# Kube Proxy
resource "aws_eks_addon" "kube_proxy_addon" {
  # aws eks describe-addon-versions --addon-name kube-proxy
  cluster_name                = aws_eks_cluster.demo_eks_cluster.id
  addon_name                  = "kube-proxy"
  addon_version               = "v1.29.3-eksbuild.5"
  resolve_conflicts_on_create = "OVERWRITE"
}
