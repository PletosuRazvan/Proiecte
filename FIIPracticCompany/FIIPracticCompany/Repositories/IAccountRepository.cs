using FIIPracticCompany.Repositories.Dtos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FIIPracticCompany.Repositories
{
    public interface IAccountRepository
    {
        void CreateAccount(AccountDto accountDto);
        void DeleteAccount(int employeeId);
        AccountDto? GetUserByEmail(string email);
        bool IsAdmin(string email);
    }
}
