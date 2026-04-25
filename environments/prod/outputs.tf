# Outputs do módulo Kubernetes
output "kubernetes_namespaces" {
  description = "Lista das namespaces Kubernetes criadas"
  value       = module.kubernetes.namespaces
}

output "kubernetes_namespace_auth" {
  description = "Namespace auth-service"
  value       = module.kubernetes.namespace_auth
}

output "kubernetes_namespace_flag" {
  description = "Namespace flag-service"
  value       = module.kubernetes.namespace_flag
}

output "kubernetes_namespace_targeting" {
  description = "Namespace targeting-service"
  value       = module.kubernetes.namespace_targeting
}

output "kubernetes_namespace_evaluation" {
  description = "Namespace evaluation-service"
  value       = module.kubernetes.namespace_evaluation
}

output "kubernetes_namespace_analytics" {
  description = "Namespace analytics-service"
  value       = module.kubernetes.namespace_analytics
}

# Outputs para o workflow CI/CD
output "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL"
  value       = module.rds.rds_instance_endpoint
  sensitive   = false
}

output "redis_endpoint" {
  description = "Endpoint do ElastiCache Redis"
  value       = module.rds.elasticache_endpoint
  sensitive   = false
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = module.resources.sqs_queue_url
  sensitive   = false
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.eks_cluster_name
  sensitive   = false
}
