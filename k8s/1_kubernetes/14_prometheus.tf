# Name: prometheus.tf
# Owner: Saurav Mitra
# Description: This terraform config will install Prometheus in EKS Cluster
# https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html
# https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack

resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

# Install the Prometheus in EKS
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.prometheus.metadata[0].name
  version    = "59.1.0"

  set {
    name  = "prometheus.service.type"
    value = "NodePort"
  }

  set {
    name  = "prometheus.ingress.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.ingress.ingressClassName"
    value = "alb"
  }

  set {
    name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
    value = "prometheus-http-${var.env}-svc"
  }

  set {
    name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.order"
    value = "10"
    type  = "string"
  }

  set {
    name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/listen-ports"
    value = "[{\"HTTP\": 80}]"
  }

  set {
    name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internal" # internet-facing
  }

  set {
    name  = "prometheus.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "prometheus.${var.route53_domain}"
  }

  set {
    name  = "prometheus.ingress.pathType"
    value = "Prefix"
  }

  set_list {
    name  = "prometheus.ingress.hosts"
    value = ["prometheus.${var.route53_domain}"]
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "2h"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp2"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }


  set {
    name  = "alertmanager.enabled"
    value = "false"
  }


  set {
    name  = "grafana.service.type"
    value = "NodePort"
  }

  set {
    name  = "grafana.ingress.enabled"
    value = "true"
  }

  set {
    name  = "grafana.ingress.ingressClassName"
    value = "alb"
  }

  set {
    name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = "instance"
  }

  set {
    name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
    value = "grafana-http-${var.env}-svc"
  }

  set {
    name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.order"
    value = "11"
    type  = "string"
  }

  set {
    name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/listen-ports"
    value = "[{\"HTTP\": 80}]"
  }

  set {
    name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internal" # internet-facing
  }

  set {
    name  = "grafana.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "grafana.${var.route53_domain}"
  }

  set {
    name  = "grafana.ingress.pathType"
    value = "Prefix"
  }

  set_list {
    name  = "grafana.ingress.hosts"
    value = ["grafana.${var.route53_domain}"]
  }

  # set {
  #   name  = "grafana.ingress.path"
  #   value = "/"
  # }

  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = "gp2"
  }

  set {
    name  = "grafana.persistence.size"
    value = "10Gi"
  }


  depends_on = [
    kubernetes_namespace_v1.prometheus
  ]
}
