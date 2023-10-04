# /modules/observability/opensearch-service/main.tf
# Provisions the OpenSearch cluster and Kibana dashboard

# Allow Terraform access to the current account ID
data "aws_caller_identity" "current" {}

# Allow Terraform to access the secrets manager secret
data "aws_secretsmanager_secret_version" "secret" {
  secret_id = var.secrets_manager_arn
}

# Security Group for the OpenSearch cluster
resource "aws_security_group" "opensearch_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-opensearch-sg"
  description = "${title(var.service_name)} ${var.environment} OpenSearch SG"

  tags = {
    Service     = "${var.service_name}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-opensearch-sg"
    Terraform   = "true"
  }
}

# Allow outbound traffic to the NAT gateway
resource "aws_security_group_rule" "opensearch_sg_outbound" {
  description       = "Allows outbound access"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.opensearch_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security Group for giving Clients Access to the OpenSearch cluster
resource "aws_security_group" "client_access_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-client-access-sg"
  description = "${title(var.service_name)} ${var.environment} client access SG"

  tags = {
    Service     = "${var.service_name}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-client-access-sg"
    Terraform   = "true"
  }
}

# Allow port 80 inbound access from the Client Access SG
resource "aws_security_group_rule" "allow_client_sg_inbound" {
  description              = "Allows port 80 access from the Client Access SG"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch_sg.id
  source_security_group_id = aws_security_group.client_access_sg.id
}

# Allow port 443 inbound access from the Client Access SG
resource "aws_security_group_rule" "allow_client_sg_inbound_443" {
  description              = "Allows port 443 access from the Client Access SG"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch_sg.id
  source_security_group_id = aws_security_group.client_access_sg.id
}

# Allow outbound traffic 
resource "aws_security_group_rule" "allow_client_sg_outbound" {
  description       = "Allows outbound access"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.client_access_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow port 443 inbound access from these VPN SGs
resource "aws_security_group_rule" "allow_sg_inbound" {
  count                    = length(var.vpn_sg_ids)
  description              = "Allows port 443 access from these VPN SGs"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch_sg.id
  source_security_group_id = var.vpn_sg_ids[count.index]
}

# Allow inbound access from these CIDR blocks (usually for VPC peering access)
resource "aws_security_group_rule" "allow_cidr_inbound" {
  for_each          = toset(var.inbound_cidr_blocks)
  description       = "Allows port 9200 access from this CIDR block"
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.opensearch_sg.id
  cidr_blocks       = [each.key]
}

# Allow inbound access from these CIDR blocks (usually for VPC peering access)
resource "aws_security_group_rule" "allow_cidr_inbound_443" {
  for_each          = toset(var.inbound_cidr_blocks)
  description       = "Allows port 443 access from this CIDR block"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.opensearch_sg.id
  cidr_blocks       = [each.key]
}

# Provision a CloudWatch Log Group for OpenSearch
resource "aws_cloudwatch_log_group" "opensearch_log_group_index_slow_logs" {
  name              = "/aws/opensearch/${var.opensearch_domain_name}/index-slow"
  retention_in_days = 14
}

# Provision a CloudWatch Log Group for OpenSearch
resource "aws_cloudwatch_log_group" "opensearch_log_group_search_slow_logs" {
  name              = "/aws/opensearch/${var.opensearch_domain_name}/search-slow"
  retention_in_days = 14
}

# Provision a CloudWatch Log Group for OpenSearch
resource "aws_cloudwatch_log_group" "opensearch_log_group_es_application_logs" {
  name              = "/aws/opensearch/${var.opensearch_domain_name}/es-application"
  retention_in_days = 14
}

# Define the CloudWatch Logs policy document
data "aws_iam_policy_document" "cloudwatch_logs_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]

    resources = [
      "${aws_cloudwatch_log_group.opensearch_log_group_index_slow_logs.arn}:*",
      "${aws_cloudwatch_log_group.opensearch_log_group_search_slow_logs.arn}:*",
      "${aws_cloudwatch_log_group.opensearch_log_group_es_application_logs.arn}:*"
    ]
  }
}

# Create the CloudWatch Logs policy
resource "aws_cloudwatch_log_resource_policy" "cloudwatch_logs_policy" {
  policy_name     = "${var.service_name}-opensearch-log-policy-${var.aws_region}"
  policy_document = data.aws_iam_policy_document.cloudwatch_logs_policy_document.json
}

# Provision the OpenSearch cluster
resource "aws_opensearch_domain" "opensearch_domain" {
  domain_name    = var.opensearch_domain_name
  engine_version = var.engine_version

  cluster_config {
    # master nodes
    dedicated_master_enabled = true
    dedicated_master_type    = var.master_nodes_type
    dedicated_master_count   = var.master_nodes_count

    # data nodes
    instance_type  = var.data_nodes_type
    instance_count = var.data_nodes_count

    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = var.az_count
    }
  }

  advanced_security_options {
    enabled                        = var.advanced_security_options_enabled
    anonymous_auth_enabled         = false
    internal_user_database_enabled = false # set to "true" to use the below credentials instead of cognito auth.

    master_user_options {
      #   master_user_name     = sensitive(jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["master_user_name"])
      #   master_user_password = sensitive(jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["master_user_password"])
      master_user_arn = var.master_user_arn # comment out if using the above credentials
    }
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest
    kms_key_id = var.kms_key_arn
  }

  domain_endpoint_options {
    enforce_https       = var.enforce_https
    tls_security_policy = var.tls_security_policy
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = var.ebs_volume_size
  }

  vpc_options {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.opensearch_sg.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  cognito_options {
    enabled          = true
    user_pool_id     = var.user_pool_id
    identity_pool_id = var.identity_pool_id
    role_arn         = var.os_cognito_role_arn
  }

  # enable when needing more granular access control
  # access_policies = data.aws_iam_policy_document.opensearch_policy_document.json 

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_log_group_index_slow_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_log_group_search_slow_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_log_group_es_application_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  tags = {
    Service     = "${var.service_name}"
    Environment = var.environment
    Region      = var.aws_region
    Name        = "${var.service_name}-opensearch-domain"
    Terraform   = "true"
  }
}

# Define the OpenSearch policy document
data "aws_iam_policy_document" "opensearch_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"]
  }
}

# Attach the OpenSearch policy to the OpenSearch domain
resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.opensearch_domain.domain_name
  access_policies = data.aws_iam_policy_document.opensearch_policy_document.json
}
