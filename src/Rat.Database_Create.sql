﻿/*
Deployment script for Rat.Database

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Rat.Database"
:setvar DefaultFilePrefix "Rat.Database"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF;
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
/* Please run the below section of statements against 'master' database. */
PRINT N'Creating database $(DatabaseName)...'
GO
CREATE DATABASE [$(DatabaseName)] COLLATE SQL_Latin1_General_CP1_CI_AS
GO
DECLARE  @job_state INT = 0;
DECLARE  @index INT = 0;
DECLARE @EscapedDBNameLiteral sysname = N'$(DatabaseName)'
WAITFOR DELAY '00:00:30';
WHILE (@index < 60)
BEGIN
	SET @job_state = ISNULL( (SELECT SUM (result)  FROM (
		SELECT TOP 1 [state] AS result
		FROM sys.dm_operation_status WHERE resource_type = 0
		AND operation = 'CREATE DATABASE' AND major_resource_id = @EscapedDBNameLiteral AND [state] = 2
		ORDER BY start_time DESC
		) r), -1);

	SET @index = @index + 1;

	IF @job_state = 0 /* pending */ OR @job_state = 1 /* in progress */ OR @job_state = -1 /* job not found */ OR (SELECT [state] FROM sys.databases WHERE name = @EscapedDBNameLiteral) <> 0
		WAITFOR DELAY '00:00:30';
	ELSE
    	BREAK;
END
GO
/* Please run the below section of statements against the database name that the above [$(DatabaseName)] variable is assigned to. */
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                DATE_CORRELATION_OPTIMIZATION OFF
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_PLANS_PER_QUERY = 200, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100)
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE = OFF
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET TEMPORAL_HISTORY_RETENTION ON
            WITH ROLLBACK IMMEDIATE;
    END


GO

PRINT N'Creating Table [dbo].[ConfigurationEntry]...';


GO
CREATE TABLE [dbo].[ConfigurationEntry] (
    [Id]                  INT                                         IDENTITY (1, 1) NOT NULL,
    [ConfigurationRootId] INT                                         NOT NULL,
    [Key]                 NVARCHAR (128)                              NOT NULL,
    [Value]               NVARCHAR (2048)                             NOT NULL,
    [SecondsToLive]       INT                                         NOT NULL,
    [Disabled]            BIT                                         NOT NULL,
    [Timestamp]           DATETIMEOFFSET (7)                          NOT NULL,
    [Operation]           NVARCHAR (16)                               NULL,
    [Operator]            INT                                         NOT NULL,
    [ValidFrom]           DATETIME2 (0) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]             DATETIME2 (0) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_ConfigurationEntry_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[ConfigurationEntryHistory], DATA_CONSISTENCY_CHECK=ON, HISTORY_RETENTION_PERIOD=6 MONTH));


GO
PRINT N'Creating Table [dbo].[ConfigurationRoot]...';


GO
CREATE TABLE [dbo].[ConfigurationRoot] (
    [Id]                  INT                                         IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (128)                              NOT NULL,
    [ConfigurationTypeId] INT                                         NOT NULL,
    [ProjectId]           INT                                         NOT NULL,
    [Timestamp]           DATETIMEOFFSET (7)                          NOT NULL,
    [Operation]           NVARCHAR (16)                               NULL,
    [Operator]            INT                                         NOT NULL,
    [ValidFrom]           DATETIME2 (0) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]             DATETIME2 (0) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_ConfigurationRoot_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[ConfigurationRootHistory], DATA_CONSISTENCY_CHECK=ON, HISTORY_RETENTION_PERIOD=6 MONTH));


GO
PRINT N'Creating Table [dbo].[ConfigurationType]...';


GO
CREATE TABLE [dbo].[ConfigurationType] (
    [Id]        INT                                         IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (64)                               NOT NULL,
    [Timestamp] DATETIMEOFFSET (7)                          NOT NULL,
    [Operation] NVARCHAR (16)                               NULL,
    [Operator]  INT                                         NOT NULL,
    [ValidFrom] DATETIME2 (0) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]   DATETIME2 (0) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_ConfigurationType_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[ConfigurationTypeHistory], DATA_CONSISTENCY_CHECK=ON, HISTORY_RETENTION_PERIOD=6 MONTH));


