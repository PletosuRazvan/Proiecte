using System.ComponentModel.DataAnnotations;

namespace FIIPracticCompany.web.Models.Account
{
    public class CreateAccountViewModel
    {
        public int EmployeeId { get; set; }

        [EmailAddress(ErrorMessage = "The email is invalid!")]
        public string Email { get; set; }

        [MinLength(10, ErrorMessage = "The password is invalid!!")]
        public string Password { get; set; }
    }
}
