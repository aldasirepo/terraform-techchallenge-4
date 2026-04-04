# Terraform Modules - Tech Challenge

Infraestrutura AWS provisionada com Terraform usando arquitetura modular.

Principais componentes:
- **Network (VPC)**
- **EKS Cluster + Managed Node Group**
- **ECR** (repositórios para os serviços)
- **Databases** (RDS Postgres + DynamoDB + ElastiCache)
- **SQS** (módulo `resources`)
- **Kubernetes** (namespaces e secrets)

## Estrutura do repositório

```
.
├── .github/workflows/         # Pipelines (GitHub Actions)
├── bootstrap/                 # Criação do bucket S3 do backend
├── environments/
│   └── prod/                  # Ambiente de produção
├── modules/
│   ├── network/               # VPC/Subnets/NAT
│   ├── eks-cluster/           # EKS + node groups
│   ├── ecr/                   # Repositórios ECR
│   ├── databases/             # RDS + DynamoDB + ElastiCache
│   ├── resources/             # SQS
│   └── kubernetes/            # Namespaces e secrets
├── jobs/                      # Jobs Kubernetes
└── CD/                        # Manifests ArgoCD
```

## Backend (state remoto)

- **Bucket**: `techchallenge4-togglemaster-state`
- **Key**: `techchallenge4/prod/terraform.tfstate`

## Pré-requisitos

- Terraform >= 1.5.0
- AWS CLI v2
- kubectl
- Helm

## Como executar

### 1) Criar o bucket do backend (bootstrap)

```bash
cd bootstrap/
terraform init
terraform apply
```

### 2) Inicializar e aplicar produção

```bash
cd environments/prod/
terraform init
terraform apply --var-file=terraform.tfvars -var="rds_password=SuaSenha123"
```

## Kubernetes / EKS

Após o `terraform apply`:

```bash
aws eks update-kubeconfig --name togglemaster-eks --region us-east-1
kubectl get nodes
kubectl get namespaces
```
