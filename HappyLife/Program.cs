using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeInterfaces.ServiceInterfaces;
using HappyLifeRepository;
using HappyLifeServices;
using Microsoft.EntityFrameworkCore;
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

builder.Services.AddDbContext<IHappyLifeDbContext, HappyLifeDbContext>(options => options.UseInMemoryDatabase(databaseName: "InMemoryHappyLifeDb"));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IConsumableRepository, ConsumableRepository>();
builder.Services.AddScoped<IInvoiceToConsumableService, InvoiceToConsumableService>();
var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
