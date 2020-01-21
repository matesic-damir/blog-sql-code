/* MS SQL DROP IF EXISTS (a.k.a. DIE) */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- drop non existing table
DROP TABLE dbo.SQLNewFunctions;

-- Check if the object exists and drop it
IF OBJECT_ID('dbo.SQLNewFunctions','U') IS NOT NULL DROP TABLE dbo.SQLNewFunctions

-- Using IF EXISTS
DROP TABLE IF EXISTS dbo.SQLNewFunctions
DROP PROCEDURE IF EXISTS dbo.sp_SQLNewFunctions