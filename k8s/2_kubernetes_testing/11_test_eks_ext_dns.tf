# Name: test_eks_ext_dns.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test External DNS in EKS Cluster
# https://repost.aws/knowledge-center/eks-set-up-externaldns

resource "kubernetes_deployment_v1" "test_ext_dns_deploy" {
  metadata {
    name = "test-ext-dns-deploy"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "test-ext-dns"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-ext-dns"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "test-ext-dns"

          port {
            container_port = 80
            name           = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "test_ext_dns_svc" {
  metadata {
    name = "test-ext-dns-svc"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal" # "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"       # "instance"
      "external-dns.alpha.kubernetes.io/hostname" = "test-ext-dns-svc.${var.route53_domain}"
    }
  }

  spec {
    load_balancer_class = "service.k8s.aws/nlb"

    selector = {
      app = "test-ext-dns"
    }

    type             = "LoadBalancer"
    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }

  wait_for_load_balancer = true
}

resource "kubernetes_ingress_v1" "test_ext_dns_ing" {
  metadata {
    name = "test-ext-dns-ing"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal" # "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"       # "instance"
      "external-dns.alpha.kubernetes.io/hostname" = "test-ext-dns-ing.${var.route53_domain}"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "test-ext-dns-ing.${var.route53_domain}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.test_ext_dns_svc.metadata.0.name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  wait_for_load_balancer = true
}


resource "kubernetes_ingress_v1" "test_ext_dns_ing_tls" {
  metadata {
    name = "test-ext-dns-ing-tls"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal" # "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"       # "instance"
      "external-dns.alpha.kubernetes.io/hostname" = "test-ext-dns-ing.${var.route53_domain}"
      "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\": 443}]"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "test-ext-dns-ing-tls.${var.route53_domain}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.test_ext_dns_svc.metadata.0.name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  wait_for_load_balancer = true
}


# Validation:
# svc_lb=`kubectl get svc test-ext-dns-svc -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
# curl $svc_lb
# curl http://test-ext-dns-svc.yourdomainname.com
# ing_lb=`kubectl get ing test-ext-dns-ing -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
# curl $ing_lb
# curl http://test-ext-dns-ing.yourdomainname.com

# ing_tls_lb=`kubectl get ing test-ext-dns-ing-tls -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
# curl $ing_tls_lb
# curl https://test-ext-dns-ing-tls.yourdomainname.com
