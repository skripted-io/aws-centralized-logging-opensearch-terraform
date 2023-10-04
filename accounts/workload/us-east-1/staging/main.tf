# /accounts/workload/us-east-1/staging/main.tf
# Provisions a flow log in the workload account and subscribe the log to the CW log destination in the log-archive account

module "vpc_flow_logs" {
  source       = "../../../../modules/network/vpc-flow-log"
  aws_region   = var.aws_region
  environment  = var.environment
  service_name = "vpc-flow-logs"
  vpc_id       = var.vpc_id
}

resource "aws_cloudwatch_log_subscription_filter" "vpc_flow_log" {
  depends_on      = [module.vpc_flow_logs]
  name            = "RecipientStream"
  log_group_name  = "/vpc-flow-logs/${var.environment}"
  filter_pattern  = ""
  destination_arn = data.terraform_remote_state.log_archive.outputs.cw_log_destination_us_east_1_arn
}
