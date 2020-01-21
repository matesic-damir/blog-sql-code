/* MS SQL CONCAT vs CONCAT_WS */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* CONCAT */

-- a minimum of two input values, otherwise, an error is raised
SELECT CONCAT('Damir') AS Result;

-- example
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
DECLARE @number_of_drinks int = 3;
SELECT CONCAT(@person_name, ' will order ', @number_of_drinks, 'x ', @drink_name, '. Cheers!') AS Result;

-- NULL values
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT CONCAT(@person_name, ' will order ', @number_of_drinks, 'x ', @drink_name, '. Cheers!') AS Result;

-- Real example
USE [WideWorldImporters];
-- Genertate drop statements for all user tables in database
SELECT CONCAT('DROP TABLE IF EXISTS [', SCHEMA_NAME(schema_id), '].[', name, '];') AS "Drop Statement" FROM sys.tables WHERE type = 'U';

/* CONCAT_WS */

-- a minimum of three input values (a separator and two arguments), otherwise, an error is raised
SELECT CONCAT_WS(';', 'Value 1') AS Result;

-- Genertate CSV file with table names
USE [WideWorldImporters];
SELECT 'Schema name,Table name,Type desc' AS Result UNION ALL
SELECT CONCAT_WS(',', SCHEMA_NAME(schema_id), name, type_desc COLLATE database_default) FROM sys.tables WHERE type = 'U';

-- NULL values
USE [WideWorldImporters];
SELECT 'Schema name,Table name,Type desc' AS Result UNION ALL
SELECT CONCAT_WS(',', SCHEMA_NAME(schema_id), NULL, type_desc COLLATE database_default) FROM sys.tables WHERE type = 'U';