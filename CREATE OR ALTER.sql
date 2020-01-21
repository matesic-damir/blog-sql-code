/* MS SQL CREATE OR ALTER */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- stored procedure that already exist
CREATE PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END
GO
CREATE PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END
GO

-- Check if the object exists, drop and create
IF OBJECT_ID(N'dbo.sp_SQLNewFunctions','P') IS NOT NULL
EXEC('DROP PROCEDURE dbo.sp_SQLNewFunctions');
GO
CREATE PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END

-- CREATE OR ALTER
CREATE OR ALTER PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END