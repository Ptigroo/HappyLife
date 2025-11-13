using Azure;
using Azure.AI.DocumentIntelligence;
using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeInterfaces.ServiceInterfaces;
using HappyLifeModels;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;

namespace HappyLifeServices;

public class InvoiceToConsumableService(
    IConsumableRepository consumableRepository,
    IOptions<AzureDocumentIntelligenceOptions> options) : IInvoiceToConsumableService
{
    private readonly AzureDocumentIntelligenceOptions _options = options.Value;

    public async Task<List<Consumable>> ExtractConsumablesFromAzureAsync(IFormFile billImage)
    {
        var extractedItems = await ExtractItemsFromInvoiceAsync(billImage);
        var processedConsumables = new List<Consumable>();

        foreach (var item in extractedItems)
        {
            var normalizedName = ConsumableNameNormalizer.Normalize(item.Name);
            
            // Chercher si un consommable avec ce nom normalisé existe déjà
            var existingConsumable = await consumableRepository.GetByNormalizedNameAsync(normalizedName);

            if (existingConsumable != null)
            {
                // Mettre à jour la quantité et le prix moyen
                existingConsumable.Quantity += item.Quantity;
                existingConsumable.Price = (existingConsumable.Price + item.Price) / 2; // Prix moyen
                await consumableRepository.UpdateConsumableAsync(existingConsumable);
                processedConsumables.Add(existingConsumable);
            }
            else
            {
                // Créer un nouveau consommable
                item.NormalizedName = normalizedName;
                await consumableRepository.AddConsumableAsync(item);
                processedConsumables.Add(item);
            }
        }

        return processedConsumables;
    }

    public async Task<List<Consumable>> InitializeMyConsumablesUsingFormerInvoices(IFormFile billImage)
    {
        var extractedItems = await ExtractItemsFromInvoiceAsync(billImage, includeQuantityAndPrice: false);
        var processedConsumables = new List<Consumable>();

        foreach (var item in extractedItems)
        {
            var normalizedName = ConsumableNameNormalizer.Normalize(item.Name);
            
            // Chercher si un consommable avec ce nom normalisé existe déjà
            var existingConsumable = await consumableRepository.GetByNormalizedNameAsync(normalizedName);

            if (existingConsumable == null)
            {
                // Créer un nouveau consommable avec quantité et prix à 0
                item.NormalizedName = normalizedName;
                item.Quantity = 0;
                item.Price = 0;
                await consumableRepository.AddConsumableAsync(item);
                processedConsumables.Add(item);
            }
            else
            {
                processedConsumables.Add(existingConsumable);
            }
        }

        return processedConsumables;
    }

    public async Task<List<Consumable>> GetAllConsumablesAsync()
    {
        return await consumableRepository.GetAllConsumablesAsync();
    }

    private async Task<List<Consumable>> ExtractItemsFromInvoiceAsync(IFormFile billImage, bool includeQuantityAndPrice = true)
    {
        var credential = new AzureKeyCredential(_options.ApiKey);
        var client = new DocumentIntelligenceClient(new Uri(_options.Endpoint), credential);

        using var memoryStream = new MemoryStream();
        await billImage.CopyToAsync(memoryStream);
        memoryStream.Position = 0;
        var binaryData = BinaryData.FromStream(memoryStream);

        // Use prebuilt-invoice model for food store bills
        var operation = await client.AnalyzeDocumentAsync(WaitUntil.Completed, "prebuilt-invoice", binaryData);
        var result = operation.Value;

        var consumables = new List<Consumable>();
        if (result.Documents != null)
        {
            foreach (var doc in result.Documents)
            {
                if (doc.Fields != null && doc.Fields.TryGetValue("Items", out var itemsField) && itemsField.ValueList != null)
                {
                    foreach (var itemField in itemsField.ValueList)
                    {
                        if (itemField.ValueDictionary != null)
                        {
                            var item = itemField.ValueDictionary;
                            string name = "Unknown";
                            if (item.TryGetValue("Description", out var nameField) && nameField.Content != null)
                                name = nameField.Content;

                            if (includeQuantityAndPrice)
                            {
                                decimal price = 0;
                                if (item.TryGetValue("Amount", out var priceField) && priceField.ValueCurrency != null)
                                    price = (decimal)priceField.ValueCurrency.Amount;
                                
                                int quantity = 1;
                                if (item.TryGetValue("Quantity", out var qtyField) && qtyField.ValueDouble != null)
                                    quantity = (int)qtyField.ValueDouble.Value;

                                consumables.Add(new Consumable { Name = name, Price = price, Quantity = quantity });
                            }
                            else
                            {
                                consumables.Add(new Consumable { Name = name, Price = 0, Quantity = 0 });
                            }
                        }
                    }
                }
            }
        }

        return consumables;
    }
}
