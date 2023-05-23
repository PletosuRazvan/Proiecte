using FIIPracticCompany.Repositories;
using FIIPracticCompany.Repositories.Dtos;
using FIIPracticCompany.Services.Models;
using FIIPracticCompany.web.Models.Account;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NuGet.Protocol.Plugins;
using System.Net;
using System.Security.Claims;

namespace FIIPracticCompany.web.Controllers
{
    public class AccountController : Controller
    {
        private readonly ICryptographyService _cryptographyService;
        private readonly IEmployeeRepository _employeeRepository;
        private readonly ICompanyUnitOfWork _companyUnitOfWork;
        private readonly IAccountRepository _accountRepository;

        public AccountController(
            ICryptographyService cryptographyService
            , IEmployeeRepository employeeRepository
            , ICompanyUnitOfWork companyUnitOfWork
            , IAccountRepository accountRepository)
        {
            _cryptographyService = cryptographyService;
            _employeeRepository = employeeRepository;
            _companyUnitOfWork = companyUnitOfWork;
            _accountRepository = accountRepository;
        }

        public IActionResult Index()
        {
            return View();
        }
        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View();
            }
            if (HttpContext.User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Index");
            }
            var account = _accountRepository.GetUserByEmail(model.Email);
            if (account == null)
            {
                Response.StatusCode = (int)HttpStatusCode.NotFound;
                ViewBag.ErrorMessage = "Could not find account";
                return View();
            }
            var hash = _cryptographyService.HashPassword(model.Password, account.PasswordSalt);

            if (account.PasswordHash != hash.Hash)
            {
                Response.StatusCode = (int)HttpStatusCode.NotFound;
                ViewBag.ErrorMessage = "Could not find account";
                return View();
            }

            await SignInAsync(model.Email);

            return RedirectToAction(nameof(Index));
        }

        [Authorize]
        public async Task<IActionResult> Logout()
        {
            if (HttpContext.User.Identity?.IsAuthenticated == false)
            {
                return RedirectToAction(nameof(Index));
            }
            await HttpContext!.SignOutAsync();
            return RedirectToAction(nameof(Login));
        }
        public IActionResult Register()
        {
            return View();
        }
        [HttpPost]
        public async Task<ActionResult> Register(CreateAccountViewModel registerModel)
        {
            var hash = _cryptographyService.HashPasswordWithSaltGeneration(registerModel.Password);
            _accountRepository.CreateAccount(new AccountDto
            {
                EmployeeId = registerModel.EmployeeId,
                Email = registerModel.Email,
                PasswordHash = hash.Hash,
                PasswordSalt = hash.Salt,
            });

            _companyUnitOfWork.SaveChanges();

            await SignInAsync(registerModel.Email);
            return RedirectToAction("Index");
        }
        public IActionResult Employees()
        {
            var employeeDtos = _employeeRepository.GetAll();
            var employeeViewModels = employeeDtos.Select(e => new EmployeeViewModel
            {
                Id = e.Id,
                LastName = e.LastName,
                FirstName = e.FirstName,
                BirthDate = e.BirthDate,
                EmploymentDate = e.EmploymentDate,
                ExperienceLevel = e.ExperienceLevel,
                ExperienceYears = e.ExperienceYears,
            });
            return View(employeeViewModels);
        }
        public IActionResult Admin()
        {
            if (!_accountRepository.IsAdmin(HttpContext.User.Identity.Name))
            {
                return RedirectToAction("Employees");
            }
            var employeeDtos = _employeeRepository.GetAll();
            var employeeViewModels = employeeDtos.Select(e => new EmployeeViewModel
            {
                Id = e.Id,
                LastName = e.LastName,
                FirstName = e.FirstName,
                BirthDate = e.BirthDate,
                EmploymentDate = e.EmploymentDate,
                ExperienceLevel = e.ExperienceLevel,
                ExperienceYears = e.ExperienceYears,
            });
            return View(employeeViewModels);
        }
        private async Task SignInAsync(string email)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimsIdentity.DefaultNameClaimType, email)
            };
            var identity = new ClaimsIdentity(claims, AuthCompanyConstants.Schema);
            var user = new ClaimsPrincipal(identity);
            await HttpContext!.SignInAsync(user);
        }
        [HttpGet]
        public IActionResult Create()
        {
            return View();
        }
        [HttpPost]
        public IActionResult Create([FromForm] AddEmployeeViewModel addEmployee)
        {
            if (addEmployee == null)
            {
                return RedirectToAction("Error", new { message = "AddEmployeeViewModel is null!" });
            }

            if (!ModelState.IsValid)
            {
                return View(addEmployee);
            }

            var employeeDto = new EmployeeDto
            {
                FirstName = addEmployee.FirstName,
                LastName = addEmployee.LastName,
                BirthDate = addEmployee.BirthDate,
                EmploymentDate = addEmployee.EmploymentDate,
                ExperienceLevel = addEmployee.ExperienceLevel,
                ExperienceYears = addEmployee.ExperienceYears,
                IsTeamLeader = addEmployee.IsTeamLeader,
                IsAdmin = addEmployee.IsAdmin,
            };

            _employeeRepository.AddEmployee(employeeDto);
            _companyUnitOfWork.SaveChanges();

            return RedirectToAction("Index");
        }
    }
}
