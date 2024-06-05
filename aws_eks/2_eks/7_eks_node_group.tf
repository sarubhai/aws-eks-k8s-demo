# Name: eks_node_group.tf
# Owner: Saurav Mitra
# Description: This terraform config will create EKS Cluster Managed Node Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.demo_eks_cluster.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "default_eks_cluster_nodegroup" {
  cluster_name    = aws_eks_cluster.demo_eks_cluster.id
  node_group_name = "${var.prefix}-eks-cluster-nodegroup"
  version         = aws_eks_cluster.demo_eks_cluster.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_id

  # ami_type = var.scaling_config.ami_type
  capacity_type  = var.node_group_scaling_config.capacity_type
  disk_size      = var.node_group_scaling_config.disk_size
  instance_types = var.node_group_scaling_config.instance_types


  scaling_config {
    desired_size = var.node_group_scaling_config.desired_size
    max_size     = var.node_group_scaling_config.max_size
    min_size     = var.node_group_scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  # remote_access {
  #   ec2_ssh_key               = var.keypair_name
  #   source_security_group_ids = []
  # }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_ecr_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_ebs_csi_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_efs_csi_policy_attachment
  ]

  tags = {
    Name  = "${var.prefix}-eks-cluster-nodegroup"
    Env   = var.env
    Owner = var.owner
  }
}
