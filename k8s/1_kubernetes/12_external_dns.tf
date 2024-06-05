# Name: external_dns.tf
# Owner: Saurav Mitra
# Description: This terraform config will install Kubernetes External DNS in EKS Cluster
# https://repost.aws/knowledge-center/eks-set-up-externaldns
# https://artifacthub.io/packages/helm/external-dns/external-dns

# IAM Role for Service Account
data "aws_iam_policy_document" "external_dns_role_trust_policy" {
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
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}

resource "aws_iam_role" "external_dns_role" {
  name               = "external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_role_trust_policy.json

  tags = {
    Name  = "external-dns-role"
    Env   = var.env
    Owner = var.owner
  }
}

data "aws_iam_policy_document" "external_dns_policy" {
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

resource "aws_iam_policy" "external_dns_policy" {
  name        = "external-dns-policy"
  description = "External DNS Policy"
  policy      = data.aws_iam_policy_document.external_dns_policy.json

  tags = {
    Name  = "external-dns-policy"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "external_dns_policy_attachment" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}


# Kubernetes Service Account
resource "kubernetes_service_account_v1" "external_dns_sa" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns_role.arn
    }
  }

  depends_on = [
    aws_iam_role.external_dns_role
  ]
}


# Install the External DNS in EKS
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "1.14.1"

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account_v1.external_dns_sa.metadata[0].name
  }

  set {
    name  = "provider.name"
    value = "aws"
  }

  set {
    name  = "sources"
    value = "{ingress,service}"
  }

  set {
    name  = "domainFilters"
    value = "{${var.route53_domain}}"
  }

  set {
    name  = "aws.zoneType"
    value = "" # public, private or no value for both
  }

  set {
    name  = "txtOwnerId"
    value = var.route53_zone_id
  }

  set {
    name  = "policy"
    value = "sync"
  }

  depends_on = [
    kubernetes_service_account_v1.external_dns_sa,
    helm_release.aws_load_balancer_controller
  ]
}
