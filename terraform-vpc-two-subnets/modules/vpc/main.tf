resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name}-vpc" })
}

data "aws_availability_zones" "available" {}

locals {
  subnets_map = { for s in var.subnets : s.name => s }
}

resource "aws_subnet" "this" {
  for_each = local.subnets_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = lookup(each.value, "az", element(data.aws_availability_zones.available.names, 0))
  map_public_ip_on_launch = each.value.public

  tags = merge(var.tags, { Name = "${var.name}-${each.key}-subnet", SubnetRole = each.value.public ? "public" : "private" })
}

# Create IGW if any public subnet exists
resource "aws_internet_gateway" "igw" {
  count  = length([for s in var.subnets : s if s.public]) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

# Public route table if public subnets exist
resource "aws_route_table" "public_rt" {
  count  = length([for s in var.subnets : s if s.public]) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  for_each = { for k, s in local.subnets_map : k => s if s.public }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public_rt[0].id
}
