# Name: test_eks_efs.tf
# Owner: Saurav Mitra
# Description: This terraform config will Test EFS Resource in EKS Cluster 

# EFS Dynamic Provisioning

resource "aws_efs_file_system" "test_efs" {
  creation_token = "test-efs"

  tags = {
    Name  = "test-efs"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_efs_mount_target" "test_efs_mount" {
  count = length(var.private_subnet_id)

  file_system_id  = aws_efs_file_system.test_efs.id
  subnet_id       = var.private_subnet_id[count.index]
  security_groups = [var.eks_sg_id]
}


resource "kubernetes_storage_class_v1" "test_efs_sc" {
  metadata {
    name = "test-efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Delete" # "Retain"
  volume_binding_mode = "Immediate"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.test_efs.id
    directoryPerms   = "700"
  }

  depends_on = [
    aws_efs_file_system.test_efs,
    aws_efs_mount_target.test_efs_mount
  ]
}

resource "kubernetes_persistent_volume_claim_v1" "test_efs_pvc" {
  metadata {
    name = "test-efs-pvc"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class_v1.test_efs_sc.metadata.0.name
    # volume_name = kubernetes_persistent_volume_v1.test_efs_pv.metadata.0.name

    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_pod_v1" "test_efs_pod" {
  metadata {
    name = "test-efs-pod"
  }

  spec {
    container {
      image   = "centos"
      name    = "test-efs"
      command = ["/bin/sh"]
      args    = ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]

      volume_mount {
        name       = "test-efs-persistent-storage"
        mount_path = "/data"
      }
    }

    volume {
      name = "test-efs-persistent-storage"

      persistent_volume_claim {
        claim_name = "test-efs-pvc" # kubernetes_persistent_volume_claim_v1.test_efs_pvc.metadata.0.name
      }
    }
  }
}

# Validation:
# kubectl exec -it test-efs-pod -- /bin/bash -c "cat /data/out.txt"
