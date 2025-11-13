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

## Flux de données

```
Controller ? Service (Interface) ? Repository (Interface) ? DbContext ? Database
```

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

## Points d'amélioration possibles

1. **Unit of Work Pattern** : Pour gérer les transactions complexes
2. **CQRS** : Séparer les commandes des requêtes
3. **Validation** : Ajouter FluentValidation pour valider les DTOs
4. **Logging** : Intégrer Serilog pour un logging structuré
5. **Exception Handling** : Middleware global pour gérer les erreurs
6. **Authentication/Authorization** : Ajouter JWT ou Azure AD
