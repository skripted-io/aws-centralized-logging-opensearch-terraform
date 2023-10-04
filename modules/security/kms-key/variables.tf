# /modules/security/kms-key/variables.tf

variable "aws_region" {
  description = "The aws region this KMS key is in"
  type        = string
}

variable "environment" {
  description = "The environment this KMS key is for"
  type        = string
}

variable "service_name" {
  description = "The name of the service this KMS key is for"
  type        = string
}

variable "member_account_ids" {
  description = "A list of AWS account IDs of accounts that needs access to this KMS key resource"
  type        = list(string)
}
