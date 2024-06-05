# Name: test_eks_vpa.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test Vertical Pod Autoscaler in EKS Cluster 
# https://docs.aws.amazon.com/eks/latest/userguide/vertical-pod-autoscaler.html

resource "kubernetes_deployment_v1" "test_vpa_deploy" {
  metadata {
    name = "test-vpa-deploy"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "test-vpa"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-vpa"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 65534
        }

        container {
          image   = "registry.k8s.io/ubuntu-slim:0.1"
          name    = "test-vpa"
          command = ["/bin/sh"]
          args    = ["-c", "while true; do timeout 0.5s yes >/dev/null; sleep 0.5s; done"]

          resources {
            requests = {
              cpu    = "100m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "test_vpa" {
  manifest = {
    "apiVersion" = "autoscaling.k8s.io/v1"
    "kind"       = "VerticalPodAutoscaler"
    "metadata" = {
      "name"      = "test-vpa"
      "namespace" = "default"
    }
    "spec" = {
      "resourcePolicy" = {
        "containerPolicies" = [
          {
            "containerName" = "*"
            "controlledResources" = [
              "cpu",
              "memory",
            ]
            "maxAllowed" = {
              "cpu"    = 1
              "memory" = "500Mi"
            }
            "minAllowed" = {
              "cpu"    = "100m"
              "memory" = "50Mi"
            }
          },
        ]
      }
      "targetRef" = {
        "apiVersion" = "apps/v1"
        "kind"       = "Deployment"
        "name"       = "test-vpa-deploy"
      }
    }
  }
}

# Validation:
# pod_name=`kubectl get pod -l app=test-vpa --output=json | jq -r '.items[0].metadata.name'`
# kubectl describe pod $pod_name
# Requests:
#   cpu:        100m
#   memory:     50Mi

# pod_name=`kubectl get pod -l app=test-vpa --output=json | jq -r '.items[0].metadata.name'`
# kubectl describe pod $pod_name
# Requests:
#   cpu:        511m
#   memory:     262144k

# kubectl describe vpa/test-vpa
# Recommendation:
#   Container Recommendations:
#     Container Name:  test-vpa
#     Lower Bound:
#       Cpu:     452m
#       Memory:  262144k
#     Target:
#       Cpu:     511m
#       Memory:  262144k
#     Uncapped Target:
#       Cpu:     511m
#       Memory:  262144k
#     Upper Bound:
#       Cpu:     1
#       Memory:  311138118
