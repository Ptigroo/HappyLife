# Cleanup script for HappyLife Kubernetes deployment

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "HappyLife Kubernetes Cleanup Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will delete all HappyLife resources from Kubernetes" -ForegroundColor Yellow
$response = Read-Host "Are you sure you want to continue? (y/N)"

if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "Cleanup cancelled" -ForegroundColor Yellow
    exit 0
}

# Delete namespace (this will delete everything in it)
Write-Host ""
Write-Host "Deleting namespace and all resources..." -ForegroundColor Yellow
kubectl delete namespace happylife

Write-Host ""
Write-Host "Cleanup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To also clean up Minikube:"
Write-Host "  minikube stop    # Stop Minikube"
Write-Host "  minikube delete  # Delete Minikube cluster"