GO
PRINT N'Creating Table [dbo].[Member]...';


GO
CREATE TABLE [dbo].[Member] (
    [Id]             INT                                         IDENTITY (1, 1) NOT NULL,
    [AuthProviderId] NVARCHAR (128)                              NOT NULL,
    [Deleted]        BIT                                         NOT NULL,
    [Timestamp]      DATETIMEOFFSET (7)                          NOT NULL,
    [Operation]      NVARCHAR (16)                               NULL,
    [Operator]       INT                                         NOT NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_User_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_AuthProviderId] UNIQUE NONCLUSTERED ([AuthProviderId] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[MemberHistory], DATA_CONSISTENCY_CHECK=ON, HISTORY_RETENTION_PERIOD=6 MONTH));


GO
PRINT N'Creating Table [dbo].[Project]...';


GO
CREATE TABLE [dbo].[Project] (
    [Id]            INT                                         IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (128)                              NOT NULL,
    [ProjectTypeId] INT                                         NOT NULL,
    [Timestamp]     DATETIMEOFFSET (7)                          NOT NULL,
    [Operation]     NVARCHAR (16)                               NULL,
    [Operator]      INT                                         NOT NULL,
    [ValidFrom]     DATETIME2 (0) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]       DATETIME2 (0) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_Project_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[ProjectHistory], DATA_CONSISTENCY_CHECK=ON, HISTORY_RETENTION_PERIOD=6 MONTH));


GO
PRINT N'Creating Table [dbo].[MemberProject]...';


GO
CREATE TABLE [dbo].[MemberProject] (
    [MemberId]  INT                                         NOT NULL,
    [ProjectId] INT                                         NOT NULL,
    [Timestamp] DATETIMEOFFSET (7)                          NOT NULL,
    [Operation] NVARCHAR (16)                               NULL,
    [Operator]  INT                                         NOT NULL,
    [ValidFrom] DATETIME2 (0) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]   DATETIME2 (0) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_MemberProject_Id] PRIMARY KEY CLUSTERED ([MemberId] ASC, [ProjectId] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[MemberProjectHistory], DATA_CONSISTENCY_CHECK=ON, HISTORY_RETENTION_PERIOD=6 MONTH));


GO
PRINT N'Creating Table [dbo].[ProjectType]...';


GO
CREATE TABLE [dbo].[ProjectType] (
    [Id]        INT                                         IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (64)                               NOT NULL,
    [Timestamp] DATETIMEOFFSET (7)                          NOT NULL,
    [Operation] NVARCHAR (16)                               NULL,
    [Operator]  INT                                         NOT NULL,
    [ValidFrom] DATETIME2 (0) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]   DATETIME2 (0) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_ProjectType_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[ProjectTypeHistory], DATA_CONSISTENCY_CHECK=ON, HISTORY_RETENTION_PERIOD=6 MONTH));


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationEntry]...';


GO
ALTER TABLE [dbo].[ConfigurationEntry]
    ADD DEFAULT -1 FOR [SecondsToLive];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationEntry]...';


GO
ALTER TABLE [dbo].[ConfigurationEntry]
    ADD DEFAULT 0 FOR [Disabled];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationEntry]...';


GO
ALTER TABLE [dbo].[ConfigurationEntry]
    ADD DEFAULT GETUTCDATE() FOR [Timestamp];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationEntry]...';


GO
ALTER TABLE [dbo].[ConfigurationEntry]
    ADD DEFAULT N'insert' FOR [Operation];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationRoot]...';


GO
ALTER TABLE [dbo].[ConfigurationRoot]
    ADD DEFAULT GETUTCDATE() FOR [Timestamp];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationRoot]...';


GO
ALTER TABLE [dbo].[ConfigurationRoot]
    ADD DEFAULT N'insert' FOR [Operation];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationType]...';


