/* MS SQL FORMATMESSAGE */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- non elegant concatenation
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
SELECT @person_name + ' likes ' + @drink_name + '. Cheers!' AS Result;

-- one more variable of different type
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
DECLARE @number_of_drinks int = 3;
SELECT @person_name + ' will order ' + CAST(@number_of_drinks AS nvarchar(max)) + 'x ' + @drink_name + '. Cheers!' AS Result;

-- NULL
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT @person_name + ' will order ' + CAST(@number_of_drinks AS nvarchar(max)) + 'x ' + @drink_name + '. Cheers!' AS Result;

-- Bullet proof solution :)
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT ISNULL(@person_name, '') + ' will order ' + ISNULL(CAST(@number_of_drinks AS nvarchar(max)), '') + 'x ' + ISNULL(@drink_name, '') + '. Cheers!' AS Result;

-- FORMATMESSAGE function
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
DECLARE @number_of_drinks int = 3;
SELECT FORMATMESSAGE('%s will order %sx %s. Cheers!', @person_name, CAST(@number_of_drinks AS NVARCHAR(MAX)), @drink_name) AS Result;

-- NULL value
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT FORMATMESSAGE('%s will order %sx %s. Cheers!', @person_name, CAST(@number_of_drinks AS NVARCHAR(MAX)), @drink_name) AS Result;

-- Genertate drop statements for all user tables in database
USE [WideWorldImporters];
SELECT FORMATMESSAGE('DROP TABLE IF EXISTS [%s].[%s];', SCHEMA_NAME(schema_id), name) AS "Drop Statement" FROM sys.tables WHERE type = 'U';