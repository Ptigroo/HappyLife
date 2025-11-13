using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeModels;
using Microsoft.EntityFrameworkCore;

namespace HappyLifeRepository;

public class HappyLifeDbContext(DbContextOptions<HappyLifeDbContext> options) : DbContext(options), IHappyLifeDbContext
{
    public DbSet<Consumable> Consumables { get; set; }
}