GO
ALTER TABLE [dbo].[ConfigurationType]
    ADD DEFAULT GETUTCDATE() FOR [Timestamp];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ConfigurationType]...';


GO
ALTER TABLE [dbo].[ConfigurationType]
    ADD DEFAULT N'insert' FOR [Operation];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Member]...';


GO
ALTER TABLE [dbo].[Member]
    ADD DEFAULT 0 FOR [Deleted];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Member]...';


GO
ALTER TABLE [dbo].[Member]
    ADD DEFAULT GETUTCDATE() FOR [Timestamp];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Member]...';


GO
ALTER TABLE [dbo].[Member]
    ADD DEFAULT N'insert' FOR [Operation];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Project]...';


GO
ALTER TABLE [dbo].[Project]
    ADD DEFAULT GETUTCDATE() FOR [Timestamp];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Project]...';


GO
ALTER TABLE [dbo].[Project]
    ADD DEFAULT N'insert' FOR [Operation];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[MemberProject]...';


GO
ALTER TABLE [dbo].[MemberProject]
    ADD DEFAULT GETUTCDATE() FOR [Timestamp];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[MemberProject]...';


GO
ALTER TABLE [dbo].[MemberProject]
    ADD DEFAULT N'insert' FOR [Operation];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ProjectType]...';


GO
ALTER TABLE [dbo].[ProjectType]
    ADD DEFAULT GETUTCDATE() FOR [Timestamp];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[ProjectType]...';


GO
ALTER TABLE [dbo].[ProjectType]
    ADD DEFAULT N'insert' FOR [Operation];


GO
PRINT N'Creating Foreign Key [dbo].[FK_ConfigurationEntry_ConfigurationRootId-ConfigurationRoot_Id]...';


GO
ALTER TABLE [dbo].[ConfigurationEntry]
    ADD CONSTRAINT [FK_ConfigurationEntry_ConfigurationRootId-ConfigurationRoot_Id] FOREIGN KEY ([ConfigurationRootId]) REFERENCES [dbo].[ConfigurationRoot] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ConfigurationEntry_Member_Operator]...';


GO
ALTER TABLE [dbo].[ConfigurationEntry]
    ADD CONSTRAINT [FK_ConfigurationEntry_Member_Operator] FOREIGN KEY ([Operator]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ConfigurationRoot_ProjectId__Project_Id]...';


GO
ALTER TABLE [dbo].[ConfigurationRoot]
    ADD CONSTRAINT [FK_ConfigurationRoot_ProjectId__Project_Id] FOREIGN KEY ([ProjectId]) REFERENCES [dbo].[Project] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ConfigurationRoot_ConfigurationTypeId__ConfigurationType_Id]...';


GO
ALTER TABLE [dbo].[ConfigurationRoot]
    ADD CONSTRAINT [FK_ConfigurationRoot_ConfigurationTypeId__ConfigurationType_Id] FOREIGN KEY ([ConfigurationTypeId]) REFERENCES [dbo].[ConfigurationType] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ConfigurationRoot_Member_Operator]...';


GO
ALTER TABLE [dbo].[ConfigurationRoot]
    ADD CONSTRAINT [FK_ConfigurationRoot_Member_Operator] FOREIGN KEY ([Operator]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ConfigurationType_Member_Operator]...';


GO
ALTER TABLE [dbo].[ConfigurationType]
    ADD CONSTRAINT [FK_ConfigurationType_Member_Operator] FOREIGN KEY ([Operator]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_Member_Member_Operator]...';


GO
ALTER TABLE [dbo].[Member]
    ADD CONSTRAINT [FK_Member_Member_Operator] FOREIGN KEY ([Operator]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_Project_ProjectType]...';


GO
ALTER TABLE [dbo].[Project]
    ADD CONSTRAINT [FK_Project_ProjectType] FOREIGN KEY ([ProjectTypeId]) REFERENCES [dbo].[ProjectType] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_Project_Member_Operator]...';


