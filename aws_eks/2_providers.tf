# Name: providers.tf
# Owner: Saurav Mitra
# Description: This terraform config will Configure Terraform Providers
# https://www.terraform.io/docs/language/providers/requirements.html

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

# Configure Terraform AWS Provider
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

# $ export AWS_ACCESS_KEY_ID="AccessKey"
# $ export AWS_SECRET_ACCESS_KEY="SecretKey"
# $ export AWS_REGION="eu-central-1"

provider "aws" {
  # Configuration options
}
