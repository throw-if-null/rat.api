﻿using MediatR;
using Rat.Api.Routes.Data;
using Rat.Core;
using Rat.Core.Queries.Projects.GetProjectById;

namespace Rat.Api.Routes
{
	internal static class GetProjectRoute
	{
		public static RouteHandlerBuilder Map(IEndpointRouteBuilder endpoints)
		{
			var builder =
				endpoints
					.MapGet(
						"/api/project/{id:int}",
						async (int id, IMediator mediator) =>
						{
							var response = await mediator.Send(new GetProjectByIdRequest { Id = id });

							if (response.Context.Status != ProcessingStatus.Ok)
								return HttpResponseHandler.HandleUnscusseful(response.Context);

							return Results.Ok(new GetProjectRouteOutput(response.Project.Id, response.Project.Name, response.Project.TypeId));
						})
					.RequireAuthorization()
					.WithName("GetProjectsById");

			return builder;
		}
	}
}