GO
ALTER TABLE [dbo].[Project]
    ADD CONSTRAINT [FK_Project_Member_Operator] FOREIGN KEY ([Operator]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_MemberProject_User]...';


GO
ALTER TABLE [dbo].[MemberProject]
    ADD CONSTRAINT [FK_MemberProject_User] FOREIGN KEY ([MemberId]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_MemberProject_Project]...';


GO
ALTER TABLE [dbo].[MemberProject]
    ADD CONSTRAINT [FK_MemberProject_Project] FOREIGN KEY ([ProjectId]) REFERENCES [dbo].[Project] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_MemberProject_Member_Operator]...';


GO
ALTER TABLE [dbo].[MemberProject]
    ADD CONSTRAINT [FK_MemberProject_Member_Operator] FOREIGN KEY ([Operator]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ProjectType_Member_Operator]...';


GO
ALTER TABLE [dbo].[ProjectType]
    ADD CONSTRAINT [FK_ProjectType_Member_Operator] FOREIGN KEY ([Operator]) REFERENCES [dbo].[Member] ([Id]);


GO
PRINT N'Creating Check Constraint [dbo].[CH_ConfigurationEntry_Operation]...';


GO
ALTER TABLE [dbo].[ConfigurationEntry]
    ADD CONSTRAINT [CH_ConfigurationEntry_Operation] CHECK ([Operation] IN (N'insert', N'update', N'delete'));


GO
PRINT N'Creating Check Constraint [dbo].[CH_ConfigurationRoot_Operation]...';


GO
ALTER TABLE [dbo].[ConfigurationRoot]
    ADD CONSTRAINT [CH_ConfigurationRoot_Operation] CHECK ([Operation] IN (N'insert', N'update', N'delete'));


GO
PRINT N'Creating Check Constraint [dbo].[CH_ConfigurationType_Operation]...';


GO
ALTER TABLE [dbo].[ConfigurationType]
    ADD CONSTRAINT [CH_ConfigurationType_Operation] CHECK ([Operation] IN (N'insert', N'update', N'delete'));


GO
PRINT N'Creating Check Constraint [dbo].[CH_Member_Operation]...';


GO
ALTER TABLE [dbo].[Member]
    ADD CONSTRAINT [CH_Member_Operation] CHECK ([Operation] IN (N'insert', N'update', N'delete'));


GO
PRINT N'Creating Check Constraint [dbo].[CH_Project_Operation]...';


GO
ALTER TABLE [dbo].[Project]
    ADD CONSTRAINT [CH_Project_Operation] CHECK ([Operation] IN (N'insert', N'update', N'delete'));


GO
PRINT N'Creating Check Constraint [dbo].[CH_MemberProject_Operation]...';


GO
ALTER TABLE [dbo].[MemberProject]
    ADD CONSTRAINT [CH_MemberProject_Operation] CHECK ([Operation] IN (N'insert', N'update', N'delete'));


GO
PRINT N'Creating Check Constraint [dbo].[CH_ProjectType_Operation]...';


GO
ALTER TABLE [dbo].[ProjectType]
    ADD CONSTRAINT [CH_ProjectType_Operation] CHECK ([Operation] IN (N'insert', N'update', N'delete'));


GO
PRINT N'Creating Function [dbo].[GetConfigurationEntryCount]...';


GO
CREATE FUNCTION [dbo].[GetConfigurationEntryCount]
(
	@configurationRootId int
)
RETURNS INT
AS
BEGIN
	DECLARE @entries INT

	SELECT @entries = COUNT(*)
	FROM [dbo].[ConfigurationEntry]
	WHERE [ConfigurationRootId] = @configurationRootId

	RETURN @entries
END
GO
PRINT N'Creating Function [dbo].[GetConfigurationRootCount]...';


GO
CREATE FUNCTION [dbo].[GetConfigurationRootCount]
(
	@projectId int
)
RETURNS INT
AS
BEGIN
	DECLARE @count int

	SELECT @count = COUNT(*) FROM [dbo].[ConfigurationRoot] WHERE [ProjectId] = @projectId

	RETURN @count
