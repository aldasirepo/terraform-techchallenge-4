variable "repository_name" {
  description = "Nome do repositório ECR"
  type = string
}

variable "tags" {
  description = "Tags para aplicar ao repositório ECR"
  type        = map(string)
  default     = {}
}

variable "aws_account_id" {
  description = "ID da conta AWS"
  type        = string
}