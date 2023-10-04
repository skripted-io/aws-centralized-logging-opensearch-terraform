# /modules/workloads/vpc-flow-log/variables.tf
# Input variable definitions

variable "aws_region" {
  description = "The aws region the flow log is provisioned in"
  type        = string
}

variable "service_name" {
  description = "The name of the service these flow logs are for"
  type        = string
}

variable "environment" {
  description = "The environment of the vpc these flow logs are for"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC the flow logs are for"
  type        = string
}
