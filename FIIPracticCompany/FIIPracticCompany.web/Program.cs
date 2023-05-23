using FIIPracticCompany.Services.Models;
using FIIPracticCompany.Services;
using FIIPracticCompany;
using FIIPracticCompany.Repositories;
using Microsoft.EntityFrameworkCore;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services
    .AddSqlServer<CompanyContext>(builder.Configuration.GetConnectionString("FIIPracticCompany"))
  .AddScoped<ICompanyUnitOfWork, CompanyUnitOfWork>()
  .AddScoped<IEmployeeRepository, EmployeeRepository>()
  .AddScoped<ICryptographyService, CryptographyService>()
  .AddScoped<IAccountRepository, AccountRepository>();

builder.Services.AddControllersWithViews();

//Configure authentication
builder.Services
  .AddAuthentication(AuthCompanyConstants.Schema)
  .AddCookie(AuthCompanyConstants.Schema);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
