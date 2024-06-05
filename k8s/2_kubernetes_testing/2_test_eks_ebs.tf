# Name: test_eks_ebs.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test EBS Resource in EKS Cluster 

# EBS Dynamic Provisioning
resource "kubernetes_storage_class_v1" "test_ebs_sc" {
  metadata {
    name = "test-ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete" # "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume_claim_v1" "test_ebs_pvc" {
  metadata {
    name = "test-ebs-pvc"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class_v1.test_ebs_sc.metadata.0.name
    # volume_name = kubernetes_persistent_volume_v1.test_ebs_pv.metadata.0.name

    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_pod_v1" "test_ebs_pod" {
  metadata {
    name = "test-ebs-pod"
  }

  spec {
    container {
      image   = "centos"
      name    = "test-ebs"
      command = ["/bin/sh"]
      args    = ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]

      volume_mount {
        name       = "test-ebs-persistent-storage"
        mount_path = "/data"
      }
    }

    volume {
      name = "test-ebs-persistent-storage"

      persistent_volume_claim {
        claim_name = "test-ebs-pvc" # kubernetes_persistent_volume_claim_v1.test_ebs_pvc.metadata.0.name
      }
    }
  }
}


# Validation:
# kubectl exec -it test-ebs-pod -- /bin/bash -c "cat /data/out.txt"
