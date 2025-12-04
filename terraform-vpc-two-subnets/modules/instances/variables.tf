variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

# map of subnet name => subnet id (from module.vpc.subnet_ids)
variable "subnet_ids" {
  type = map(string)
  default = {}
}

# map of subnet name => desired instance count
# e.g. { "public-1" = 2, "private-1" = 2 }
variable "instances_per_subnet" {
  type = map(number)
  default = {}
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# optional tags map from root
variable "tags" {
  type    = map(string)
  default = {}
}
