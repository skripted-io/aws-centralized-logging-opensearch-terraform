# /accounts/log-archive/main.tf
# Build the centralized logging solution in the log-archive account

# Get access to account specific data sources
data "aws_caller_identity" "current" {}

# Provision a Cognito User Pool and a Cognito Identity Pool
module "cognito_authorizer" {
  source                 = "../../modules/security/cognito-authorizer"
  aws_region             = var.aws_region
  environment            = var.environment
  service_name           = "centralized-logging"
  opensearch_domain_name = "centralized-logging-${var.environment}"
}

# Provision the OpenSearch cluster to collect the data and provide a Kibana dashboard
module "centralized_logging_os_cluster" {
  source                            = "../../modules/observability/opensearch-cluster"
  aws_region                        = var.aws_region
  environment                       = var.environment
  service_name                      = "centralized-logging-${var.environment}"
  engine_version                    = "OpenSearch_2.7"
  advanced_security_options_enabled = true
  node_to_node_encryption_enabled   = true
  encrypt_at_rest                   = true
  enforce_https                     = true
  tls_security_policy               = "Policy-Min-TLS-1-2-2019-07"
  kms_key_arn                       = data.terraform_remote_state.mgt.outputs.log_archive_os_kms_key_arn
  vpc_id                            = var.vpc_id
  private_subnet_ids                = var.vpc_private_subnet_ids
  az_count                          = var.vpc_az_count
  secrets_manager_arn               = data.terraform_remote_state.mgt.outputs.centralized_logging_os_secrets_manager_arn
  vpn_sg_ids                        = []
  inbound_cidr_blocks               = []
  aws_client_account_id             = data.aws_caller_identity.current.account_id
  opensearch_domain_name            = "centralized-logging-${var.environment}"
  master_nodes_type                 = var.centralized_logging_os_master_nodes_type
  master_nodes_count                = var.centralized_logging_os_master_nodes_count
  data_nodes_type                   = var.centralized_logging_os_data_nodes_type
  data_nodes_count                  = var.centralized_logging_os_data_nodes_count
  ebs_volume_size                   = var.centralized_logging_os_ebs_volume_size
  user_pool_id                      = module.cognito_authorizer.cognito_user_pool_id
  identity_pool_id                  = module.cognito_authorizer.cognito_identity_pool_id
  os_cognito_role_arn               = module.cognito_authorizer.os_cognito_role_arn
  master_user_arn                   = module.cognito_authorizer.cognito_auth_role_arn
}

# Provision a Jumpbox to allowing connecting to the private OpenSearch cluster via RDP
module "jumpbox" {
  source               = "../../modules/security/jumpbox"
  aws_region           = var.aws_region
  environment          = var.environment
  service_name         = "centralized-logging"
  vpc_id               = var.vpc_id
  vpc_public_subnet_id = var.vpc_public_subnet_ids[0]
  ami_id               = var.jumpbox_ami
  key_name             = var.jumpbox_key_name
  client_ip            = var.client_ip
  sg_groups            = [module.centralized_logging_os_cluster.client_access_sg_id]
}

# Provision a Kinesis Stream to ingest the data from the spoke account
module "kinesis_stream" {
  source       = "../../modules/observability/kinesis-stream"
  aws_region   = var.aws_region
  environment  = var.environment
  service_name = "centralized-logging"
  kms_key_arn  = data.terraform_remote_state.mgt.outputs.log_archive_kinesis_kms_key_arn
}

# Provision a Kinesis Firehose to send the data to the OpenSearch cluster
module "kinesis_firehose" {
  source               = "../../modules/observability/kinesis-firehose"
  aws_region           = var.aws_region
  environment          = var.environment
  service_name         = "centralized-logging"
  firehose_kms_key_arn = data.terraform_remote_state.mgt.outputs.log_archive_kinesis_kms_key_arn
  s3_kms_key_arn       = data.terraform_remote_state.mgt.outputs.log_archive_s3_kms_key_arn
  os_cluster_arn       = module.centralized_logging_os_cluster.arn
  os_cluster_sg_id     = module.centralized_logging_os_cluster.client_access_sg_id
  vpc_id               = var.vpc_id
  subnet_ids           = var.vpc_private_subnet_ids
  kinesis_stream_arn   = module.kinesis_stream.arn
}

# Provision a Transformer Lambda function to convert the CloudWatch Logs to JSON
module "transformer_lamda" {
  source                = "../../modules/observability/transformer-lambda"
  aws_region            = var.aws_region
  environment           = var.environment
  service_name          = "centralized-logging"
  sqs_kms_key_arn       = data.terraform_remote_state.mgt.outputs.log_archive_sqs_kms_key_arn
  kinesis_kms_key_arn   = data.terraform_remote_state.mgt.outputs.log_archive_kinesis_kms_key_arn
  kinesis_firehose_arn  = module.kinesis_firehose.arn
  kinesis_firehose_name = module.kinesis_firehose.name
  kinesis_stream_arn    = module.kinesis_stream.arn
  vpc_id                = var.vpc_id
  private_subnet_ids    = var.vpc_private_subnet_ids
  os_ebs_volume_size    = var.centralized_logging_os_ebs_volume_size
}

# Provision a CloudWatch Log Destination in us-east-1 for the spoke accounts to subscribe to
module "cw_log_destination_us_east_1" {
  source               = "../../modules/observability/cw-log-destination"
  aws_region           = "us-east-1"
  environment          = var.environment
  service_name         = "centralized-logging"
  producer_account_ids = [data.aws_caller_identity.current.account_id, var.workload_staging_account_id, var.workload_prod_account_id]
  kinesis_stream_arn   = module.kinesis_stream.arn
}

# Provision a CloudWatch Log Destination in us-west-2 for the spoke accounts to subscribe to
module "cw_log_destination_us_west_2" {
  source               = "../../modules/observability/cw-log-destination"
  aws_region           = "us-west-2"
  environment          = var.environment
  service_name         = "centralized-logging"
  producer_account_ids = [data.aws_caller_identity.current.account_id, var.workload_staging_account_id, var.workload_prod_account_id]
  kinesis_stream_arn   = module.kinesis_stream.arn
  providers = {
    aws = aws.us_west_2
  }
}
