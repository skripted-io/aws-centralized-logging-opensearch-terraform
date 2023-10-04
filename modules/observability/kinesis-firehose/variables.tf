# /modules/observability/kinesis-firehose/variables.tf

variable "aws_region" {
  description = "The aws region this Kinesis Firehose is in"
  type        = string
}

variable "environment" {
  description = "The environment this Kinesis Firehose is for"
  type        = string
}

variable "service_name" {
  description = "The name of the service this Kinesis Firehose is for"
  type        = string
}

variable "firehose_kms_key_arn" {
  description = "The arn of the KMS key of the Kinesis Firehose"
  type        = string
}

variable "kinesis_stream_arn" {
  description = "The arn of the Kinesis stream this Firehose will will need to forward data from"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "The arn of the KMS key for S3"
  type        = string
}

variable "os_cluster_arn" {
  description = "The arn of the OS cluster this Firehose will send data to"
  type        = string
}

variable "os_cluster_sg_id" {
  description = "The security group id of the OS cluster this Firehose will send data to"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet ids for the VPC this Firehose will be in"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC id this Firehose will be in"
  type        = string
}



