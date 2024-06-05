# Name: eks_cluster.tf
# Owner: Saurav Mitra
# Description: This terraform config will create EKS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

# EKS Cluster
resource "aws_eks_cluster" "demo_eks_cluster" {
  name     = "${var.prefix}-eks-cluster"
  version  = var.eks_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.private_subnet_id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.eks_sg.id]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.kms_eks.arn
    }

    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment,
    aws_iam_role_policy_attachment.eks_vpc_role_policy_attachment,
    aws_cloudwatch_log_group.lg_eks
  ]

  tags = {
    Name  = "${var.prefix}-eks-cluster"
    Env   = var.env
    Owner = var.owner
  }
}
