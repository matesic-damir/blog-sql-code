/* MS SQL JSON functions, tips & tricks */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* JSON_VALUE */

-- Extract some values
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\\www.microsoft.com",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteColors": ["Red", "Purple", "Green"]
}';
SELECT 
	JSON_VALUE(@JSON_data, '$.Name') AS Name
	, JSON_VALUE(@JSON_data, '$.BornAfterWoodstock') AS BornAfterWoodstock
	, JSON_VALUE(@JSON_data, '$.FavoriteColors') AS FavoriteColors 
	, JSON_VALUE(@JSON_data, '$.FavoriteColors[1]') AS SecondColor 

-- Extract some values - strict
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\\www.microsoft.com",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteColors": ["Red", "Purple", "Green"]
}';
SELECT 
	JSON_VALUE(@JSON_data, 'strict $.Name') AS Name
	, JSON_VALUE(@JSON_data, 'strict $.BornAfterWoodstock') AS BornAfterWoodstock
	, JSON_VALUE(@JSON_data, 'strict $.FavoriteColors') AS FavoriteColors 
	, JSON_VALUE(@JSON_data, 'strict $.FavoriteColors[1]') AS SecondColor 

-- more than 4000 chars
DECLARE @LargeJSON NVARCHAR(MAX) = CONCAT('{"data":"', REPLICATE('0',4096), '",}')
SELECT
	JSON_VALUE(@LargeJSON, '$.data') AS LargeData;

-- more than 4000 chars - strict
DECLARE @LargeJSON NVARCHAR(MAX) = CONCAT('{"data":"', REPLICATE('0',4096), '",}')
SELECT
	JSON_VALUE(@LargeJSON, 'strict $.data') AS LargeData;

/* JSON_QUERY */

-- Extract some values
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\\www.microsoft.com",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteColors": ["Red", "Purple", "Green"]
}';
SELECT 
	JSON_QUERY(@JSON_data, '$.Name') AS Name
	, JSON_QUERY(@JSON_data, '$.BornAfterWoodstock') AS BornAfterWoodstock
	, JSON_QUERY(@JSON_data, '$.FavoriteColors') AS FavoriteColors 
	, JSON_QUERY(@JSON_data, '$.FavoriteColors[1]') AS SecondColor 

-- Extract some values - strict
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\\www.microsoft.com",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteColors": ["Red", "Purple", "Green"]
}';
SELECT 
	JSON_QUERY(@JSON_data, 'strict $.Name') AS Name
	, JSON_QUERY(@JSON_data, 'strict $.BornAfterWoodstock') AS BornAfterWoodstock
	, JSON_QUERY(@JSON_data, 'strict $.FavoriteColors') AS FavoriteColors 
	, JSON_QUERY(@JSON_data, 'strict $.FavoriteColors[1]') AS SecondColor 

/* ISJSON */

