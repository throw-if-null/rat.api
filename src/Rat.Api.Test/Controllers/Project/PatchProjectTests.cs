﻿using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Rat.Api.Controllers.Projects.Models;
using Rat.Data;
using Rat.Data.Views;
using Xunit;

namespace Rat.Api.Test.Controllers.Project
{
    [Collection("Integration")]
    public class PatchProjectTests
    {
        private readonly IConfiguration Configuration;
        private readonly HttpClient Client;

        public PatchProjectTests(RatFixture fixture)
        {
            Configuration = fixture.Configuration;
            Client = fixture.Client;
        }

        [Fact]
        public async Task Should_Patch()
        {
            using var context = new RatDbContext(Configuration.GetConnectionString("RatDb"));
            var projectTypes = await context.ProjectTypes.ToListAsync();
            var jsType = projectTypes.First(x => x.Name == "js");
            var csharpType = projectTypes.First(x => x.Name == "csharp");

            var project = await context.Projects.AddAsync(new Data.Entities.Project { Name = "Patch", Type = jsType });
            await context.SaveChangesAsync();

            var model = new PatchProjectModel
            {
                Id = project.Entity.Id,
                Name = "New test",
                TypeId = csharpType.Id
            };

            var response = await Client.PatchAsync(
                $"/api/projects/{model.Id}",
                new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json"));

            var contentStream = await response.Content.ReadAsStreamAsync();
            var content = await JsonSerializer.DeserializeAsync<ProjectView>(contentStream, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            Assert.Equal("New test", content.Name);
            Assert.Equal(csharpType.Id, content.TypeId);
        }

        [Theory]
        [InlineData("")]
        [InlineData(null)]
        [InlineData("sqoyhhpamcsnpwzjdwwneydgighyecnwpykbtbugmqclefuhndqpvnfhupwaofgnwlehtwfujyrlavgubnuvqrjdbbanpwvnaneembgplatqvselnwvfefezxznyvnqkdqaalqwyjmlskovuowehyaujnhevlpcgtxhfwwbiwsuozfmeishfnovyteddvyxfmclwiekfqjmelujrevprrsctksqkvnzwqwksibojrnhmcftdjnogsrmane")]
        public async Task Should_Return_BadRequest_When_Name_Value_Is_Invalid(string name)
        {
            using var context = new RatDbContext(Configuration.GetConnectionString("RatDb"));
            var projectType = await context.ProjectTypes.FirstAsync(x => x.Name == "js");

            var project = await context.Projects.AddAsync(new Data.Entities.Project { Name = "Patch", Type = projectType });
            await context.SaveChangesAsync();

            var model = new PatchProjectModel()
            {
                Id = project.Entity.Id,
                Name = name,
                TypeId = projectType.Id
            };

            var response = await Client.PatchAsync(
                $"/api/projects/{model.Id}",
                new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json"));

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }

        [Fact]
        public async Task Should_Return_NotFound()
        {
            using var context = new RatDbContext(Configuration.GetConnectionString("RatDb"));
            var projectType = await context.ProjectTypes.FirstAsync(x => x.Name == "js");

            var project = await context.Projects.AddAsync(new Data.Entities.Project { Name = "Patch", Type = projectType });
            await context.SaveChangesAsync();

            context.Projects.Remove(project.Entity);
            await context.SaveChangesAsync();

            var model = new PatchProjectModel()
            {
                Id = project.Entity.Id,
                Name = "Rat",
                TypeId = projectType.Id
            };

            var response = await Client.PatchAsync(
                $"/api/projects/{model.Id}",
                new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json"));

            Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        }
    }
}
