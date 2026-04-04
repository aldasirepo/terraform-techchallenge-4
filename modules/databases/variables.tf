variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default = {}
}

#=======================
# Variáveis do RDS
#=======================
variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
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
  default     = "testedbteste"
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

# Variáveis do ElastiCache
variable "elasticache_cluster_id" {
  description = "ElastiCache cluster identifier"
  type        = string
}

variable "elasticache_engine" {
  description = "ElastiCache engine"
  type        = string
  default     = "redis"
}

variable "elasticache_engine_version" {
  description = "ElastiCache engine version"
  type        = string
  default     = "7.0"
}

variable "elasticache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "elasticache_num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "elasticache_az_mode" {
  description = "Availability zone mode"
  type        = string
  default     = "single-az"
}

variable "elasticache_parameter_group_family" {
  description = "Parameter group family"
  type        = string
  default     = "redis7"
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

# VPC-related variables for ElastiCache
variable "vpc_id" {
  description = "VPC ID for ElastiCache"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for ElastiCache security group"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ElastiCache"
  type        = list(string)
}

variable "elasticache_replication_group_id" {
  description = "ElastiCache replication group identifier"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  type        = string
}

