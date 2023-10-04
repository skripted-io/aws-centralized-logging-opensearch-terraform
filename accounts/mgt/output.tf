# /accounts/mgt/output.tf
# Define outputs that can be referenced by Terraform in other configurations

output "log_archive_cloudwatch_kms_key_arn" {
  description = "The ARN of KMS key used to encrypt CloudWatch Log data in log-archive"
  value       = module.log_archive_cloudwatch_kms_key.kms_key_arn
}

output "log_archive_os_kms_key_arn" {
  description = "The ARN of KMS key used to encrypt OpenSearch data in log-archive"
  value       = module.log_archive_os_kms_key.kms_key_arn
}

output "log_archive_kinesis_kms_key_arn" {
  description = "The ARN of KMS key used to encrypt Kinesis data in log-archive"
  value       = module.log_archive_kinesis_kms_key.kms_key_arn
}

output "log_archive_sqs_kms_key_arn" {
  description = "The ARN of KMS key used to encrypt SQS messages in log-archive"
  value       = module.log_archive_sqs_kms_key.kms_key_arn
}

output "log_archive_s3_kms_key_arn" {
  description = "The ARN of KMS key used to encrypt s3 in log-archive"
  value       = module.log_archive_s3_kms_key.kms_key_arn
}

output "centralized_logging_os_secrets_manager_arn" {
  description = "The ARN of the Secrets Manager resource for Centralized Logging OpenSearch"
  value       = module.centralized_logging_os_secrets_manager.secrets_manager_arn
}
