# Name: backends.tf
# Owner: Saurav Mitra
# Description: This terraform config will Configure Terraform Backend
# https://www.terraform.io/docs/language/settings/backends/index.html

terraform {
  backend "s3" {
    bucket         = "aws-eks-k8s-demo-tf-state"
    key            = "k8s-terraform.tfstate"
    acl            = "private"
    encrypt        = "true"
    dynamodb_table = "aws-eks-k8s-demo-k8s-tf-state-lock"
  }
}
