/* MS SQL TRIM */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- input value
DECLARE @StringValue nvarchar(max) = '  remove spaces from both sides of this string  ';
-- string with spaces
SELECT @StringValue AS Result UNION ALL
-- old way before introducing TRIM
SELECT LTRIM(RTRIM(@StringValue)) AS Result UNION ALL
-- new way with TRIM
SELECT TRIM(@StringValue) AS Result;