﻿using MediatR;
using Rat.Api.Auth;
using Rat.Api.Routes.Data;
using Rat.Core;
using Rat.Core.Queries.Projects.GetProjectsForUser;

namespace Rat.Api.Routes
{
	internal static class GetProjectsForUserRoute
	{
		public static RouteHandlerBuilder Map(IEndpointRouteBuilder endpoints)
		{
			var builder =
				endpoints
					.MapGet(
						"/api/project",
						async (IMediator mediator, IUserProvider userProvider) =>
							{
								var userId = userProvider.GetUserId();

								if (string.IsNullOrWhiteSpace(userId))
									return Results.Forbid();

								var response = await mediator.Send(new GetProjectsForUserRequest { UserId = userId });

								if (response.Context.Status != ProcessingStatus.Ok)
									return HttpResponseHandler.HandleUnscusseful(response.Context);

								var projectStats = response.UserProjectStats.ProjectStats.Select(x => new ProjectStats(x.Id, x.Name, x.TotalConfigurationCount, x.TotalEntryCount));

								return Results.Ok(new GetProjectForUserRouteOutput(response.UserProjectStats.UserId, projectStats));
							})
					.RequireAuthorization()
					.WithName("GetProjectsForUser");

			return builder;
		}
	}
}
