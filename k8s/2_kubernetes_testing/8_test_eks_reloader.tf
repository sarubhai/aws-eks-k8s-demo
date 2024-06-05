# Name: test_eks_reloader.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test Reloader in EKS Cluster
# https://github.com/stakater/Reloader

resource "aws_secretsmanager_secret" "test_reloader_secrets" {
  name = "test_reloader/demo-${var.suffix}"
}

resource "aws_secretsmanager_secret_version" "test_reloader_secrets_version" {
  secret_id     = aws_secretsmanager_secret.test_reloader_secrets.id
  secret_string = jsonencode({ username = "admin", password = "S3cr3T11" })
}


resource "kubernetes_manifest" "test_reloader_secretstore" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata" = {
      "name"      = "test-reloader-secretstore"
      "namespace" = "default"
    }
    "spec" = {
      "provider" = {
        "aws" = {
          "region"  = var.region
          "service" = "SecretsManager"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "test_reloader_externalsecret" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ExternalSecret"
    "metadata" = {
      "name"      = "test-reloader-externalsecret"
      "namespace" = "default"
    }
    "spec" = {
      "secretStoreRef" = {
        "kind" = "SecretStore"
        "name" = "test-reloader-secretstore"
      }
      "refreshInterval" = "1m"
      "target" = {
        "name"           = "test-reloader-externalsecret"
        "creationPolicy" = "Owner"
      }
      "data" = [
        {
          "remoteRef" = {
            "key"      = "test_reloader/demo-${var.suffix}"
            "property" = "username"
          }
          "secretKey" = "demo-username"
        },
        {
          "remoteRef" = {
            "key"      = "test_reloader/demo-${var.suffix}"
            "property" = "password"
          }
          "secretKey" = "demo-password"
        },
      ]
    }
  }
}

resource "kubernetes_deployment_v1" "test_reloader_deploy" {
  metadata {
    name = "test-reloader-deploy"

    annotations = {
      "reloader.stakater.com/auto" = true
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "test-reloader"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-reloader"
        }
      }

      spec {
        container {
          image   = "busybox"
          name    = "test-reloader"
          command = ["/bin/sh"]
          args    = ["-c", "sleep 3600"]

          env {
            name = "DEMO_USERNAME"
            value_from {
              secret_key_ref {
                name     = "test-reloader-externalsecret"
                key      = "demo-username"
                optional = false
              }
            }
          }

          env {
            name = "DEMO_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "test-reloader-externalsecret"
                key      = "demo-password"
                optional = false
              }
            }
          }

        }
      }
    }
  }
}

# Validation:
# kubectl describe secretstores test-reloader-secretstore
# kubectl describe externalsecret test-reloader-externalsecret
# kubectl describe secret test-reloader-externalsecret
# kubectl get secret test-reloader-externalsecret -o json | jq '.data | map_values(@base64d)'
# pod_name=`kubectl get pod -l app=test-reloader --output=json | jq -r '.items[0].metadata.name'`
# kubectl exec -it $pod_name -- /bin/sh -c 'echo $DEMO_USERNAME'
# kubectl exec -it $pod_name -- /bin/sh -c 'echo $DEMO_PASSWORD'
