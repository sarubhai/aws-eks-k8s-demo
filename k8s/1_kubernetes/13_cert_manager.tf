# Name: cert_manager.tf
# Owner: Saurav Mitra
# Description: This terraform config will install Kubernetes Certificate Manager in EKS Cluster
# https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-end-to-end-encryption-for-applications-on-amazon-eks-using-cert-manager-and-let-s-encrypt.html
# https://artifacthub.io/packages/helm/cert-manager/cert-manager

# IAM Role for Service Account
data "aws_iam_policy_document" "cert_manager_role_trust_policy" {
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
      values   = ["system:serviceaccount:kube-system:cert-manager"]
    }
  }
}

resource "aws_iam_role" "cert_manager_role" {
  name               = "cert-manager-role"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_role_trust_policy.json

  tags = {
    Name  = "cert-manager-role"
    Env   = var.env
    Owner = var.owner
  }
}

data "aws_iam_policy_document" "cert_manager_policy" {
  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "cert-manager-policy"
  description = "Certificate Manager Policy"
  policy      = data.aws_iam_policy_document.cert_manager_policy.json

  tags = {
    Name  = "cert-manager-policy"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "cert_manager_policy_attachment" {
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}


# Kubernetes Service Account
resource "kubernetes_service_account_v1" "cert_manager_sa" {
  metadata {
    name      = "cert-manager"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" = "cert-manager"
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager_role.arn
    }
  }

  depends_on = [
    aws_iam_role.cert_manager_role
  ]
}


# Install the Cert Manager in EKS
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "kube-system"
  version    = "1.14.5"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account_v1.cert_manager_sa.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account_v1.cert_manager_sa,
    helm_release.aws_load_balancer_controller
  ]
}
