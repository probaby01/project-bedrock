variable "project_name" {
  description = "Name of the project for all resources"
  type        = string
}

variable "pb_sg_id" {
  description = "Security Group ID for EC2 instances"
  type = string
}

variable "private_subnets_ids" {
  description = "List of private subnet IDs"
  type = list(string)
}

variable "instance_types" {
  description = "The EC2 instance types to use for EKS worker nodes."
  type        = list(string)
}