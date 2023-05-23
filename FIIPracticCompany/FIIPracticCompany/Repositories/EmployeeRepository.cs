using FIIPracticCompany.Entities;
using FIIPracticCompany.Repositories.Dtos;

namespace FIIPracticCompany.Repositories
{
    public class EmployeeRepository :  IEmployeeRepository
    {
        private readonly CompanyContext _context;
        public EmployeeRepository(CompanyContext context)
        {
            _context = context;
        }
        public void AddEmployee (EmployeeDto employeeDto) 
        {
            if (employeeDto == null) throw new ArgumentNullException(nameof(employeeDto));
            if (string.IsNullOrEmpty(employeeDto.LastName)) throw new ArgumentException($"{nameof(employeeDto.LastName)} cannot be null or empty.");
            if (string.IsNullOrEmpty(employeeDto.FirstName)) throw new ArgumentException($"{nameof(employeeDto.FirstName)} cannot be null or empty.");
            if (string.IsNullOrEmpty(employeeDto.ExperienceLevel)) throw new ArgumentException($"{nameof(employeeDto.ExperienceLevel)} cannot be null or empty.");
            if (employeeDto.ExperienceYears < 0) throw new ArgumentOutOfRangeException(nameof(employeeDto.ExperienceYears));

            var employeeEntity = new Employee
            {
                LastName = employeeDto.LastName,
                FirstName = employeeDto.FirstName,
                BirthDate = employeeDto.BirthDate,
                EmploymentDate = employeeDto.EmploymentDate,
                ExperienceLevel = employeeDto.ExperienceLevel,
                ExperienceYears = employeeDto.ExperienceYears,
                IsTeamLeader = employeeDto.IsTeamLeader,
                IsAdmin = employeeDto.IsAdmin,
            };
            _context.Add(employeeEntity);
        }

        public void DeleteEmployee(int employeeId)
        {
            if(employeeId <= 0) throw new ArgumentOutOfRangeException(nameof(employeeId));
            var employeeToDelete = _context.Employees.Find(employeeId);
            if (employeeToDelete != null)
            {
                _context.Employees.Remove(employeeToDelete);
            }
        }

        public Account? GetAccount(int employeeId)
        {
            var account = _context.Accounts.First(a => a.EmployeeId == employeeId);
            return account;
        }

        public List<EmployeeDto> GetAll()
        {
            return _context.Employees
                .Select(e => new EmployeeDto
                {
                    Id = e.Id,
                    LastName = e.LastName,
                    FirstName = e.FirstName,
                    BirthDate = e.BirthDate,
                    EmploymentDate = e.EmploymentDate,
                    ExperienceLevel = e.ExperienceLevel,
                    ExperienceYears = e.ExperienceYears,
                    IsTeamLeader = e.IsTeamLeader,
                    IsAdmin = e.IsAdmin,
                })
                .ToList();
                
        }

        public EmployeeDto? GetEmployee(int employeeId)
        {
            if (employeeId <= 0) throw new ArgumentOutOfRangeException(nameof(employeeId));

            var employee = _context.Employees.SingleOrDefault(e => e.Id == employeeId);

            if (employee == null) return null;

            var employeeDto = new EmployeeDto
            {
                LastName = employee.LastName,
                FirstName = employee.FirstName,
                BirthDate = employee.BirthDate,
                EmploymentDate = employee.EmploymentDate,
                ExperienceLevel = employee.ExperienceLevel,
                ExperienceYears = employee.ExperienceYears,
                IsTeamLeader = employee.IsTeamLeader,
                IsAdmin = employee.IsAdmin,
            };

            return employeeDto;
        }

        public IEnumerable<EmployeeDto> SearchByName(string searchTerm)
        {
            return _context.Employees
                .Where(e => e.FirstName.Contains(searchTerm) || e.LastName.Contains(searchTerm))
                .Select(e => new EmployeeDto 
                { 
                    Id = e.Id, 
                    LastName = e.LastName, 
                    FirstName = e.FirstName, 
                    BirthDate = e.BirthDate,
                })
                .ToList();
        }

        public void UpdateEmployee(EmployeeDto employeeDto)
        {
            if (employeeDto == null) throw new ArgumentNullException(nameof(employeeDto));
            if (string.IsNullOrEmpty(employeeDto.LastName)) throw new ArgumentException($"{nameof(employeeDto.LastName)} cannot be null or empty.");
            if (string.IsNullOrEmpty(employeeDto.FirstName)) throw new ArgumentException($"{nameof(employeeDto.FirstName)} cannot be null or empty.");
            if (string.IsNullOrEmpty(employeeDto.ExperienceLevel)) throw new ArgumentException($"{nameof(employeeDto.ExperienceLevel)} cannot be null or empty.");
            if (employeeDto.ExperienceYears < 0) throw new ArgumentOutOfRangeException(nameof(employeeDto.ExperienceYears));

            var employeeToUpdate = _context.Employees.Find(employeeDto.Id);
            if (employeeToUpdate == null)
            {
                throw new Exception("The employee has not been found");
            }
            
            employeeToUpdate.FirstName = employeeDto.FirstName;
            employeeToUpdate.LastName = employeeDto.LastName;
            employeeToUpdate.ExperienceLevel = employeeDto.ExperienceLevel;
            employeeToUpdate.ExperienceYears = employeeDto.ExperienceYears;
            employeeToUpdate.IsTeamLeader = employeeDto.IsTeamLeader;
            employeeToUpdate.IsAdmin = employeeDto.IsAdmin;
        }
    }
}