# /accounts/log-archive/terraform.tfvars
# Define the variable values for the provisioning of the log-archive account

aws_region                                    = "us-east-1"    # Set the AWS region to deploy to
environment                                   = "prod"         # Set to the environment (only used for tagging)
account_terraform_role_arn                    = "arn:aws:iam::999999999999:role/TerraformRole" # Replace with the ARN of your Terraform role created in the log-archive account
workload_staging_account_id                   = "999999999999" # Replace with the account ID of your staging account
workload_prod_account_id                      = "999999999999" # Replace with the account ID of your production account

# VPC
vpc_id                                        = "vpc-abcdefgh01234567890" # Replace with the ID of your VPC in the log-archive account
vpc_public_subnet_ids                         = ["subnet-abcdefgh01234567890","subnet-abcdefgh01234567890"] # Replace with the public subnets of your VPC in the log-archive account
vpc_private_subnet_ids                        = ["subnet-abcdefgh01234567890","subnet-abcdefgh01234567890"] # Replace with the private subnets of your VPC in the log-archive account
vpc_az_count                                  = 2 # Update to the number of AZs in your VPC in the log-archive account

# Centralized Logging OS
centralized_logging_os_master_nodes_type      = "t3.small.search"
centralized_logging_os_master_nodes_count     = 3
centralized_logging_os_data_nodes_type        = "t3.small.search"
centralized_logging_os_data_nodes_count       = 2 # Must be equal to the number of availability zones in the log-archive account
centralized_logging_os_ebs_volume_size        = 100

# Jumpbox
jumpbox_ami                                   = "ami-024c22d5868672534" # Replace with the correct one for your region - Microsoft Windows Server 2019 with Desktop Experience Locale English AMI provided by Amazon
jumpbox_key_name                              = "ec2-keypair" # Replace with the name of your keypair in the log-archive account
client_ip                                     = "0.0.0.0" # Replace with your home, office, or VPN IP address
