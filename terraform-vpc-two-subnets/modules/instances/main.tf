data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  common_tags = var.tags

  instances_list = flatten([
    for subnet_name, count in var.instances_per_subnet : [
      for idx in range(count) : {
        key    = "${subnet_name}-${idx}"
        subnet = subnet_name
        idx    = idx
      }
    ]
  ])

  instances_map = {
    for inst in local.instances_list :
    inst.key => inst
  }

  ordered_keys = sort(keys(local.instances_map))
  number_map = {
    for index, key in local.ordered_keys :
    key => index + 1
  }

  subnet_is_public = {
    for subnet_name, _ in var.subnet_ids :
    subnet_name => can(regex("(?i)public|pub", subnet_name))
  }
}

resource "aws_security_group" "public_sg" {
  name        = "${var.name}-public-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.name}-public-sg" }
  )
}

resource "aws_security_group" "private_sg" {
  name        = "${var.name}-private-sg"
  description = "Allow internal traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.name}-private-sg" }
  )
}

resource "aws_instance" "this" {
  for_each = local.instances_map

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  subnet_id = lookup(var.subnet_ids, each.value.subnet)

  associate_public_ip_address = local.subnet_is_public[each.value.subnet]

  vpc_security_group_ids = local.subnet_is_public[each.value.subnet]? [aws_security_group.public_sg.id] : [aws_security_group.private_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.name}-${each.key}"
      Role            = local.subnet_is_public[each.value.subnet] ? "public-web" : "private-app"
      InstanceOrdinal = tostring(local.number_map[each.key])
      SubnetName      = each.value.subnet
    }
  )

  user_data = templatefile("${path.module}/templates/public.sh", {
    instance_number = local.number_map[each.key]
  })
}

