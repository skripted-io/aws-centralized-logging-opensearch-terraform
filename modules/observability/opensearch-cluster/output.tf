# /modules/observability/opensearch-cluster/output.tf
# Define outputs that can be referenced by Terraform in other configurations

output "client_access_sg_id" {
  description = "The ID of the client access security group"
  value       = aws_security_group.client_access_sg.id
}

output "domain_name" {
  description = "The  name of the OpenSearch domain"
  value       = aws_opensearch_domain.opensearch_domain.domain_name
}

output "dashboard_endpoint" {
  description = "The endpoint of the OpenSearch dashboard"
  value       = aws_opensearch_domain.opensearch_domain.dashboard_endpoint
}

output "domain_endpoint" {
  description = "The endpoint of the OpenSearch domain"
  value       = aws_opensearch_domain.opensearch_domain.endpoint
}

output "arn" {
  description = "The ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.opensearch_domain.arn
}
