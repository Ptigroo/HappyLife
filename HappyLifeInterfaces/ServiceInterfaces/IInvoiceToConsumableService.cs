using HappyLifeModels;
using Microsoft.AspNetCore.Http;

namespace HappyLifeInterfaces.ServiceInterfaces;

public interface IInvoiceToConsumableService
{
    Task<List<Consumable>> ExtractConsumablesFromAzureAsync(IFormFile billImage);
    Task<List<Consumable>> InitializeMyConsumablesUsingFormerInvoices(IFormFile billImage);
    Task<List<Consumable>> GetAllConsumablesAsync();
}
