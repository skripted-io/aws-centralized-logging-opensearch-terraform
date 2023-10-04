# /modules/observability/kinesis-stream/variables.tf

variable "aws_region" {
  description = "The aws region this Kinesis Stream is in"
  type        = string
}

variable "environment" {
  description = "The environment this Kinesis Stream is for"
  type        = string
}

variable "service_name" {
  description = "The name of the service this Kinesis Stream is for"
  type        = string
}

variable "kms_key_arn" {
  description = "The arn of the KMS key of the Kinesis Stream"
  type        = string
}
