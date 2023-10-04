# /accounts/log-archive/variables.tf
# Define the variables that are available when provisining the log-archive account

variable "aws_region" {
  description = "The aws region"
  type        = string
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "account_terraform_role_arn" {
  description = "The role and permissions used by Terraform to be able to provision resources in this account"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_public_subnet_ids" {
  description = "The ids of the public subnets"
  type        = list(string)
}

variable "vpc_private_subnet_ids" {
  description = "The ids of the private subnets"
  type        = list(string)
}

variable "vpc_az_count" {
  description = "The number of availability zones to deploy the OpenSearch cluster in"
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

variable "centralized_logging_os_master_nodes_type" {
  description = "The instance type to use for the Centralized Logging OpenSearch master nodes"
  type        = string
}

variable "centralized_logging_os_data_nodes_type" {
  description = "The instance type to use for the Centralized Logging OpenSearch data nodes"
  type        = string
}

variable "centralized_logging_os_master_nodes_count" {
  description = "The number of master nodes to provision in the Centralized Logging OpenSearch cluster"
  type        = string
}

variable "centralized_logging_os_data_nodes_count" {
  description = "The number of data nodes to provision in the Centralized Logging OpenSearch cluster"
  type        = string
}

variable "centralized_logging_os_ebs_volume_size" {
  description = "The size of the EBS volume to attach to each node in the Centralized Logging OpenSearch cluster"
  type        = string
}

variable "jumpbox_key_name" {
  description = "The name of the key pair to use for the Jumpbox"
  type        = string
}

variable "jumpbox_ami" {
  description = "The AMI ID to use for the Jumpbox"
  type        = string
}

variable "client_ip" {
  description = "The IP address to allow RDP access from"
  type        = string
}
