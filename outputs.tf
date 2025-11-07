output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.web[*].public_ip
}

output "instance_private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.web[*].private_ip
}
