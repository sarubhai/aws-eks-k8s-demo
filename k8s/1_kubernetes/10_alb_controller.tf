# Name: alb_controller.tf
# Owner: Saurav Mitra
# Description: This terraform config will create AWS Load Balancer Controller in EKS Cluster
# https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
# https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller

# IAM Role for Service Account
data "aws_iam_policy_document" "aws_load_balancer_controller_role_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name               = "aws-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_role_trust_policy.json

  tags = {
    Name  = "aws-load-balancer-controller-role"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "aws-load-balancer-controller-policy"
  description = "AWS Load Balancer Controller Policy"
  policy      = file("${path.module}/9_alb_controller_policy.json")

  tags = {
    Name  = "aws-load-balancer-controller-policy"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_role_policy_attachment" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}


# Kubernetes Service Account
resource "kubernetes_service_account_v1" "aws_load_balancer_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }

    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.aws_load_balancer_controller_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }

  depends_on = [
    aws_iam_role.aws_load_balancer_controller_role
  ]
}


# Install the AWS Load Balancer Controller in EKS
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"
  timeout    = 900

  set {
    name  = "image.repository"
    value = "public.ecr.aws/eks/aws-load-balancer-controller" # "602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account_v1.aws_load_balancer_controller_sa.metadata[0].name
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  depends_on = [
    kubernetes_service_account_v1.aws_load_balancer_controller_sa
  ]
}
