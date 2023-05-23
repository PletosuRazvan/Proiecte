using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FIIPracticCompany.Services.Models
{
    public record HashedPassword(string Hash, string Salt);
}

