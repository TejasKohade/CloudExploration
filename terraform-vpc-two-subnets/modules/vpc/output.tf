output "vpc_id" {
  value = aws_vpc.this.id
  description = "ID of the created VPC"
}

# map of subnet-name => subnet-id
output "subnet_ids" {
  value = { for k, v in aws_subnet.this : k => v.id }
  description = "Map of subnet name -> subnet id"
}

# list of public subnet ids (useful for ALB etc.)
# Uses local.subnets_map to check the 'public' flag reliably.
output "public_subnet_ids" {
  value = [
    for k, v in aws_subnet.this :
    v.id if lookup(local.subnets_map[k], "public", false)
  ]
  description = "List of subnet ids that are marked public"
}
