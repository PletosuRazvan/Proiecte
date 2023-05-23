namespace FIIPracticCompany.Entities
{
    public class Account
    {
        public int Id { get; set; }
        public int EmployeeId { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string PasswordSalt { get; set; }
    }
}
