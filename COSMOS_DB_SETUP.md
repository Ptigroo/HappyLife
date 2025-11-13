# Configuration Azure Cosmos DB

## Vue d'ensemble

L'application HappyLife utilise maintenant **Azure Cosmos DB** au lieu d'une base de données en mémoire. Cela permet :
- ? **Persistance des données** entre les redémarrages
- ? **Scalabilité** pour de grandes quantités de données
- ? **Performance** avec indexation automatique
- ? **Clé de partition** optimisée sur `NormalizedName`

## Options pour exécuter Cosmos DB localement

### Option 1 : Émulateur Windows (Recommandé pour Windows)

#### Installation
1. Téléchargez l'émulateur : https://aka.ms/cosmosdb-emulator
2. Installez l'émulateur
3. Lancez le script PowerShell :
   ```powershell
   .\start-cosmos-emulator.ps1
   ```

#### Caractéristiques
- ? Interface graphique Data Explorer incluse
- ? Performances optimales sur Windows
- ?? Disponible uniquement sur Windows

### Option 2 : Docker (Multiplateforme)

#### Prérequis
- Docker Desktop installé et démarré

#### Démarrage
```powershell
.\start-cosmos-docker.ps1
```

Ou manuellement :
```bash
docker run -d \
  --name cosmos-emulator \
  -p 8081:8081 \
  -p 10250-10255:10250-10255 \
  mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
```

#### Caractéristiques
- ? Fonctionne sur Windows, macOS et Linux
- ? Isolation dans un conteneur
- ?? Première exécution : téléchargement ~2GB

## Configuration de l'application

### Connection String
Les paramètres de connexion sont dans `appsettings.json` :

```json
{
  "CosmosDb": {
    "AccountEndpoint": "https://localhost:8081",
    "AccountKey": "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==",
    "DatabaseName": "HappyLifeDb"
  }
}
```

?? **Note** : La clé ci-dessus est la clé par défaut de l'émulateur local. **Ne l'utilisez jamais en production !**

### Structure de la base de données

**Base de données** : `HappyLifeDb`

**Conteneur** : `Consumables`
- **Clé de partition** : `/NormalizedName`
- **Indexation** : Automatique sur toutes les propriétés

### Clé de partition

La clé de partition est `NormalizedName` car :
- ? Distribution équilibrée des données (différents produits)
- ? Requêtes optimisées lors de la recherche de consommables similaires
- ? Meilleure performance pour les opérations CRUD

## Accès au Data Explorer

Une fois l'émulateur démarré, accédez au Data Explorer :
- **URL** : https://localhost:8081/_explorer/index.html

Le Data Explorer permet de :
- ?? Visualiser les données
- ?? Exécuter des requêtes SQL
- ?? Gérer les conteneurs et les bases de données
- ?? Voir les métriques de performance

## Démarrage de l'application

1. **Démarrer Cosmos DB** (choisir une option) :
   ```powershell
   # Option 1 : Émulateur Windows
   .\start-cosmos-emulator.ps1
   
   # Option 2 : Docker
   .\start-cosmos-docker.ps1
   ```

2. **Démarrer l'application** :
   ```bash
   dotnet run --project HappyLife
   ```

3. **Première exécution** :
   - La base de données `HappyLifeDb` est créée automatiquement
   - Le conteneur `Consumables` est créé automatiquement

## Gestion du certificat SSL (Émulateur Windows)

L'émulateur Cosmos DB utilise un certificat auto-signé. Pour éviter les avertissements :

### PowerShell (Admin)
```powershell
# Exporter le certificat
$cert = Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Subject -eq "CN=localhost"}
Export-Certificate -Cert $cert -FilePath "C:\cosmos-cert.cer"

# Importer dans Trusted Root (si nécessaire)
Import-Certificate -FilePath "C:\cosmos-cert.cer" -CertStoreLocation Cert:\CurrentUser\Root
```

### Dans le code (déjà configuré dans Program.cs)
Le code ignore automatiquement les erreurs de certificat en développement.

## Migration vers Azure Cosmos DB en production

### 1. Créer une instance Cosmos DB sur Azure
```bash
az cosmosdb create \
  --name happylife-cosmosdb \
  --resource-group happylife-rg \
  --default-consistency-level Session
```

### 2. Mettre à jour appsettings.Production.json
```json
{
  "CosmosDb": {
    "AccountEndpoint": "https://happylife-cosmosdb.documents.azure.com:443/",
    "AccountKey": "YOUR_PRODUCTION_KEY",
    "DatabaseName": "HappyLifeDb"
  }
}
```

?? **Sécurité** : Utilisez Azure Key Vault pour stocker la clé en production !

### 3. Utiliser Managed Identity (recommandé)
```csharp
builder.Services.AddDbContext<HappyLifeDbContext>(options =>
{
    var credential = new DefaultAzureCredential();
    options.UseCosmos(
        cosmosDbConfig.AccountEndpoint,
        credential,
        cosmosDbConfig.DatabaseName);
});
```

## Requêtes Cosmos DB

### Exemples de requêtes SQL dans Data Explorer

**Tous les consommables** :
```sql
SELECT * FROM c
```

**Recherche par nom normalisé** :
```sql
SELECT * FROM c WHERE c.NormalizedName = "salmon"
```

**Consommables avec quantité > 0** :
```sql
SELECT * FROM c WHERE c.Quantity > 0
```

**Prix moyen par produit** :
```sql
SELECT c.NormalizedName, AVG(c.Price) as avgPrice 
FROM c 
GROUP BY c.NormalizedName
```

## Dépannage

### L'émulateur ne démarre pas
- Vérifiez que le port 8081 n'est pas déjà utilisé
- Redémarrez votre ordinateur
- Réinstallez l'émulateur

### Erreur de certificat SSL
```
HttpRequestException: The SSL connection could not be established
```

**Solution** :
- Utilisez l'option `-SkipCertificateCheck` en développement
- Ou importez le certificat de l'émulateur

### Docker : Conteneur ne démarre pas
```bash
# Voir les logs
docker logs cosmos-emulator

# Supprimer et recréer
docker rm -f cosmos-emulator
.\start-cosmos-docker.ps1
```

### Base de données non créée automatiquement
Vérifiez que `EnsureCreatedAsync()` est appelé dans `Program.cs`.

## Commandes utiles

### Docker
```bash
# Status
docker ps -a | grep cosmos

# Logs
docker logs -f cosmos-emulator

# Arrêter
docker stop cosmos-emulator

# Redémarrer
docker restart cosmos-emulator

# Supprimer
docker rm -f cosmos-emulator
```

### Émulateur Windows
```powershell
# Vérifier le processus
Get-Process -Name "CosmosDB.Emulator"

# Arrêter
Stop-Process -Name "CosmosDB.Emulator"
```

## Performances et coûts

### En développement (émulateur)
- ? Gratuit
- ? Pas de limite de requêtes
- ? Données locales

### En production (Azure)
- ?? Facturation basée sur les RU/s (Request Units)
- ?? Stockage facturé au Go
- ?? Surveillez les métriques dans le portail Azure

### Optimisations
1. Utilisez la clé de partition dans toutes les requêtes
2. Indexez uniquement les propriétés nécessaires
3. Limitez la taille des documents
4. Utilisez les requêtes paginées pour les grandes listes

## Ressources

- [Documentation Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/)
- [Émulateur Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/local-emulator)
- [Cosmos DB avec Entity Framework Core](https://docs.microsoft.com/ef/core/providers/cosmos/)
- [Best practices Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/best-practice)
