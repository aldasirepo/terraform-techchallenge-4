locals {
  azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
  project_name = var.project_name

  public_subnets = [for i in range(length(local.azs)) : cidrsubnet(var.cidr_block, 8, i)]
}

module "vpc" {
  source = "../../modules/network"

  aws_region   = var.aws_region
  project_name = var.project_name
  cidr_block   = var.cidr_block
  tags         = var.network_tags
  cluster_name = var.network_cluster_name

  # Variáveis de otimização de custos
  availability_zones     = var.availability_zones
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_flow_log        = var.enable_flow_log
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_dns_support     = var.enable_dns_support
  assign_ipv6_address    = var.assign_ipv6_address
  enable_ipv6            = var.enable_ipv6
}

module "ecr" {
  source         = "../../modules/ecr"
  for_each       = toset(var.repository_name)

  repository_name = each.key
  tags            = var.tags
  aws_account_id  = var.aws_account_id
}

module "rds" {
  source       = "../../modules/databases"
  project_name = var.project_name
  aws_region   = var.aws_region
  tags         = var.tags

  # Variáveis RDS
  rds_identifier        = var.rds_identifier
  rds_engine            = var.rds_engine
  rds_engine_version    = var.rds_engine_version
  rds_instance_class    = var.rds_instance_class
  rds_allocated_storage = var.rds_allocated_storage
  rds_db_name           = var.project_name
  rds_username          = var.rds_username
  rds_password          = var.rds_password
  rds_port              = var.rds_port

  # Configurações de segurança
  rds_iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  rds_vpc_security_group_ids              = [] # Será preenchido após criação da VPC

  # Janelas de manutenção
  rds_maintenance_window = var.rds_maintenance_window
  rds_backup_window      = var.rds_backup_window

  # Monitoring
  rds_monitoring_interval    = var.rds_monitoring_interval
  rds_monitoring_role_name   = var.rds_monitoring_role_name
  rds_create_monitoring_role = var.rds_create_monitoring_role

  # Configurações de subnet
  rds_create_db_subnet_group = var.rds_create_db_subnet_group
  rds_subnet_ids             = module.vpc.private_subnets

  # Configurações de engine
  rds_family               = var.rds_family
  rds_major_engine_version = var.rds_major_engine_version

  # Proteção
  rds_deletion_protection = var.rds_deletion_protection

  # Parâmetros e options
  rds_parameters                           = var.rds_parameters
  rds_options                              = var.rds_options
  
  # Variáveis ElastiCache
  elasticache_cluster_id                   = var.elasticache_cluster_id
  elasticache_replication_group_id          = var.elasticache_replication_group_id
  create_elasticache                      = var.create_elasticache
  create_elasticache_replication_group     = var.create_elasticache_replication_group
  
  # Variáveis DynamoDB
  dynamodb_table_name                      = var.dynamodb_table_name
  
  # VPC information for ElastiCache
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.vpc_cidr_block
  private_subnet_ids   = module.vpc.private_subnets
  
  # VPC and EKS information for RDS security group
  eks_cluster_security_group_id = module.eks.eks_cluster_security_group_id
}

module "eks" {
  source = "../../modules/eks-cluster"

  # Variáveis principais
  aws_region   = var.aws_region
  project_name = var.project_name
  tags         = var.tags
  aws_account_id = var.aws_account_id

  # Variáveis EKS
  eks_cluster_name              = var.eks_cluster_name
  eks_kubernetes_version        = var.eks_kubernetes_version
  
  # VPC information for EKS
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnets
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  project_name = var.project_name
  tags         = var.tags

  # Database credentials
  db_user     = var.rds_username
  db_password = module.rds.rds_password
  rds_password = module.rds.rds_password

  # Database endpoints
  db_auth_endpoint     = module.rds.rds_instance_endpoint
  db_flag_endpoint     = module.rds.rds_instance_endpoint
  db_targeting_endpoint = module.rds.rds_instance_endpoint
  
  # Other endpoints
  evaluation_db_endpoint = module.rds.elasticache_endpoint
  sqs_queue_url         = module.resources.sqs_queue_url
  dynamodb_url          = var.dynamodb_table_name
}

module "resources" {
  source = "../../modules/resources"

  project_name = var.project_name
  environment  = "prod"
  aws_region  = var.aws_region
  tags        = var.tags
}
