# /accounts/mgt/terraform.tfvars
# Define the variable values for the provisioning of the mgt account

aws_region                                    = "us-east-1"    # Set the AWS region to deploy to
environment                                   = "prod"         # Set to the environment (only used for tagging)
log_archive_account_id                        = "999999999999" # Replace with the account ID of your log-archive account
workload_staging_account_id                   = "999999999999" # Replace with the account ID of your staging account
workload_prod_account_id                      = "999999999999" # Replace with the account ID of your production account
