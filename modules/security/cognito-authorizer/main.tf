# /modules/security/cognito/main.tf
# Configures a Cognito User Pool and Identity pool to authenticate users with OpenSearch

# Provision a Cognito User Pool for the Centralized Logging service
resource "aws_cognito_user_pool" "cl_user_pool" {
  name = "cl-user-pool-${var.environment}"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 3
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "email"
    required            = true
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  username_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "The verification code to your new account is {####}"
    email_subject        = "Verify your new account"
    sms_message          = "The verification code to your new account is {####}"
  }

  tags = {
    Service     = "${var.service_name}"
    Region      = var.aws_region
    Environment = var.environment
    Name        = "${var.service_name}-cognito-user-pool-${var.environment}"
    Terraform   = "true"
  }
}

# Provision a Cognito User Pool Domain for the Centralized Logging service
resource "aws_cognito_user_pool_domain" "cl_user_pool_domain" {
  domain       = var.opensearch_domain_name
  user_pool_id = aws_cognito_user_pool.cl_user_pool.id
}

# Provision a Cognito Identity Pool for the Centralized Logging service
resource "aws_cognito_identity_pool" "cl_identity_pool" {
  identity_pool_name               = "cl-identity-pool-${var.environment}"
  allow_unauthenticated_identities = false

  lifecycle {
    ignore_changes = [cognito_identity_providers]
  }

  tags = {
    Service     = "${var.service_name}"
    Region      = var.aws_region
    Environment = var.environment
    Name        = "${var.service_name}-cognito-identity-pool-${var.environment}"
    Terraform   = "true"
  }
}

# Create a role that defines what Cognito Authorized users can do
resource "aws_iam_role" "cognito_auth_role" {
  name = "CognitoAuthRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity",
      Effect    = "Allow",
      Principal = { Federated = "cognito-identity.amazonaws.com" },
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.cl_identity_pool.id
        },
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }]
  })
}

# Create a policy that allows OpenSearch to use Cognito
resource "aws_iam_policy" "cognito_auth_policy" {
  name        = "cognito-auth-user-policy-${var.environment}"
  description = "Policy to allow the authenticated user access to OS Dashboards"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["es:ESHttp*"],
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "cognito_auth_policy" {
  policy_arn = aws_iam_policy.cognito_auth_policy.arn
  role       = aws_iam_role.cognito_auth_role.name
}

# Attach the authenticated role to the Cognito Identity Pool
resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.cl_identity_pool.id

  roles = {
    authenticated = aws_iam_role.cognito_auth_role.arn
  }
}

# Create a role for OpenSearch to assume
resource "aws_iam_role" "os_cognito_role" {
  name = "os-cognito-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "es.amazonaws.com" }
    }]
  })
}

# Create a policy that allows OpenSearch to use Cognito
resource "aws_iam_policy" "os_cognito_policy" {
  name        = "os-cognito-access-${var.environment}"
  description = "Policy for allowing OpenSearch to use Cognito"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "cognito-idp:DescribeUserPool",
        "cognito-idp:CreateUserPoolClient",
        "cognito-idp:DeleteUserPoolClient",
        "cognito-idp:DescribeUserPoolClient",
        "cognito-idp:AdminInitiateAuth",
        "cognito-idp:AdminUserGlobalSignOut",
        "cognito-idp:ListUserPoolClients",
        "cognito-identity:DescribeIdentityPool",
        "cognito-identity:UpdateIdentityPool",
        "cognito-identity:SetIdentityPoolRoles",
        "cognito-identity:GetIdentityPoolRoles",
        "ec2:DescribeVpcs",
        "cognito-identity:ListIdentityPools",
        "cognito-idp:ListUserPools"
      ],
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "os_cognito_policy" {
  policy_arn = aws_iam_policy.os_cognito_policy.arn
  role       = aws_iam_role.os_cognito_role.name
}

resource "aws_iam_role_policy" "oscognito_role_default_policy" {
  name = "os-cognito-role-default-policy-${var.environment}"
  role = aws_iam_role.os_cognito_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["iam:PassRole", "iam:GetRole"]
      Effect   = "Allow",
      Resource = aws_iam_role.os_cognito_role.arn,
      Condition = {
        StringLike = {
          "iam:PassedToService" = "cognito-identity.amazonaws.com"
        }
      }
    }]
  })
}
