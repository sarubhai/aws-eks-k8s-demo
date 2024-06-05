# Name: test_eks_ext_secrets.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test External Secrets in EKS Cluster
# https://aws.amazon.com/blogs/containers/leverage-aws-secrets-stores-from-eks-fargate-with-external-secrets-operator/

resource "aws_secretsmanager_secret" "test_ext_secrets_secrets" {
  name = "test_ext_secrets/demo-${var.suffix}"
}

resource "aws_secretsmanager_secret_version" "test_ext_secrets_secrets_version" {
  secret_id     = aws_secretsmanager_secret.test_ext_secrets_secrets.id
  secret_string = jsonencode({ username = "admin", password = "S3cr3T1" })
}

resource "kubernetes_manifest" "test_ext_secrets_secretstore" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata" = {
      "name"      = "test-ext-secrets-secretstore"
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

resource "kubernetes_manifest" "test_ext_secrets_externalsecret" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ExternalSecret"
    "metadata" = {
      "name"      = "test-ext-secrets-externalsecret"
      "namespace" = "default"
    }
    "spec" = {
      "secretStoreRef" = {
        "kind" = "SecretStore"
        "name" = "test-ext-secrets-secretstore"
      }
      "refreshInterval" = "1m"
      "target" = {
        "name"           = "test-ext-secrets-externalsecret"
        "creationPolicy" = "Owner"
      }
      "data" = [
        {
          "remoteRef" = {
            "key"      = "test_ext_secrets/demo-${var.suffix}"
            "property" = "username"
          }
          "secretKey" = "demo-username"
        },
        {
          "remoteRef" = {
            "key"      = "test_ext_secrets/demo-${var.suffix}"
            "property" = "password"
          }
          "secretKey" = "demo-password"
        },
      ]
    }
  }
}

resource "kubernetes_pod_v1" "test_ext_secrets_pod" {
  metadata {
    name = "test-ext-secrets-pod"
  }

  spec {
    container {
      image   = "busybox"
      name    = "test-ext-secrets"
      command = ["/bin/sh"]
      args    = ["-c", "sleep 3600"]

      env {
        name = "DEMO_USERNAME"
        value_from {
          secret_key_ref {
            name     = "test-ext-secrets-externalsecret"
            key      = "demo-username"
            optional = false
          }
        }
      }

      env {
        name = "DEMO_PASSWORD"
        value_from {
          secret_key_ref {
            name     = "test-ext-secrets-externalsecret"
            key      = "demo-password"
            optional = false
          }
        }
      }
    }
  }
}

# Validation:
# kubectl describe secretstores test-ext-secrets-secretstore
# kubectl describe externalsecret test-ext-secrets-externalsecret
# kubectl describe secret test-ext-secrets-externalsecret
# kubectl get secret test-ext-secrets-externalsecret -o json | jq '.data | map_values(@base64d)'
# kubectl exec -it test-ext-secrets-pod -- /bin/sh -c 'echo $DEMO_USERNAME'
# kubectl exec -it test-ext-secrets-pod -- /bin/sh -c 'echo $DEMO_PASSWORD'
