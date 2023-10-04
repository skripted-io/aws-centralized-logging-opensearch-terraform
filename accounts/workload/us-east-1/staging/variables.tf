# /accounts/workload/us-west-2/staging/variables.tf
# Define the variables that are available when provisining the workload account

variable "account_terraform_role_arn" {
  description = "The role and permissions used by Terraform to be able to provision resources in this account"
  type        = string
}

variable "aws_region" {
  description = "The aws region for this workload"
  type        = string
}

variable "environment" {
  description = "The environment of this workload"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID for this workload"
  type        = string
}


