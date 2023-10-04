# /modules/security/kms-key/main.tf
# Define output that can be referenced by Terraform in other configurations

output "kms_key_arn" {
  description = "The ARN of the KMS key created"
  value       = aws_kms_key.kms_key.arn
}
