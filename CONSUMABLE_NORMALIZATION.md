# Normalisation des noms de consommables

## Problème résolu

Lorsque vous scannez plusieurs factures, le même produit peut apparaître avec différentes descriptions :
- "Salmon 400gr"
- "Salmon from Delhaize"
- "Fresh Salmon 500g"

Sans normalisation, ces produits seraient créés comme des entrées séparées dans la base de données.

## Solution implémentée

### 1. Normalisation automatique des noms

Le système utilise `ConsumableNameNormalizer` qui :
- **Supprime les quantités** : "400gr", "2kg", "500ml" ? éliminés
- **Supprime les marques** : "from Delhaize", "Carrefour" ? éliminés
- **Supprime les mots inutiles** : "de", "du", "fresh", "bio" ? éliminés
- **Normalise la casse** : "SALMON" ? "salmon"
- **Trie les mots** : Pour une comparaison cohérente

**Exemple** :
```
"Salmon 400gr" ? "salmon"
"Salmon from Delhaize" ? "salmon"
"Fresh Salmon bio" ? "salmon"
```

### 2. Fusion automatique des consommables

Lors de l'ajout d'un consommable :
1. Le système normalise le nom
2. Cherche si un consommable avec le même nom normalisé existe
3. **Si trouvé** : Met à jour la quantité et calcule le prix moyen
4. **Si nouveau** : Crée une nouvelle entrée

### 3. Nouvelle structure de données

La table `Consumable` contient maintenant :
```csharp
public class Consumable
{
    public Guid Id { get; set; }
    public string Name { get; set; }              // Nom original
    public string NormalizedName { get; set; }    // Nom normalisé (pour recherche)
    public decimal Price { get; set; }
    public int Quantity { get; set; }
}
```

## Utilisation des endpoints

### 1. Upload d'une facture normale
```http
POST /Consumable/upload-bill
Content-Type: multipart/form-data

BillImage: [fichier image]
```
**Comportement** :
- Extrait les articles avec prix et quantités
- Normalise les noms
- Fusionne avec les consommables existants
- Met à jour les quantités

### 2. Initialisation depuis anciennes factures
```http
POST /Consumable/initialize-from-invoice
Content-Type: multipart/form-data

BillImage: [fichier image]
```
**Comportement** :
- Extrait uniquement les noms d'articles
- Crée des consommables avec quantité = 0 et prix = 0
- Utile pour créer votre catalogue initial
- Évite les doublons grâce à la normalisation

## Personnalisation

### Ajouter des mots à ignorer

Dans `ConsumableNameNormalizer.cs`, modifiez le tableau `StopWords` :
```csharp
private static readonly string[] StopWords = 
{
    "de", "du", "des", "le", "la", "les",
    "votre_magasin", "votre_marque", // Ajoutez ici
};
```

### Ajouter des unités à supprimer

Modifiez le tableau `CommonUnits` :
```csharp
private static readonly string[] CommonUnits = 
{
    "kg", "g", "gr", "l", "ml",
    "units", "pcs", // Ajoutez ici
};
```

### Ajuster le seuil de similarité

Dans la méthode `AreSimilar`, modifiez le seuil (actuellement 75%) :
```csharp
return totalWords > 0 && (double)commonWords / totalWords >= 0.75; // Changez 0.75
```

## Exemples de normalisation

| Nom original | Nom normalisé | Résultat |
|--------------|---------------|----------|
| "Salmon 400gr" | "salmon" | ? Groupé |
| "Fresh Salmon from Delhaize" | "salmon" | ? Groupé |
| "Salmon bio 2kg" | "salmon" | ? Groupé |
| "Tomato sauce 500ml" | "sauce tomato" | ? Groupé |
| "Sauce tomate 1L" | "sauce tomate" | ? Groupé |
| "Apple juice" | "apple juice" | ? Séparé |
| "Orange juice" | "juice orange" | ? Séparé |

## Optimisations techniques

1. **Index sur NormalizedName** : Recherches rapides dans la base de données
2. **Calcul du prix moyen** : Lorsque des consommables sont fusionnés
3. **Pattern Repository** : Encapsulation de la logique d'accès aux données

## Limitations actuelles

- La normalisation est basique (mots-clés)
- Pas d'analyse sémantique avancée
- Pas de machine learning

## Améliorations futures possibles

1. **Fuzzy matching** : Utiliser Levenshtein distance pour les fautes de frappe
2. **Machine Learning** : Classifier automatiquement les produits
3. **API de suggestion** : "Voulez-vous grouper avec [X] ?"
4. **Historique** : Tracer les fusions pour permettre l'annulation
