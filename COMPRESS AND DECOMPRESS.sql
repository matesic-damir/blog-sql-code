/* MS SQL COMPRESS AND DECOMPRESS */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* COMPRESS */

-- One compress example
DECLARE @Input NVARCHAR(MAX) = N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam mollis maximus quam, quis malesuada felis sollicitudin eget. Nunc feugiat nisi et elit blandit, eget vulputate quam faucibus. Nullam vitae commodo nisi. Cras consequat sapien et urna malesuada rhoncus. Sed feugiat ornare ultricies. Nulla neque velit, tristique pretium erat ut, fermentum consequat nulla. Fusce pellentesque ornare lacus, tempor molestie libero tincidunt nec. Pellentesque ac purus mattis, semper sapien id, rhoncus elit. Morbi sagittis sapien sit amet condimentum mollis. Maecenas in mollis eros.'
SELECT COMPRESS(@Input) AS Compressed

-- Efficiency  
DECLARE @Input NVARCHAR(MAX) = N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam mollis maximus quam, quis malesuada felis sollicitudin eget. Nunc feugiat nisi et elit blandit, eget vulputate quam faucibus. Nullam vitae commodo nisi. Cras consequat sapien et urna malesuada rhoncus. Sed feugiat ornare ultricies. Nulla neque velit, tristique pretium erat ut, fermentum consequat nulla. Fusce pellentesque ornare lacus, tempor molestie libero tincidunt nec. Pellentesque ac purus mattis, semper sapien id, rhoncus elit. Morbi sagittis sapien sit amet condimentum mollis. Maecenas in mollis eros.'
SELECT
	DATALENGTH(@Input) AS "Original size"
	, DATALENGTH(COMPRESS(@Input)) AS "Compressed size"
	, CAST((DATALENGTH(@Input) - DATALENGTH(COMPRESS(@Input)))*100.0/DATALENGTH(@Input) AS DECIMAL(5,2)) AS "Compression rate"

-- Small string compression
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	DATALENGTH(@Input) AS "Original size"
	, DATALENGTH(COMPRESS(@Input)) AS "Compressed size"
	, CAST((DATALENGTH(@Input) - DATALENGTH(COMPRESS(@Input)))*100.0/DATALENGTH(@Input) AS DECIMAL(5,2)) AS "Compression rate"

-- Compare COMPRESS with ROW and PAGE compression
USE [WideWorldImporters];

DROP TABLE IF EXISTS [Sales].[OrderLines_Copy]

-- Test table
CREATE TABLE [Sales].[OrderLines_Copy](
	[OrderLineID] [int] NOT NULL,
	[Description] [nvarchar](256) NOT NULL
 CONSTRAINT [PK_Sales_OrderLines_Copy] PRIMARY KEY CLUSTERED 
(
	[OrderLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
GO

DROP TABLE IF EXISTS [Sales].[OrderLines_Compress]

-- Test table COMPRESS
CREATE TABLE [Sales].[OrderLines_Compress](
	[OrderLineID] [int] NOT NULL,
	[Description] [varbinary](max) NOT NULL
 CONSTRAINT [PK_Sales_OrderLines_Compress] PRIMARY KEY CLUSTERED 
(
	[OrderLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
GO


-- Insert test records
INSERT INTO [Sales].[OrderLines_Copy]([OrderLineID], [Description])
SELECT O1.[OrderLineID], FORMATMESSAGE('%s %s', O1.[Description], O2.[Description]) FROM [Sales].[OrderLines] O1 LEFT JOIN [Sales].[OrderLines] O2 ON O1.OrderLineID = O2.OrderLineID + 1;

INSERT INTO [Sales].[OrderLines_Compress]([OrderLineID], [Description])
SELECT O1.[OrderLineID], COMPRESS(FORMATMESSAGE('%s %s', O1.[Description], O2.[Description])) FROM [Sales].[OrderLines] O1 LEFT JOIN [Sales].[OrderLines] O2 ON O1.OrderLineID = O2.OrderLineID + 1;


-- NO Compression -> data 43200 KB
ALTER TABLE [Sales].[OrderLines_Copy] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = NONE
)

EXEC sp_spaceused N'[Sales].[OrderLines_Copy]'; 

-- ROW Compression -> data 22600 KB
ALTER TABLE [Sales].[OrderLines_Copy] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = ROW
)

EXEC sp_spaceused N'[Sales].[OrderLines_Copy]'; 

-- PAGE Compression -> data 22248 KB
ALTER TABLE [Sales].[OrderLines_Copy] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

EXEC sp_spaceused N'[Sales].[OrderLines_Copy]'; 

-- COMPRESS -> data 32656 KB
EXEC sp_spaceused N'[Sales].[OrderLines_Compress]'; 

/* XML DATA */
DROP TABLE IF EXISTS [Sales].[OrderLines_XML]
DROP TABLE IF EXISTS [Sales].[OrderLines_XML_Compress]

SELECT
A.[OrderLineID]
, CAST((SELECT D.* FROM [Sales].[OrderLines] D WHERE D.OrderLineID = A.OrderLineID FOR XML AUTO, ELEMENTS) AS XML) AS Details
INTO [Sales].[OrderLines_XML]
FROM
[Sales].[OrderLines] A

SELECT
A.[OrderLineID]
, COMPRESS(CAST((SELECT D.* FROM [Sales].[OrderLines] D WHERE D.OrderLineID = A.OrderLineID FOR XML AUTO, ELEMENTS) AS NVARCHAR(MAX))) AS Details
INTO [Sales].[OrderLines_XML_Compress]
FROM
[Sales].[OrderLines] A


-- NO Compression -> data 156488 KB
ALTER TABLE [Sales].[OrderLines_XML] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = NONE
)

EXEC sp_spaceused N'[Sales].[OrderLines_XML]'; 

-- ROW Compression -> data 155752 KB
ALTER TABLE [Sales].[OrderLines_XML] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = ROW
)

EXEC sp_spaceused N'[Sales].[OrderLines_XML]'; 

-- PAGE Compression -> 155720 KB
ALTER TABLE [Sales].[OrderLines_XML] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

EXEC sp_spaceused N'[Sales].[OrderLines_XML]'; 

-- COMPRESS -> data 79776 KB
EXEC sp_spaceused N'[Sales].[OrderLines_XML_Compress]'; 

/* DECOMPRESS */

-- Example
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	DECOMPRESS(COMPRESS(@Input)) AS "Decompressed value"

-- Example with cast
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	CAST(DECOMPRESS(COMPRESS(@Input)) AS nvarchar(max)) AS "Decompressed value"

-- Example with change nvarchar to varchar (GRID and TEXT)
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	CAST(DECOMPRESS(COMPRESS(@Input)) AS varchar(max)) AS "Decompressed value"

-- Example with change from varchar to nvarchar
DECLARE @Input VARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	CAST(DECOMPRESS(COMPRESS(@Input)) AS nvarchar(max)) AS "Decompressed value"