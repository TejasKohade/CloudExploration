output "instance_private_ips" {
  value = { for k, v in aws_instance.this : k => v.private_ip }
}

output "instance_public_ips" {
  value = { for k, v in aws_instance.this : k => try(v.public_ip, "") }
}

# also output a flat list of public ips (useful)
output "public_instance_ips_list" {
  value = [for k, v in aws_instance.this : try(v.public_ip, "") if try(v.public_ip, "") != "" ]
}
