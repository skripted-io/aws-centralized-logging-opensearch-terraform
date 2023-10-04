# Creates the IAM role for Terraform to assume.
# Before running this script, make sure to replace <Mgt-Account-ID> with the account ID of the mgt account
# Run it while your AWS CLI is authenticated to the workload and/or log-archive account
aws iam create-role --role-name TerraformRole --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::<Mgt-Account-ID>:root"},"Action":"sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name TerraformRole --policy-arn arn:aws:iam::aws:policy/AdministratorAccess