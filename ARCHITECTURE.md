# HappyLife - Architecture

## Structure de la solution

Cette solution suit une architecture en couches avec séparation des responsabilités :

### 1. **HappyLife** (API Web)
- Point d'entrée de l'application
- Contient les contrôleurs API
- Configure l'injection de dépendances
- Gère les requêtes HTTP

### 2. **HappyLifeInterfaces**
- Définit tous les contrats (interfaces)
- `RepositoryInterfaces` : Contrats pour l'accès aux données
- `ServiceInterfaces` : Contrats pour la logique métier
- Aucune dépendance vers les implémentations

### 3. **HappyLifeModels**
- Contient les entités de domaine
- Classes de configuration (Options)
- DTOs (Data Transfer Objects)
- Aucune logique métier

### 4. **HappyLifeRepository**
- Implémente l'accès aux données
- Contient le `DbContext` Entity Framework
- Implémente les interfaces de `IRepositoryInterfaces`
- Gère la persistance des données

### 5. **HappyLifeServices**
- Contient la logique métier
- Implémente les interfaces de `IServiceInterfaces`
- Orchestre les appels aux repositories
- Intègre les services externes (Azure Document Intelligence)
- **Normalisation des noms** : `ConsumableNameNormalizer` pour éviter les doublons

## Flux de données

```
Controller ? Service (Interface) ? Repository (Interface) ? DbContext ? Database
```

## Fonctionnalités clés

### ?? Normalisation et fusion des consommables
Le système détecte automatiquement les consommables similaires et les fusionne :
- **"Salmon 400gr"** et **"Salmon from Delhaize"** ? Même consommable
- Suppression automatique des quantités, marques et mots inutiles
- Mise à jour intelligente des quantités lors de nouveaux scans

?? **Voir** : [CONSUMABLE_NORMALIZATION.md](CONSUMABLE_NORMALIZATION.md) pour plus de détails

## Principes appliqués

### ? Separation of Concerns
- Chaque projet a une responsabilité unique et bien définie

### ? Dependency Inversion
- Les dépendances pointent vers les abstractions (interfaces)
- Injection de dépendances configurée dans `Program.cs`

### ? Configuration externalisée
- Clés API et endpoints stockés dans `appsettings.json`
- Configuration injectée via `IOptions<T>`

### ? Repository Pattern
- Abstraction de la couche de données
- Facilite les tests unitaires

### ? Clean Architecture
- Les dépendances pointent vers l'intérieur
- Les couches externes dépendent des couches internes

### ? Domain-Driven Design (DDD)
- Normalisation des noms comme logique de domaine
- `NormalizedName` comme propriété calculée

## Configuration

### Azure Document Intelligence

Configurez vos credentials Azure dans `appsettings.json` ou `appsettings.Development.json` :

```json
{
  "AzureDocumentIntelligence": {
    "Endpoint": "https://your-endpoint.cognitiveservices.azure.com/",
    "ApiKey": "YOUR_API_KEY"
  }
}
```

?? **Important** : Ne commitez jamais les clés API en production. Utilisez Azure Key Vault ou les variables d'environnement.

## Endpoints API

### Upload d'une facture
```http
POST /Consumable/upload-bill
Content-Type: multipart/form-data
```
Extrait les articles avec prix et quantités, fusionne avec les existants.

### Initialisation depuis anciennes factures
```http
POST /Consumable/initialize-from-invoice
Content-Type: multipart/form-data
```
Crée le catalogue de consommables sans quantités ni prix.

## Points d'amélioration possibles

1. **Unit of Work Pattern** : Pour gérer les transactions complexes
2. **CQRS** : Séparer les commandes des requêtes
3. **Validation** : Ajouter FluentValidation pour valider les DTOs
4. **Logging** : Intégrer Serilog pour un logging structuré
5. **Exception Handling** : Middleware global pour gérer les erreurs
6. **Authentication/Authorization** : Ajouter JWT ou Azure AD
7. **Fuzzy Matching** : Améliorer la détection de similarité avec Levenshtein
8. **Machine Learning** : Classification automatique des produits
