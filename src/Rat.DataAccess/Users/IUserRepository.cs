﻿using System.Threading;
using System.Threading.Tasks;
using Rat.Data.Entities;

namespace Rat.DataAccess.Users
{
    public interface IUserRepository
    {
        Task<User> Create(string externalId, CancellationToken cancellation);
        Task<User> Retrieve(string externalId, CancellationToken cancellation);
    }
}
