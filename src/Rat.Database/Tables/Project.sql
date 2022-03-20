﻿CREATE TABLE [dbo].[Project]
(
	[Id] INT NOT NULL IDENTITY(1, 1),
	[Name] NVARCHAR(128) NOT NULL,
	[ProjectTypeId] INT NOT NULL,

	[Created] DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(), 
    [Modified] DATETIMEOFFSET NOT NULL DEFAULT GETUTCDATE(), 
    CONSTRAINT [PK_Project_Id] PRIMARY KEY ([Id] ASC),
    CONSTRAINT [FK_Project_ProjectType] FOREIGN KEY ([ProjectTypeId]) REFERENCES [ProjectType]([Id])
)
