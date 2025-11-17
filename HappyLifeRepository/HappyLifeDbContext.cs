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

        // Configuration for SQL Server
        modelBuilder.Entity<Consumable>(entity =>
        {
            entity.HasKey(c => c.Id);
            
            entity.Property(c => c.Id)
                .ValueGeneratedOnAdd();
            
            entity.Property(c => c.Name)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(c => c.NormalizedName)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.HasIndex(c => c.NormalizedName)
                .IsUnique();
            
            entity.Property(c => c.Price)
                .HasColumnType("decimal(18,2)");
            
            entity.Property(c => c.Quantity)
                .IsRequired();
        });
    }
}