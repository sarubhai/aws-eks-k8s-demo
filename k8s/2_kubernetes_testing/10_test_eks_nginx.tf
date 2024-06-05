# Name: test_eks_nginx.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test Nginx Controller in EKS Cluster
# https://aws.amazon.com/blogs/containers/exposing-kubernetes-applications-part-3-nginx-ingress-controller/

resource "kubernetes_deployment_v1" "test_nginx_deploy" {
  metadata {
    name = "test-nginx-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "test-nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-nginx"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "test-nginx"

          port {
            container_port = 80
            name           = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "test_nginx_svc" {
  metadata {
    name = "test-nginx-svc"
  }

  spec {
    selector = {
      app = "test-nginx"
    }

    type             = "NodePort"
    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "test_nginx_ing" {
  metadata {
    name = "test-nginx-ing"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.test_nginx_svc.metadata.0.name

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
# ing_lb=`kubectl get ing test-nginx-ing -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
# curl $ing_lb
