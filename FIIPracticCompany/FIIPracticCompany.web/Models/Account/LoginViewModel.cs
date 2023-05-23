using System.ComponentModel.DataAnnotations;

namespace FIIPracticCompany.web.Models.Account
{
    public class LoginViewModel
    {
        [EmailAddress(ErrorMessage = "The email is invalid!")]
        public required string Email { get; set; }
        [MinLength(10, ErrorMessage = "The password is invalid!!")]
        public required string Password { get; set; }
    }
}
