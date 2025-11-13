# Migration vers Azure Cosmos DB - Résumé des changements

## ? Changements effectués

### 1. Installation des packages NuGet
- ? Ajout de `Microsoft.EntityFrameworkCore.Cosmos` version 9.0.0
- ? Conservation de `Microsoft.EntityFrameworkCore` version 9.0.10

### 2. Nouveau modèle de configuration
**Fichier créé** : `HappyLifeModels/CosmosDbOptions.cs`
```csharp
public class CosmosDbOptions
{
    public string AccountEndpoint { get; set; }
    public string AccountKey { get; set; }
    public string DatabaseName { get; set; }
}
```

### 3. Configuration mise à jour

**`appsettings.json`** et **`appsettings.Development.json`**
```json
{
  "CosmosDb": {
    "AccountEndpoint": "https://localhost:8081",
    "AccountKey": "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==",
    "DatabaseName": "HappyLifeDb"
  }
}
```

?? La clé fournie est celle de l'émulateur local (sécurisée pour le développement).

### 4. DbContext reconfiguré

**`HappyLifeRepository/HappyLifeDbContext.cs`**
- ? Configuration Cosmos DB avec `ToContainer("Consumables")`
- ? Définition de la clé de partition : `HasPartitionKey(c => c.NormalizedName)`
- ? Mapping de la propriété Id vers "id" (standard Cosmos)

### 5. Program.cs mis à jour

**`HappyLife/Program.cs`**
- ? Configuration de `UseCosmos()` au lieu de `UseInMemoryDatabase()`
- ? Lecture de la configuration depuis `appsettings.json`
- ? Création automatique de la base de données avec `EnsureCreatedAsync()`

### 6. Scripts PowerShell créés

#### `start-cosmos-emulator.ps1`
- Vérifie l'installation de l'émulateur Windows
- Démarre l'émulateur si nécessaire
- Attend que l'émulateur soit opérationnel
- Affiche les informations de connexion

#### `start-cosmos-docker.ps1`
- Vérifie l'installation de Docker
- Crée ou démarre le conteneur Cosmos
- Configure les ports (8081, 10250-10255)
- Affiche les commandes utiles

### 7. Documentation complète

#### `COSMOS_DB_SETUP.md` (Nouveau)
- Guide d'installation de l'émulateur
- Instructions Docker
- Configuration de l'application
- Gestion des certificats SSL
- Migration vers Azure en production
- Dépannage

#### `QUICK_START.md` (Nouveau)
- Guide de démarrage en 3 étapes
- Tests de l'API
- Visualisation des données
- Commandes de dépannage

#### `ARCHITECTURE.md` (Mis à jour)
- Documentation de l'infrastructure Cosmos DB
- Flux de données mis à jour
- Configuration ajoutée

## ?? Résultats

### Avant (In-Memory Database)
- ? Données perdues à chaque redémarrage
- ? Pas de scalabilité
- ? Pas de persistance
- ? Simple à démarrer
- ? Aucune dépendance externe

### Après (Cosmos DB)
- ? **Données persistées** entre redémarrages
- ? **Scalabilité** pour des milliers de consommables
- ? **Performance** avec indexation automatique
- ? **Clé de partition optimisée** (`NormalizedName`)
- ? **Prêt pour Azure** (production)
- ?? Nécessite l'émulateur local ou Docker

## ?? Comment utiliser ?

### Démarrage

1. **Démarrer Cosmos DB** (une seule fois par session) :
   ```powershell
   # Option 1 : Émulateur Windows
   .\start-cosmos-emulator.ps1
   
   # Option 2 : Docker
   .\start-cosmos-docker.ps1
   ```

2. **Lancer l'application** :
   ```bash
   dotnet run --project HappyLife
   ```

3. **Tester** :
   - API : https://localhost:5001/swagger
   - Data Explorer : https://localhost:8081/_explorer/index.html

### Vérification des données

Dans Cosmos Data Explorer :
1. Ouvrir **HappyLifeDb**
2. Conteneur **Consumables**
3. Voir les items stockés

Ou via SQL :
```sql
SELECT * FROM c
```

## ?? Migration vers Azure (Production)

### 1. Créer une instance Cosmos DB
```bash
az cosmosdb create \
  --name happylife-cosmosdb \
  --resource-group happylife-rg \
  --locations regionName=WestEurope
```

### 2. Obtenir la connexion string
```bash
az cosmosdb keys list \
  --name happylife-cosmosdb \
  --resource-group happylife-rg \
  --type connection-strings
```

### 3. Mettre à jour appsettings.Production.json
```json
{
  "CosmosDb": {
    "AccountEndpoint": "https://happylife-cosmosdb.documents.azure.com:443/",
    "AccountKey": "VOTRE_CLE_PRODUCTION",
    "DatabaseName": "HappyLifeDb"
  }
}
```

?? **Important** : Utilisez Azure Key Vault en production !

## ?? Avantages de Cosmos DB

### Performance
- **Indexation automatique** de toutes les propriétés
- **Clé de partition** optimisée (`NormalizedName`)
- **Latence faible** (< 10ms)

### Scalabilité
- **Scalabilité horizontale** automatique
- **Distribution globale** possible
- **99.999% de disponibilité** (SLA Azure)

### Flexibilité
- **Schéma flexible** (NoSQL)
- **Changements de structure** sans migration
- **Requêtes SQL** familières

## ?? Retour en arrière (si nécessaire)

Si vous voulez revenir à InMemory :

1. Dans `Program.cs`, remplacez :
   ```csharp
   options.UseCosmos(...);
   ```
   par :
   ```csharp
   options.UseInMemoryDatabase("HappyLifeDb");
   ```

2. Supprimez la configuration Cosmos de `appsettings.json`

3. Le reste du code reste compatible ! ??

## ? Bonus

### Clé de partition intelligente

La clé de partition `/NormalizedName` a été choisie car :
- ? **Distribution équilibrée** : Chaque produit normalisé est une partition
- ? **Requêtes optimisées** : Recherche de doublons ultra-rapide
- ? **Pas de hotspots** : Pas de partition surchargée

### Création automatique

Au premier démarrage, l'application crée automatiquement :
- La base de données `HappyLifeDb`
- Le conteneur `Consumables`
- L'index sur `NormalizedName`

Aucune intervention manuelle nécessaire ! ??

## ?? Notes importantes

1. **Émulateur local** : La clé par défaut est publique et sécurisée pour le développement
2. **Docker** : Le conteneur conserve les données même après redémarrage
3. **Production** : Utilisez Azure Key Vault et Managed Identity
4. **Coûts** : L'émulateur est gratuit, Azure Cosmos DB est payant (RU/s)

## ?? Conclusion

Votre application utilise maintenant **Azure Cosmos DB** avec :
- ? Persistance des données
- ? Architecture cloud-native
- ? Scalabilité illimitée
- ? Prêt pour la production Azure

Consultez les fichiers de documentation pour plus de détails !
