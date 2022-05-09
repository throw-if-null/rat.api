﻿CREATE PROCEDURE [dbo].[ProjectType_GetById]
	@id int,
	@numberOfChanges int = null OUTPUT
AS
BEGIN
	SELECT [Id], [Name] FROM [dbo].[ProjectType] WHERE Id = @id

	SELECT @numberOfChanges = @@ROWCOUNT
END

RETURN @@ROWCOUNT
