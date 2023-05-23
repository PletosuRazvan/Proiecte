using Microsoft.IdentityModel.Tokens;

namespace FIIPracticCompany
{
    public class CompanyUnitOfWork : ICompanyUnitOfWork, IDisposable
    {
        private bool disposedValue;
        private readonly CompanyContext companyContext;

        public CompanyUnitOfWork(CompanyContext companyContext)
        {
            this.companyContext = companyContext;
        }

        public void SaveChanges()
        {
            companyContext.SaveChanges();
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    companyContext.Dispose();
                }

                disposedValue = true;
            }
        }

        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }
}