-- NULL
SELECT ISJSON(NULL) AS IsJson_Result
UNION
-- Invalid
SELECT ISJSON(N'"Name": "John Doe"') AS IsJson_Result
UNION
-- Valid
SELECT ISJSON(N'{
"Name": "John Doe",
"URL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}') AS IsJson_Result

-- Check constraint

USE WideWorldImporters;
GO
DROP TABLE IF EXISTS dbo.TestUserSettings;
GO
CREATE TABLE dbo.TestUserSettings(
	[Key] NVARCHAR(256) NOT NULL,
	App_Settings NVARCHAR(MAX) NULL CONSTRAINT CK_user_settings CHECK (ISJSON(App_Settings) = 1)
);
GO
INSERT INTO dbo.TestUserSettings ([Key], App_Settings) VALUES ('key1', NULL);
INSERT INTO dbo.TestUserSettings ([Key], App_Settings) VALUES  ('key1', N'"Name": "John Doe"');
INSERT INTO dbo.TestUserSettings ([Key], App_Settings) VALUES  ('key1', N'{
"Name": "John Doe",
"URL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}');
GO
SELECT * FROM dbo.TestUserSettings;
GO
DROP TABLE IF EXISTS dbo.TestUserSettings;
GO

/* Import JSON data from a file */

-- Existing file
SELECT [key], [value], [type]
FROM OPENROWSET (BULK 'C:\Private\JSON_data.json', SINGLE_CLOB) AS x
CROSS APPLY OPENJSON(BulkColumn);

/* Indexing JSON data */

USE WideWorldImporters;
GO
DROP TABLE IF EXISTS dbo.JSONIndexing;
GO
CREATE TABLE dbo.JSONIndexing(
    [CustomerID] INT NOT NULL,
    [CustomerData] NVARCHAR(2000) NULL,
    CONSTRAINT PK_JSONIndexing PRIMARY KEY CLUSTERED([CustomerID])
);
GO
INSERT INTO dbo.JSONIndexing ([CustomerID], [CustomerData])
SELECT 
    [CustomerID] 
    , ( SELECT 
		  C1.[CustomerName] AS Name
		  , PC1.FullName AS PrimaryContact
		  , C1.PhoneNumber AS 'Contact.Phone'
		  , C1.FaxNumber AS 'Contact.Fax'
		  , C1.WebsiteURL
	   FROM 
		  [Sales].[Customers] C1 
		  LEFT JOIN [Application].[People] PC1 ON C1.PrimaryContactPersonID = PC1.PersonID
	   WHERE 
		  C1.CustomerID = C.CustomerID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
FROM [Sales].[Customers] C
GO

-- Select Idaho City customers
SELECT * FROM dbo.JSONIndexing WHERE JSON_VALUE([CustomerData],'$.Name') LIKE '%Idaho City%';
GO

-- Add computed column with index
ALTER TABLE dbo.JSONIndexing ADD Customer_Name AS JSON_VALUE([CustomerData], '$.Name');
CREATE INDEX IDX_Customer_Name ON dbo.JSONIndexing(Customer_Name);
GO

-- Repeat
SELECT * FROM dbo.JSONIndexing WHERE Customer_Name LIKE '%Idaho City%';
GO

-- Drop index and column
DROP INDEX [IDX_Customer_Name] ON [dbo].[JSONIndexing]
ALTER TABLE [dbo].[JSONIndexing] DROP COLUMN Customer_Name
GO

-- Full-text index
CREATE FULLTEXT CATALOG FullTextCatalog AS DEFAULT;
CREATE FULLTEXT INDEX ON [dbo].[JSONIndexing]([CustomerData]) KEY INDEX PK_JSONIndexing ON FullTextCatalog;
GO
/* Wait for the index to be populated */
SELECT [CustomerID], [CustomerData] FROM dbo.JSONIndexing WHERE CONTAINS([CustomerData],'NEAR(Name,"Idaho City")');
SELECT [CustomerID], [CustomerData] FROM dbo.JSONIndexing WHERE CONTAINS([CustomerData],'Huiting');

-- Clean

DROP TABLE dbo.JSONIndexing;
DROP FULLTEXT CATALOG FullTextCatalog;
GO

/* Compare two table rows using JSON */

USE WideWorldImporters;
GO
DROP TABLE IF EXISTS dbo.TestCompareRecords;
GO
CREATE TABLE dbo.TestCompareRecords(
	[Key] INT NOT NULL,
	App_Settings NVARCHAR(MAX) NULL,
	App_ID INT NOT NULL,
	App_Version NVARCHAR(256) NOT NULL,
	Active BIT NOT NULL,
	AdditionalData NVARCHAR(MAX) NULL
);
GO
INSERT INTO dbo.TestCompareRecords ([Key], App_Settings, App_ID, App_Version, Active, AdditionalData) VALUES (1, NULL, 1, '101.253.253b', 1, NULL);
INSERT INTO dbo.TestCompareRecords ([Key], App_Settings, App_ID, App_Version, Active, AdditionalData) VALUES  (2, N'"Name": "John Doe"', 2, '101.253.253c', 0, NULL);
GO
SELECT * FROM dbo.TestCompareRecords
GO
SELECT
	A.[key] AS "Column Name"
	, ISNULL(A.[value], 'db_null') AS Source
	, ISNULL(B.[value], 'db_null') AS Destination
FROM 
	OPENJSON (
	(	SELECT * FROM dbo.TestCompareRecords WHERE [Key] = 1 FOR JSON AUTO, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER)) A
		INNER JOIN OPENJSON((SELECT * FROM dbo.TestCompareRecords WHERE [Key] = 2 FOR JSON AUTO, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER)
	) B
	ON A.[key] = B.[key] AND ISNULL(A.[value], 'db_null') <> ISNULL(B.[value], 'db_null')
GO
DROP TABLE dbo.TestCompareRecords;
GO
