namespace FIIPracticCompany.Repositories.Dtos
{
    public class EmployeeDto
    {
        public int Id { get; set; }
        public string LastName { get; set; }
        public string FirstName { get; set; }
        public DateTime BirthDate { get; set; }
        public DateTime EmploymentDate { get; set; }
        public string ExperienceLevel { get; set; }
        public int ExperienceYears { get; set; }
        public int IsTeamLeader { get; set; }
        public int IsAdmin { get; set; }
    }
}
