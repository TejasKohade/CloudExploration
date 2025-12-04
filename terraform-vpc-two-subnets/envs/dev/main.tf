locals {
  name = "demo"
  common_tags = {
    Environment = "dev"
    Owner       = "tejas"
    Project     = "terraform-vpc-dynamic"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source   = "../../modules/vpc"
  name     = local.name
  vpc_cidr = "10.0.0.0/16"

  subnets = [
    { name = "public-1",  cidr = "10.0.1.0/24", public = true,  az = "ap-south-1a" },
    { name = "private-1", cidr = "10.0.2.0/24", public = false, az = "ap-south-1a" }
  ]

  tags = local.common_tags
}

module "instances" {
  source = "../../modules/instances"
  name   = local.name

  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.subnet_ids

  # create 2 instances in public-1, 2 in private-1
  instances_per_subnet = {
    "public-1"  = 2,
    "private-1" = 2
  }

  instance_type = "t3.micro"

  tags = local.common_tags
}

output "public_instance_ips" {
  value = module.instances.public_instance_ips_list
}
