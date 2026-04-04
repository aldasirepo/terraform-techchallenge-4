# locals {
#   name = "teste"
# }

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.1.0"

  repository_name = var.repository_name

  repository_force_delete         = true
  repository_image_tag_mutability = "MUTABLE"
  repository_read_write_access_arns = [
    "arn:aws:iam::${var.aws_account_id}:user/techchallenge-admin"
  ]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = var.tags
}