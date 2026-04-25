variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_chart_version" {
  type    = string
  default = "7.7.11"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cd_apps_path" {
  type        = string
  description = "Caminho absoluto para CD/apps/ — usado no kubectl apply após instalar o ArgoCD"
}
