variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_instance_count" {
  type    = number
  default = 2
}

variable "private_instance_count" {
  type    = number
  default = 2
}

