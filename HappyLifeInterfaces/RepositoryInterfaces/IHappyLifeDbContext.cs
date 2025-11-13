namespace HappyLifeInterfaces.RepositoryInterfaces;

public interface IHappyLifeDbContext
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
