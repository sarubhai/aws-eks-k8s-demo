# Name: test_eks_hpa.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test Horizontal Pod Autoscaler in EKS Cluster
# https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html

resource "kubernetes_deployment_v1" "test_hpa_deploy" {
  metadata {
    name = "test-hpa-deploy"
  }

  spec {
    selector {
      match_labels = {
        app = "test-hpa"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-hpa"
        }
      }

      spec {
        container {
          image = "registry.k8s.io/hpa-example"
          name  = "test-hpa"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu = "200m"
            }

            limits = {
              cpu = "500m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "test_hpa_svc" {
  metadata {
    name = "test-hpa-svc"

    labels = {
      name = "test-hpa-svc"
    }
  }

  spec {
    selector = {
      app = "test-hpa"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
      protocol    = "TCP"
    }
  }
}

# Validation:
# kubectl autoscale deployment test-hpa-deploy --cpu-percent=50 --min=1 --max=5
# kubectl get hpa

# Generate Load
# kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://test-hpa-svc.default.svc.cluster.local; done"

# kubectl get hpa
