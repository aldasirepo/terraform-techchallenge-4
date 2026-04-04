# =============================================================================
# ToggleMaster - SUBIDA COMPLETA
# =============================================================================

$REGION          = "us-east-1"
$ACCOUNT_ID      = "251246746789"
$CLUSTER_NAME    = "togglemaster-eks"
$TERRAFORM_ROOT  = "C:\FIAP\TECH4\terraform-techchallenge-4"
$RDS_PASSWORD    = "TechChallenge4@2026"
$MASTER_KEY      = "masterkey123"
$SERVICE_API_KEY = "tm_key_7dfc8c2e8ff245f6987dba7391f76c1fd6a83b7d6c86e1e0aaf0f9c296614a76"
$SQS_URL         = "https://sqs.$REGION.amazonaws.com/$ACCOUNT_ID/togglemaster_prod_sqs_queue"
$DYNAMODB_TABLE  = "togglemaster-prod"
$POSTGRES_DB     = "togglemaster"
$POSTGRES_PORT   = "5432"
$POSTGRES_USER   = "togglemaster_admin"

# =============================================================================
# PASSO 1 - Terraform apply
# =============================================================================
Write-Host "`n[1/7] Terraform apply..." -ForegroundColor Cyan
Set-Location "$TERRAFORM_ROOT\environments\prod"
terraform apply -var="rds_password=$RDS_PASSWORD" --var-file=terraform.tfvars -auto-approve

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERRO] terraform apply falhou." -ForegroundColor Red
    exit 1
}
Write-Host "  Apply concluido." -ForegroundColor Green

# =============================================================================
# PASSO 2 - Endpoints dinamicos
# =============================================================================
Write-Host "`n[2/7] Buscando endpoints dinamicos..." -ForegroundColor Cyan

$RDS_HOST = aws rds describe-db-instances `
  --region $REGION `
  --query "DBInstances[?starts_with(DBInstanceIdentifier, 'togglemaster')].Endpoint.Address | [0]" `
  --output text

if (-not $RDS_HOST -or $RDS_HOST -eq "None") {
    $RDS_HOST = aws rds describe-db-instances `
      --region $REGION `
      --query "DBInstances[0].Endpoint.Address" `
      --output text
}

$REDIS_HOST = aws elasticache describe-cache-clusters `
  --region $REGION `
  --show-cache-node-info `
  --query "CacheClusters[0].CacheNodes[0].Endpoint.Address" `
  --output text

if (-not $RDS_HOST -or $RDS_HOST -eq "None") {
    Write-Host "[ERRO] Endpoint RDS nao encontrado." -ForegroundColor Red
    exit 1
}

if (-not $REDIS_HOST -or $REDIS_HOST -eq "None") {
    Write-Host "[ERRO] Endpoint Redis nao encontrado." -ForegroundColor Red
    exit 1
}

Write-Host "  RDS Host  : $RDS_HOST" -ForegroundColor Green
Write-Host "  Redis Host: $REDIS_HOST" -ForegroundColor Green

$SECRET_ID = aws secretsmanager list-secrets `
  --region $REGION `
  --query "SecretList[?starts_with(Name, 'rds!')].Name | [0]" `
  --output text

if ($SECRET_ID -and $SECRET_ID -ne "None") {
    $SECRET_RAW    = aws secretsmanager get-secret-value --secret-id $SECRET_ID --region $REGION --query SecretString --output text
    $SECRET_JSON   = $SECRET_RAW | ConvertFrom-Json
    $POSTGRES_USER = $SECRET_JSON.username
    $RDS_PASSWORD  = $SECRET_JSON.password
    Write-Host "  Senha obtida do Secrets Manager (usuario: $POSTGRES_USER)" -ForegroundColor Green
} else {
    Write-Host "  Secrets Manager nao encontrado, usando senha padrao." -ForegroundColor Yellow
}

$PASS_ENCODED = [Uri]::EscapeDataString($RDS_PASSWORD)
$DATABASE_URL = "postgres://${POSTGRES_USER}:${PASS_ENCODED}@${RDS_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=require"
$REDIS_URL    = "redis://${REDIS_HOST}:6379"

# =============================================================================
# PASSO 3 - kubeconfig + ArgoCD + Nginx Ingress
# =============================================================================
Write-Host "`n[3/7] Configurando kubectl, ArgoCD e Nginx Ingress..." -ForegroundColor Cyan

aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# ArgoCD
$argoNs = kubectl get namespace argocd --ignore-not-found 2>$null
if (-not $argoNs) {
    kubectl create namespace argocd
}

kubectl apply -n argocd `
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml `
  --server-side --force-conflicts

Write-Host "  Aguardando ArgoCD ficar pronto..." -ForegroundColor Yellow
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s