END
GO
PRINT N'Creating Function [dbo].[GetProjectConfigurationEntryCount]...';


GO
CREATE FUNCTION [dbo].[GetProjectConfigurationEntryCount]
(
	@projectId int
)
RETURNS INT
AS
BEGIN
	DECLARE @count int

	SELECT @count = COUNT(*)
	FROM [dbo].[ConfigurationEntry] AS ce
	INNER JOIN [dbo].[ConfigurationRoot] AS cr
	ON ce.[ConfigurationRootId] = cr.[Id]
	WHERE cr.[ProjectId] = @projectId

	RETURN @count
END
GO
PRINT N'Creating Procedure [dbo].[ConfigurationEntry_GetByConfigurationRootId]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationEntry_GetByConfigurationRootId]
	@configurationRootId int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT
		ce.[Id],
		ce.[Key],
		ce.[Value],
		ce.[Disabled],
		ce.[SecondsToLive],
		ce.[Operator],
		ce.[Operation],
		ce.[Timestamp]
	FROM [dbo].[ConfigurationEntry] AS ce
	WHERE [ConfigurationRootId] = @configurationRootId
	ORDER BY ce.[Timestamp] ASC

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationEntry_Insert]...';


GO
CREATE PROCEDURE dbo.ConfigurationEntry_Insert
    @configurationRootId int,
    @key nvarchar(128),
    @value nvarchar(2048),
    @secondsToLive int,
    @disabled bit,
    @createdBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
    INSERT INTO [dbo].[ConfigurationEntry] ([ConfigurationRootId], [Key], [Value], [SecondsToLive], [Disabled], [Operator], [Operation])
    VALUES(@configurationRootId, @key, @value, @secondsToLive, @disabled, @createdBy, N'insert')

    SELECT SCOPE_IDENTITY() AS [Id]

    SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationRoot_GetByProjectId]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationRoot_GetByProjectId]
	@projectId int = 0,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT
		cr.[Id],
		cr.[Name],
		cr.[ConfigurationTypeId],
		cr.[Operator],
		cr.[Operation],
		cr.[Timestamp],
		[ConfigurationEntryCount] = [dbo].[GetConfigurationEntryCount] (cr.[Id])
	FROM [dbo].[ConfigurationRoot] AS cr
	WHERE cr.[ProjectId] = @projectId

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationRoot_Update]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationRoot_Update]
	@name nvarchar(64) = NULL,
	@configurationTypeId int = NULL,
	@modifiedBy int,
	@id int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	UPDATE [dbo].[ConfigurationRoot]
	SET
		[Name] = ISNULL(@name, [Name]),
		[ConfigurationTypeId] = ISNULL(@configurationTypeId, [ConfigurationTypeId]),
		[Operator] = @modifiedBy,
		[Operation] = N'update',
		[Timestamp] = GETUTCDATE()
	WHERE
		(@name IS NOT NULL OR @configurationTypeId IS NOT NULL) AND
		[Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Member_Insert]...';


GO
CREATE PROCEDURE dbo.Member_Insert
    @authProviderId nvarchar(128),
    @createdBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
    INSERT INTO [dbo].[Member] ([AuthProviderId], [Operator], [Operation])
    VALUES(@authProviderId, @createdBy, N'insert')

    SELECT SCOPE_IDENTITY() AS [Id]

    SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[MemberProject_Insert]...';


GO
CREATE PROCEDURE dbo.MemberProject_Insert
    @memberId int,
    @projectId int,
    @createdBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
    INSERT INTO [dbo].[MemberProject] ([MemberId], [ProjectId], [Operator], [Operation])
    VALUES(@memberId, @projectId, @createdBy, N'insert')

    SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Project_GetById]...';


