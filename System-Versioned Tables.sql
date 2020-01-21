/* Historical data with MS SQL System-Versioned (Temporal) Tables */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

USE TestSystemVersioned;
GO

/* Create a System-Versioned (Temporal) Table */

-- Try to create our first System-Versioned (Temporal) Table
CREATE TABLE dbo.TestTable (
    IDTest INT NOT NULL CONSTRAINT PK_TestTable PRIMARY KEY
    , DrinkName NVARCHAR(256) NOT NULL
    , IsAlcoholic BIT NOT NULL
) WITH (SYSTEM_VERSIONING = ON);
GO

-- Drinks System-Versioned (Temporal) Table with default name 
CREATE TABLE dbo.Drinks (
    IDDrink INT NOT NULL CONSTRAINT PK_Drinks PRIMARY KEY
    , DrinkName NVARCHAR(256) NOT NULL
    , IsAlcoholic BIT NOT NULL
    , ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
    , ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
    , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON);
GO

-- Pricelist System-Versioned (Temporal) Table with custom name
CREATE TABLE dbo.PriceList (
    IDPriceList INT NOT NULL CONSTRAINT PK_PriceList PRIMARY KEY
    , DrinkName NVARCHAR(256) NOT NULL
    , IsAlcoholic BIT NOT NULL
    , Price MONEY
    , ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
    , ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
    , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON(HISTORY_TABLE = dbo.PriceListHistory));
GO

-- Non System-Versioned (Temporal) Table
CREATE TABLE dbo.NonHistoryTable (
    IDPriceList INT NOT NULL CONSTRAINT PK_NonHistoryTable PRIMARY KEY
    , DrinkName NVARCHAR(256) NOT NULL
    , IsAlcoholic BIT NOT NULL
    , Price MONEY    
)
GO
-- ALter the table to support System-Versioned (Temporal) Table
ALTER TABLE dbo.NonHistoryTable ADD 
	ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL CONSTRAINT DF_Validfrom DEFAULT '1991-01-01 00:00:00.0000000'
	, ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL CONSTRAINT DF_ValidTo DEFAULT '9999-12-31 23:59:59.9999999'
	, PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO
-- Turn on System-Versioned (Temporal) Table
ALTER TABLE dbo.NonHistoryTable SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.NonHistoryTabletHistory));
GO

/* Alter a System-Versioned (Temporal) Table */

-- Adding 2 new columns
ALTER TABLE dbo.PriceList ADD
	Quantity SMALLINT NOT NULL CONSTRAINT DF_Category DEFAULT 0
	, Remarks NVARCHAR(256) NULL;
GO

-- Add a computed column
ALTER TABLE dbo.PriceList ADD
	Total  AS (Quantity * Price);

-- Solving the issue
ALTER TABLE dbo.PriceList SET (SYSTEM_VERSIONING = OFF);
GO
ALTER TABLE dbo.PriceList ADD
	Total  AS (Quantity * Price);
GO
ALTER TABLE dbo.PriceListHistory ADD
	Total  Money;
GO
UPDATE dbo.PriceListHistory SET Total = Quantity * Price;
GO
ALTER TABLE dbo.PriceList SET (SYSTEM_VERSIONING = ON(HISTORY_TABLE = dbo.PriceListHistory));
GO


/* Drop a System-Versioned (Temporal) Table */

-- Error
DROP TABLE dbo.PriceList;
GO

-- Remove system-versioned 
ALTER TABLE dbo.PriceList SET (SYSTEM_VERSIONING = OFF);
GO
DROP TABLE dbo.PriceList;
DROP TABLE dbo.PriceListHistory;
GO

/* Querying system-versioned tables */

-- Test Data
CREATE TABLE [dbo].[PriceList](
	[IDPriceList] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY
	, [DrinkName] [nvarchar](256) NOT NULL
	, [IsAlcoholic] [bit] NOT NULL
	, [Price] [money] NOT NULL
	, [Quantity] [smallint] NOT NULL
	, [Amount]  AS ([Quantity]*[Price])
);
GO

ALTER TABLE [dbo].[PriceList] ADD 
	ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL CONSTRAINT DF_Pricelist_Validfrom DEFAULT '1991-01-01 00:00:00.0000000'
	, ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL CONSTRAINT DF_Pricelist_ValidTo DEFAULT '9999-12-31 23:59:59.9999999'
	, PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.PriceList SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.PriceListHistory));
GO

INSERT INTO [dbo].[PriceList]([DrinkName], [IsAlcoholic], [Price], [Quantity])
SELECT [DrinkName], [IsAlcoholic], [Price], [Quantity]
FROM
(
	SELECT 'Gin tonic' AS [DrinkName], 1 AS [IsAlcoholic], 25.99 AS [Price], 100 AS [Quantity] UNION ALL
	SELECT 'Coffe' AS [DrinkName], 0 AS [IsAlcoholic], 9.99 AS [Price], 57 AS [Quantity] UNION ALL
	SELECT 'Juice' AS [DrinkName], 0 AS [IsAlcoholic], 12 AS [Price], 32 AS [Quantity] UNION ALL
	SELECT 'Umbrella' AS [DrinkName], 1 AS [IsAlcoholic], 1 AS [Price], 1 AS [Quantity] 
) A;
GO

