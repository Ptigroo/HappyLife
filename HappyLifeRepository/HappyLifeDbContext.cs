using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeModels;
using Microsoft.EntityFrameworkCore;

namespace HappyLifeRepository;

public class HappyLifeDbContext(DbContextOptions<HappyLifeDbContext> options) : DbContext(options), IHappyLifeDbContext
{
    public DbSet<Consumable> Consumables { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configuration pour Cosmos DB
        modelBuilder.Entity<Consumable>(entity =>
        {
            // Définir le conteneur (collection) dans Cosmos DB
            entity.ToContainer("Consumables");
            
            // Définir la clé de partition
            entity.HasPartitionKey(c => c.NormalizedName);
            
            // Pas besoin d'index explicite avec Cosmos DB - il indexe automatiquement toutes les propriétés
            // mais on peut définir la propriété qui sera utilisée comme "id" dans Cosmos
            entity.Property(c => c.Id)
                .ToJsonProperty("id")
                .ValueGeneratedOnAdd();
        });
    }
}