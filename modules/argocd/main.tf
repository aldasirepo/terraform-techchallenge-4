resource "null_resource" "helm_repo_argo" {
  provisioner "local-exec" {
    command     = "helm repo add argo https://argoproj.github.io/argo-helm; helm repo update argo"
    interpreter = ["powershell", "-Command"]
  }
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = merge(var.tags, {
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  timeout = 600
  wait    = true

  depends_on = [null_resource.helm_repo_argo, kubernetes_namespace_v1.argocd]
}

# Aplica os ArgoCD Applications (root-app + monitoramento) após o ArgoCD subir
resource "null_resource" "argocd_apps" {
  triggers = {
    helm_release_id = helm_release.argocd.id
  }

  provisioner "local-exec" {
    command     = "kubectl apply --server-side --force-conflicts -k \"${var.cd_apps_path}\""
    interpreter = ["powershell", "-Command"]
  }
}
