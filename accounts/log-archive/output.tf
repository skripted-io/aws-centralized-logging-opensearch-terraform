# /accounts/log-archive/output.tf
# Define outputs that can be referenced by Terraform in other configurations

output "cw_log_destination_us_west_2_arn" {
  description = "The ARN of the CloudWatch Log Destination"
  value       = module.cw_log_destination_us_west_2.arn
}

output "cw_log_destination_us_east_1_arn" {
  description = "The ARN of the CloudWatch Log Destination"
  value       = module.cw_log_destination_us_east_1.arn
}
