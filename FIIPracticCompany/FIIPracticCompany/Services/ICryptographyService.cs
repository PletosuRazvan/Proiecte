namespace FIIPracticCompany.Services.Models
{
    public interface ICryptographyService
    {
        HashedPassword HashPasswordWithSaltGeneration(string password);
        HashedPassword HashPassword(string password, string salt);
    }
}
