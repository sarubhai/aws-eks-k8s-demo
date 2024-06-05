# Name: data.tf
# Owner: Saurav Mitra
# Description: This terraform config declares data blocks

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}
