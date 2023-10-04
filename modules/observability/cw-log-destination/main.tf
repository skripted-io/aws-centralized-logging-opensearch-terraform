# /modules/observability/cw-log-destination/main.tf
# Configures a CloudWatch Log Destination to send logs to a Kinesis Stream

# Account specific data sources
data "aws_caller_identity" "current" {}

# Define policy document for CloudWatch role
data "aws_iam_policy_document" "cloudwatch_role_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        for account_id in var.producer_account_ids : format("arn:aws:logs:%s:%s:*", var.aws_region, account_id)
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM Role to allow CloudWatch to write to the Kinesis stream
resource "aws_iam_role" "cloudwatch_role" {
  name               = "${var.service_name}-cw-role-${var.aws_region}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_role_trust_policy.json

  tags = {
    Service     = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-cw-role-${var.aws_region}-${var.environment}"
    Terraform   = "true"
  }
}

# Define Kinesis policy document for CloudWatch role
data "aws_iam_policy_document" "kinesis_policy" {
  statement {
    actions = [
      "kinesis:PutRecord"
    ]
    resources = [var.kinesis_stream_arn]
  }
}

# Attach Kinesis access policy to the CloudWatch Role
resource "aws_iam_role_policy" "cloudwatch_role_kinesis_policy" {
  name   = "${var.service_name}-cw-kinesis-policy-${var.aws_region}-${var.environment}"
  role   = aws_iam_role.cloudwatch_role.id
  policy = data.aws_iam_policy_document.kinesis_policy.json
}

# Define KMS policy document for CloudWatch role
data "aws_iam_policy_document" "kms_policy" {
  statement {
    actions = [
      "kms:Decrypt", "kms:DescribeKey", "kms:Encrypt", "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

# Attach KMS access policy to the CloudWatch Role
resource "aws_iam_role_policy" "cloudwatch_role_kms_policy" {
  name   = "${var.service_name}-cw-kms-policy-${var.aws_region}-${var.environment}"
  role   = aws_iam_role.cloudwatch_role.id
  policy = data.aws_iam_policy_document.kms_policy.json
}

# Create CloudWatch Log Destination
resource "aws_cloudwatch_log_destination" "log_destination" {
  name       = "${var.service_name}-cw-log-destination-${var.environment}"
  role_arn   = aws_iam_role.cloudwatch_role.arn
  target_arn = var.kinesis_stream_arn
}

# Define policy document for CloudWatch Log Destination
data "aws_iam_policy_document" "destination_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.producer_account_ids
    }

    actions = [
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      aws_cloudwatch_log_destination.log_destination.arn,
    ]
  }
}

# Attach policy to CloudWatch Log Destination
resource "aws_cloudwatch_log_destination_policy" "destination_policy" {
  destination_name = aws_cloudwatch_log_destination.log_destination.name
  access_policy    = data.aws_iam_policy_document.destination_policy.json
}

