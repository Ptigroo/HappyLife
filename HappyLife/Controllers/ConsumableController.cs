using Microsoft.AspNetCore.Mvc;
using HappyLife.Models;
using HappyLife.Controllers.Dtos;
using Azure;
using Azure.AI.DocumentIntelligence;
namespace HappyLife.Controllers;
[ApiController]
[Route("[controller]")]
public class ConsumableController(AppDbContext dbContext) : ControllerBase
{

    [HttpPost("upload-bill")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UploadBill([FromForm] BillUploadDto request)
    {
        if (request.BillImage == null || request.BillImage.Length == 0)
            return BadRequest("No image uploaded.");
        var consumables = await ExtractConsumablesFromAzureAsync(request.BillImage);
        foreach (var c in consumables)
        {
            dbContext.Consumables.Add(c);
        }
        await dbContext.SaveChangesAsync();
        return Ok(consumables);
    }

    private async Task<List<Consumable>> ExtractConsumablesFromAzureAsync(IFormFile billImage)
    {
        // Replace with your Azure endpoint and key
        string endpoint = "https://invoicetoconsumable.cognitiveservices.azure.com/";
        string apiKey = "5GbUl0ETJdY008l0etsEDH6mNDubvDAXUsNpudoNppMwDBRZ3IJZJQQJ99BKAC5RqLJXJ3w3AAALACOG9VZG";
        var credential = new AzureKeyCredential(apiKey);
        var client = new DocumentIntelligenceClient(new Uri(endpoint), credential);

        using var memoryStream = new MemoryStream();
        await billImage.CopyToAsync(memoryStream);
        memoryStream.Position = 0;
        var binaryData = BinaryData.FromStream(memoryStream);
        
        // Use prebuilt-receipt model for food store bills
        var operation = await client.AnalyzeDocumentAsync(WaitUntil.Completed, "prebuilt-receipt", binaryData);
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
                            if (item.TryGetValue("TotalPrice", out var priceField) && priceField.ValueCurrency != null)
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
        return consumables;
    }
}
