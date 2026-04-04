
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

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "togglemaster-eks"
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.28"
}




# VPC-related variables for EKS
variable "vpc_id" {
  description = "VPC ID for EKS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}



variable "eks_cluster_endpoint_public_access" {
  description = "Enable public access to EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "eks_cluster_endpoint_private_access" {
  description = "Enable private access to EKS cluster endpoint"
  type        = bool
  default     = true
}




variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

