# Name: test_eks_cert_manager.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test Certificate Manager in EKS Cluster
# https://cert-manager.io/docs/installation/kubectl/#2-optional-end-to-end-verify-the-installation

resource "kubernetes_manifest" "test_cert_manager_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "test-cert-manager-selfsigned-issuer"
      "namespace" = "default"
    }
    "spec" = {
      "selfSigned" = {}
    }
  }
}

resource "kubernetes_manifest" "test_cert_manager_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "test-cert-manager-selfsigned-cert"
      "namespace" = "default"
    }
    "spec" = {
      "dnsNames" = [
        "test-cert-manager.${var.route53_domain}"
      ]
      "secretName" = "test-cert-manager-selfsigned-cert-tls"
      "issuerRef" = {
        "name" = "test-cert-manager-selfsigned-issuer"
      }
    }
  }
}

# Validation:
# kubectl describe certificate
