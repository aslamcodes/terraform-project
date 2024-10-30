variable "subnet_count" {
  default = 1
  type    = number
}

variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_CIDRs" {
  type = list(string)
  validation {
    condition     = length(var.public_subnet_CIDRs) == var.subnet_count
    error_message = "Public subnets count must match with give CIDRs"
  }
}


variable "private_subnets_CIDRs" {
  type = list(string)
  validation {
    condition     = length(var.private_subnets_CIDRs) == var.subnet_count
    error_message = "Private subnets count must match with give CIDRs"
  }
}
