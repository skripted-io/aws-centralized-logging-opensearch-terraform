# /modules/observability/cw-log-destination/variables.tf

variable "aws_region" {
  description = "The aws region this service is provisioned in"
  type        = string
}

variable "environment" {
  description = "The environment of this service"
  type        = string
}

variable "service_name" {
  description = "The name to use for all the service resources"
  type        = string
}

variable "producer_account_ids" {
  description = "The account ids of the accounts that will be sending logs to the Kinesis stream"
  type        = list(string)
}

variable "kinesis_stream_arn" {
  description = "The ARN of the Kinesis stream to use"
  type        = string
}
