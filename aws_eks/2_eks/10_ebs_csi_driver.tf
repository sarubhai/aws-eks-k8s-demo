# Name: ebs_csi_driver.tf
# Owner: Saurav Mitra
# Description: This terraform config will create AWS EBS CSI Driver Controller in EKS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

# IAM Role for Service Account
data "aws_iam_policy_document" "aws_ebs_csi_controller_role_trust_policy" {
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
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "aws_ebs_csi_controller_role" {
  name               = "aws-ebs-csi-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_ebs_csi_controller_role_trust_policy.json

  tags = {
    Name  = "aws-ebs-csi-controller-role"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_role_policy_attachment" {
  role       = aws_iam_role.aws_ebs_csi_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_node_role_policy_attachment" {
  role       = aws_iam_role.aws_ebs_csi_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# EBS CSI Addon
resource "aws_eks_addon" "aws_ebs_csi_driver_addon" {
  # aws eks describe-addon-versions --addon-name aws-ebs-csi-driver
  cluster_name                = aws_eks_cluster.demo_eks_cluster.id
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.31.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.aws_ebs_csi_controller_role.arn
}
