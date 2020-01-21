/* MS SQL TRANSLATE */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- TRANSLATE replaces ) with (
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace :) with :(';
SELECT TRANSLATE(@StringValue, ')', '(') AS Result;

-- replace a character with an empty string
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace spaces with empty string.';
-- result of TRANSLATE
SELECT TRANSLATE(@StringValue, ' ', '') AS Result;

-- the old way using replace
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace spaces with empty string.';
-- result of REPLACE
SELECT REPLACE(@StringValue, ' ', '') AS Result;

-- replace multiple characters (strings) at once
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace all brackets with parentheses in [database].[schema].[table_name].';
-- result of TRANSLATE
SELECT TRANSLATE(@StringValue, '[]', '()') AS Result
-- implementation of REPLACE
SELECT REPLACE(REPLACE(@StringValue,'[','('), ']', ')') AS Result;

-- replace multiple characters (strings) at once
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace :( with ;)';
-- benefit of replace
SELECT REPLACE(@StringValue, ':(', ';)') AS Result;