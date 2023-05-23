using FIIPracticCompany.Repositories.Dtos;

namespace FIIPracticCompany.Repositories
{
    public interface IEmployeeRepository
    {
        void AddEmployee(EmployeeDto employeeDto);
        IEnumerable<EmployeeDto> SearchByName(string searchTerm);
        void DeleteEmployee(int employeeId);
        List<EmployeeDto> GetAll();
        void UpdateEmployee(EmployeeDto employeeDto);
        EmployeeDto? GetEmployee(int employeeId);

    }
}
