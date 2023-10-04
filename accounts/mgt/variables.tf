# /accounts/mgt/variables.tf
# Define the variables that are available when provisining the mgt account

variable "aws_region" {
  description = "The aws region"
  type        = string
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "org_name" {
  description = "The name of the organization"
  type        = string
  default     = "central-logging-demo"
}

variable "log_archive_account_id" {
  description = "The ID of the log archive account"
  type        = string
}

variable "workload_staging_account_id" {
  description = "The ID of the workload staging account"
  type        = string
}

variable "workload_prod_account_id" {
  description = "The ID of the workload production account"
  type        = string
}

