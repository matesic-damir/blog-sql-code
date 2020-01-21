/* MS SQL AT TIME ZONE */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- Get all time zones from system view 
SELECT 
	* 
FROM 
	sys.time_zone_info;

USE master;
-- Get the current time zone of the SQL server
DECLARE @SystemTimeZone NVARCHAR(256);
EXEC dbo.xp_regread N'HKEY_LOCAL_MACHINE', N'SYSTEM\CurrentControlSet\Control\TimeZoneInformation', N'TimeZoneKeyName', @SystemTimeZone OUTPUT;
SELECT @SystemTimeZone AS SystemTimeZone;

-- More info about Croatian time zone
SELECT 
	* 
FROM 
	sys.time_zone_info 
WHERE 
	name = 'Central European Standard Time';

-- Convert local time to UTC date/time
DECLARE @CurrentCroatianTime DATETIME = GETDATE();
DECLARE @UTCOffset DATETIMEOFFSET = SWITCHOFFSET(@CurrentCroatianTime AT TIME ZONE 'Central European Standard Time', '+00:00');
SELECT 
	@CurrentCroatianTime AS "Current local date/time"
	, @UTCOffset AS "UTC offset"
	, CAST(@UTCOffset AS DATETIME) AS "UTC Date/Time";

-- Get the system UTC date/time
SELECT 
	SYSUTCDATETIME() AS "System UTC date/time"
	, GETDATE() AS "Current local date/time";

-- See what time is in US Eastern Standard Time time zone
DECLARE @LocalOffset NVARCHAR(256) = DATENAME(TZ, SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')
DECLARE @CSTOffset NVARCHAR(256) = DATENAME(TZ, SYSUTCDATETIME() AT TIME ZONE 'Central Standard Time')
SELECT 
	GETDATE() AS "Local date/time"
	, @LocalOffset AS "Local offset (CEST)"
	, @CSTOffset AS "US Eastern Standard time offset"
	, CAST(SWITCHOFFSET(SYSUTCDATETIME(), @CSTOffset) AS DATETIME) AS "US Eastern Standard Time";

-- Date time values for all time zones in the system
SELECT 
	SYSUTCDATETIME() AT TIME ZONE name AS "Time zone date/time offset"
	, CAST(SWITCHOFFSET(SYSUTCDATETIME(), current_utc_offset) AS DATETIME) AS "Time zone date/time"
	, name AS "Time zone name"
	, is_currently_dst AS "Is currently daylight saving"
FROM
	sys.time_zone_info;


