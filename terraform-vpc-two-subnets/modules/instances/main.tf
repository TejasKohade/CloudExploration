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

# Public Security Group
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
}

# Private Security Group
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
}

resource "aws_instance" "public" {
  count         = var.public_instance_count
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }

  user_data = templatefile("${path.module}/templates/public.sh", {
    instance_number = count.index + 1
  })
}

resource "aws_instance" "private" {
  count         = var.private_instance_count
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }

  user_data = templatefile("${path.module}/templates/private.sh", {
    instance_number = var.public_instance_count + count.index + 1
  })
}
