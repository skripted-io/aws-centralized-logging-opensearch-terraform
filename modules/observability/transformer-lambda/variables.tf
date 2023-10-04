# /modules/observability/transformer-lambda/variables.tf

variable "aws_region" {
  description = "The aws region this service is provisioned in"
  type        = string
}

variable "environment" {
  description = "The environment of this service"
  type        = string
}

variable "service_name" {
  description = "The name to use for all the Lambda service resources"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC the Lambda service resources need to be deployed in"
  type        = string
}

variable "private_subnet_ids" {
  description = "The private subnet IDs the Lambda service resources need to be deployed in"
  type        = list(string)
}

variable "sqs_kms_key_arn" {
  description = "The KMS key ARN to use for encrypting the SQS queue"
  type        = string
}

variable "kinesis_kms_key_arn" {
  description = "The KMS key ARN to use for encrypting the Kinesis stream"
  type        = string
}

variable "kinesis_firehose_arn" {
  description = "The ARN of the Kinesis Firehose to use as the Lambda event source"
  type        = string
}

variable "kinesis_firehose_name" {
  description = "The name of the Kinesis Firehose to use as the Lambda event source"
  type        = string
}

variable "kinesis_stream_arn" {
  description = "The ARN of the Kinesis stream to use as the Lambda event source"
  type        = string
}

variable "os_ebs_volume_size" {
  description = "The size of the EBS volume to use for the OS cluster"
  type        = string
}
