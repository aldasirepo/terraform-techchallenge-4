module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "1.11.0"
  create_cluster           = false
  create_replication_group = true
  replication_group_id = var.elasticache_cluster_id
  engine         = var.elasticache_engine
  engine_version = var.elasticache_engine_version
  node_type      = var.elasticache_node_type
  num_cache_clusters = 1
  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true
  vpc_id = var.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = var.vpc_cidr_block
    }
  }
  subnet_ids = var.private_subnet_ids
  create_parameter_group = false
  transit_encryption_enabled = false
  at_rest_encryption_enabled = false
}