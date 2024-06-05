# Name: eks_oidc.tf
# Owner: Saurav Mitra
# Description: This terraform config will create IAM OIDC Provider for EKS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

data "tls_certificate" "tlscert" {
  url = aws_eks_cluster.demo_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider_demo_eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.tlscert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.tlscert.url
}