GO
CREATE PROCEDURE [dbo].[Project_GetById]
	@id int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT
		p.[Id],
		p.[Name],
		p.[ProjectTypeId],
		p.[Operator],
		p.[Operation],
		p.[Timestamp],
		[ConfigurationCount] = [dbo].[GetConfigurationRootCount] ([Id]),
		[EntriesCount] = [dbo].[GetProjectConfigurationEntryCount] ([Id])
	FROM [dbo].[Project] AS p
	WHERE [Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Project_GetProjectsForMember]...';


GO
CREATE PROCEDURE [dbo].[Project_GetProjectsForMember]
	@memberId int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT
		p.[Id],
		p.[Name],
		p.[ProjectTypeId],
		p.[Operator],
		p.[Operation],
		p.[Timestamp]
	FROM [dbo].[MemberProject] AS mp
	INNER JOIN [dbo].[Project] AS p
		ON mp.[ProjectId] = p.[Id]
	WHERE mp.[MemberId] = @memberId

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Project_Update]...';


GO
CREATE PROCEDURE [dbo].[Project_Update]
	@name nvarchar(128) = NULL,
	@projectTypeId int = NULL,
	@id int,
	@modifiedBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	UPDATE [dbo].[Project]
	SET
		[Name] = ISNULL(@name, [Name]),
		[ProjectTypeId] = ISNULL(@projectTypeId, [ProjectTypeId]),
		[Operator] = @modifiedBy,
		[Operation] = N'update',
		[Timestamp] = GETUTCDATE()
	WHERE
		[Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ProjectType_GetAll]...';


GO
CREATE PROCEDURE dbo.ProjectType_GetAll(
	@numberOfChanges int = null OUTPUT
)
AS
BEGIN
    SELECT
		pt.[Id],
		pt.[Name],
		pt.[Operator],
		pt.[Operation],
		pt.[Timestamp]
	FROM [dbo].[ProjectType] AS pt

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ProjectType_GetById]...';


GO
CREATE PROCEDURE [dbo].[ProjectType_GetById]
	@id int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT
		pt.[Id],
		pt.[Name],
		pt.[Operator],
		pt.[Operation],
		pt.[Timestamp]
	FROM [dbo].[ProjectType] AS pt
	WHERE Id = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ProjectType_Insert]...';


GO
CREATE PROCEDURE dbo.ProjectType_Insert
    @name nvarchar(64),
    @createdBy int,
    @numberOfChanges int = null OUTPUT
AS
BEGIN
    INSERT INTO [dbo].[ProjectType] ([Name], [Operator], [Operation])
    VALUES(@name, @createdBy, N'insert')

    SELECT SCOPE_IDENTITY() AS [Id]

    SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ProjectType_Update]...';


GO
CREATE PROCEDURE [dbo].[ProjectType_Update]
	@name nvarchar(64),
	@id int,
	@modifiedBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	UPDATE [ProjectType]
	SET
		[Name] = @name,
		[Operator] = @modifiedBy,
		[Operation] = N'update',
		[Timestamp] = GETUTCDATE()
	WHERE
		[Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Member_SoftDelete]...';


GO
CREATE PROCEDURE [dbo].[Member_SoftDelete]
	@id int,
	@modifiedBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	UPDATE [dbo].[Member]
	SET
		[Deleted] = 1,
		[Operator] = @modifiedBy,
		[Operation] = N'delete',
		[Timestamp] = GETUTCDATE()
	WHERE [Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Project_Insert]...';


GO
CREATE PROCEDURE dbo.Project_Insert
    @name nvarchar(128),
    @projectTypeId int,
    @createdBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
    INSERT INTO [dbo].[Project] ([Name], [ProjectTypeId], [Operator], [Operation])
    VALUES(@name, @projectTypeId, @createdBy, N'insert')

    DECLARE @id int = SCOPE_IDENTITY()

    EXEC [dbo].[Project_GetById] @id

    SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Project_Delete]...';


