locals {
  name = var.name
}

module "vpc" {
  source             = "../../modules/vpc"
  name               = local.name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr= var.private_subnet_cidr
}

module "instances" {
  source                  = "../../modules/instances"
  name                    = local.name
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id        = module.vpc.public_subnet_id
  private_subnet_id       = module.vpc.private_subnet_id
  instance_type           = var.instance_type
  public_instance_count   = var.public_instance_count
  private_instance_count  = var.private_instance_count
}
 
output "alb_dns_placeholder" {
  value = "No ALB in this example - see outputs for instance IPs"
}

output "public_instance_ips" {
  value = module.instances.public_instance_ips
}

output "private_instance_private_ips" {
  value = module.instances.private_instance_private_ips
}
