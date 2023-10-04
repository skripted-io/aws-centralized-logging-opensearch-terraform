# /modules/security/jumpbox/main.tf
# Provision an EC2 Windows instance in the public subnet that we can use to access the OpenSearch cluster in the private subnet

# Create a security group that allows RDP access from the client IP address, and outbound access to the OpenSearch cluster
resource "aws_security_group" "cl_jumpbox" {
  name_prefix = "${var.service_name}-jumpbox-sg-${var.environment}"
  description = "Allow port 80 and 443 outbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3389 # RDP port
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.client_ip}/32"]
  }

  egress {
    description = "allow outbound http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow outbound https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM role that the EC2 instance will use to allow it to access the OpenSearch cluster
resource "aws_iam_role" "cl_jumpbox_ec2_instance_role" {
  name = "${var.service_name}-jumpbox-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
      }
    ]
  })

  tags = {
    Service     = "${var.service_name}"
    Region      = var.aws_region
    Environment = var.environment
    Name        = "${var.service_name}-jumpbox-role-${var.environment}"
    Terraform   = "true"
  }
}

# Create an IAM instance profile that the EC2 instance will use to allow it to access the OpenSearch cluster
resource "aws_iam_instance_profile" "cl_jumpbox_ec2_instance_profile" {
  name = "${var.service_name}_jumpbox_ec2_instance_profile-${var.environment}"
  role = aws_iam_role.cl_jumpbox_ec2_instance_role.name
}

# Create a launch template that we can use to provision the EC2 instance
resource "aws_launch_template" "cl_jumpbox_launch_template" {
  name_prefix            = "${var.service_name}_jumpbox_launch_template-${var.environment}"
  update_default_version = true

  metadata_options {
    http_tokens = "required"
  }
}

# Provision the EC2 instance
resource "aws_instance" "cl_jumpbox_ec2" {
  instance_type               = "t3.micro"
  ami                         = var.ami_id
  key_name                    = var.key_name
  subnet_id                   = var.vpc_public_subnet_id
  iam_instance_profile        = aws_iam_instance_profile.cl_jumpbox_ec2_instance_profile.name
  vpc_security_group_ids      = concat([aws_security_group.cl_jumpbox.id], var.sg_groups)
  associate_public_ip_address = true

  tags = {
    Service     = "${var.service_name}"
    Region      = var.aws_region
    Environment = var.environment
    Name        = "${var.service_name}-jumpbox-instance-${var.environment}"
    Terraform   = "true"
  }
}
