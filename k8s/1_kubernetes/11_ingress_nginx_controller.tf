# Name: ingress_nginx_controller.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Nginx Ingress Controller in EKS Cluster
# https://kubernetes.github.io/ingress-nginx/
# https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx

resource "helm_release" "ingress_nginx_controller" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
  version    = "4.10.1"
  timeout    = 900

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = "true"
  }

  # set {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
  #   value = "ip"
  # }

  set {
    name  = "controller.ingressClassResource.default"
    value = "false"
  }

  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}
