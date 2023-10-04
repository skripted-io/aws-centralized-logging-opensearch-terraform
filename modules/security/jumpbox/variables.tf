# /modules/security/jumpbox/variables.tf

variable "aws_region" {
  description = "The aws region this Jumpbox resource is in"
  type        = string
}

variable "environment" {
  description = "The environment this Jumpbox resource is for"
  type        = string
}

variable "service_name" {
  description = "The name of the service this Jumpbox resource is for"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the Jumpbox in"
  type        = string
}

variable "vpc_public_subnet_id" {
  description = "The ID of the public subnet to deploy the Jumpbox in"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the Jumpbox"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the Jumpbox"
  type        = string
}

variable "client_ip" {
  description = "The IP address to allow RDP access from"
  type        = string
}

variable "sg_groups" {
  description = "A list of security group IDs to associate with the Jumpbox"
  type        = list(string)
  default     = []
}
