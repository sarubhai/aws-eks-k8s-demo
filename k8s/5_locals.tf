# Name: locals.tf
# Owner: Saurav Mitra
# Description: This terraform config will declare some local variable

resource "random_integer" "rid" {
  min = 100
  max = 900
}

locals {
  suffix                           = random_integer.rid.result
  secretsmanager_secret_name_msk   = "AmazonMSK_${var.prefix}_svc_credentials-${local.suffix}"
  secretsmanager_secret_name_kafka = "kafka-secrets-${local.suffix}"
  secretsmanager_secret_name_s3    = "s3-access-credentials-${local.suffix}"
  kms_msk_alias                    = "alias/msk/${var.prefix}-kms-${local.suffix}"
  kms_eks_alias                    = "alias/eks/${var.prefix}-kms-${local.suffix}"
  kms_sm_alias                     = "alias/sm/${var.prefix}-kms-${local.suffix}"
}
