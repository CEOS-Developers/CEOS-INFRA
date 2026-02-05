output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.main.private_ip
}

output "public_ip" {
  description = "Public IP (Elastic IP if enabled, otherwise instance public IP)"
  value       = var.enable_elastic_ip ? aws_eip.main[0].public_ip : aws_instance.main.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = var.enable_elastic_ip ? aws_eip.main[0].public_ip : null
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.ec2.id
}
