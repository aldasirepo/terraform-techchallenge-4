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

  depends_on = [kubernetes_namespace_v1.argocd]
}

resource "null_resource" "ingress_nginx" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.6/deploy/static/provider/cloud/deploy.yaml"
  }
  depends_on = [helm_release.argocd]
}

resource "null_resource" "sealed_secrets" {
  provisioner "local-exec" {
    command = "helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets && helm repo update && helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets -n sealed-secrets --create-namespace --wait"
  }
  depends_on = [helm_release.argocd]
}

resource "null_resource" "argocd_apps" {
  triggers = {
    helm_release_id = helm_release.argocd.id
  }

  provisioner "local-exec" {
    command = "kubectl apply --server-side --force-conflicts -k ${var.cd_apps_path}"
  }

  depends_on = [helm_release.argocd]
}
