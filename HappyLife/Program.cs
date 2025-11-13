using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeInterfaces.ServiceInterfaces;
using HappyLifeModels;
using HappyLifeRepository;
using HappyLifeServices;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Configure services
builder.Services.AddControllers();

// Configure Azure Document Intelligence
builder.Services.Configure<AzureDocumentIntelligenceOptions>(
    builder.Configuration.GetSection(AzureDocumentIntelligenceOptions.SectionName));

// Configure Cosmos DB
var cosmosDbConfig = builder.Configuration.GetSection(CosmosDbOptions.SectionName).Get<CosmosDbOptions>();
if (cosmosDbConfig == null)
{
    throw new InvalidOperationException("CosmosDb configuration is missing");
}

builder.Services.AddDbContext<HappyLifeDbContext>(options =>
{
    options.UseCosmos(
        cosmosDbConfig.AccountEndpoint,
        cosmosDbConfig.AccountKey,
        cosmosDbConfig.DatabaseName);
});

builder.Services.AddScoped<IHappyLifeDbContext>(provider => 
    provider.GetRequiredService<HappyLifeDbContext>());

// Configure Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register repositories and services
builder.Services.AddScoped<IConsumableRepository, ConsumableRepository>();
builder.Services.AddScoped<IInvoiceToConsumableService, InvoiceToConsumableService>();

var app = builder.Build();

// Ensure Cosmos DB database is created
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<HappyLifeDbContext>();
    await dbContext.Database.EnsureCreatedAsync();
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
