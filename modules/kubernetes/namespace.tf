# 1. Lista dos serviços
variable "namespaces_k8s" {
  type    = set(string)
  default = ["auth-service", "flag-service", "targeting-service", "evaluation-service", "analytics-service"]
}

# 2. Criação das namespaces (Loop)
resource "kubernetes_namespace_v1" "services" {
  for_each = var.namespaces_k8s

  metadata {
    name                 = each.value # O nome vem da lista acima
  }
}