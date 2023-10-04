# /modules/observability/cw-log-destination/output.tf
# Define outputs that can be referenced by Terraform in other configurations

output "arn" {
  description = "The ARN of the CloudWatch Log Destination"
  value       = aws_cloudwatch_log_destination.log_destination.arn
}
