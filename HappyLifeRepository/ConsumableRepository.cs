using HappyLifeInterfaces.RepositoryInterfaces;
using HappyLifeModels;

namespace HappyLifeRepository;

public class ConsumableRepository(HappyLifeDbContext dbContext) : IConsumableRepository
{
    public async Task<Guid> AddConsumableAsync(Consumable consumable)
    {
        await dbContext.Consumables.AddAsync(consumable);
        await dbContext.SaveChangesAsync();
        return consumable.Id;
    }
}
