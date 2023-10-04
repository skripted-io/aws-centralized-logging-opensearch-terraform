# /modules/workloads/vpc-flow-log/main.tf
# Provision a VPC flow log in a VPC

# Create a VPC flow log
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.log_group.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = {
    Service     = var.service_name
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.environment}-vpc-flow-log"
    Terraform   = "true"
  }
}

# Create a CloudWatch log group for the VPC flow log
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/vpc-flow-logs/${var.environment}"
  retention_in_days = 3

  tags = {
    Service     = var.service_name
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.environment}-vpc-flow-log"
    Terraform   = "true"
  }
}

# Create the trust policy for the VPC flow log role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create the IAM role for the VPC flow log
resource "aws_iam_role" "flow_log_role" {
  name               = "${var.environment}-flow-logs-role-${var.aws_region}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Service     = var.service_name
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.environment}-${var.aws_region}-vpc-flow-log-role"
    Terraform   = "true"
  }
}

# Define the IAM policy for the VPC flow log role
data "aws_iam_policy_document" "flow_log_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

# Create the IAM policy for the VPC flow log role
resource "aws_iam_role_policy" "flow_log_role_policy" {
  name   = "${var.environment}-flow-logs-role-policy-${var.aws_region}"
  role   = aws_iam_role.flow_log_role.id
  policy = data.aws_iam_policy_document.flow_log_role_policy_document.json
}
