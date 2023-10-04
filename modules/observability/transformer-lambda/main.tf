# /modules/observability/transformer-lambda/main.tf
# Provisions the Lambda function for the Centralized Logging service that transforms the CloudWatch Logs to OpenSearch format

# SQS DL Queue for the transformer Lambda
resource "aws_sqs_queue" "dlq" {
  name              = "${var.service_name}-tf-lambda-dlq-${var.environment}"
  kms_master_key_id = var.sqs_kms_key_arn

  tags = {
    Service     = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-tf-lambda-dlq-${var.environment}"
    Terraform   = "true"
  }
}

# Define policy document for the transformer Lambda
data "aws_iam_policy_document" "cl_transformer_policy" {
  version = "2012-10-17"

  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.dlq.arn # Replace with the actual ARN or reference
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "kinesis:DescribeStreamSummary",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:ListShards",
      "kinesis:SubscribeToShard",
      "kinesis:DescribeStream",
      "kinesis:ListStreams",
      "kinesis:DescribeStreamConsumer"
    ]
    resources = [var.kinesis_stream_arn]
    effect    = "Allow"
  }

  statement {
    actions = [
      "firehose:PutRecordBatch"
    ]
    resources = [var.kinesis_firehose_arn]
    effect    = "Allow"
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      var.kinesis_kms_key_arn
    ]
    effect = "Allow"
  }
}

# Define trust policy for the Lambda execution role
data "aws_iam_policy_document" "lambda_role_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM Role for the Transformer Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.service_name}-tf-lambda-role-${var.aws_region}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_trust_policy.json

  tags = {
    Service     = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-tf-lambda-role-${var.aws_region}-${var.environment}"
    Terraform   = "true"
  }
}

# Attach Managed Policy: Basic execution policy for the Lambda
resource "aws_iam_role_policy_attachment" "lambda_role_basic_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach Managed Policy: VPC Access execution policy for the Lambda
resource "aws_iam_role_policy_attachment" "lambda_role_vpc_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Attach custom policy for the Lambda
resource "aws_iam_role_policy" "lambda_role_cl_transformer_policy" {
  role   = aws_iam_role.lambda_execution_role.name
  policy = data.aws_iam_policy_document.cl_transformer_policy.json
}

# Security Group for the Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-tf-lambda-sg-${var.environment}"
  description = "SG for the transformer lambda"

  tags = {
    Service      = "${var.service_name}-${var.environment}"
    Servicegroup = "reports"
    Environment  = var.environment
    Region       = var.aws_region
    Name         = "${var.service_name}-tf-lambda-sg-${var.environment}"
    Terraform    = "true"
  }
}

# Allow outbound traffic to the NAT gateway
resource "aws_security_group_rule" "lambda_outbound" {
  description       = "Allows Lambda outbound access to the internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lambda_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Lambda function for the Service
resource "aws_lambda_function" "transformer_lamda_function" {
  function_name = "${var.service_name}-tf-lambda-function-${var.environment}"
  s3_bucket     = "solutions-${var.aws_region}"
  s3_key        = "centralized-logging/v4.0.5/asset08f8afc8332905f7685da70fd126471c93d02e9c88a4c310573671c4046dfcbe.zip"
  package_type  = "Zip"
  architectures = ["x86_64"]
  handler       = "asset08f8afc8332905f7685da70fd126471c93d02e9c88a4c310573671c4046dfcbe/index.handler"
  runtime       = "nodejs18.x"
  timeout       = 300

  role = aws_iam_role.lambda_execution_role.arn

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      LOG_LEVEL             = "info"
      SOLUTION_ID           = "SO0009"
      SOLUTION_VERSION      = "v4.0.4"
      UUID                  = "1234567890" # not sure what this is
      CLUSTER_SIZE          = var.os_ebs_volume_size
      DELIVERY_STREAM       = var.kinesis_firehose_name
      METRICS_ENDPOINT      = "https://metrics.awssolutionsbuilder.com/generic"
      END_METRIC            = false
      CUSTOM_SDK_USER_AGENT = "AwsSolution/SO0009/v4.0.4"
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  tags = {
    Service     = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-tf-lambda-function-${var.environment}"
    Terraform   = "true"
  }
}

# Map the Kinesis Stream to the Lambda
resource "aws_lambda_event_source_mapping" "tf_lambda" {
  function_name     = aws_lambda_function.transformer_lamda_function.function_name
  event_source_arn  = var.kinesis_stream_arn
  starting_position = "TRIM_HORIZON"
  batch_size        = 100
}
