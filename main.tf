###############################################################################
# main.tf — EC2 instance that auto-deploys the Python_Coding repo
###############################################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = var.aws_region
}

# Look up the latest Amazon Linux 2023 AMI — no hardcoded AMI IDs
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use the default VPC and a default subnet — keeps things simple
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Upload the local SSH public key as an AWS key pair.
# The .pub file is safe to commit; the matching private key stays on your laptop.
resource "aws_key_pair" "deployer" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)

  tags = {
    Project = "Python_Coding"
  }
}

# Security group: SSH inbound from your IP only, all egress allowed
resource "aws_security_group" "app" {
  name        = "${var.instance_name}-sg"
  description = "SSH access for Python_Coding deployment"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.instance_name}-sg"
    Project = "Python_Coding"
  }
}

# Render the user_data script from a template (keeps shell out of HCL)
locals {
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    git_repo_url = var.git_repo_url
    git_branch   = var.git_branch
  })
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required" # IMDSv2 only
    http_endpoint = "enabled"
  }

  tags = {
    Name    = var.instance_name
    Project = "Python_Coding"
  }
}
