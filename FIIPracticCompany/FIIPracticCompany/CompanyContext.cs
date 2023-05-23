using FIIPracticCompany.Entities;
using Microsoft.EntityFrameworkCore;

namespace FIIPracticCompany
{
    public class CompanyContext : DbContext
    {
        public DbSet<Employee> Employees { get; set; }
        public DbSet<Account> Accounts { get; set; }
        public DbSet<Team> Teams { get; set; }
        public DbSet<Project> Projects { get; set; }
        public DbSet<TeamProject> TeamProjects { get; set; }
        public DbSet<TeamEmployee> TeamEmployees { get; set; }

        public CompanyContext(DbContextOptions options)
          : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<TeamProject>()
              .HasKey(tp => new { tp.TeamId, tp.ProjectId });
            modelBuilder.Entity<TeamEmployee>()
                .HasKey(te => new { te.TeamId, te.EmployeeId });

            modelBuilder.Entity<Team>()
                .HasMany(t => t.Projects)
                .WithMany(p => p.Teams)
                .UsingEntity<TeamProject>();

            modelBuilder.Entity<Team>()
              .HasMany(t => t.Employees)
              .WithMany(e => e.Teams)
              .UsingEntity<TeamEmployee>();
        }
    }
}
