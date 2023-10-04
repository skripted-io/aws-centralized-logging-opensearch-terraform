# /accounts/log-archive/providers.tf
# Define that we will be using the AWS provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Specify that we want to use the Terraform role of the log-archive account
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.account_terraform_role_arn
  }
}

# Since the default region is us-east-1, set up a dedicated us-west-2 alias so we can provision a CW log destination there
provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
  assume_role {
    role_arn = var.account_terraform_role_arn
  }
}