GO
CREATE PROCEDURE [dbo].[Project_Delete]
	@id int,
	@deletedBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT @numberOfChanges = @@ROWCOUNT
	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE [dbo].[Project]
		SET
			[Operator] = @deletedBy,
			[Operation] = N'delete',
			[Timestamp] = GETUTCDATE()
		WHERE [Id] = @id

		DELETE FROM [dbo].[Project] WHERE Id = @id

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		DECLARE @error nvarchar(2048) = error_message()
		RAISERROR(@error, 16, 1)
	END CATCH

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationEntry_Delete]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationEntry_Delete]
	@id int,
	@deletedBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE [dbo].[ConfigurationEntry]
		SET
			[Operator] = @deletedBy,
			[Operation] = N'delete',
			[Timestamp] = GETUTCDATE()
		WHERE [Id] = @id

		DELETE FROM [dbo].[ConfigurationEntry] WHERE Id = @id

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		DECLARE @error nvarchar(2048) = error_message()
		RAISERROR(@error, 16, 1)
	END CATCH

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationRoot_Delete]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationRoot_Delete]
	@id int,
	@deletedBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE [dbo].[ConfigurationRoot]
		SET
			[Operator] = @deletedBy,
			[Operation] = N'delete',
			[Timestamp] = GETUTCDATE()
		WHERE [Id] = @id

		DELETE FROM [dbo].[ConfigurationRoot] WHERE [Id] = @id

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		DECLARE @error nvarchar(2048) = error_message()
		RAISERROR(@error, 16, 1)
	END CATCH

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[MemberProject_Delete]...';


GO
CREATE PROCEDURE [dbo].[MemberProject_Delete]
	@memberId int,
	@projectId int,
	@deletedBy int,
	@numberOfChanges int NULL OUTPUT
AS
BEGIN
	SELECT @numberOfChanges = @@ROWCOUNT
		BEGIN TRANSACTION

		BEGIN TRY
			UPDATE [dbo].[MemberProject]
			SET
				[Operator] = @deletedBy,
				[Operation] = N'delete',
				[Timestamp] = GETUTCDATE()
			WHERE
				[MemberId] = @memberId AND
				[ProjectId] = @projectId

			DELETE FROM [dbo].[MemberProject] WHERE [MemberId] = @memberId AND [ProjectId] = @projectId

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END

			DECLARE @error nvarchar(2048) = error_message()
			RAISERROR(@error, 16, 1)
		END CATCH

		SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ProjectType_Delete]...';


GO
CREATE PROCEDURE [dbo].[ProjectType_Delete]
	@id int,
	@deletedBy int,
	@numberOfChanges int = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE [dbo].[ProjectType]
		SET
			[Operator] = @deletedBy,
			[Operation] = N'delete',
			[Timestamp] = GETUTCDATE()
		WHERE [Id] = @id

		DELETE FROM [ProjectType] WHERE Id = @id

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		DECLARE @error nvarchar(2048) = error_message()
		RAISERROR(@error, 16, 1)
	END CATCH

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationRoot_Insert]...';


