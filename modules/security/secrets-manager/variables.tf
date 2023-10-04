# /modules/security/secrets-manager/variables.tf

variable "aws_region" {
  description = "The aws region this Secrets Manager resource is in"
  type        = string
}

variable "environment" {
  description = "The environment this Secrets Manager resource is for"
  type        = string
}

variable "service_name" {
  description = "The name of the service this Secrets Manager resource is for"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt this Secrets Manager resource"
  type        = string
}

variable "workload_account_id" {
  description = "The id of the AWS account that needs access to this Secrets Manager resource"
  type        = string
}

variable "secret_string" {
  description = "A key/value map of secrets to be stored in this Secrets Manager resource"
  type        = map(string)
  default     = {}
}