# Nginx Ingress Controller
Write-Host "  Instalando Nginx Ingress Controller..." -ForegroundColor Cyan
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/aws/deploy.yaml

Write-Host "  Aguardando Nginx Ingress ficar pronto..." -ForegroundColor Yellow
kubectl wait --for=condition=available deployment/ingress-nginx-controller -n ingress-nginx --timeout=120s

# Manifests CD - deletar root-app se existir para evitar cache antigo
$rootApp = kubectl get application root-app -n argocd --ignore-not-found 2>$null
if ($rootApp) {
    Write-Host "  Deletando root-app para evitar cache antigo..." -ForegroundColor Yellow
    kubectl delete application root-app -n argocd
    Start-Sleep -Seconds 5
}

Write-Host "  Aplicando manifests CD..." -ForegroundColor Cyan
Set-Location $TERRAFORM_ROOT
kubectl apply --server-side --force-conflicts -k CD/base/
kubectl apply --server-side --force-conflicts -k CD/apps/

Write-Host "  ArgoCD e Nginx OK." -ForegroundColor Green

# =============================================================================
# PASSO 4 - Namespaces e secrets
# =============================================================================
Write-Host "`n[4/7] Criando namespaces e secrets..." -ForegroundColor Cyan

foreach ($ns in @("auth-service","flag-service","targeting-service","evaluation-service","analytics-service")) {
    $exists = kubectl get namespace $ns --ignore-not-found 2>$null
    if (-not $exists) {
        kubectl create namespace $ns
    }
}

function New-K8sSecret([string]$Name, [string]$Namespace, [string[]]$Literals) {
    kubectl delete secret $Name -n $Namespace --ignore-not-found 2>$null | Out-Null
    $cmd = @("create","secret","generic",$Name,"-n",$Namespace) + $Literals
    kubectl @cmd 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    OK: $Name" -ForegroundColor Green
    } else {
        Write-Host "    ERRO: $Name" -ForegroundColor Red
    }
}

# auth-service
Write-Host "  [auth-service]" -ForegroundColor White
New-K8sSecret "auth-service-db-secret" "auth-service" @(
    "--from-literal=POSTGRES_USER=$POSTGRES_USER",
    "--from-literal=POSTGRES_PASSWORD=$RDS_PASSWORD",
    "--from-literal=POSTGRES_DB=$POSTGRES_DB",
    "--from-literal=POSTGRES_PORT=$POSTGRES_PORT",
    "--from-literal=MASTER_KEY=$MASTER_KEY",
    "--from-literal=DATABASE_URL=$DATABASE_URL"
)
New-K8sSecret "auth-service-db-secret-host" "auth-service" @(
    "--from-literal=POSTGRES_HOST=$RDS_HOST"
)

# flag-service
Write-Host "  [flag-service]" -ForegroundColor White
New-K8sSecret "flag-service-db-secret" "flag-service" @(
    "--from-literal=POSTGRES_USER=$POSTGRES_USER",
    "--from-literal=POSTGRES_PASSWORD=$RDS_PASSWORD",
    "--from-literal=POSTGRES_DB=$POSTGRES_DB",
    "--from-literal=POSTGRES_PORT=$POSTGRES_PORT",
    "--from-literal=AUTH_SERVICE_URL=http://app-auth-service.auth-service.svc.cluster.local:8001",
    "--from-literal=DATABASE_URL=$DATABASE_URL"
)
New-K8sSecret "flag-service-db-secret-host" "flag-service" @(
    "--from-literal=POSTGRES_HOST=$RDS_HOST"
)

# targeting-service
Write-Host "  [targeting-service]" -ForegroundColor White
New-K8sSecret "targeting-service-db-secret" "targeting-service" @(
    "--from-literal=POSTGRES_USER=$POSTGRES_USER",
    "--from-literal=POSTGRES_PASSWORD=$RDS_PASSWORD",
    "--from-literal=POSTGRES_DB=$POSTGRES_DB",
    "--from-literal=POSTGRES_PORT=$POSTGRES_PORT",
    "--from-literal=AUTH_SERVICE_URL=http://app-auth-service.auth-service.svc.cluster.local:8001",
    "--from-literal=DATABASE_URL=$DATABASE_URL"
)
New-K8sSecret "targeting-service-db-secret-host" "targeting-service" @(
    "--from-literal=POSTGRES_HOST=$RDS_HOST"
)