GO
CREATE PROCEDURE dbo.ConfigurationRoot_Insert
    @projectId int,
    @name nvarchar(128),
    @configurationTypeId int,
    @createdBy int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
    INSERT INTO [dbo].[ConfigurationRoot] ([Name], [ConfigurationTypeId], [ProjectId], [Operator], [Operation])
    VALUES(@name, @configurationTypeId, @projectId, @createdBy, N'insert')

    SELECT SCOPE_IDENTITY() AS [Id]

    SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationEntry_Update]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationEntry_Update]
	@key nvarchar(128) = NULL,
	@value nvarchar(2096) = NULL,
	@secondsToLive int = NULL,
	@disabled bit = NULL,
	@modifiedBy int,
	@id int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	UPDATE [dbo].[ConfigurationEntry]
	SET
		[Key] = ISNULL(@key, [Key]),
		[Value] = ISNULL(@value, [Value]),
		[SecondsToLive] = ISNULL(@secondsToLive, [SecondsToLive]),
		[Disabled] = ISNULL(@disabled, [Disabled]),
		[Operator] = @modifiedBy,
		[Operation] = N'update',
		[Timestamp] = GETUTCDATE()
	WHERE
		(@key IS NOT NULL OR @value IS NOT NULL OR @secondsToLive IS NOT NULL OR @disabled IS NOT NULL) AND
		[Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationEntry_GetById]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationEntry_GetById]
	@id int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT
		ce.[Id],
		ce.[Key],
		ce.[Value],
		ce.[SecondsToLive],
		ce.[Disabled],
		ce.[Operator],
		ce.[Operation],
		ce.[Timestamp],
		ce.[ConfigurationRootId]
	FROM [dbo].[ConfigurationEntry] AS ce
	WHERE ce.[Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[ConfigurationRoot_GetById]...';


GO
CREATE PROCEDURE [dbo].[ConfigurationRoot_GetById]
	@id int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT
		cr.[Id],
		cr.[Name],
		cr.[ConfigurationTypeId],
		cr.[ProjectId],
		cr.[Operator],
		cr.[Operation],
		cr.[Timestamp]
	FROM [dbo].[ConfigurationRoot] AS cr
	WHERE cr.[Id] = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
PRINT N'Creating Procedure [dbo].[Member_GetByAuthProviderId]...';


GO
CREATE PROCEDURE [dbo].[Member_GetByAuthProviderId]
	@authProviderId nvarchar(128),
	@numberOfChanges int = NULL OUTPUT

AS
BEGIN
	SELECT
		m.[Id],
		m.[AuthProviderId],
		m.[Deleted],
		m.[Timestamp],
		m.[Operator],
		m.[Operation]
	FROM [dbo].[Member] AS m
	WHERE
		m.[AuthProviderId] = @authProviderId AND
		m.[Deleted] = 0

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
GO
-- Refactoring step to update target server with deployed transaction logs

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = 'a8c1facd-de0a-4375-a104-34489e6d7318')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('a8c1facd-de0a-4375-a104-34489e6d7318')
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = 'd7ba0951-1cff-47b1-b76e-4deed6ad3850')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('d7ba0951-1cff-47b1-b76e-4deed6ad3850')

GO

GO
/*
Post-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.
 Use SQLCMD syntax to include a file in the post-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the post-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/

-- Insert machine user
SET IDENTITY_INSERT [dbo].[Member] ON

INSERT INTO [dbo].[Member] ([Id], [AuthProviderId], [Operator], [Operation])
SELECT 1, '', 1, N'insert'
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[Member] WHERE Id = 1)

SET IDENTITY_INSERT [dbo].[Member] OFF

-- Insert project types
SET IDENTITY_INSERT [dbo].[ProjectType] ON

INSERT INTO [dbo].[ProjectType] ([Id], [Name], [Operator], [Operation])
SELECT 1, 'js', 1, N'insert'
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ProjectType] WHERE Id = 1)

INSERT INTO [dbo].[ProjectType] ([Id], [Name], [Operator], [Operation])
SELECT 2, 'csharp', 1, N'insert'
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ProjectType] WHERE Id = 2)

SET IDENTITY_INSERT [dbo].[ProjectType] OFF

-- Insert configuration types
SET IDENTITY_INSERT [dbo].[ConfigurationType] ON

INSERT INTO [dbo].[ConfigurationType] ([Id], [Name], [Operator], [Operation])
SELECT 1, 'web', 1, N'insert'
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ConfigurationType] WHERE Id = 1)

INSERT INTO [dbo].[ConfigurationType] ([Id], [Name], [Operator], [Operation])
SELECT 2, 'desktop', 1, N'insert'
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ConfigurationType] WHERE Id = 2)

INSERT INTO [dbo].[ConfigurationType] ([Id], [Name], [Operator], [Operation])
SELECT 3, 'mobile', 1, N'insert'
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ConfigurationType] WHERE Id = 3)

INSERT INTO [dbo].[ConfigurationType] ([Id], [Name], [Operator], [Operation])
SELECT 4, 'api', 1, N'insert'
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[ConfigurationType] WHERE Id = 4)

SET IDENTITY_INSERT [dbo].[ConfigurationType] OFF
GO

GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
PRINT N'Update complete.';


GO
