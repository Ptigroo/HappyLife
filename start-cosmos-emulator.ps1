# Script pour démarrer l'émulateur Azure Cosmos DB localement

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Azure Cosmos DB Emulator Setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si l'émulateur est installé
$emulatorPath = "C:\Program Files\Azure Cosmos DB Emulator\CosmosDB.Emulator.exe"

if (-not (Test-Path $emulatorPath)) {
    Write-Host "? L'émulateur Azure Cosmos DB n'est pas installé." -ForegroundColor Red
    Write-Host ""
    Write-Host "?? Téléchargez et installez l'émulateur depuis:" -ForegroundColor Yellow
    Write-Host "https://aka.ms/cosmosdb-emulator" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "?? Alternative: Utilisez Docker" -ForegroundColor Cyan
    Write-Host "docker run -p 8081:8081 -p 10250-10255:10250-10255 --name cosmos-emulator mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest" -ForegroundColor Gray
    exit 1
}

Write-Host "? Émulateur trouvé à: $emulatorPath" -ForegroundColor Green
Write-Host ""

# Vérifier si l'émulateur est déjà en cours d'exécution
$emulatorProcess = Get-Process -Name "CosmosDB.Emulator" -ErrorAction SilentlyContinue

if ($emulatorProcess) {
    Write-Host "? L'émulateur Cosmos DB est déjà en cours d'exécution." -ForegroundColor Green
    Write-Host ""
    Write-Host "?? Data Explorer: https://localhost:8081/_explorer/index.html" -ForegroundColor Cyan
} else {
    Write-Host "?? Démarrage de l'émulateur Cosmos DB..." -ForegroundColor Yellow
    Write-Host ""
    
    # Démarrer l'émulateur
    Start-Process $emulatorPath -ArgumentList "/NoUI" -PassThru
    
    Write-Host "? Attente du démarrage de l'émulateur (cela peut prendre 1-2 minutes)..." -ForegroundColor Yellow
    
    # Attendre que l'émulateur soit prêt
    $maxAttempts = 60
    $attempt = 0
    $isReady = $false
    
    while (-not $isReady -and $attempt -lt $maxAttempts) {
        Start-Sleep -Seconds 2
        $attempt++
        
        try {
            $response = Invoke-WebRequest -Uri "https://localhost:8081/_explorer/emulator.pem" -SkipCertificateCheck -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $isReady = $true
            }
        } catch {
            # L'émulateur n'est pas encore prêt
        }
        
        if ($attempt % 5 -eq 0) {
            Write-Host "  ? Tentative $attempt/$maxAttempts..." -ForegroundColor Gray
        }
    }
    
    if ($isReady) {
        Write-Host ""
        Write-Host "? L'émulateur Cosmos DB est maintenant opérationnel!" -ForegroundColor Green
        Write-Host ""
        Write-Host "?? Data Explorer: https://localhost:8081/_explorer/index.html" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "? L'émulateur n'a pas démarré dans le délai imparti." -ForegroundColor Red
        Write-Host "Veuillez vérifier les logs et réessayer." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Configuration de connexion" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Endpoint: https://localhost:8081" -ForegroundColor White
Write-Host "Key: C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==" -ForegroundColor White
Write-Host ""
Write-Host "? Vous pouvez maintenant démarrer votre application!" -ForegroundColor Green
Write-Host ""
