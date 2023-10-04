# /accounts/mgt/main.tf
# Provisions the Terraform state resources, KMS keys, and Secrets Manager resources in the management account

# Account specific data sources
data "aws_caller_identity" "current" {}

# Provision a KMS key to allow for the encryption of the Terraform state bucket
module "terraform_s3_kms_key" {
  source             = "../../modules/security/kms-key"
  aws_region         = var.aws_region
  environment        = var.environment
  service_name       = "terraform-bucket-${var.environment}"
  member_account_ids = []
}

# S3 bucket with all of the appropriate security configurations
resource "aws_s3_bucket" "terraform-state" {
  bucket = "${var.org_name}-tf-state"
}

# Configure the S3 bucket to encrypt all objects by default
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-encryption" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.terraform_s3_kms_key.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "terraform-state-ownership-controls" {
  bucket = aws_s3_bucket.terraform-state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket ACL
resource "aws_s3_bucket_acl" "terraform-state-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.terraform-state-ownership-controls]

  bucket = aws_s3_bucket.terraform-state.id
  acl    = "private"
}

# Enable versioning on the bucket for DR purposes
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable "block public access" on the bucket
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.terraform-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Provision a DynamoDB table, to allow for the locking of the state file
resource "aws_dynamodb_table" "terraform-state" {
  name           = "${var.org_name}-tf-lock-table"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Provision a KMS key for Secrets Manager resources in this account
module "secrets_manager_kms_key" {
  source             = "../../modules/security/kms-key"
  aws_region         = var.aws_region
  environment        = var.environment
  service_name       = "secrets-manager-${var.environment}"
  member_account_ids = [data.aws_caller_identity.current.account_id, var.log_archive_account_id, var.workload_staging_account_id, var.workload_prod_account_id] // mgt, log-archive, workloads
}

# Provision a KMS key for CloudWatch resources, accessible by log-archive account and workload accounts
module "log_archive_cloudwatch_kms_key" {
  source             = "../../modules/security/kms-key"
  aws_region         = var.aws_region
  environment        = var.environment
  service_name       = "log-archive-cloudwatch-${var.environment}"
  member_account_ids = [var.log_archive_account_id, var.workload_staging_account_id, var.workload_prod_account_id] // log-archive, workloads
}

# Provision a KMS key for OpenSearch resources, accessible by log-archive account
module "log_archive_os_kms_key" {
  source             = "../../modules/security/kms-key"
  aws_region         = var.aws_region
  environment        = var.environment
  service_name       = "log-archive-opensearch-${var.environment}"
  member_account_ids = [var.log_archive_account_id] // log-archive
}

# Provision a KMS key for Kinesis resources, accessible by log-archive account
module "log_archive_kinesis_kms_key" {
  source             = "../../modules/security/kms-key"
  aws_region         = var.aws_region
  environment        = var.environment
  service_name       = "log-archive-kinesis-${var.environment}"
  member_account_ids = [var.log_archive_account_id] // log-archive
}

# Provision a KMS key for SQS, accessible by log-archive
module "log_archive_sqs_kms_key" {
  source             = "../../modules/security/kms-key"
  aws_region         = var.aws_region
  environment        = var.environment
  service_name       = "log-archive-sqs-${var.environment}"
  member_account_ids = [var.log_archive_account_id] // log-archive
}

# Provision a KMS key for S3, accessible by log-archive
module "log_archive_s3_kms_key" {
  source             = "../../modules/security/kms-key"
  aws_region         = var.aws_region
  environment        = var.environment
  service_name       = "log-archive-s3-${var.environment}"
  member_account_ids = [var.log_archive_account_id] // log-archive
}

# Generate a random username for the "Centralized Logging" OpenSearch service (if not using Cognito)
resource "random_string" "centralized_logging_os_master_user_name" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

# Generate a random password for the "Centralized Logging" OpenSearch service (if not using Cognito)
resource "random_password" "centralized_logging_os_master_user_password" {
  length  = 16
  special = true
}

# Provision a Secrets Manager resource for the "Centralized Logging" OpenSearch service (if not using Cognito)
module "centralized_logging_os_secrets_manager" {
  source              = "../../modules/security/secrets-manager"
  aws_region          = var.aws_region
  environment         = var.environment
  service_name        = "centralized-logging-os"
  workload_account_id = var.log_archive_account_id
  kms_key_arn         = module.secrets_manager_kms_key.kms_key_arn

  secret_string = {
    master_user_name     = sensitive(random_string.centralized_logging_os_master_user_name.result)
    master_user_password = sensitive(random_password.centralized_logging_os_master_user_password.result)
  }
}
