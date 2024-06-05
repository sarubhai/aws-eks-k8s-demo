# Name: cloudwatch_log_group.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Cloudwatch Log Groups for MSK Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group

resource "aws_cloudwatch_log_group" "lg_eks" {
  name              = "/aws/eks/${var.prefix}-eks-cluster/cluster"
  retention_in_days = 1

  tags = {
    Name  = "${var.prefix}-cluster-lg-eks"
    Env   = var.env
    Owner = var.owner
  }
}
