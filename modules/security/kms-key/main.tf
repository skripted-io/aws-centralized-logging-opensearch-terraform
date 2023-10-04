# /modules/security/kms-key/main.tf
# Provisions a KMS key including an alias and a policy to allow access to the key

# account specific data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# create the KMS key
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for ${var.service_name} in the ${var.environment} environment"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "${var.service_name}-${var.environment}-key-policy",
    Statement = concat([
      {
        Sid    = "Allow administration of the key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = ["kms:*"],
        Resource = "*"
      }],
      [for account in var.member_account_ids : {
        Sid    = "Allow use of the key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${account}:root"
        },
        Action   = ["kms:Decrypt", "kms:DescribeKey", "kms:Encrypt", "kms:GenerateDataKey*", "kms:ReEncrypt*", "kms:CreateGrant"]
        Resource = "*"
      }]
    )
  })

  tags = {
    Service     = var.service_name
    Region      = var.aws_region
    Environment = var.environment
    Name        = "${var.service_name}-kms-key"
    Terraform   = "true"
  }
}

# Create a random suffix for the alias
resource "random_id" "random_alias_suffix" {
  byte_length = 8
}

# Add an alias to the KMS key
resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.service_name}-kms-key-${random_id.random_alias_suffix.hex}"
  target_key_id = aws_kms_key.kms_key.key_id
}
