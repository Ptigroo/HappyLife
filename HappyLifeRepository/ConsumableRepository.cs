using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeModels;
using Microsoft.EntityFrameworkCore;

namespace HappyLifeRepository;

public class ConsumableRepository(HappyLifeDbContext dbContext) : IConsumableRepository
{
    public async Task<Guid> AddConsumableAsync(Consumable consumable)
    {
        await dbContext.Consumables.AddAsync(consumable);
        await dbContext.SaveChangesAsync();
        return consumable.Id;
    }

    public async Task<Consumable?> GetByNormalizedNameAsync(string normalizedName)
    {
        return await dbContext.Consumables
            .FirstOrDefaultAsync(c => c.NormalizedName == normalizedName);
    }

    public async Task UpdateConsumableAsync(Consumable consumable)
    {
        dbContext.Consumables.Update(consumable);
        await dbContext.SaveChangesAsync();
    }

    public async Task<List<Consumable>> GetAllConsumablesAsync()
    {
        return await dbContext.Consumables
            .OrderBy(c => c.NormalizedName)
            .ToListAsync();
    }
}
