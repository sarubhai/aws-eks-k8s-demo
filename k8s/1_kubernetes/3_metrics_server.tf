# Name: metrics_server.tf
# Owner: Saurav Mitra
# Description: This terraform config will install Kubernetes Metrics Server in EKS Cluster
# https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
# https://artifacthub.io/packages/helm/metrics-server/metrics-server

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
}
