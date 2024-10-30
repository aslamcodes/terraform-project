

variable "instance_count" {
  default = 1
  type    = number
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}
