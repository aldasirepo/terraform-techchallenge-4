# =============================================================================
# ToggleMaster - DESTROY COMPLETO
# =============================================================================

$REGION         = "us-east-1"
$VPC_ID         = "vpc-0675755f6df00fd02"
$TERRAFORM_ROOT = "C:\FIAP\TECH4\terraform-techchallenge-4"
$RDS_PASSWORD   = "TechChallenge4@2026"

# =============================================================================
# PASSO 1 - Liberar Elastic IPs
# =============================================================================
Write-Host "`n[1/4] Liberando Elastic IPs..." -ForegroundColor Cyan

$eips = aws ec2 describe-addresses --region $REGION `
  --query "Addresses[*].{AllocId:AllocationId,AssocId:AssociationId}" `
  --output json | ConvertFrom-Json

if ($eips.Count -eq 0) {
    Write-Host "  Nenhum EIP encontrado." -ForegroundColor Green
} else {
    foreach ($eip in $eips) {
        if ($eip.AssocId) {
            Write-Host "  Desassociando: $($eip.AssocId)"
            aws ec2 disassociate-address --association-id $eip.AssocId --region $REGION
        }
        Write-Host "  Liberando: $($eip.AllocId)"
        aws ec2 release-address --allocation-id $eip.AllocId --region $REGION
    }
}

# =============================================================================
# PASSO 2 - Deletar Load Balancers
# =============================================================================
Write-Host "`n[2/4] Deletando Load Balancers orfaos..." -ForegroundColor Cyan

$lbs = aws elbv2 describe-load-balancers --region $REGION `
  --query "LoadBalancers[*].LoadBalancerArn" --output json | ConvertFrom-Json

if ($lbs.Count -eq 0) {
    Write-Host "  Nenhum LB encontrado." -ForegroundColor Green
} else {
    foreach ($arn in $lbs) {
        Write-Host "  Deletando LB: $arn"
        aws elbv2 delete-load-balancer --load-balancer-arn $arn --region $REGION
    }
    Write-Host "  LBs deletados. ENIs serao liberadas pela AWS automaticamente." -ForegroundColor Yellow
}

# =============================================================================
# PASSO 3 - Terraform destroy
# =============================================================================
Write-Host "`n[3/4] Terraform destroy..." -ForegroundColor Red

Set-Location "$TERRAFORM_ROOT\environments\prod"
terraform destroy -var="rds_password=$RDS_PASSWORD" --var-file=terraform.tfvars

Write-Host "  Terraform destroy finalizado." -ForegroundColor Yellow

# =============================================================================
# PASSO 4 - Limpar VPC manualmente (SG, subnet, IGW)
# =============================================================================
Write-Host "`n[4/4] Limpando restos da VPC manualmente..." -ForegroundColor Cyan

$sgs = aws ec2 describe-security-groups --region $REGION `
  --filters "Name=vpc-id,Values=$VPC_ID" `
  --query "SecurityGroups[?GroupName!='default'].GroupId" --output json | ConvertFrom-Json

foreach ($sg in $sgs) {
    Write-Host "  Deletando SG: $sg"
    aws ec2 delete-security-group --region $REGION --group-id $sg 2>$null
}

$subnets = aws ec2 describe-subnets --region $REGION `
  --filters "Name=vpc-id,Values=$VPC_ID" `
  --query "Subnets[*].SubnetId" --output json | ConvertFrom-Json

foreach ($subnet in $subnets) {
    Write-Host "  Deletando Subnet: $subnet"
    aws ec2 delete-subnet --region $REGION --subnet-id $subnet 2>$null
}

$igws = aws ec2 describe-internet-gateways --region $REGION `
  --filters "Name=attachment.vpc-id,Values=$VPC_ID" `
  --query "InternetGateways[*].InternetGatewayId" --output json | ConvertFrom-Json

foreach ($igw in $igws) {
    Write-Host "  Desanexando IGW: $igw"
    aws ec2 detach-internet-gateway --region $REGION `
      --internet-gateway-id $igw --vpc-id $VPC_ID 2>$null
    Write-Host "  Deletando IGW: $igw"
    aws ec2 delete-internet-gateway --region $REGION --internet-gateway-id $igw 2>$null
}

Write-Host "  Deletando VPC: $VPC_ID"
aws ec2 delete-vpc --region $REGION --vpc-id $VPC_ID 2>$null

# =============================================================================
# VERIFICACAO FINAL (aguarda 2 min para AWS processar)
# =============================================================================
Write-Host "`n  Aguardando 2 min para AWS processar destruicao..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host " VERIFICACAO FINAL" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "`n  EKS Clusters:"
$eks = aws eks list-clusters --region $REGION --query "clusters" --output json | ConvertFrom-Json
if ($eks.Count -eq 0) { Write-Host "  OK - nenhum cluster." -ForegroundColor Green } else { Write-Host "  ATENCAO: $eks" -ForegroundColor Red }

Write-Host "`n  RDS Instances:"
$rds = aws rds describe-db-instances --region $REGION --query "DBInstances[*].DBInstanceIdentifier" --output json | ConvertFrom-Json
if ($rds.Count -eq 0) { Write-Host "  OK - nenhuma instancia." -ForegroundColor Green } else { Write-Host "  ATENCAO: $rds" -ForegroundColor Red }

Write-Host "`n  NAT Gateways:"
$nat = aws ec2 describe-nat-gateways --region $REGION `
  --filter "Name=vpc-id,Values=$VPC_ID" `
  --query "NatGateways[?State!='deleted'].NatGatewayId" --output json | ConvertFrom-Json
if ($nat.Count -eq 0) { Write-Host "  OK - nenhum NAT Gateway." -ForegroundColor Green } else { Write-Host "  ATENCAO: $nat" -ForegroundColor Red }

Write-Host "`n  ElastiCache:"
$redis = aws elasticache describe-cache-clusters --region $REGION `
  --query "CacheClusters[*].CacheClusterId" --output json | ConvertFrom-Json
if ($redis.Count -eq 0) { Write-Host "  OK - nenhum cluster Redis." -ForegroundColor Green } else { Write-Host "  ATENCAO: $redis" -ForegroundColor Red }

Write-Host "`n  Load Balancers:"
$lbsRestantes = aws elbv2 describe-load-balancers --region $REGION `
  --query "LoadBalancers[*].LoadBalancerName" --output json | ConvertFrom-Json
if ($lbsRestantes.Count -eq 0) { Write-Host "  OK - nenhum LB." -ForegroundColor Green } else { Write-Host "  ATENCAO: $lbsRestantes" -ForegroundColor Red }

Write-Host "`n  ENIs (sem custo, AWS libera automaticamente):"
$enisFinal = aws ec2 describe-network-interfaces --region $REGION `
  --filters "Name=vpc-id,Values=$VPC_ID" `
  --query "NetworkInterfaces[*].NetworkInterfaceId" --output text
if ($enisFinal) { Write-Host "  Ainda presas: $enisFinal" -ForegroundColor Yellow } else { Write-Host "  OK - nenhuma ENI." -ForegroundColor Green }

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host " DESTROY FINALIZADO" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Custo estimado agora: ~`$0.00/dia"
Write-Host "  Para subir de novo: .\2-apply.ps1"
