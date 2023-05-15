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
WHERE [Forecast ID] = 1400
;

SELECT * FROM [dbo].[forecast]
WHERE forecast_id = 1400
;


SELECT [Cost Center Code]
FROM [dbo].[vw_forecast_full]
GROUP BY [Cost Center Code]






SELECT DISTINCT
	f.[forecast_id] as [Forecast ID],
	cc.[company_code] as [Company Code],
	bu.[business_unit] as [Business Unit],
	d.[department_long] as [Department],
	ccc.[cost_center_code] as [Cost Center Code],
	dl.[employee] as [Department Leader],
	tl.[employee] as [Team Leader],
	bo.[employee] as [Business Owner],
	pc.[employee] as [Primary Contact],
	s.[supplier] as [Supplier],
	c.[full_name] as [Contractor],
	c.[worker_id] as [Worker ID],
	c.[pid] as [PID],
	start_d.[full_date] as [Worker Start Date],
	end_d.[full_date] as [Worker End Date],
	override_d.[full_date] as [Override End Date],
	mdt.[main_document_title] as [Main Document Title],
	coc.[cost_object_code] as [Cost Object Code],
	l.[location] as [Site],
	a.[account_code] as [Account Code],
	wt.[work_type] as [Work Type],
	ws.[worker_status] as [Worker Status],
	woc.[work_order_category] as [Work Order Category],
	ec.[expense_classification] as [Expense Classification],
	bc.[budget_code] as [Budget Code],
	seg.[segmentation] as [Segmentation],
	plat.[platform] as [Platform],
	fun.[function] as [Function],
	f.[work_order_id] as [Work Order ID],
	f.[description] as [Description],
	f.[allocation] as [Allocation],
	f.[current_bill_rate_hr] as [Current Bill Rate (Hr)],
	f.[current_bill_rate_day] as [Current Bill Rate (Day)],
	f.[comment] as [Comment]
FROM [dbo].[forecast] as f
JOIN [dbo].[company_code] as cc
	ON f.[company_code_id] = cc.[company_code_id]
JOIN [dbo].[business_unit] as bu
	ON f.[business_unit_id] = bu.[business_unit_id]
JOIN [dbo].[deptartment] as d
	ON f.[department_id] = d.[department_id]
JOIN [dbo].[cost_center_code] as ccc
	ON f.[cost_center_code_id] = ccc.[cost_center_code_id]
JOIN [dbo].[employee] as dl
	ON f.[department_leader_id] = dl.[employee_id]
JOIN [dbo].[employee] as tl
	ON f.[team_leader_id] = tl.[employee_id]
JOIN [dbo].[employee] as bo
	ON f.[business_owner_id] = bo.[employee_id]
JOIN [dbo].[employee] as pc
	ON f.[primary_contact_id] = pc.[employee_id]
JOIN [dbo].[supplier] as s
	ON f.[supplier_id] = s.[supplier_id]
JOIN [dbo].[contractor] as c
	ON f.[contractor_id] = c.[contractor_id]
LEFT JOIN [dbo].[date_dimension] as start_d
	ON f.[worker_start_date_id] = start_d.[date_id]
LEFT JOIN [dbo].[date_dimension] as end_d
	ON f.[worker_end_date_id] = end_d.[date_id]
LEFT JOIN [dbo].[date_dimension] as override_d
	ON f.[override_end_date_id] = override_d.[date_id]
JOIN [dbo].[main_document_title] as mdt
	ON f.[main_document_title_id] = mdt.[main_document_title_id]
JOIN [dbo].[cost_object_code] as coc
	ON f.[cost_object_code_id] = coc.[cost_object_code_id]
JOIN [dbo].[location] as l
	ON f.[site_id] = l.[location_id]
JOIN [dbo].[account] as a
	ON f.[account_code_id] = a.[account_id]
JOIN [dbo].[work_type] as wt
	ON f.[work_type_id] = wt.[work_type_id]
JOIN [dbo].[worker_status] as ws
	ON f.[worker_status_id] = ws.[worker_status_id]
JOIN [dbo].[work_order_category] as woc
	ON f.[work_order_category_id] = woc.[work_order_category_id]
JOIN [dbo].[expense_classification] as ec
	ON f.[expense_classification_id] = ec.[expense_classification_id]
JOIN [dbo].[budget_code] as bc
	ON f.[budget_code_id] = bc.[budget_code_id]
JOIN [dbo].[segmentation] as seg
	ON f.[segmentation_id] = seg.[segmentation_id]
JOIN [dbo].[platform] as plat
	ON f.[platform_id] = plat.[platform_id]
JOIN [dbo].[function] as fun
	ON f.[function_id] = fun.[function_id]
WHERE f.[is_deleted] = 0
AND d.[department_long] IS NULL