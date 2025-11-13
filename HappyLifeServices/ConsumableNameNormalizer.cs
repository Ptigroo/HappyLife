using System.Text;
using System.Text.RegularExpressions;

namespace HappyLifeServices;

public static class ConsumableNameNormalizer
{
    private static readonly string[] CommonUnits = 
    {
        "kg", "g", "gr", "l", "ml", "cl", "oz", "lb", "mg",
        "gram", "grams", "gramme", "grammes", "litre", "litres",
        "kilo", "kilos", "kilogram", "kilograms"
    };

    private static readonly string[] StopWords = 
    {
        "de", "du", "des", "le", "la", "les", "un", "une",
        "from", "by", "at", "in", "of", "the", "a", "an",
        "delhaize", "carrefour", "colruyt", "aldi", "lidl", // Magasins courants
        "bio", "organic", "fresh", "frais", "fraiche"
    };

    /// <summary>
    /// Normalise le nom d'un consommable en supprimant les quantités, marques et mots inutiles
    /// </summary>
    public static string Normalize(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            return string.Empty;

        var normalized = name.ToLowerInvariant();

        // Supprimer les quantités avec unités (ex: "400gr", "2kg", "500 ml")
        normalized = Regex.Replace(normalized, @"\d+\s*(" + string.Join("|", CommonUnits) + @")\b", "", RegexOptions.IgnoreCase);

        // Supprimer les nombres seuls
        normalized = Regex.Replace(normalized, @"\b\d+\b", "");

        // Supprimer les caractères spéciaux
        normalized = Regex.Replace(normalized, @"[^\w\s]", " ");

        // Diviser en mots
        var words = normalized.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

        // Filtrer les stop words
        var filteredWords = words
            .Where(w => !StopWords.Contains(w) && w.Length > 2)
            .Distinct()
            .OrderBy(w => w);

        // Reconstruire le nom normalisé
        var result = string.Join(" ", filteredWords).Trim();

        return string.IsNullOrWhiteSpace(result) ? name.ToLowerInvariant() : result;
    }

    /// <summary>
    /// Calcule la similarité entre deux noms (retourne true si similaires)
    /// </summary>
    public static bool AreSimilar(string name1, string name2)
    {
        var normalized1 = Normalize(name1);
        var normalized2 = Normalize(name2);

        // Même nom normalisé = similaires
        if (normalized1 == normalized2)
            return true;

        // Vérifier si l'un contient l'autre (pour des variantes)
        var words1 = normalized1.Split(' ');
        var words2 = normalized2.Split(' ');

        // Si 75% des mots sont communs, considérer comme similaires
        var commonWords = words1.Intersect(words2).Count();
        var totalWords = Math.Min(words1.Length, words2.Length);

        return totalWords > 0 && (double)commonWords / totalWords >= 0.75;
    }
}
