# /accounts/workload/us-west-2/staging/terraform.tfvars
# Define the variable values for the provisioning of the workload account

aws_region                        = "us-east-1"
environment                       = "staging"
account_terraform_role_arn        = "arn:aws:iam::999999999999:role/TerraformRole"
vpc_id                            = "vpc-abcdefgh01234567890"