using Microsoft.EntityFrameworkCore;
namespace HappyLife.Models
{
    public class Consumable
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public Guid CategoryId { get; set; }
        public Category Category { get; set; }
    }
    public class Category
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
        public DbSet<Consumable> Consumables { get; set; }
        public DbSet<Category> Categories { get; set; }
    }
}
