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

        // Configurer un index sur NormalizedName pour améliorer les performances de recherche
        modelBuilder.Entity<Consumable>()
            .HasIndex(c => c.NormalizedName);
    }
}