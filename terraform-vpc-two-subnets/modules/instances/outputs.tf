output "public_instance_ips" {
  description = "Public IPs of instances in the public subnet"
  value       = [for i in aws_instance.public : i.public_ip]
}

output "private_instance_private_ips" {
  description = "Private IPs of instances in the private subnet"
  value       = [for i in aws_instance.private : i.private_ip]
}
