# /modules/observability/cw-log-destination/providers.tf
# This is needed so we can change the provider region from the main configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
