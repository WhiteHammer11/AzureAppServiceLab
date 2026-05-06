using AzureAppServiceLab.Models;
using Microsoft.EntityFrameworkCore;

namespace AzureAppServiceLab.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Note> Notes => Set<Note>();
}