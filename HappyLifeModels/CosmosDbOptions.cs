namespace HappyLifeModels;

public class CosmosDbOptions
{
    public const string SectionName = "CosmosDb";
    
    public string AccountEndpoint { get; set; } = string.Empty;
    public string AccountKey { get; set; } = string.Empty;
    public string DatabaseName { get; set; } = string.Empty;
}
