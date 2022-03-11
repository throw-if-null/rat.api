﻿using MediatR;
using Microsoft.EntityFrameworkCore;
using Rat.Data;
using Rat.Data.Exceptions;
using Rat.Data.Views;
using Rat.Queries.Properties;

namespace Rat.Queries.Projects.GetProjectsForUser
{
	internal class GetProjectsForUserQuery : IRequestHandler<GetProjectsForUserRequest, GetProjectsForUserResponse>
	{
		private readonly RatDbContext _context;

		public GetProjectsForUserQuery(RatDbContext context)
		{
			_context = context;
		}

		public async Task<GetProjectsForUserResponse> Handle(GetProjectsForUserRequest request, CancellationToken cancellationToken)
		{
			request.Validate();

			var userId = request.UserId;
			var user =
				await
					_context.Users
						.Include(x => x.Projects)
						.ThenInclude(x => x.Project)
						.FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

			// TODO: Moved this to a Command
			if (user == null)
			{
				var userEntity = await _context.Users.AddAsync(new() { UserId = request.UserId }, cancellationToken);

				var expectedNumberOfChanges = 1;
				var changes = await _context.SaveChangesAsync(cancellationToken);

				if (changes != expectedNumberOfChanges)
					throw new RatDbException(string.Format(Resources.ExpactedAndActualNumberOfDatabaseChangesMismatch, changes, expectedNumberOfChanges));

				user = userEntity.Entity;
			}

			return new()
			{
				UserId = user.Id,
				ProjectStats = user.Projects.Select(x => new ProjectStatsView
				{
					Id = x.ProjectId,
					Name = x.Project.Name,
					TotalConfigurationCount = 0,
					TotalEntryCount = 0
				})
			};
		}
	}
}