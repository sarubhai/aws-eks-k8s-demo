# Name: vertical_pod_autoscaler.tf
# Owner: Saurav Mitra
# Description: This terraform config will install Kubernetes Vertical Pod Autoscaler in EKS Cluster
# https://docs.aws.amazon.com/eks/latest/userguide/vertical-pod-autoscaler.html
# https://artifacthub.io/packages/helm/cowboysysop/vertical-pod-autoscaler

resource "helm_release" "vertical_pod_autoscaler" {
  name       = "vertical-pod-autoscaler"
  repository = "https://cowboysysop.github.io/charts"
  chart      = "vertical-pod-autoscaler"
  namespace  = "kube-system"
  version    = "9.8.2"
}
