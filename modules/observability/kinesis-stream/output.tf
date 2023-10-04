# /modules/observability/kinesis-stream/output.tf
# Define output that can be referenced by Terraform in other configurations

output "arn" {
  description = "The ARN of the Kinesis stream"
  value       = aws_kinesis_stream.stream.arn
}
