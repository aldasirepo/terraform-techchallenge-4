
variable "aws_region" {
  type        = string
  description = "AWS Region for resources deployment"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name to identify VPC"
  default     = "prod-techchallenge"
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR block for VPC"
  default     = "10.50.0.0/16"
}

variable "tags" {
  type        = map(any)
  description = "A map of tags to add to all resources."
  default = {
    team    = "Devops"
    project = "prod-techchallenge"
    environment = "Prod"
    managedBy = "Terraform"
  }
}

variable "cluster_name" {
  type        = string
  description = "Cluster name for EKS"
}

variable "network_tags" {
  type        = map(any)
  description = "Tags for network resources"
  default     = {}
}

variable "network_cluster_name" {
  type        = string
  description = "Cluster name for network module"
  default     = ""
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = []
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT gateway"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use single NAT gateway"
  default     = false
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Create one NAT gateway per AZ"
  default     = true
}

variable "enable_flow_log" {
  type        = bool
  description = "Enable VPC flow logs"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support"
  default     = true
}

variable "assign_ipv6_address" {
  type        = bool
  description = "Assign IPv6 addresses"
  default     = false
}

variable "enable_ipv6" {
  type        = bool
  description = "Enable IPv6"
  default     = false
}