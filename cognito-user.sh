## Creates a user in the Cognito user pool

# 1. First get the id of the user pool that was created by Terraform
aws cognito-idp list-user-pools --max-results 10 | jq -r '.UserPools[] | select(.Name=="cl-user-pool-prod") | .Id'

# 2. Then create a user in the user pool. Replace <YourUserPoolId> with the id of the user pool, <UserEmail> with the email address of the user 
# and <TempPassword> with the temporary password that you want to assign to the user.

aws cognito-idp admin-create-user \
  --user-pool-id <YourUserPoolId> \
  --username <UserEmail> \
  --user-attributes Name=email,Value=<UserEmail> \
  --temporary-password <TempPassword>