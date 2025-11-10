using Azure;
using Azure.AI.DocumentIntelligence;
using HappyLife.Controllers.Dtos;
using HappyLifeInterfaces.ServiceInterfaces;
using HappyLifeServices;
using Microsoft.AspNetCore.Mvc;
namespace HappyLife.Controllers;
[ApiController]
[Route("[controller]")]
public class ConsumableController(IInvoiceToConsumableService invoiceToConsumableService) : ControllerBase
{
    [HttpPost("upload-bill")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UploadBill([FromForm] BillUploadDto request)
    {
        if (request.BillImage == null || request.BillImage.Length == 0)
            return BadRequest("No image uploaded.");
        var consumables = await invoiceToConsumableService.ExtractConsumablesFromAzureAsync(request.BillImage);
        return Ok(consumables);
    }
}
