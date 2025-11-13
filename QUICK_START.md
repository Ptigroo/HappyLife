# ?? Guide de démarrage rapide - HappyLife

## Prérequis

- ? .NET 9 SDK installé
- ? Azure Cosmos DB Emulator **OU** Docker Desktop

## Démarrage en 3 étapes

### 1?? Démarrer la base de données

**Choisissez UNE des deux options** :

#### Option A : Émulateur Windows (Recommandé pour Windows)
```powershell
.\start-cosmos-emulator.ps1
```

#### Option B : Docker (macOS, Linux, Windows)
```powershell
.\start-cosmos-docker.ps1
```

? **Attendez 1-2 minutes** que l'émulateur soit opérationnel.

? Vérifiez que l'émulateur fonctionne : https://localhost:8081/_explorer/index.html

---

### 2?? Lancer l'application

```bash
dotnet run --project HappyLife
```

ou dans Visual Studio : **F5**

---

### 3?? Tester l'API

Accédez à Swagger : https://localhost:5001/swagger

#### Test 1 : Uploader une facture
1. Cliquez sur **POST /Consumable/upload-bill**
2. Cliquez sur **Try it out**
3. Uploadez une image de facture
4. Cliquez sur **Execute**

#### Test 2 : Voir tous les consommables
1. Cliquez sur **GET /Consumable/all**
2. Cliquez sur **Try it out**
3. Cliquez sur **Execute**

---

## ?? Résultat attendu

Après avoir uploadé une facture, vous devriez voir :
```json
[
  {
    "id": "...",
    "name": "Salmon 400gr",
    "normalizedName": "salmon",
    "price": 8.50,
    "quantity": 2
  }
]
```

Les données sont **persistées dans Cosmos DB** ! ??

---

## ?? Visualiser les données

### Data Explorer (Navigateur)
https://localhost:8081/_explorer/index.html

Navigation :
1. Ouvrez **HappyLifeDb**
2. Cliquez sur **Consumables**
3. Cliquez sur **Items**
4. Vous voyez vos données !

### Requête SQL
Dans Data Explorer, onglet "Query" :
```sql
SELECT * FROM c
```

---

## ??? Commandes utiles

### Cosmos DB (Docker)
```bash
# Voir les logs
docker logs -f cosmos-emulator

# Arrêter
docker stop cosmos-emulator

# Redémarrer
docker restart cosmos-emulator

# Supprimer tout et recommencer
docker rm -f cosmos-emulator
.\start-cosmos-docker.ps1
```

### Application
```bash
# Build
dotnet build

# Tests
dotnet test

# Clean
dotnet clean
```

---

## ? Dépannage

### Erreur : "Could not connect to Cosmos DB"
1. Vérifiez que l'émulateur est démarré
2. Allez sur https://localhost:8081/_explorer/index.html
3. Si ça ne fonctionne pas, redémarrez l'émulateur

### Erreur SSL
L'application ignore automatiquement les erreurs SSL en développement.

### Port 8081 déjà utilisé
```powershell
# Voir ce qui utilise le port
netstat -ano | findstr :8081

# Arrêter le processus (remplacez PID)
taskkill /PID <PID> /F
```

### L'émulateur ne démarre pas (Windows)
1. Redémarrez votre PC
2. Réinstallez l'émulateur : https://aka.ms/cosmosdb-emulator

---

## ?? Documentation complète

- **Architecture** : [ARCHITECTURE.md](ARCHITECTURE.md)
- **Cosmos DB** : [COSMOS_DB_SETUP.md](COSMOS_DB_SETUP.md)
- **Normalisation** : [CONSUMABLE_NORMALIZATION.md](CONSUMABLE_NORMALIZATION.md)

---

## ?? C'est parti !

Vous êtes maintenant prêt à développer avec HappyLife ! ??

Besoin d'aide ? Consultez la documentation ou ouvrez une issue sur GitHub.
