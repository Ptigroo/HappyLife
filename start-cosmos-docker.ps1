# Script pour démarrer l'émulateur Azure Cosmos DB avec Docker

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Azure Cosmos DB Emulator (Docker)" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Docker est installé
try {
    docker --version | Out-Null
    Write-Host "? Docker est installé" -ForegroundColor Green
} catch {
    Write-Host "? Docker n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Red
    Write-Host "?? Installez Docker Desktop depuis: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Vérifier si le conteneur existe déjà
$containerName = "cosmos-emulator"
$existingContainer = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if ($existingContainer -eq $containerName) {
    Write-Host "?? Conteneur '$containerName' trouvé" -ForegroundColor Yellow
    
    # Vérifier si le conteneur est en cours d'exécution
    $runningContainer = docker ps --filter "name=$containerName" --format "{{.Names}}"
    
    if ($runningContainer -eq $containerName) {
        Write-Host "? Le conteneur est déjà en cours d'exécution" -ForegroundColor Green
    } else {
        Write-Host "?? Démarrage du conteneur existant..." -ForegroundColor Yellow
        docker start $containerName
        Write-Host "? Conteneur démarré" -ForegroundColor Green
    }
} else {
    Write-Host "?? Création et démarrage d'un nouveau conteneur Cosmos DB..." -ForegroundColor Yellow
    Write-Host "??  Première exécution: le téléchargement de l'image peut prendre plusieurs minutes" -ForegroundColor Yellow
    Write-Host ""
    
    docker run -d `
        --name $containerName `
        -p 8081:8081 `
        -p 10250-10255:10250-10255 `
        -e AZURE_COSMOS_EMULATOR_PARTITION_COUNT=10 `
        -e AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=true `
        mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "? Conteneur créé et démarré avec succès" -ForegroundColor Green
        Write-Host "? L'émulateur prend environ 1-2 minutes pour être complètement opérationnel..." -ForegroundColor Yellow
    } else {
        Write-Host "? Erreur lors de la création du conteneur" -ForegroundColor Red
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
Write-Host "?? Data Explorer: https://localhost:8081/_explorer/index.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "?? Commandes utiles:" -ForegroundColor Yellow
Write-Host "  • Voir les logs: docker logs -f $containerName" -ForegroundColor Gray
Write-Host "  • Arrêter: docker stop $containerName" -ForegroundColor Gray
Write-Host "  • Redémarrer: docker restart $containerName" -ForegroundColor Gray
Write-Host "  • Supprimer: docker rm -f $containerName" -ForegroundColor Gray
Write-Host ""
Write-Host "? Vous pouvez maintenant démarrer votre application!" -ForegroundColor Green
Write-Host ""
