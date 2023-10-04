# /modules/security/cognito/variables.tf

variable "aws_region" {
  description = "The aws region these Cognito resources are in"
  type        = string
}

variable "environment" {
  description = "The environment these Cognito resources are for"
  type        = string
}

variable "service_name" {
  description = "The name of the service thse Cognito resources are for"
  type        = string
}

variable "opensearch_domain_name" {
  description = "The domain name to use for all the OpenSearch cluster"
  type        = string
}
