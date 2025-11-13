using HappyLifeModels;

namespace HappyLifeInterfaces.RepositoryInterfaces;
public interface IConsumableRepository
{
    Task<Guid> AddConsumableAsync(Consumable consumable);
    Task<Consumable?> GetByNormalizedNameAsync(string normalizedName);
    Task UpdateConsumableAsync(Consumable consumable);
    Task<List<Consumable>> GetAllConsumablesAsync();
}
