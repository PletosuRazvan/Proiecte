namespace FIIPracticCompany.Entities
{
    public class Team
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public List<Employee> Employees { get; set; }
        public List<Project> Projects { get; set; }

    }
}
