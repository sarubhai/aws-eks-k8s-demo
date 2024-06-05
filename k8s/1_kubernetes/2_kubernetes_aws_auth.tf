# Name: kubernetes_aws_auth.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Kubernetes AWS Auth
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data
# Optional, when we want to grant AWS users/groups access to Kubetnetes

data "aws_caller_identity" "current" {}

# k8sAdmin Role
resource "aws_iam_role" "k8sadmin_role" {
  name        = "k8sAdmin"
  description = "EKS IAM role for kubernetes admin."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = {
    Name  = "k8sAdmin"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "k8sadmin_role_policy_attachment" {
  role       = aws_iam_role.k8sadmin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = <<EOT
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: ${var.eks_node_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
- groups:
  - system:masters
  rolearn: ${aws_iam_role.k8sadmin_role.arn}
  username: admin
    EOT

    "mapUsers" = <<EOT
- groups:
  - system:masters
  userarn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:root
  username: root
    EOT
  }

  force = true

  lifecycle {
    prevent_destroy = true
  }
}
