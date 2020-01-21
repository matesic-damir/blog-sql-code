/* MS SQL STRING_ESCAPE */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- Example of STRING_ESCAPE
DECLARE @InputValue NVARCHAR(MAX) = N'
https://blog.matesic.info
C:\\MS SQL STRING ESCAPE
TAB:	';
SELECT STRING_ESCAPE(@InputValue,'JSON') AS Result;

-- Control character escape
SELECT STRING_ESCAPE(CHAR(7),'JSON') AS Result;

-- Escape of NULL value
SELECT STRING_ESCAPE(NULL,'JSON') AS Result;

-- Creating JSON object 
USE [WideWorldImporters];
SELECT 
	FORMATMESSAGE('{ "CustomerID": %d,"Name": "%s" }', [CustomerID], STRING_ESCAPE([CustomerName],'json')) AS "JSON Object"
FROM 
	[Sales].[Customers]  