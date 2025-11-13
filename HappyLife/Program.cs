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

// Configure Database
builder.Services.AddDbContext<HappyLifeDbContext>(options => 
    options.UseInMemoryDatabase(databaseName: "InMemoryHappyLifeDb"));
builder.Services.AddScoped<IHappyLifeDbContext>(provider => 
    provider.GetRequiredService<HappyLifeDbContext>());

// Configure Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register repositories and services
builder.Services.AddScoped<IConsumableRepository, ConsumableRepository>();
builder.Services.AddScoped<IInvoiceToConsumableService, InvoiceToConsumableService>();

var app = builder.Build();

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
