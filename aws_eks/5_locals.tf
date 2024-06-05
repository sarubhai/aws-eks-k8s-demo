# Name: locals.tf
# Owner: Saurav Mitra
# Description: This terraform config will declare some local variable

resource "random_integer" "rid" {
  min = 100
  max = 900
}

locals {
  suffix        = random_integer.rid.result
  kms_eks_alias = "alias/eks/${var.prefix}-kms-${local.suffix}"
}
