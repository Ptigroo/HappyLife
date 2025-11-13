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
        var credential = new AzureKeyCredential(_options.ApiKey);
        var client = new DocumentIntelligenceClient(new Uri(_options.Endpoint), credential);

        using var memoryStream = new MemoryStream();
        await billImage.CopyToAsync(memoryStream);
        memoryStream.Position = 0;
        var binaryData = BinaryData.FromStream(memoryStream);

        // Use prebuilt-receipt model for food store bills
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
                            decimal price = 0;
                            if (item.TryGetValue("Amount", out var priceField) && priceField.ValueCurrency != null)
                                price = (decimal)priceField.ValueCurrency.Amount;
                            int quantity = 1;
                            if (item.TryGetValue("Quantity", out var qtyField) && qtyField.ValueDouble != null)
                                quantity = (int)qtyField.ValueDouble.Value;

                            consumables.Add(new Consumable { Name = name, Price = price, Quantity = quantity });
                        }
                    }
                }
            }
        }
        
        foreach (var c in consumables)
        {
            await consumableRepository.AddConsumableAsync(c);
        }
        
        return consumables;
    }
}
