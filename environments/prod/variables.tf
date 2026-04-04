# =============================================================================
# VARIÁVEIS GLOBAIS DO PROJETO
# =============================================================================
variable "aws_region" {
  type        = string
  description = "AWS Region for resources deployment"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name to identify resources"
  default     = "togglemaster"
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "global_tags" {
  type        = map(any)
  description = "A map of tags to add to all resources."
  default = {
    team        = "DevOps"
    project     = "ToggleMaster"
    environment = "Prod"
    managedBy   = "Terraform"
  }
}

variable "tags" {
  type        = map(any)
  description = "Tags for resources"
  default = {
    team        = "DevOps"
    project     = "ToggleMaster"
    environment = "Prod"
    managedBy   = "Terraform"
  }
}

variable "rds_tags" {
  type        = map(any)
  description = "Tags for RDS resources"
  default     = {}
}

variable "repository_name" {
  type        = list(string)
  description = "ECR repository names"
}

variable "aws_account_id" {
  description = "ID da conta AWS"
  type        = string
}

# =============================================================================
# VARIÁVEIS DO MÓDULO NETWORK (VPC)
# =============================================================================
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

# =============================================================================
# VARIÁVEIS DO MÓDULO EKS-CLUSTER
# =============================================================================
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

variable "eks_tags" {
  type        = map(any)
  description = "Tags for EKS resources"
  default     = {}
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node groups configuration"
  type        = any
  default     = {}
}

variable "eks_access_entries" {
  description = "Map of IAM principals to grant EKS access"
  type        = any
  default     = {}
}

variable "eks_enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "eks_cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  type        = string
  default     = ""
}

variable "eks_node_group_role_arn" {
  description = "IAM role ARN for EKS node groups"
  type        = string
  default     = ""
}

# =============================================================================
# VARIÁVEIS DO MÓDULO DATABASES (RDS)
# =============================================================================
variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = "togglemaster-db"
}

variable "rds_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Database name"
  type        = string
}

variable "rds_username" {
  description = "Master username"
  type        = string
}

variable "rds_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "rds_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "rds_iam_database_authentication_enabled" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = false
}

variable "rds_vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "rds_maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "Sun:02:00-Sun:04:00"
}

variable "rds_backup_window" {
  description = "Backup window"
  type        = string
  default     = "04:00-06:00"
}

variable "rds_monitoring_interval" {
  description = "Enhanced Monitoring interval"
  type        = string
  default     = "0"
}

variable "rds_monitoring_role_name" {
  description = "Monitoring role name"
  type        = string
  default     = "ToggleMasterRDSMonitoringRole"
}

variable "rds_create_monitoring_role" {
  description = "Create monitoring role"
  type        = bool
  default     = false
}

variable "rds_create_db_subnet_group" {
  description = "Create DB subnet group"
  type        = bool
  default     = true
}

variable "rds_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}

variable "rds_family" {
  description = "DB parameter group family"
  type        = string
  default     = "postgres15"
}

variable "rds_major_engine_version" {
  description = "Major engine version"
  type        = string
  default     = "15"
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "rds_parameters" {
  description = "DB parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "rds_options" {
  description = "DB options"
  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

# =============================================================================
# VARIÁVEIS DO MÓDULO DATABASES (DYNAMODB)
# =============================================================================
variable "dynamodb_tables" {
  description = "List of DynamoDB tables"
  type = list(object({
    name         = string
    hash_key     = string
    billing_mode = string
    attributes = list(object({
      name = string
      type = string
    }))
    tags = map(string)
  }))
  default = []
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
}

# =============================================================================
# VARIÁVEIS DO MÓDULO DATABASES (ELASTICACHE)
# =============================================================================
variable "elasticache_cluster_id" {
  description = "ElastiCache cluster identifier"
  type        = string
  default     = ""
}

variable "elasticache_replication_group_id" {
  description = "ElastiCache replication group identifier"
  type        = string
  default     = ""
}

variable "create_elasticache" {
  description = "Create ElastiCache cluster"
  type        = bool
  default     = false
}

variable "create_elasticache_replication_group" {
  description = "Create ElastiCache replication group"
  type        = bool
  default     = false
}

variable "enable_iam_session_context" {
  description = "Enable IAM session context check (disable when not needed)"
  type        = bool
  default     = false
}

# =============================================================================
# VARIÁVEIS DE BACKEND S3
# =============================================================================
variable "backend_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "togglemaster-terraform-state-us-east-1"
}

variable "backend_key" {
  description = "S3 key for Terraform state"
  type        = string
  default     = "prod/terraform.tfstate"
}

variable "backend_region" {
  description = "S3 region for Terraform state"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# VARIÁVEIS DO MÓDULO KUBERNETES
# =============================================================================
variable "sqs_queue_url" {
  description = "SQS queue URL for services"
  type        = string
  default     = ""
}