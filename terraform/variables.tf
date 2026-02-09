variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "The name of the project for tagging resources."
  type        = string
  default     = "project-bedrock"
}

variable "instance_type" {
  description = "The EC2 instance type to use for EKS worker nodes."
  type        = list(string)
  default     = ["t3.small"]
}