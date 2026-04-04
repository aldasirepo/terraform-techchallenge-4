# =============================================================================
# VARIÁVEIS GLOBAIS DO PROJETO
# =============================================================================
aws_region     = "us-east-1"
project_name   = "togglemaster"
cidr_block     = "10.0.0.0/16"
aws_account_id = "251246746789"

# =============================================================================
# VARIÁVEIS DO MÓDULO NETWORK (VPC)
# =============================================================================
network_tags = {
  team        = "DevOps"
  project     = "togglemaster"
  environment = "Production"
  managedBy   = "Terraform"
  Name        = "togglemaster-vpc"
}

network_cluster_name = "togglemaster-eks"

availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
enable_nat_gateway      = true
single_nat_gateway      = true
one_nat_gateway_per_az  = false
enable_flow_log         = true
enable_dns_hostnames    = true
enable_dns_support      = true
assign_ipv6_address     = false
enable_ipv6             = false

# =============================================================================
# VARIÁVEIS DO MÓDULO EKS-CLUSTER
# =============================================================================
eks_cluster_name       = "togglemaster-eks"
eks_kubernetes_version = "1.30"

eks_tags = {
  team        = "DevOps"
  project     = "togglemaster"
  environment = "Production"
  managedBy   = "Terraform"
  Name        = "togglemaster-eks"
}

eks_enable_irsa = false

eks_managed_node_groups = {
  prod_nodes = {
    instance_types = ["t3.medium"]
    min_size       = 1
    max_size       = 4
    desired_size   = 3    # ← mude aqui
    capacity_type  = "ON_DEMAND"
    ami_type       = "AL2023_x86_64_STANDARD"

    k8s_labels = {
      environment = "prod"
      node-type   = "general"
    }

    taints = []
  }
}

eks_access_entries = {
  admin = {
    principal_arn = "arn:aws:iam::251246746789:user/techchallenge-admin"
    policy_associations = {
      cluster_admin = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    }
  }
}

# =============================================================================
# VARIÁVEIS DO MÓDULO DATABASES (RDS)
# =============================================================================
rds_identifier        = "togglemaster-db"
rds_engine            = "postgres"
rds_engine_version    = "15"
rds_instance_class    = "db.t3.micro"
rds_allocated_storage = 20

rds_db_name  = "togglemaster_prod"
rds_username = "togglemaster_admin"
rds_port     = 5432

rds_iam_database_authentication_enabled = false
rds_vpc_security_group_ids              = []

rds_maintenance_window = "Sun:02:00-Sun:04:00"
rds_backup_window      = "04:00-06:00"

rds_monitoring_interval    = "0"
rds_create_monitoring_role = false

rds_create_db_subnet_group = true
rds_subnet_ids             = []

rds_family               = "postgres15"
rds_major_engine_version = "15"

rds_deletion_protection = false

rds_parameters = [
  {
    name  = "checkpoint_completion_target"
    value = "0.9"
  },
  {
    name  = "default_statistics_target"
    value = "100"
  }
]

rds_options = []

rds_tags = {
  team        = "DevOps"
  project     = "togglemaster"
  environment = "Production"
  managedBy   = "Terraform"
  Name        = "togglemaster-rds"
}

# =============================================================================
# VARIÁVEIS DO MÓDULO DATABASES (DYNAMODB)
# =============================================================================
dynamodb_tables = [
  {
    name         = "togglemaster-sessions"
    hash_key     = "session_id"
    billing_mode = "PAY_PER_REQUEST"
    attributes = [
      {
        name = "session_id"
        type = "S"
      }
    ]
    tags = {
      team        = "DevOps"
      project     = "togglemaster"
      environment = "Production"
      managedBy   = "Terraform"
      Name        = "togglemaster-sessions"
    }
  },
  {
    name         = "togglemaster-logs"
    hash_key     = "log_id"
    billing_mode = "PAY_PER_REQUEST"
    attributes = [
      {
        name = "log_id"
        type = "S"
      }
    ]
    tags = {
      team        = "DevOps"
      project     = "togglemaster"
      environment = "Production"
      managedBy   = "Terraform"
      Name        = "togglemaster-logs"
    }
  }
]

dynamodb_table_name = "togglemaster-prod"

# =============================================================================
# VARIÁVEIS DE TAGS GLOBAIS
# =============================================================================
global_tags = {
  team        = "DevOps"
  project     = "togglemaster"
  environment = "Production"
  managedBy   = "Terraform"
  owner       = "DevOpsTeam"
  cost-center = "Engineering"
}

tags = {
  team        = "DevOps"
  project     = "togglemaster"
  environment = "Production"
  managedBy   = "Terraform"
}

# =============================================================================
# VARIÁVEIS DO MÓDULO ECR
# =============================================================================
repository_name = [
  "auth-service",
  "flag-service",
  "targeting-service",
  "evaluation-service",
  "analytics-service"
]

# =============================================================================
# VARIÁVEIS DO MÓDULO DATABASES (ELASTICACHE)
# =============================================================================
elasticache_cluster_id               = "togglemaster-redis"
elasticache_replication_group_id     = "togglemaster-redis-rg"
create_elasticache                   = true
create_elasticache_replication_group = false

# =============================================================================
# CONFIGURAÇÕES IAM
# =============================================================================
enable_iam_session_context = false
