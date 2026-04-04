locals {
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
 
  public_subnets  = [for i in range(length(local.azs)) : cidrsubnet(var.cidr_block, 4, i)]
  private_subnets = [for i, az in local.azs : cidrsubnet(var.cidr_block, 4, i + 10)]
}

module "this" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.0"

  name = var.project_name
  cidr = var.cidr_block
  azs = local.azs

  tags = var.tags

  public_subnets = local.public_subnets
  private_subnets = local.private_subnets

  create_multiple_public_route_tables  = true
  enable_nat_gateway = true
  single_nat_gateway = true
  manage_default_route_table = false

  vpc_tags = merge(
    var.tags,
    { Name = var.project_name }
  )

  igw_tags = merge(
    var.tags,
    { Name = "igw-${var.project_name}" }
  )

  default_network_acl_tags = merge(
    var.tags,
    { Name = "acl-${var.project_name}" }
  )

  # Não cria SG default
  manage_default_security_group = false

  nat_gateway_tags = merge(
    var.tags,
    { Name = "nat-${var.project_name}" }
  )

  public_subnet_tags = merge(
    var.network_tags,
    {
      "kubernetes.io/role/elb"                    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )

  private_subnet_tags = merge(
    var.network_tags,
    {
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } 
  )

  public_route_table_tags = merge(
    var.tags,
    { Name = "${var.project_name}-public-rt" }
  )

  private_route_table_tags = merge(
    var.tags,
    { Name = "${var.project_name}-private-rt" }
  )
}