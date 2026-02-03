variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "project_name" {
  description = "The name of the project for tagging resources."
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
}