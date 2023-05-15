SELECT * FROM [audit].[user_actions]
ORDER BY 1 desc




update dbo.employee set
employee = case
			when [employee] LIKE '%[_]%' and employee like '%(P%' then trim(left([employee],nullif(charindex(' (P',[employee]),0)-1))
			when [employee] LIKE '%[_]P%' then concat(trim(left([employee],nullif(charindex('_',[employee]),0)-1)),trim(right([employee],nullif(charindex('_',reverse([employee])),0)-9)))
			else [employee]
			end


SELECT *,
case
			when [employee] LIKE '%[_]%' and employee like '%(P%' then trim(left([employee],nullif(charindex(' (P',[employee]),0)-1))
			when [employee] LIKE '%[_]P%' then concat(trim(left([employee],nullif(charindex('_',[employee]),0)-1)),trim(right([employee],nullif(charindex('_',reverse([employee])),0)-9)))
			else [employee]
			end
FROM [dbo].[employee]
WHERE [employee] LIKE '%Baldino%'
ORDER BY [raw]


SELECT * FROM [TEST].[dbo].[vw_forecast_full]


SELECT * FROM [dbo].[cost_object_code]


SELECT * FROM [dbo].[worker_status] 


SELECT * FROM [dbo].[supplier] 


SELECT
	[forecasting_month],
	MIN(full_date),
	MAX(full_date)
FROM [dbo].[date_dimension]
WHERE full_date > '2022-01-01'
GROUP BY [forecasting_month]
ORDER BY 1




SELECT * FROM [staging].[pcode_to_bcode]

SELECT * FROM [dbo].[budget_code]

SELECT * FROM [staging].[account_mapping]

SELECT * FROM [staging].[company_entity]

SELECT DISTINCT
	m.[Department Code],
	m.[Project Name],
	p.[project_name],
	d.[department],
	bc.[budget_code],
	t.[Bcode/Investment Position ID],
	m.*
FROM [staging].[opex_department_mapping] as m
LEFT JOIN [dbo].[project] as p
	ON m.[Project Name] = p.[raw]
LEFT JOIN [dbo].[deptartment] as d
	ON m.[Project Name] = d.[raw]
LEFT JOIN [dbo].[budget_code] as bc
	ON m.[Project Name] = bc.[raw]
LEFT JOIN [staging].[pcode_to_bcode] as t
	ON m.[Project Name] = t.[Bcode/Investment Position Name]
ORDER BY 1



SELECT * FROM [dbo].[deptartment]
ORDER BY 2

SELECT * FROM [staging].[pcode_to_bcode]

SELECT * FROM [dbo].[project]



SELECT TOP 100
    sql.text AS QueryText,
    execution_count AS ExecutionCount,
    total_worker_time/1000 AS TotalWorkerTime_ms,
    last_execution_time AS LastExecutionTime
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS sql
ORDER BY last_execution_time DESC;

