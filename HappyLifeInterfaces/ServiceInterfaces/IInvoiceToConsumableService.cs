using HappyLifeModels;
using Microsoft.AspNetCore.Http;
namespace HappyLifeInterfaces.ServiceInterfaces;

public interface IInvoiceToConsumableService
{
    Task<List<Consumable>> ExtractConsumablesFromAzureAsync(IFormFile billImage);
}
