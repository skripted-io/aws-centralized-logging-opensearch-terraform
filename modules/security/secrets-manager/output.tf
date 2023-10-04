# /modules/security/secrets-manager/main.tf
# Define output that can be referenced by Terraform in other configurations

output "secrets_manager_arn" {
  description = "The ARN of this Secrets Manager resource"
  value       = aws_secretsmanager_secret.secrets_manager.arn
}
