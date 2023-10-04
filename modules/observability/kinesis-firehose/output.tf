# /modules/observability/kinesis-firehose/output.tf
# Define outputs that can be referenced by Terraform in other configurations

output "arn" {
  description = "The ARN of the Kinesis Firehose"
  value       = aws_kinesis_firehose_delivery_stream.centralized_logging_firehose.arn
}

output "name" {
  description = "The Name of the Kinesis Firehose"
  value       = aws_kinesis_firehose_delivery_stream.centralized_logging_firehose.name
}
