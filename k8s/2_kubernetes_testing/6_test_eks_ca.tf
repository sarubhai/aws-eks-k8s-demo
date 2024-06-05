# Name: test_eks_ca.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test Cluster Autoscaler in EKS Cluster
# https://repost.aws/knowledge-center/eks-set-up-externaldns

resource "kubernetes_deployment_v1" "test_eks_ca_deploy" {
  metadata {
    name = "monte-carlo-pi-service"
    labels = {
      app = "monte-carlo-pi-service"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "monte-carlo-pi-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "monte-carlo-pi-service"
        }
      }

      spec {
        container {
          image = "ruecarlo/monte-carlo-pi-service"
          name  = "monte-carlo-pi-service"

          port {
            container_port = 8080
            name           = "http"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "512m"
            }

            limits = {
              memory = "256Mi"
              cpu    = "512m"
            }
          }

          security_context {
            privileged                 = "false"
            read_only_root_filesystem  = "true"
            allow_privilege_escalation = "false"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "test_eks_ca_svc" {
  metadata {
    name = "monte-carlo-pi-service"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal" # "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"       # "instance"
      "external-dns.alpha.kubernetes.io/hostname" = "test-ext-dns-svc.${var.route53_domain}"
    }
  }

  spec {
    load_balancer_class = "service.k8s.aws/nlb"

    selector = {
      app = "monte-carlo-pi-service"
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
  }

  wait_for_load_balancer = true
}


# kubectl get node
# svc_lb=`kubectl get svc monte-carlo-pi-service -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
# curl $svc_lb

# kubectl scale deployment/monte-carlo-pi-service --replicas=3
# kubectl get pods | grep ^monte-carlo-pi-service
# kubectl get node

# kubectl scale deployment/monte-carlo-pi-service --replicas=1
# kubectl get node
