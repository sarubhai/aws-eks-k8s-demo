# Name: test_eks_alb.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test AWS Load Balancer in EKS Cluster
# https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html

resource "kubernetes_deployment_v1" "test_alb_deploy" {
  metadata {
    name = "test-alb-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "test-alb"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-alb"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "test-alb"

          port {
            container_port = 80
            name           = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "test_alb_svc" {
  metadata {
    name = "test-alb-svc"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internal" # "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"       # "instance"
    }
  }

  spec {
    selector = {
      app = "test-alb"
    }

    type                = "LoadBalancer"
    load_balancer_class = "service.k8s.aws/nlb"
    session_affinity    = "ClientIP"

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }

  wait_for_load_balancer = true
}

resource "kubernetes_ingress_v1" "test_alb_ing" {
  metadata {
    name = "test-alb-ing"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internal" # "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"       # "instance"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.test_alb_svc.metadata.0.name

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
# svc_lb=`kubectl get svc test-alb-svc -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
# curl $svc_lb
# ing_lb=`kubectl get ing test-alb-ing -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
# curl $ing_lb
