# /accounts/workload/us-west-2/prod/terraform.tfvars
# Define the variable values for the provisioning of the workload account

aws_region                        = "us-west-2"
environment                       = "prod"
account_terraform_role_arn        = "arn:aws:iam::999999999999:role/TerraformRole"
vpc_id                            = "vpc-abcdefgh01234567890"