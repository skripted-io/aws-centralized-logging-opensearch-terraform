# /modules/observability/kinesis-firehose/main.tf
# Provisions the Kinesis Firehose service for the Centralized Logging service. It sends transformed logs to OpenSearch and S3.

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/centralized-logging/${var.service_name}-firehose/${var.environment}"
  retention_in_days = 365
}

# Create CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "firehose_os" {
  name           = "OpenSearchDelivery"
  log_group_name = aws_cloudwatch_log_group.firehose.name
}

# Create CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "firehose_s3" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose.name
}

# Create S3 bucket
resource "aws_s3_bucket" "firehose" {
  bucket = "${var.service_name}-firehose-bucket-${var.environment}"

  tags = {
    Service     = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-firehose-bucket-${var.environment}"
    Terraform   = "true"
  }
}

# Define the S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "firehose" {
  bucket = aws_s3_bucket.firehose.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Attach the S3 bucket ACL
resource "aws_s3_bucket_acl" "firehose_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.firehose]
  bucket     = aws_s3_bucket.firehose.id
  acl        = "private"
}

# Configure server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.firehose.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Define trust policy for the Lambda execution role
data "aws_iam_policy_document" "firehose_bucket_policy_document" {
  statement {
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.firehose.arn,
      "${aws_s3_bucket.firehose.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    actions = ["s3:Put*", "s3:Get*"]
    effect  = "Allow"
    resources = [
      aws_s3_bucket.firehose.arn,
      "${aws_s3_bucket.firehose.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose.arn]
    }
  }
}

# Create the S3 bucket policy
resource "aws_s3_bucket_policy" "firehose_policy" {
  bucket = aws_s3_bucket.firehose.bucket
  policy = data.aws_iam_policy_document.firehose_bucket_policy_document.json
}

# Define trust policy for the Lambda execution role
data "aws_iam_policy_document" "firehose_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM Role for the Lambda
resource "aws_iam_role" "firehose" {
  name               = "${var.service_name}-firehose-role-${var.aws_region}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.firehose_trust_policy.json

  tags = {
    Service     = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-firehose-role-${var.aws_region}-${var.environment}"
    Terraform   = "true"
  }
}

# Define the IAM policy document for Firehose
data "aws_iam_policy_document" "firehose_policy_document" {
  # S3 Permissions
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.firehose.arn}",
      "${aws_s3_bucket.firehose.arn}/*"
    ]
  }

  # KMS Permissions
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${var.aws_region}.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values   = ["${aws_s3_bucket.firehose.arn}/*"]
    }
  }

  # EC2 Permissions
  statement {
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # Elasticsearch Permissions
  statement {
    actions = [
      "es:*"
    ]
    effect = "Allow"
    resources = [
      "${var.os_cluster_arn}",
      "${var.os_cluster_arn}/*"
    ]
  }

  # CloudWatch Logs Permissions
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.firehose.arn}:*"]
  }

  # KMS Permissions for Kinesis
  statement {
    actions = [
      "kms:Decrypt"
    ]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["kinesis.${var.aws_region}.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values   = [var.kinesis_stream_arn]
    }
  }
}

# Create the IAM policy for Firehose
resource "aws_iam_role_policy" "firehose" {
  name   = "${var.service_name}-firehose-policy-${var.aws_region}-${var.environment}"
  policy = data.aws_iam_policy_document.firehose_policy_document.json
  role   = aws_iam_role.firehose.id
}

# Security Group for Firehose
resource "aws_security_group" "firehose" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-firehose-sg-${var.environment}"
  description = "SG for Firehose"

  tags = {
    Service     = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-firehose-sg-${var.environment}"
    Terraform   = "true"
  }
}

# Allow outbound traffic to the NAT gateway
resource "aws_security_group_rule" "firehose_outbound" {
  description       = "Allows Firehose outbound access to the internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.firehose.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create the Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "centralized_logging_firehose" {
  name        = "${var.service_name}-firehose-${var.environment}"
  destination = "opensearch"

  opensearch_configuration {
    domain_arn            = var.os_cluster_arn
    role_arn              = aws_iam_role.firehose.arn
    index_name            = "cwl"
    index_rotation_period = "OneDay"
    buffering_interval    = 60
    retry_duration        = 300 # Adjust based on your needs

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_os.name
    }

    s3_configuration {
      role_arn   = aws_iam_role.firehose.arn
      bucket_arn = aws_s3_bucket.firehose.arn

      cloudwatch_logging_options {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.firehose.name
        log_stream_name = aws_cloudwatch_log_stream.firehose_s3.name
      }
    }

    vpc_config {
      role_arn           = aws_iam_role.firehose.arn
      subnet_ids         = var.subnet_ids
      security_group_ids = [aws_security_group.firehose.id, var.os_cluster_sg_id]
    }
  }

  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = var.firehose_kms_key_arn
  }
}
