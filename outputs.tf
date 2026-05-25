###############################################################################
# outputs.tf — handy info after `terraform apply`
###############################################################################

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IPv4 address of the instance."
  value       = aws_instance.app.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance."
  value       = aws_instance.app.public_dns
}

output "ssh_command" {
  description = "Ready-to-paste SSH command. Replace the path if your private key isn't at ~/.ssh/id_ed25519."
  value       = "ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.app.public_ip}"
}

output "run_slot_machine" {
  description = "Command to run once SSH'd into the instance."
  value       = "cd /home/ec2-user/Python_Coding/Slot_Machine && source ../.venv/bin/activate && python3 main.py"
}
