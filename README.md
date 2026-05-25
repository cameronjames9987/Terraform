# Terraform — Python_Coding EC2 Deployment

Provisions a single EC2 instance, installs Python and dependencies, and clones the [Python_Coding](https://github.com/cameronjames9987/Python_Coding) repo onto the instance automatically. The slot machine can then be played interactively over SSH.

## What gets created

| Resource | Notes |
|---|---|
| EC2 instance | Amazon Linux 2023,, IMDSv2-only, encrypted EBS |
| Security Group | SSH inbound from a /32 IP only |
| Key Pair | Uploaded from your local SSH public key |
| (uses default VPC) |  |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure`)
- An SSH key pair on your laptop:
  ```sh
  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
  ```

## Run it

```sh
# 1. Create your tfvars (one-time)
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set allowed_ssh_cidr to YOUR_IP/32, or let it prompt for an IP
curl -s https://checkip.amazonaws.com   # to find your IP

# 2. Deploy
terraform init
terraform plan
terraform apply
# Enter your region when prompted (e.g. ap-southeast-2)

# 3. SSH in (wait ~1–2 min for cloud-init after apply finishes)
ssh -i ~/.ssh/id_ed25519 ec2-user@<public_ip>
cat ~/.deploy_ready          # should print "ready"

# 4. Run the slot machine
cd ~/Python_Coding/Slot_Machine
source ~/Python_Coding/.venv/bin/activate
python3 main.py

# 5. Tear it down (don't leave EC2 running)
terraform destroy
```

## Files

| File | Purpose |
|---|---|
| `main.tf` | Provider, AMI lookup, key pair, security group, EC2 |
| `variables.tf` | Input variables (region, instance type, etc.) |
| `outputs.tf` | Public IP, SSH command, etc. |
| `user_data.sh.tftpl` | Cloud-init script — installs Python and clones the repo |
| `terraform.tfvars.example` | Template for variable values; copy to `terraform.tfvars` and edit |
| `.gitignore` | Excludes state, tfvars, plans, editor swap files |


```

## Troubleshooting

- **SSH connection refused**: wait ~30s for sshd to start.
- **`cat ~/.deploy_ready` says no such file**: cloud-init still running or failed. Run `sudo cat /var/log/user-data.log` on the instance.
- **`Permission denied (publickey)`**: wrong private key path, or `public_key_path` in tfvars points to the wrong `.pub`.
- **`terraform plan` errors with `AccessDenied`**: your IAM user lacks the required permissions.
