# /accounts/workload/us-west-2/staging/state.tf
# Define the remote state for the workload account

terraform {
  backend "s3" {
    bucket         = "central-logging-demo-tf-state"
    key            = "workload/us-east-1/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/terraform-bucket-key"
    dynamodb_table = "central-logging-demo-tf-lock-table"
  }
}

# Allow us to access the remote state of the log-archive account
data "terraform_remote_state" "log_archive" {
  backend = "s3"

  config = {
    bucket = "central-logging-demo-tf-state"
    key    = "log-archive/terraform.tfstate"
    region = "us-east-1"
  }
}