DELETE FROM [dbo].[PriceList] WHERE [DrinkName] = 'Umbrella';
GO

UPDATE [dbo].[PriceList] SET [Quantity] = [Quantity] - 1 WHERE [DrinkName] = 'Gin tonic';
GO 7 -- Repeat 7 times

UPDATE [dbo].[PriceList] SET [Quantity] = [Quantity] - 1 WHERE [DrinkName] = 'Coffe';
GO 3 -- Repeat 3 times

SELECT * FROM [dbo].[PriceList];
SELECT * FROM [dbo].[PriceListHistory];
GO

-- Some data manipulation
ALTER TABLE dbo.PriceList SET (SYSTEM_VERSIONING = OFF);
GO

UPDATE [dbo].[PriceListHistory] SET ValidFrom = '2018-01-01', ValidTo = '2018-01-02' WHERE Quantity IN (1, 100, 57);
UPDATE [dbo].[PriceListHistory] SET ValidFrom = '2018-01-02', ValidTo = '2018-01-03' WHERE Quantity IN (99, 56);
UPDATE [dbo].[PriceListHistory] SET ValidFrom = '2018-01-03', ValidTo = '2018-01-04' WHERE Quantity IN (98, 55);
UPDATE [dbo].[PriceListHistory] SET ValidFrom = '2018-01-04', ValidTo = '2018-01-05' WHERE Quantity IN (97);
UPDATE [dbo].[PriceListHistory] SET ValidFrom = '2018-01-05', ValidTo = '2018-01-06' WHERE Quantity IN (96);
UPDATE [dbo].[PriceListHistory] SET ValidFrom = '2018-01-06', ValidTo = '2018-01-07' WHERE Quantity IN (95);
UPDATE [dbo].[PriceListHistory] SET ValidFrom = '2018-01-07', ValidTo = '2018-01-08' WHERE Quantity IN (94);
GO

ALTER TABLE [dbo].[PriceList] DROP PERIOD FOR SYSTEM_TIME;
GO

UPDATE [dbo].[PriceList] SET ValidFrom = '2018-01-08' WHERE Quantity IN (93);
UPDATE [dbo].[PriceList] SET ValidFrom = '2018-01-04' WHERE Quantity IN (54);
UPDATE [dbo].[PriceList] SET ValidFrom = '2018-01-01' WHERE Quantity IN (32);
GO

ALTER TABLE [dbo].[PriceList] ADD PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.PriceList SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.PriceListHistory));
GO


SELECT * FROM [dbo].[PriceList] 
SELECT * FROM [dbo].[PriceListHistory] ORDER BY ValidFrom;
-- Finished

-- All data for a drink
SELECT * FROM [dbo].[PriceList] WHERE DrinkName = 'Gin tonic'
UNION ALL
SELECT * FROM [dbo].[PriceListHistory] WHERE DrinkName = 'Gin tonic' ORDER BY ValidFrom;

SELECT * FROM [dbo].[PriceList] FOR SYSTEM_TIME ALL WHERE DrinkName = 'Gin tonic' ORDER BY ValidFrom;
GO

-- Current data
SELECT * FROM [dbo].[PriceList] ORDER BY IDPriceList;

-- History data
SELECT * FROM [dbo].[PriceList] FOR SYSTEM_TIME AS OF '2018-01-03 08:00:00'  ORDER BY IDPriceList;

-- Current data using the FOR SYSTEM_TIME AS OF
DECLARE @RightNow AS DATETIME2 = SYSUTCDATETIME();
SELECT * FROM [dbo].[PriceList] FOR SYSTEM_TIME AS OF @RightNow  ORDER BY IDPriceList;


-- FROM - TO
SELECT * FROM [dbo].[PriceList] FOR SYSTEM_TIME FROM '2018-01-02' TO '2018-01-04' WHERE DrinkName = 'Gin tonic' ORDER BY ValidFrom;

-- BETWEEN
SELECT * FROM [dbo].[PriceList] FOR SYSTEM_TIME BETWEEN '2018-01-02' AND '2018-01-04' WHERE DrinkName = 'Gin tonic' ORDER BY ValidFrom;

-- CONTAINED IN
SELECT * FROM [dbo].[PriceList] FOR SYSTEM_TIME CONTAINED IN ('2018-01-02','2018-01-04') WHERE DrinkName = 'Gin tonic' ORDER BY ValidFrom;

/* Last words */

-- Delete rows from a history table

DELETE FROM [dbo].[PriceListHistory];
GO

-- Truncate table
TRUNCATE TABLE [dbo].[PriceListHistory];
TRUNCATE TABLE [dbo].[PriceList];
GO

-- Alter the schema of the history table
ALTER TABLE [dbo].[PriceListHistory] ADD NewColumn BIT NULL;
GO

-- Trigger
CREATE TRIGGER dbo.trg_TestMe
   ON  [dbo].[PriceListHistory]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
END;
GO

-- Hidden columns
CREATE TABLE dbo.Hidden(
    ID INT NOT NULL PRIMARY KEY,
    DrinkName NVARCHAR(256) NOT NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.HiddenHistory));
GO
INSERT INTO dbo.Hidden(ID, DrinkName) VALUES(1, 'Gin tonic');
GO
SELECT *, ValidFrom, ValidTo FROM dbo.Hidden;
GO