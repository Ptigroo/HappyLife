using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeModels;
using Microsoft.EntityFrameworkCore;
namespace HappyLifeRepository;
public class HappyLifeDbContext(DbContextOptions<HappyLifeDbContext> options) : DbContext, IHappyLifeDbContext
{
    public DbSet<Consumable> Consumables { get; set; }
    public async Task SaveHappyLifeDb()
    {
        await SaveChangesAsync();
    }
}