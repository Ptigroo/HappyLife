using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeInterfaces.ServiceInterfaces;
using HappyLifeModels;
using HappyLifeRepository;
using HappyLifeServices;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);

// Configure services
builder.Services.AddControllers();

// Configure health checks for Kubernetes
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy())
    .AddCheck<DatabaseHealthCheck>("database");

// Configure Azure Document Intelligence
builder.Services.Configure<AzureDocumentIntelligenceOptions>(
    builder.Configuration.GetSection(AzureDocumentIntelligenceOptions.SectionName));

// Configure MySQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (string.IsNullOrEmpty(connectionString))
{
    throw new InvalidOperationException("MySQL connection string is missing");
}

builder.Services.AddDbContext<HappyLifeDbContext>(options =>
{
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));
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

// Ensure MySQL database is created
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

// Map health check endpoints for Kubernetes
app.MapHealthChecks("/health");

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();

// Custom health check for database connectivity
public class DatabaseHealthCheck : IHealthCheck
{
    private readonly HappyLifeDbContext _dbContext;

    public DatabaseHealthCheck(HappyLifeDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _dbContext.Database.CanConnectAsync(cancellationToken);
            return HealthCheckResult.Healthy("Database connection is healthy");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Database connection failed", ex);
        }
    }
}
