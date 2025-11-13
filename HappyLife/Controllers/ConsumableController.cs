using HappyLife.Controllers.Dtos;
using HappyLifeInterfaces.ServiceInterfaces;
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

    [HttpPost("initialize-from-invoice")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> InitializeFromInvoice([FromForm] BillUploadDto request)
    {
        if (request.BillImage == null || request.BillImage.Length == 0)
            return BadRequest("No image uploaded.");
        
        var consumables = await invoiceToConsumableService.InitializeMyConsumablesUsingFormerInvoices(request.BillImage);
        return Ok(consumables);
    }

    [HttpGet("all")]
    public async Task<IActionResult> GetAllConsumables()
    {
        var consumables = await invoiceToConsumableService.GetAllConsumablesAsync();
        return Ok(consumables);
    }
}
