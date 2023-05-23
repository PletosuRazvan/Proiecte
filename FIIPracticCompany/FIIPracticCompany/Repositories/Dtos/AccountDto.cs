using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FIIPracticCompany.Repositories.Dtos
{
    public class AccountDto
    {
        public int Id { get; set; }
        public int EmployeeId { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string PasswordSalt { get; set; }
    }
}
