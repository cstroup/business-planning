--USE [TEST]
--GO

USE [PLANNING_APP]
GO

INSERT INTO [dbo].[forecast_line_item]
           ([forecast_id]
           ,[date_id]
           ,[amount]
		   ,[forecast]
           ,[budget]
           ,[q1f]
           ,[q2f]
           ,[q3f]
		   ,[forecast_spring]
		   ,[forecast_summer]
           ,[actual]
           ,[is_deleted]
		   ,[is_actualized]
           ,[created_by]
           ,[created_date]
           ,[updated_by]
           ,[updated_date])
SELECT
	f.forecast_id,
	dd.date_id,
	ISNULL(rf.value, 0) AS amount,
	ISNULL(rf.value, 0) AS forecast,
	0 AS budget,
	0 AS q1f,
	0 AS q2f,
	0 AS q3f,
	0 AS forecast_spring,
	0 AS forecast_summer,
	0 AS actual,
	ISNULL(f.is_deleted, 0) AS is_deleted,
	0 AS is_actualized,
	CURRENT_USER AS created_by,
	CURRENT_TIMESTAMP AS created_date,
	CURRENT_USER AS updated_by,
	CURRENT_TIMESTAMP AS updated_date
FROM [dbo].[forecast] as f
JOIN
(
	SELECT 'Jan-23' AS month_num UNION ALL SELECT 'Feb-23' UNION ALL SELECT 'Mar-23' UNION ALL 
	SELECT 'Apr-23' UNION ALL SELECT 'May-23' UNION ALL SELECT 'Jun-23' UNION ALL 
	SELECT 'Jul-23' UNION ALL SELECT 'Aug-23' UNION ALL SELECT 'Sep-23' UNION ALL 
	SELECT 'Oct-23' UNION ALL SELECT 'Nov-23' UNION ALL SELECT 'Dec-23'
) as m ON 1=1
LEFT JOIN
(
	SELECT 
		FCSTID, 
		month_name, 
		value
	FROM [Compiler].[snap].[RollingF 7.14.23] -- [Compiler].[mart].[RollingF]
	UNPIVOT (
	  value FOR month_name IN ([Jan-23], [Feb-23], [Mar-23], [Apr-23], [May-23], [Jun-23], [Jul-23], [Aug-23], [Sep-23], [Oct-23], [Nov-23], [Dec-23])
	) AS unpivoted_table
) AS rf
	ON f.[old_forecast_id] = rf.FCSTID
	AND rf.month_name = m.month_num
JOIN
(
	SELECT 
		short_month_short_year,
		MIN(date_id) as date_id
	FROM [dbo].[date_dimension]
	GROUP BY short_month_short_year
) as dd 
	ON m.month_num = dd.short_month_short_year
ORDER BY [forecast_id], [date_id]
;




DROP TABLE IF EXISTS #TMP_ACTUALS;
SELECT
	year_month,
	forecast_id,
	sum([actual_amount]) as actual
INTO #TMP_ACTUALS
FROM
	(SELECT
		LEFT(gl.[journal_entry_date_id], 6) as year_month,
		CASE
			WHEN f.[forecast_id] IS NOT NULL
			THEN f.[forecast_id]
			WHEN tag.[forecast_id] IS NOT NULL
			THEN tag.[forecast_id]
			ELSE NULL
		END as forecast_id,
		gl.[actual_amount]
	FROM [dbo].[general_ledger] as gl
	LEFT JOIN [dbo].[forecast] as f
		ON gl.[forecast_id] = f.[forecast_id]
	LEFT JOIN [dbo].[auto_tag] as tag
		ON gl.[auto_tag_id] = tag.[auto_tag_id]
	WHERE gl.[journal_entry_date_id] >= 20221201
	) as gl
WHERE forecast_id IS NOT NULL
GROUP BY year_month, forecast_id
ORDER BY 1,2
;

--SELECT * FROM #TMP_ACTUALS ORDER BY 1 DESC

MERGE [dbo].[forecast_line_item] AS TGT
USING #TMP_ACTUALS	AS SRC
ON SRC.forecast_id = TGT.forecast_id
	AND SRC.year_month = LEFT(TGT.[date_id], 6)
-- For Updates
WHEN MATCHED THEN UPDATE SET
    TGT.[actual]	= SRC.actual,
	TGT.[is_actualized] = 1
;




-- UPDATE BUDGET
DROP TABLE IF EXISTS #TMP_BUDGET;
SELECT
	f.forecast_id,
	rf.[value],
	dd.[date_id]
INTO #TMP_BUDGET
FROM [dbo].[forecast] as f
JOIN
(
	SELECT 
		FCSTID, 
		month_name, 
		value
	FROM [Compiler].[fcst].[Budget FY23] as c
	UNPIVOT (
	  value FOR month_name IN ([Jan-23], [Feb-23], [Mar-23], [Apr-23], [May-23], [Jun-23], [Jul-23], [Aug-23], [Sep-23], [Oct-23], [Nov-23], [Dec-23])
	) AS unpivoted_table
) AS rf
	ON f.[old_forecast_id] = rf.FCSTID
JOIN
(
	SELECT 
		short_month_short_year,
		MIN(date_id) as date_id
	FROM [dbo].[date_dimension]
	GROUP BY short_month_short_year
) as dd 
	ON rf.month_name = dd.short_month_short_year
ORDER BY [forecast_id], [date_id]
;


MERGE [dbo].[forecast_line_item] AS TGT
USING #TMP_BUDGET	AS SRC
ON SRC.forecast_id = TGT.forecast_id
	AND SRC.date_id = TGT.[date_id]
-- For Updates
WHEN MATCHED THEN UPDATE SET
    TGT.[budget] = SRC.[value]
;



-- SELECT * FROM  [dbo].[forecast_line_item_v2] order by 1 DESC, 2 DESC
-- SELECT * FROM  [dbo].[forecast_line_item_v2] WHERE forecast_id = 8311


--SELECT TOP 1000
--	dd.[calendar_year],
--	frcst.[forecast_id],
--	SUM(IIF(frcst.[actual] > 0, frcst.[actual], frcst.[amount])) as fy_forecast,
--	SUM(frcst.[budget]) as fy_budget,
--	(SUM(IIF(frcst.[actual] > 0, frcst.[actual], frcst.[amount])) - SUM(frcst.[budget])) as fy_forecast_budget_var,
--	SUM(frcst.[q1f]) as fy_q1f,
--	SUM(frcst.[q2f]) as fy_q2f,
--	SUM(frcst.[q3f]) as fy_q3f,
--	SUM(0) as prev_fy_budget,
--	SUM(0) as prev_fy_q1f,
--	SUM(0) as prev_fy_q2f,
--	SUM(0) as prev_fy_q3f
--FROM  [dbo].[forecast_line_item_v2] as frcst
--JOIN [dbo].[date_dimension] as dd
--	ON frcst.[date_id] = dd.[date_id]
--GROUP BY dd.[calendar_year],
--	frcst.[forecast_id]
--ORDER BY 1,2
--;