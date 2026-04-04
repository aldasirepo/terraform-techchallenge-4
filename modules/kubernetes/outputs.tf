# Outputs das namespaces criadas
output "namespaces" {
  description = "Lista das namespaces Kubernetes criadas"
  value       = values(kubernetes_namespace_v1.services)[*].metadata[0].name
}

# Output individual de cada namespace para referência em outros recursos
output "namespace_auth" {
  description = "Namespace auth-service"
  value       = kubernetes_namespace_v1.services["auth-service"]
}

output "namespace_flag" {
  description = "Namespace flag-service"
  value       = kubernetes_namespace_v1.services["flag-service"]
}

output "namespace_targeting" {
  description = "Namespace targeting-service"
  value       = kubernetes_namespace_v1.services["targeting-service"]
}

output "namespace_evaluation" {
  description = "Namespace evaluation-service"
  value       = kubernetes_namespace_v1.services["evaluation-service"]
}

output "namespace_analytics" {
  description = "Namespace analytics-service"
  value       = kubernetes_namespace_v1.services["analytics-service"]
}
