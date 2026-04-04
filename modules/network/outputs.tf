output "vpc_id" {
  value = module.this.vpc_id
}

output "vpc_cidr_block" {
  value = module.this.vpc_cidr_block
}

output "public_subnets" {
  value = module.this.public_subnets
}

output "private_subnets" {
  value = module.this.private_subnets
}

output "region" {
  value = var.aws_region
}

output "tags" {
  value = var.tags
}

output "azs" {
  value = module.this.azs
}

output "default_security_group_id" {
  value = module.this.default_security_group_id
}