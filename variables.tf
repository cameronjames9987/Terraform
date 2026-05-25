###############################################################################
# variables.tf — inputs (override via terraform.tfvars or -var flags)
###############################################################################

variable "aws_region" {
  description = "AWS region to deploy into. Examples: ap-southeast-2 (Sydney), us-east-1 (N. Virginia), eu-west-1 (Ireland)."
  type        = string

  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "ap-southeast-1", "ap-southeast-2", "ap-southeast-4",
      "ap-northeast-1", "ap-northeast-2", "ap-south-1",
      "eu-west-1", "eu-west-2", "eu-west-3",
      "eu-central-1", "eu-north-1",
      "ca-central-1", "sa-east-1",
    ], var.aws_region)
    error_message = "Region must be one of the standard AWS regions (e.g. ap-southeast-2). Add yours to variables.tf if missing."
  }
}

variable "instance_name" {
  description = "Name tag for the EC2 instance."
  type        = string
  default     = "Cam_Demo"
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro is free-tier eligible."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB."
  type        = number
  default     = 10
}

variable "key_pair_name" {
  description = "Name to give the AWS key pair created by Terraform."
  type        = string
#  default     = "Cam_Default_Key"
}

variable "public_key_path" {
  description = "Local path to your SSH public key (e.g. ~/.ssh/id_ed25519.pub)."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance. Use your /32 IP — never 0.0.0.0/0 in production."
  type        = string

  validation {
    condition     = var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "Refusing to open SSH to the world. Set allowed_ssh_cidr to your IP /32."
  }
}

variable "git_repo_url" {
  description = "HTTPS URL of the public Git repo to clone on the instance."
  type        = string
  default     = "https://github.com/cameronjames9987/Python_Coding.git"
}

variable "git_branch" {
  description = "Branch to clone."
  type        = string
  default     = "main"
}
