# /modules/observability/kinesis-stream/main.tf
# Provisions a Kinesis stream to ingest logs from the workload accounts

# Provisions the Kinesis stream
resource "aws_kinesis_stream" "stream" {
  name = "${var.service_name}-kinesis-stream-${var.environment}"

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  encryption_type = "KMS"
  kms_key_id      = var.kms_key_arn

  tags = {
    Service     = "${var.service_name}-kinesis-stream-${var.environment}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-kinesis-stream-${var.environment}"
    Terraform   = "true"
  }
}