# evaluation-service
Write-Host "  [evaluation-service]" -ForegroundColor White
New-K8sSecret "evaluation-service-db-secret" "evaluation-service" @(
    "--from-literal=REDIS_URL=$REDIS_URL",
    "--from-literal=FLAG_SERVICE_URL=http://app-flag-service.flag-service.svc.cluster.local:8002",
    "--from-literal=TARGETING_SERVICE_URL=http://app-targeting-service.targeting-service.svc.cluster.local:8003",
    "--from-literal=AWS_SQS_URL=$SQS_URL",
    "--from-literal=AWS_REGION=$REGION",
    "--from-literal=SERVICE_API_KEY=$SERVICE_API_KEY"
)
New-K8sSecret "evaluation-service-db-secret-host" "evaluation-service" @(
    "--from-literal=REDIS_URL=$REDIS_URL",
    "--from-literal=AWS_REGION=$REGION",
    "--from-literal=AWS_SQS_URL=$SQS_URL"
)
New-K8sSecret "shared-api-key" "evaluation-service" @(
    "--from-literal=SERVICE_API_KEY=$SERVICE_API_KEY"
)

# analytics-service
Write-Host "  [analytics-service]" -ForegroundColor White
New-K8sSecret "analytics-service-db-secret" "analytics-service" @(
    "--from-literal=AWS_REGION=$REGION",
    "--from-literal=AWS_SQS_URL=$SQS_URL",
    "--from-literal=AWS_DYNAMODB_TABLE=$DYNAMODB_TABLE"
)

# =============================================================================
# PASSO 5 - Aguardar NLB ficar disponivel
# =============================================================================
Write-Host "`n[5/7] Aguardando NLB ficar disponivel..." -ForegroundColor Cyan

$maxWait = 24
$count   = 0
$LB      = $null
$tcp     = $null

do {
    Start-Sleep -Seconds 15
    $count++
    $LB = aws elbv2 describe-load-balancers --region $REGION `
      --query "LoadBalancers[0].DNSName" --output text 2>$null
    if ($LB -and $LB -ne "None") {
        $tcp = Test-NetConnection -ComputerName $LB -Port 80 -WarningAction SilentlyContinue
        if ($tcp.TcpTestSucceeded) {
            Write-Host "  NLB pronto: $LB" -ForegroundColor Green
            break
        } else {
            Write-Host "  NLB existe mas ainda nao responde... ($($count * 15)s)"
        }
    } else {
        Write-Host "  Aguardando NLB ser criado... ($($count * 15)s)"
    }
} while ($count -lt $maxWait)

if (-not $tcp -or -not $tcp.TcpTestSucceeded) {
    Write-Host "  NLB ainda nao responde apos 6 min - verifique manualmente." -ForegroundColor Yellow
}

# =============================================================================
# PASSO 6 - Recriar applications de monitoramento (evitar cache)
# =============================================================================
Write-Host "`n[6/7] Recriando applications de monitoramento..." -ForegroundColor Cyan

Write-Host "  Aguardando ArgoCD processar aplicacoes iniciais..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

foreach ($app in @("prometheus","otel-collector")) {
    $exists = kubectl get application $app -n argocd --ignore-not-found 2>$null
    if ($exists) {
        Write-Host "  Deletando $app..." -ForegroundColor Yellow
        kubectl delete application $app -n argocd
        Start-Sleep -Seconds 5
    }
}

kubectl apply -f "$TERRAFORM_ROOT\CD\apps\monitoring\argocd-app-prometheus.yaml"
kubectl apply -f "$TERRAFORM_ROOT\CD\apps\monitoring\argocd-app-otel.yaml"

Write-Host "  Aguardando Prometheus e OTel subirem (~2 min)..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

# =============================================================================
# PASSO 7 - Status final
# =============================================================================
Write-Host "`n[7/7] Status dos pods..." -ForegroundColor Cyan
kubectl get pods -A --no-headers | Where-Object { $_ -match "service|argocd|monitoring" }

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host " SUBIDA FINALIZADA" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  RDS Host  : $RDS_HOST"
Write-Host "  Redis URL : $REDIS_URL"
if ($LB -and $LB -ne "None") {
    Write-Host "  LB URL    : http://$LB"
}
Write-Host ""
Write-Host "  ArgoCD : kubectl port-forward svc/argocd-server -n argocd 8080:80"
Write-Host "  Grafana: kubectl port-forward svc/prometheus-grafana -n monitoring 9090:80"
Write-Host "           Acesse: http://127.0.0.1:9090/grafana | admin / admin123"
Write-Host ""
Write-Host "  IMPORTANTE: As imagens do ECR foram destruidas junto com a infra." -ForegroundColor Yellow
Write-Host "  Rode o deploy-all no GitHub Actions para fazer o push das imagens:" -ForegroundColor Yellow
Write-Host "  https://github.com/aldasirepo/tech-challenge-4/actions/workflows/deploy-all.yml" -ForegroundColor Yellow
Write-Host "  Apos o Actions terminar, o ArgoCD sincroniza automaticamente." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Lembre de dar DESTROY ao terminar: .\1-destroy.ps1"
