# /modules/security/secrets-manager/main.tf
# Provision a Secrets Manager resource and Secret string for the Service (when not using Cognito authentication)

data "aws_caller_identity" "current" {}

# Create a random suffix for the alias
resource "random_id" "random_alias_suffix" {
  byte_length = 8
}

# Provision a Secrets Manager resource for the Service
resource "aws_secretsmanager_secret" "secrets_manager" {
  name        = "${var.service_name}-${var.environment}-secrets-${random_id.random_alias_suffix.hex}"
  description = "Secrets manager resource for ${var.service_name} service of the ${var.environment} environment"
  kms_key_id  = var.kms_key_arn

  tags = {
    Service     = "${var.service_name}"
    Region      = var.aws_region
    Environment = var.environment
    Name        = "${var.service_name}-secrets"
    Terraform   = "true"
  }
}

# Defines the Secrets Manager Secret string
resource "aws_secretsmanager_secret_version" "secrets_string" {
  secret_id     = aws_secretsmanager_secret.secrets_manager.id
  secret_string = jsonencode(var.secret_string)
}

# Policy to allow access from another account
resource "aws_secretsmanager_secret_policy" "secrets_manager_policy" {
  secret_arn = aws_secretsmanager_secret.secrets_manager.arn

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::${var.workload_account_id}:root" 
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "${aws_secretsmanager_secret.secrets_manager.arn}"
  } ]
}
EOF
}
