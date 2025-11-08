using Microsoft.AspNetCore.Mvc;
using HappyLife.Models;
using HappyLife.Controllers.Dtos;

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
        await Task.Delay(500); 
        return new List<Consumable>
        {
            new Consumable { Name = "Apple", Price = 1.20M, Quantity = 2 },
            new Consumable { Name = "Bread", Price = 2.50M, Quantity = 1 }
        };
    }
}
