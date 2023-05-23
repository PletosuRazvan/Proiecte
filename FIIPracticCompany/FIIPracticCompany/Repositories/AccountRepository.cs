using FIIPracticCompany.Entities;
using FIIPracticCompany.Repositories.Dtos;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FIIPracticCompany.Repositories
{
    public class AccountRepository : IAccountRepository
    {
        private readonly CompanyContext _context;
        private object employeeToUddate;

        public AccountRepository(CompanyContext context)
        {
            _context = context;
        }
        public void CreateAccount(AccountDto accountDto)
        {
            if (accountDto == null) throw new ArgumentNullException(nameof(accountDto));
            if (accountDto.Id <0) throw new ArgumentOutOfRangeException(nameof(accountDto.Id));
            if (string.IsNullOrEmpty(accountDto.Email)) throw new ArgumentException($"{nameof(accountDto.Email)} cannot be null or empty.");

            if (_context.Accounts.Any(a => a.Email == accountDto.Email))
            {
                throw new Exception("Cannot insert a new account with the same Email.");
            }
            if(_context.Accounts.Any(a => a.EmployeeId == accountDto.EmployeeId))
            {
                throw new Exception("This employee already has an account");
            }
            var accountEntity = new Account
            {
                EmployeeId = accountDto.EmployeeId,
                Email = accountDto.Email,
                PasswordHash = accountDto.PasswordHash,
                PasswordSalt = accountDto.PasswordSalt,
            };
            _context.Accounts.Add(accountEntity);

        }

        public void DeleteAccount(int employeeId)
        {
            if (employeeId <= 0) throw new ArgumentOutOfRangeException(nameof(employeeId));
            var accountToDelete = _context.Accounts.First(a => a.EmployeeId.Equals(employeeId));
            if (accountToDelete != null)
            {
                _context.Accounts.Remove(accountToDelete);
            }
        }

        public AccountDto? GetUserByEmail(string email)
        {
            if (string.IsNullOrEmpty(email)) throw new ArgumentNullException(nameof(email));

            var account = _context.Accounts.SingleOrDefault(a => a.Email == email);

            if (account == null) return null;

            var accountDto = new AccountDto
            {
                Id = account.Id,
                EmployeeId = account.EmployeeId,
                Email = account.Email,
                PasswordHash = account.PasswordHash,
                PasswordSalt = account.PasswordSalt
            };

            return accountDto;
        }

        public bool IsAdmin(string email)
        {
            if (string.IsNullOrEmpty(email)) throw new ArgumentNullException(nameof(email));

            var account = _context.Accounts.SingleOrDefault(a => a.Email == email);

            if (account == null) return false;

            if (_context.Employees.Any(e => e.Id == account.EmployeeId && e.IsAdmin == 1)) return true; 

            return false;
        }
    }
}
