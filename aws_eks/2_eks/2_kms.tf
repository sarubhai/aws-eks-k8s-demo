# Name: kms_key.tf
# Owner: Saurav Mitra
# Description: This terraform config will create KMS Keys for EKS
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key

# EKS Encryption Key
resource "aws_kms_key" "kms_eks" {
  description = "${var.prefix}-kms-eks"

  tags = {
    Name  = "${var.prefix}-kms"
    Env   = var.env
    Owner = var.owner
  }
}

resource "aws_kms_alias" "kms_eks_alias" {
  name          = var.kms_eks_alias
  target_key_id = aws_kms_key.kms_eks.key_id
}
