/* MS SQL HASHBYTES */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

USE [WideWorldImporters];
GO

-- Basic example
DECLARE @TestData NVARCHAR(MAX) = 'My test data'
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value];
GO

-- All the hashing algorithms
DECLARE @TestData NVARCHAR(MAX) = 'My test data'
SELECT HASHBYTES ('MD2', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('MD2', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('MD4', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('MD4', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('MD5', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('MD5', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA1', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA1', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA2_256', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA2_256', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA2_512', @TestData)) AS [Data lenght];
GO

-- No salt
DECLARE @TestData NVARCHAR(MAX) = 'My test data'
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value 1];
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value 2];

-- Different data types
SELECT HASHBYTES ('SHA2_512', N'Gin tonic') AS [Hash value 1];
SELECT HASHBYTES ('SHA2_512', 'Gin tonic') AS [Hash value 2];

-- Get hashes for customer invoices
USE [WideWorldImporters];
GO
SELECT 
	C.CustomerID
	, HASHBYTES ('SHA2_512', (
		SELECT 
			*
		FROM 
			[Sales].[Invoices] I 
			INNER JOIN [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
		WHERE 
			I.CustomerID = C.CustomerID 
		FOR XML AUTO)
		) AS [Invoices hash]
FROM 
	[Sales].[Customers] C






