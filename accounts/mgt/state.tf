# /accounts/mgt/state.tf
# Define the remote state for the mgt account

# Uncomment the following block to enable remote state storage for the mgt account

# terraform {
#   backend "s3" {
#     bucket         = "central-logging-demo-tf-state"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     kms_key_id     = "alias/terraform-bucket-key"
#     dynamodb_table = "central-logging-demo-tf-lock-table"
#   }
# }

