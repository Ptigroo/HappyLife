# HappyLife Kubernetes Deployment Script for Minikube
# This script automates the deployment process for Windows PowerShell

# Exit on error
$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "HappyLife Kubernetes Deployment Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Minikube is running
Write-Host "Checking Minikube status..." -ForegroundColor Yellow
try {
    $minikubeStatus = minikube status 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Minikube not running"
    }
    Write-Host "Minikube is already running" -ForegroundColor Green
} catch {
    Write-Host "Minikube is not running. Starting Minikube..." -ForegroundColor Yellow
    minikube start --cpus=4 --memory=8192 --driver=docker
    Write-Host "Minikube started successfully" -ForegroundColor Green
}

# Configure Docker to use Minikube's daemon
Write-Host ""
Write-Host "Configuring Docker environment..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
Write-Host "Docker configured to use Minikube's daemon" -ForegroundColor Green

# Build Docker image
Write-Host ""
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t happylife-webapp:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image built successfully" -ForegroundColor Green

# Check if namespace exists
Write-Host ""
Write-Host "Checking if namespace exists..." -ForegroundColor Yellow
$ErrorActionPreference = "SilentlyContinue"
$namespaceCheck = kubectl get namespace happylife 2>&1
$namespaceExists = $LASTEXITCODE -eq 0
$ErrorActionPreference = "Stop"

if ($namespaceExists) {
    Write-Host "Namespace 'happylife' already exists" -ForegroundColor Yellow
    $response = Read-Host "Do you want to delete and recreate it? (y/N)"
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Host "Deleting existing namespace..." -ForegroundColor Yellow
        kubectl delete namespace happylife
        Write-Host "Waiting for namespace to be fully deleted..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Write-Host "Namespace deleted" -ForegroundColor Green
    } else {
        Write-Host "Keeping existing namespace. Will update resources..." -ForegroundColor Yellow
    }
} else {
    Write-Host "Namespace 'happylife' does not exist. Will create it..." -ForegroundColor Yellow
}

# Check if API key is set in secret
Write-Host ""
Write-Host "Checking Azure API key configuration..." -ForegroundColor Yellow
$secretContent = Get-Content -Path "k8s/app-secret.yaml" -Raw
if ($secretContent -match "YOUR_API_KEY_HERE") {
    Write-Host "ERROR: Azure API key not set in k8s/app-secret.yaml" -ForegroundColor Red
    Write-Host "Please update the AZURE_DOC_INTEL_API_KEY value before deploying." -ForegroundColor Red
    exit 1
}
Write-Host "Azure API key is configured" -ForegroundColor Green

# Deploy Kubernetes resources
Write-Host ""
Write-Host "Deploying Kubernetes resources..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql-secret.yaml
kubectl apply -f k8s/app-secret.yaml
kubectl apply -f k8s/app-configmap.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml
kubectl apply -f k8s/webapp-deployment.yaml
kubectl apply -f k8s/webapp-service.yaml

Write-Host "All resources deployed successfully" -ForegroundColor Green

# Wait for MySQL to be ready
Write-Host ""
Write-Host "Waiting for MySQL to be ready (this may take a few minutes)..." -ForegroundColor Yellow
Write-Host "Timeout: 5 minutes" -ForegroundColor Gray
$ErrorActionPreference = "Continue"
kubectl wait --for=condition=ready pod -l app=mysql -n happylife --timeout=300s
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: MySQL may not be ready yet. Checking status..." -ForegroundColor Yellow
    kubectl get pods -n happylife -l app=mysql
    Write-Host "You can check logs with: kubectl logs -n happylife -l app=mysql" -ForegroundColor Gray
} else {
    Write-Host "MySQL is ready" -ForegroundColor Green
}
$ErrorActionPreference = "Stop"

# Wait for webapp to be ready
Write-Host ""
Write-Host "Waiting for webapp to be ready (this may take a few minutes)..." -ForegroundColor Yellow
Write-Host "Timeout: 5 minutes" -ForegroundColor Gray
$ErrorActionPreference = "Continue"
kubectl wait --for=condition=ready pod -l app=webapp -n happylife --timeout=300s
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Webapp may not be ready yet. Checking status..." -ForegroundColor Yellow
    kubectl get pods -n happylife -l app=webapp
    Write-Host "You can check logs with: kubectl logs -n happylife -l app=webapp" -ForegroundColor Gray
} else {
    Write-Host "Webapp is ready" -ForegroundColor Green
}
$ErrorActionPreference = "Stop"

# Display deployment status
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Deployment Status" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
kubectl get all -n happylife

# Get service URL
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Access Information" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
$minikubeIP = minikube ip
Write-Host "Application URL: http://${minikubeIP}:30080" -ForegroundColor Green
Write-Host "Swagger UI:      http://${minikubeIP}:30080/swagger" -ForegroundColor Green
Write-Host "Health Check:    http://${minikubeIP}:30080/health" -ForegroundColor Green
Write-Host ""
Write-Host "You can also use:" -ForegroundColor Cyan
Write-Host "  minikube service webapp-service -n happylife" -ForegroundColor White
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Cyan
Write-Host "  kubectl logs -n happylife -l app=webapp -f" -ForegroundColor White
Write-Host "  kubectl logs -n happylife -l app=mysql -f" -ForegroundColor White
Write-Host ""
Write-Host "To access Kubernetes dashboard:" -ForegroundColor Cyan
Write-Host "  minikube dashboard" -ForegroundColor White
Write-Host ""
Write-Host "To scale the application:" -ForegroundColor Cyan
Write-Host "  kubectl scale deployment webapp -n happylife --replicas=3" -ForegroundColor White
Write-Host ""
Write-Host "Deployment completed successfully!" -ForegroundColor Green
