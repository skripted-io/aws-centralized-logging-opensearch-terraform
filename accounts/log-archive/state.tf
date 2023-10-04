# /accounts/log-archive/state.tf
# Define the remote state for the log-archive account

terraform {
  backend "s3" {
    bucket         = "central-logging-demo-tf-state"
    key            = "log-archive/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/terraform-bucket-key"
    dynamodb_table = "central-logging-demo-tf-lock-table"
  }
}

# Allow us to access the remote state of the mgt account
data "terraform_remote_state" "mgt" {
  backend = "s3"
  config = {
    bucket = "central-logging-demo-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
