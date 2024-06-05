# Name: reloader.tf
# Owner: Saurav Mitra
# Description: This terraform config will install Kubernetes Reloader in EKS Cluster
# https://github.com/stakater/Reloader
# https://artifacthub.io/packages/helm/stakater/reloader

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  namespace  = "kube-system"
  version    = "1.0.105"
}
