data "aws_region" "current" {}

resource "kubernetes_secret_v1" "auth_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.services["auth-service"]]
  metadata {
    name      = "auth-service-db-secret-host"
    namespace = "auth-service"
  }
  data = {
    POSTGRES_HOST = var.db_auth_endpoint
  }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "flag_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.services["flag-service"]]
  metadata {
    name      = "flag-service-db-secret-host"
    namespace = "flag-service"
  }
  data = {
    POSTGRES_HOST = var.db_auth_endpoint
  }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "targeting_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.services["targeting-service"]]
  metadata {
    name      = "targeting-service-db-secret-host"
    namespace = "targeting-service"
  }
  data = {
    POSTGRES_HOST = var.db_targeting_endpoint
  }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "evaluation_db_endpoint" {
  depends_on = [kubernetes_namespace_v1.services["evaluation-service"]]
  metadata {
    name      = "evaluation-service-db-secret-host"
    namespace = "evaluation-service"
  }
  data = {
    REDIS_URL   = "rediss://${var.evaluation_db_endpoint}:6379"
    AWS_REGION  = data.aws_region.current.id
    AWS_SQS_URL = var.sqs_queue_url
  }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "analytics_db_endpoint" {
  depends_on = [kubernetes_namespace_v1.services["analytics-service"]]
  metadata {
    name      = "analytics-service-db-secret-host"
    namespace = "analytics-service"
  }
  data = {
    AWS_DYNAMODB_TABLE = var.dynamodb_url
    AWS_REGION         = data.aws_region.current.id
    AWS_SQS_URL        = var.sqs_queue_url
  }
  type = "Opaque"
}