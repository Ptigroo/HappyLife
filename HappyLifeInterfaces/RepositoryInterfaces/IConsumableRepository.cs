using HappyLifeModels;

namespace HappyLifeInterfaces.RepositoryInterfaces;
public  interface IConsumableRepository
{
    Task<Guid> AddConsumableAsync(Consumable consumable);
}
