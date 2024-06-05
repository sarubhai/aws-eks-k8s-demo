# Name: efs_csi_driver.tf
# Owner: Saurav Mitra
# Description: This terraform config will create AWS EFS CSI Driver Controller in EKS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

# IAM Role for Service Account
data "aws_iam_policy_document" "aws_efs_csi_controller_role_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider_demo_eks_cluster.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider_demo_eks_cluster.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider_demo_eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-*"]
    }
  }
}

resource "aws_iam_role" "aws_efs_csi_controller_role" {
  name               = "aws-efs-csi-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_efs_csi_controller_role_trust_policy.json

  tags = {
    Name  = "aws-efs-csi-controller-role"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "efs_csi_role_policy_attachment" {
  role       = aws_iam_role.aws_efs_csi_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "efs_csi_node_role_policy_attachment" {
  role       = aws_iam_role.aws_efs_csi_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# EFS CSI Addon
resource "aws_eks_addon" "aws_efs_csi_driver_addon" {
  # aws eks describe-addon-versions --addon-name aws-efs-csi-driver
  cluster_name                = aws_eks_cluster.demo_eks_cluster.id
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = "v2.0.3-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.aws_efs_csi_controller_role.arn
}
