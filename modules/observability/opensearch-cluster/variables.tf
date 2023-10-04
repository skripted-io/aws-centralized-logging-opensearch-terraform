# /modules/observability/opensearch-cluster/variables.tf

variable "aws_region" {
  description = "The aws region this OpenSearch Cluster is provisioned in"
  type        = string
}

variable "environment" {
  description = "The environment of this OpenSearch Cluster"
  type        = string
}

variable "service_name" {
  description = "The name to use for all the OpenSearch Cluster resources"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC the OpenSearch Cluster need to be deployed in"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of private subnets the OpenSearch Cluster need to be deployed in"
  type        = list(string)
}

variable "az_count" {
  description = "The number of availability zones to deploy the OpenSearch Cluster in"
  type        = string
}

variable "opensearch_domain_name" {
  description = "The domain name to use for the OpenSearch Cluster"
  type        = string
}

variable "secrets_manager_arn" {
  description = "The ARN of the secrets manager resource that the OpenSearch Cluster will use to retrieve secrets from"
  type        = string
}

variable "vpn_sg_ids" {
  description = "The IDs of the VPN Security Groups that need access to this the OpenSearch Cluster"
  type        = list(string)
}

variable "inbound_cidr_blocks" {
  description = "The IDs of the Security Groups that need access to this the OpenSearch Cluster"
  type        = list(string)
}

variable "aws_client_account_id" {
  description = "The ID of an AWS account that needs access to this cluster"
  type        = string
}

variable "engine_version" {
  description = "The version of OpenSearch to use"
  type        = string
  default     = "Elasticsearch_5.6"
}

variable "master_nodes_type" {
  description = "The instance type to use for the OpenSearch master nodes"
  type        = string
}

variable "data_nodes_type" {
  description = "The instance type to use for the OpenSearch data nodes"
  type        = string
}

variable "master_nodes_count" {
  description = "The number of master nodes to provision"
  type        = string
}

variable "data_nodes_count" {
  description = "The number of data nodes to provision"
  type        = string
}

variable "ebs_volume_size" {
  description = "The size of the EBS volume to attach to each node"
  type        = string
}

variable "advanced_security_options_enabled" {
  description = "Whether to enable advanced security options"
  type        = string
  default     = false
}

variable "node_to_node_encryption_enabled" {
  description = "Whether to enable node to node encryption"
  type        = string
  default     = false
}

variable "encrypt_at_rest" {
  description = "Whether to enable encryption at rest"
  type        = string
  default     = false
}

variable "enforce_https" {
  description = "Whether to enforce HTTPS"
  type        = string
  default     = false
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for encryption at rest"
  type        = string
  default     = ""
}

variable "tls_security_policy" {
  description = "The ARN of the KMS key to use for encryption at rest"
  type        = string
  default     = "Policy-Min-TLS-1-0-2019-07"
}

variable "user_pool_id" {
  description = "The ID of the Cognito user pool"
  type        = string
}

variable "identity_pool_id" {
  description = "The ID of the Cognito identity pool"
  type        = string
}

variable "os_cognito_role_arn" {
  description = "The ARN of the OpenSearch Cognito role"
  type        = string
}

variable "master_user_arn" {
  description = "The ARN of the master user"
  type        = string
}
