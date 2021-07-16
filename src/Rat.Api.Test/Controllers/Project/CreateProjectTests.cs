﻿using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Rat.Api.Controllers.Projects.Models;
using Rat.Data;
using Rat.Data.Views;
using Snapshooter.Xunit;
using Xunit;

namespace Rat.Api.Test.Controllers.Project
{
    [Collection("Integration")]
    public class CreateProjectTests
    {
        private readonly IConfiguration Configuration;
        private readonly HttpClient Client;

        public CreateProjectTests(RatFixture fixture)
        {
            Configuration = fixture.Configuration;
            Client = fixture.Client;
        }

        [Fact]
        public async Task Should_Return_Created()
        {
            using var context = new RatDbContext(Configuration.GetConnectionString("RatDb"));
            var projectType = await context.ProjectTypes.FirstOrDefaultAsync(x => x.Name == "js");

            var model = new CreateProjectModel
            {
                Name = "Rat Api",
                TypeId = projectType.Id
            };

            var response = await Client.PostAsync(
                "/api/projects",
                new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json"));

            Assert.Equal(HttpStatusCode.Created, response.StatusCode);

            var contentStream = await response.Content.ReadAsStreamAsync();
            var content = await JsonSerializer.DeserializeAsync<ProjectView>(contentStream, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            Assert.True(content.Id > 0);
        }

        [Theory]
        [InlineData("", "1")]
        [InlineData(null, "2")]
        public async Task Should_Return_BadRequest(string name, string version)
        {
            var model = new CreateProjectModel
            {
                Name = name
            };

            var response = await Client.PostAsync(
                "/api/projects",
                new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json"));

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

            Snapshot.Match(response.ReasonPhrase, $"{nameof(CreateProjectTests)}.{nameof(Should_Return_BadRequest)}.{version}");
        }
    }
}
