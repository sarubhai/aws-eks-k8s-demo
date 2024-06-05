# Name: external_secrets.tf
# Owner: Saurav Mitra
# Description: This terraform config will install Kubernetes External Secrets in EKS Cluster
# https://github.com/external-secrets/external-secrets
# https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets

# IAM Role for Service Account
data "aws_iam_policy_document" "external_secrets_role_trust_policy" {
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
      values   = ["system:serviceaccount:kube-system:external-secrets"]
    }
  }
}

resource "aws_iam_role" "external_secrets_role" {
  name               = "external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_role_trust_policy.json

  tags = {
    Name  = "external-secrets-role"
    Env   = var.env
    Owner = var.owner
  }
}

data "aws_iam_policy_document" "external_secrets_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_secrets_policy" {
  name        = "external-secrets-policy"
  description = "External Secrets Policy"
  policy      = data.aws_iam_policy_document.external_secrets_policy.json

  tags = {
    Name  = "external-secrets-policy"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets_policy_attachment" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}


# Kubernetes Service Account
resource "kubernetes_service_account_v1" "external_secrets_sa" {
  metadata {
    name      = "external-secrets"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" = "external-secrets"
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_role.arn
    }
  }

  depends_on = [
    aws_iam_role.external_secrets_role
  ]
}


# Install the External Secrets in EKS
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
  version    = "0.9.19"

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account_v1.external_secrets_sa.metadata[0].name
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "webhook.port"
    value = "10250" # "9443"
  }

  # set {
  #   name  = "metrics.service.enabled"
  #   value = "false"
  # }

  # set {
  #   name  = "webhook.certManager.cert.create"
  #   value = "false"
  # }

  # set {
  #   name  = "webhook.metrics.service.enabled"
  #   value = "false"
  # }

  depends_on = [
    kubernetes_service_account_v1.external_secrets_sa
  ]
}
