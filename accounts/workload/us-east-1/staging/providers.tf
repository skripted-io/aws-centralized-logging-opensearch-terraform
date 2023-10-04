# /accounts/workload/us-west-2/staging/providers.tf
# Define that we will be using the AWS provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Specify that we want to use the Terraform role of the staging account
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.account_terraform_role_arn
  }
}
