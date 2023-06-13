USE TEST;

-- different forecast line items with allocations higher than 100%
SELECT
	c.pid,
	f.worker_start_date_id,
	f.worker_end_date_id,
	coc.cost_object_code,
	sum(f.allocation) AS total_allocation
FROM  [dbo].[forecast] as f
JOIN [dbo].[contractor] as c
	ON f.[contractor_id] = c.[contractor_id]
JOIN [dbo].[cost_object_code] as coc
	ON f.[cost_object_code_id] = coc.[cost_object_code_id]
WHERE c.pid IS NOT NULL
AND f.worker_start_date_id IS NOT NULL
AND f.worker_end_date_id IS NOT NULL
AND coc.cost_object_code IS NOT NULL
GROUP BY c.pid,
	f.worker_start_date_id,
	f.worker_end_date_id,
	coc.cost_object_code
HAVING sum(f.allocation) > 100
ORDER BY 5 desc
;

-- mismatch of cost center code and company code
SELECT 
	rf.[FCSTID],
	[Cost Center Code],
	[Company Code]
FROM [Compiler].[mart].[RollingF] as rf
--JOIN [dbo].[company_code] as cc
--	ON LEFT(rf.[Cost Center Code], 3) = cc.[raw]
WHERE [Cost Center Code] IS NOT NULL
AND [Company Code] IS NOT NULL
AND LEFT([Cost Center Code], 3) != LEFT([Company Code], 3)
;



-- no department so doesn't show in tagger
SELECT * FROM [dbo].[vw_forecast_full]
WHERE Department IS NULL
;