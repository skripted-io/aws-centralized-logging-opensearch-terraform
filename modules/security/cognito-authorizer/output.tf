# /modules/security/cognito-authorizer/output.tf
# Define outputs that can be referenced by Terraform in other configurations

output "cognito_identity_pool_id" {
  description = "The ID of the Cognito identity pool"
  value       = aws_cognito_identity_pool.cl_identity_pool.id
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito identity pool"
  value       = aws_cognito_user_pool.cl_user_pool.id
}

output "os_cognito_role_arn" {
  description = "The ARN of the OpenSearch Cognito role"
  value       = aws_iam_role.os_cognito_role.arn
}

output "cognito_auth_role_arn" {
  description = "The ARN of the Cognito auth role"
  value       = aws_iam_role.cognito_auth_role.arn
}
