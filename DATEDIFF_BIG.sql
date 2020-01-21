/* MS SQL DATEDIFF_BIG */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- Using DATEDIFF
DECLARE @StartDate DATETIME = GETDATE()
DECLARE @EndDate DATETIME = DATEADD(day, 1, @StartDate)

SELECT 
	DATEDIFF(WK , @StartDate, @EndDate) AS "Week diff"
	, DATEDIFF(DD , @StartDate, @EndDate) AS "Day diff"
	, DATEDIFF(HH , @StartDate, @EndDate) AS "Hour diff"
	, DATEDIFF(MI, @StartDate, @EndDate) AS "Minute diff"
	, DATEDIFF(SS, @StartDate, @EndDate) AS "Second diff"
	, DATEDIFF(MS, @StartDate, @EndDate ) AS "Millisecond diff"
	
-- DATEDIFF overflow
DECLARE @StartDate DATETIME = GETDATE()
DECLARE @EndDate DATETIME = DATEADD(day, 1, @StartDate)

SELECT DATEDIFF(MCS, @StartDate, @EndDate ) AS "Microsecond diff"


-- Using DATEDIFF_BIG
DECLARE @StartDate DATETIME = GETDATE()
DECLARE @EndDate DATETIME = DATEADD(day, 1, @StartDate)

SELECT 
	DATEDIFF_BIG(WK , @StartDate, @EndDate) AS "Week diff"
	, DATEDIFF_BIG(DD , @StartDate, @EndDate) AS "Day diff"
	, DATEDIFF_BIG(HH , @StartDate, @EndDate) AS "Hour diff"
	, DATEDIFF_BIG(MI, @StartDate, @EndDate) AS "Minute diff"
	, DATEDIFF_BIG(SS, @StartDate, @EndDate) AS "Second diff"
	, DATEDIFF_BIG(MS, @StartDate, @EndDate ) AS "Millisecond diff"
	, DATEDIFF_BIG(MCS, @StartDate, @EndDate ) AS "Microsecond diff"
	, DATEDIFF_BIG(NS, @StartDate, @EndDate ) AS "Nanosecond diff"


