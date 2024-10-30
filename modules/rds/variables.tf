variable "vpc_id" {
  type = string
}

variable "db_subnets" {
  type = list(any)
}

variable "ingress_cidrs" {
  type = list(string)
}
