variable "name" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# list of subnets to create
# object: { name = string, cidr = string, az = optional(string), public = bool }
variable "subnets" {
  type = list(object({
    name   = string
    cidr   = string
    az     = optional(string)
    public = bool
  }))
  default = []
}

# optional: tags map passed from root
variable "tags" {
  type    = map(string)
  default = {}
}
