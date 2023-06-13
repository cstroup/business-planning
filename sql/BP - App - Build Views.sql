USE TEST;
GO

DROP VIEW IF EXISTS vw_auto_tagger_full;
GO
CREATE VIEW vw_auto_tagger_full AS 

SELECT
	tag.[auto_tag_id] as [Auto Tag ID],
	tag.[forecast_id] as [Forecast ID],
	ccc.[cost_center_code] as [Cost Center Code],
	a.[account_code] as [Account Code],
	tag.[purchase_order_number] as [Purchase Order Number],
	coc.[cost_object_code] as [Cost Object Code],
	tag.[po_composite] as [PO Composite],
	tag.[po_cost_object_composite] as [PO/Cost Object Composite]
FROM [dbo].[auto_tag] as tag
LEFT JOIN [dbo].[cost_center_code] as ccc
	ON tag.[cost_center_code_id] = ccc.[cost_center_code_id]
LEFT JOIN [dbo].[account] as a
	ON tag.[account_code_id] = a.[account_id]
LEFT JOIN [dbo].[cost_object_code] as coc
	ON tag.[cost_object_code_id] = coc.[cost_object_code_id]
WHERE tag.[is_deleted] = 0
;
GO

DROP VIEW IF EXISTS vw_general_ledger_full;
GO
CREATE VIEW vw_general_ledger_full AS 

SELECT DISTINCT
	gl.[general_ledger_id] as [GL ID],
	gl.[forecast_id] as [Forecast ID],
	tag.[forecast_id] as [Auto Tagger ID],
	date_je.[full_date] as [Journal Entry Date],
	date_p.[full_date] as [Posting Date],
	jet.[journal_entry_type] as [JE Type],
	ar.[assignment_reference] as [Assignment Ref],
	a.[account_code] as [Account Code],
	d.[department_long] as [Department],
	pc.[profit_center] as [Profit Center],
	ccc.[cost_center_code] as [Cost Center Code],
	coc.[cost_object_code] as [Cost Object Code],
	pt.[project_type] as [Project Type],
	p.[project] as [Project],
	p.[project_name] as [Project Name],
	s.[supplier_long] as [Supplier],
	et.[expense_type] as [Expense Type],
	gl.[actual_amount] as [Amount],
	gl.[purchase_order_number] as [PO Number],
	gl.[po_composite] as [PO Composite],
	gl.[po_cost_object_composite] as [PO Cost Obj. Composite],
	gl.[header_text] as [Header Text],
	gl.[item_text] as [Item Text],
	gl.[comment] as [Comment],
	gl.[journal_entry] as [Journal Entry],
	gl.[journal_entry_item] as [Journal Entry Item],
	gl.[journal_entry_composite] as [Journaly Entry Composite],
	gl.[department_id]
FROM [dbo].[general_ledger] as gl
LEFT JOIN [dbo].[auto_tag] as tag
	ON gl.[auto_tag_id] = tag.[auto_tag_id]
JOIN [dbo].[date_dimension] as date_je
	ON gl.[journal_entry_date_id] = date_je.[date_id]
JOIN [dbo].[date_dimension] as date_p
	ON gl.[posting_date_id] = date_p.[date_id]
JOIN [dbo].[journal_entry_type] as jet
	ON gl.[journal_entry_type_id] = jet.[journal_entry_type_id]
JOIN [dbo].[assignment_reference] as ar
	ON gl.[assignment_reference_id] = ar.[assignment_reference_id]
JOIN [dbo].[account] as a
	ON gl.[account_id] = a.[account_id]
JOIN [dbo].[deptartment] as d
	ON gl.[department_id] = d.[department_id]
JOIN [dbo].[profit_center] as pc
	ON gl.[profit_center_id] = pc.[profit_center_id]
JOIN [dbo].[cost_center_code] as ccc
	ON gl.[cost_center_code_id] = ccc.[cost_center_code_id]
JOIN [dbo].[cost_object_code] as coc
	ON gl.[wbs_code_id] = coc.[cost_object_code_id]
JOIN [dbo].[project_type] as pt
	ON gl.[project_type_id] = pt.[project_type_id]
JOIN [dbo].[project] as p
	ON gl.[project_id] = p.[project_id]
JOIN [dbo].[supplier] as s
	ON gl.[supplier_id] = s.[supplier_id]
JOIN [dbo].[expense_type] as et
	ON gl.[expense_type_id] = et.[expense_type_id]
WHERE gl.[is_deleted] = 0
AND gl.[department_id] IN -- user filter
	(SELECT
		[department_id]
	FROM [dbo].[user_access] as ua
	JOIN [dbo].[user] as u 
		ON ua.[user_id] = u.[user_id]
	JOIN [dbo].[deptartment_business_unit] as dbu
		ON ua.[department_bu_id] = dbu.[department_bu_id]
	WHERE u.[username] = CURRENT_USER
	) 
; 
GO


--SELECT * FROM vw_general_ledger_full 


DROP VIEW IF EXISTS vw_forecast_full;
GO
CREATE VIEW vw_forecast_full AS

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
	ss.[support_scalable] as [Support/Scalable],
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
LEFT JOIN [dbo].[support_scalable] as ss
	ON f.[support_scalable_id] = ss.[support_scalable_id]
WHERE f.[is_deleted] = 0 
--AND f.[department_id] IN -- user filter
--	(SELECT
--		[department_id]
--	FROM [dbo].[user_access] as ua
--	JOIN [dbo].[user] as u 
--		ON ua.[user_id] = u.[user_id]
--	JOIN [dbo].[deptartment_business_unit] as dbu
--		ON ua.[department_bu_id] = dbu.[department_bu_id]
--	WHERE u.[username] = CURRENT_USER
--	) 
;
GO


-- SELECT * FROM vw_forecast_full WHERE [Forecast ID] = 2219



DROP VIEW IF EXISTS vw_forecast_line_items;
GO
CREATE VIEW vw_forecast_line_items AS

SELECT *
FROM (
  SELECT [forecast_id], [date_type], ISNULL([amount], 0) as amount
  FROM 
	(SELECT
		fli.[forecast_id],
		LEFT(dd.[month_name], 3) as [date_type],
		ISNULL(fli.[amount], 0) as amount
	FROM [dbo].[forecast_line_item] as fli
	JOIN [dbo].[date_dimension] as dd
		ON fli.[date_id] = dd.[date_id]
	WHERE fli.[is_deleted] = 0
	) as t
) src
PIVOT (
  SUM([amount])
  FOR [date_type] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
) piv
GO
;


--DROP VIEW IF EXISTS vw_forecast_line_items_v2;
--GO
--CREATE VIEW vw_forecast_line_items_v2 AS

--SELECT *
--FROM (
--  SELECT [forecast_id], [date_type], ISNULL([amount], 0) as amount
--  FROM 
--	(SELECT
--		fli.[forecast_id],
--		dd.[short_month_short_year] as [date_type],
--		LEFT(dd.date_id, 6) as year_month,
--		ISNULL(fli.[amount], 0) as amount
--	FROM [dbo].[forecast_line_item] as fli
--	JOIN [dbo].[date_dimension] as dd
--		ON fli.[date_id] = dd.[date_id]
--	WHERE fli.[is_deleted] = 0
--	) as t
--) src
--PIVOT (
--  SUM([amount])
--  FOR [date_type] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
--) piv
--GO
--;





DROP VIEW IF EXISTS vw_work_orders_full;
GO
CREATE VIEW vw_work_orders_full AS 

SELECT
	wo.[id] as [WO ID],
	wt.[work_type] as [Worker Type],
	ws.[worker_status] as [Worker Status],
	wos.[work_order_status] as [Work Order Status],
	jpc.[employee] as [Job Posting Creator],
	jpa.[employee] as [Jost Posting Approver],
	svp.[employee] as [SVP],
	pce.[employee] as [Primary Contact], 
	mdt.[main_document_title] as [Main Document Title],
	d.[department_long] as [Department],
	s.[supplier] as [Supplier],
	bu.[business_unit] as [Business Unit],
	cc.[company_code] as [Company Code],
	coc.[cost_object_code] as [Cost Object Code],
	con.[worker_id] as [Worker ID],
	con.[pid] as [PID],
	con.[full_name] as [Contractor],
	start_d.[full_date] as [Worker Start Date],
	end_d.[full_date] as [Worker End Date],
	l.[location] as [Location],
	l.[local] as [Locale],
	wo.[job_posting_id] as [Job Posting ID],
	wo.[work_order_id] as [Work Order ID],
	wo.[purchase_order_number] as [PO Number],
	wo.[revision_number] as [Revision],
	wo.[current_bill_rate] as [Bill Rate],
	wo.[hours_per_week] as [Hours Per Week],
	wo.[hours_per_day] as [Hours Per Day],
	wo.[allocation_percentage] as [Allocation],
	wo.[cumulative_committed_spend] as [Cummulative Committed Spend],
	wo.[spend_to_date] as [Spend to Date],
	wo.[other_pending_spend] as [Other Pending Spend],
	wo.[remaining_spend] as [Remaining Spend],
	wo.[work_order_tenure] as [Work Order Tenure],
	wo.[work_order_composite] as [Work Order Composite]
FROM [dbo].[work_order] as wo
JOIN [dbo].[work_order_status] as wos
	ON wo.[work_order_status_id] = wos.[work_order_status_id]
JOIN [dbo].[employee] as jpc
	ON wo.[job_posting_creator_id] = jpc.[employee_id]
JOIN [dbo].[employee] as jpa
	ON wo.[job_posting_approver_id] = jpa.[employee_id]
JOIN [dbo].[employee] as svp
	ON wo.[svp_id] = svp.[employee_id]
JOIN [dbo].[employee] as pce
	ON wo.[primary_contact_id] = pce.[employee_id]
JOIN [dbo].[work_type] as wt
	ON wo.[worker_type_id] = wt.[work_type_id]
JOIN [dbo].[worker_status] as ws
	ON wo.[worker_status_id] = ws.[worker_status_id]
JOIN [dbo].[main_document_title] as mdt
	ON wo.[main_document_title_id] = mdt.[main_document_title_id]
LEFT JOIN [dbo].[date_dimension] as start_d
	ON wo.[worker_start_date_id] = start_d.[date_id]
LEFT JOIN [dbo].[date_dimension] as end_d
	ON wo.[worker_end_date_id] = end_d.[date_id]
JOIN [dbo].[deptartment] as d
	ON wo.[department_id] = d.[department_id]
JOIN [dbo].[supplier] as s
	ON wo.[supplier_id] = s.[supplier_id]
JOIN [dbo].[business_unit] as bu
	ON wo.[business_unit_id] = bu.[business_unit_id]
JOIN [dbo].[location] as l
	ON wo.[location_id] = l.[location_id]
JOIN [dbo].[company_code] as cc
	ON wo.[company_code_id]  = cc.[company_code_id]
JOIN [dbo].[cost_object_code] as coc
	ON wo.[cost_object_code_id] = coc.[cost_object_code_id]
JOIN [dbo].[contractor] as con
	ON wo.[contractor_id] = con.[contractor_id]
WHERE wo.[is_deleted] = 0
;
GO




DROP VIEW IF EXISTS vw_work_orders_new;
GO
CREATE VIEW vw_work_orders_new AS 

SELECT TOP 500
	wo.[id] as [WO ID],
	wt.[work_type] as [Worker Type],
	ws.[worker_status] as [Worker Status],
	wos.[work_order_status] as [Work Order Status],
	mdt.[main_document_title] as [Main Document Title],
	d.[department_long] as [Department],
	s.[supplier] as [Supplier],
	bu.[business_unit] as [Business Unit],
	coc.[cost_object_code] as [Cost Object Code],
	con.[worker_id] as [Worker ID],
	con.[pid] as [PID],
	con.[full_name] as [Contractor],
	start_d.[full_date] as [Worker Start Date],
	end_d.[full_date] as [Worker End Date],
	l.[location] as [Location],
	l.[local] as [Locale],
	wo.[job_posting_id] as [Job Posting ID],
	wo.[work_order_id] as [Work Order ID],
	wo.[purchase_order_number] as [PO Number],
	wo.[revision_number] as [Revision],
	wo.[current_bill_rate] as [Bill Rate],
	wo.[hours_per_week] as [Hours Per Week],
	wo.[hours_per_day] as [Hours Per Day],
	wo.[allocation_percentage] as [Allocation],
	wo.[work_order_composite] as [Work Order Composite]
FROM [dbo].[work_order_add_to_forecast] as woatf
JOIN [dbo].[work_order] as wo
	ON woatf.[work_order_id] = wo.[id]
JOIN [dbo].[work_order_status] as wos
	ON wo.[work_order_status_id] = wos.[work_order_status_id]
JOIN [dbo].[work_type] as wt
	ON wo.[worker_type_id] = wt.[work_type_id]
JOIN [dbo].[worker_status] as ws
	ON wo.[worker_status_id] = ws.[worker_status_id]
JOIN [dbo].[main_document_title] as mdt
	ON wo.[main_document_title_id] = mdt.[main_document_title_id]
LEFT JOIN [dbo].[date_dimension] as start_d
	ON wo.[worker_start_date_id] = start_d.[date_id]
LEFT JOIN [dbo].[date_dimension] as end_d
	ON wo.[worker_end_date_id] = end_d.[date_id]
JOIN [dbo].[deptartment] as d
	ON wo.[department_id] = d.[department_id]
JOIN [dbo].[supplier] as s
	ON wo.[supplier_id] = s.[supplier_id]
JOIN [dbo].[business_unit] as bu
	ON wo.[business_unit_id] = bu.[business_unit_id]
JOIN [dbo].[location] as l
	ON wo.[location_id] = l.[location_id]
JOIN [dbo].[cost_object_code] as coc
	ON wo.[cost_object_code_id] = coc.[cost_object_code_id]
JOIN [dbo].[contractor] as con
	ON wo.[contractor_id] = con.[contractor_id]
WHERE woatf.[is_added] = 0
AND woatf.[is_ignored] = 0
AND woatf.[is_deleted] = 0
AND wo.[is_deleted] = 0
AND YEAR(start_d.[full_date]) >= YEAR(CURRENT_TIMESTAMP)
--AND con.[pid] IN ('P3180681', 'P2692432', 'P3180682', 'P3145314',
--                        'P3047046', 'P3112437', 'P3045551', 'P2239909')
;
GO



DROP VIEW IF EXISTS vw_dropdown_business_unit;
GO
CREATE VIEW vw_dropdown_business_unit AS 

SELECT DISTINCT
	MIN([business_unit_id]) as [business_unit_id],
    [business_unit] 
FROM  [dbo].[business_unit]
WHERE [business_unit] IS NOT NULL
--AND [business_unit_id] IN (
--    SELECT DISTINCT
--        [business_unit_id]
--    FROM [dbo].[user_access] as ua
--    JOIN [dbo].[user] as u 
--        ON ua.[user_id] = u.[user_id]
--    JOIN [dbo].[deptartment_business_unit] as dbu
--        ON ua.[department_bu_id] = dbu.[department_bu_id]
--    WHERE u.[username] = CURRENT_USER
--)
GROUP BY [business_unit]
;
GO


DROP VIEW IF EXISTS vw_dropdown_location;
GO
CREATE VIEW vw_dropdown_location AS 

SELECT
	MIN([location_id]) as [location_id],
	[location]
FROM [dbo].[location]
WHERE [location] IS NOT NULL
AND LEN([location]) > 0
GROUP BY [location]
;
GO



DROP VIEW IF EXISTS vw_dropdown_employee;
GO
CREATE VIEW vw_dropdown_employee AS 

SELECT
	MIN([employee_id]) as [employee_id],
	[employee]
FROM [dbo].[employee]
WHERE [employee] IS NOT NULL
AND LEN([employee]) > 0
GROUP BY [employee]
;
GO


DROP VIEW IF EXISTS vw_dropdown_work_type;
GO
CREATE VIEW vw_dropdown_work_type AS 

SELECT
	MIN([work_type_id]) as [work_type_id],
	[work_type]
FROM [dbo].[work_type]
WHERE [work_type] IS NOT NULL
AND LEN([work_type]) > 0
GROUP BY [work_type]
;
GO


DROP VIEW IF EXISTS vw_dropdown_worker_status;
GO
CREATE VIEW vw_dropdown_worker_status AS 

SELECT
	MIN([worker_status_id]) as [worker_status_id],
	[worker_status]
FROM [dbo].[worker_status]
WHERE [worker_status] IS NOT NULL
AND LEN([worker_status]) > 0
GROUP BY [worker_status]
;
GO


DROP VIEW IF EXISTS vw_dropdown_work_order_category;
GO
CREATE VIEW vw_dropdown_work_order_category AS 

SELECT
	MIN([work_order_category_id]) as [work_order_category_id],
	[work_order_category]
FROM [dbo].[work_order_category]
WHERE [work_order_category] IS NOT NULL
AND LEN([work_order_category]) > 0
GROUP BY [work_order_category]
;
GO


DROP VIEW IF EXISTS vw_dropdown_expense_classification;
GO
CREATE VIEW vw_dropdown_expense_classification AS 

SELECT
	MIN([expense_classification_id]) as [expense_classification_id],
	[expense_classification]
FROM [dbo].[expense_classification]
WHERE [expense_classification] IS NOT NULL
AND LEN([expense_classification]) > 0
GROUP BY [expense_classification]
;
GO


DROP VIEW IF EXISTS vw_dropdown_segmentation;
GO
CREATE VIEW vw_dropdown_segmentation AS 

SELECT
	MIN([segmentation_id]) as [segmentation_id],
	[segmentation]
FROM [dbo].[segmentation]
WHERE [segmentation] IS NOT NULL
AND LEN([segmentation]) > 0
GROUP BY [segmentation]
;
GO


DROP VIEW IF EXISTS vw_dropdown_platform;
GO
CREATE VIEW vw_dropdown_platform AS 

SELECT
	MIN([platform_id]) as [platform_id],
	[platform]
FROM [dbo].[platform]
WHERE [platform] IS NOT NULL
AND LEN([platform]) > 0
GROUP BY [platform]
;
GO


DROP VIEW IF EXISTS vw_dropdown_function;
GO
CREATE VIEW vw_dropdown_function AS 

SELECT
	MIN([function_id]) as [function_id],
	[function]
FROM [dbo].[function]
WHERE [function] IS NOT NULL
AND LEN([function]) > 0
GROUP BY [function]
;
GO

DROP VIEW IF EXISTS vw_dropdown_support_scalable;
GO
CREATE VIEW vw_dropdown_support_scalable AS 

SELECT
	MIN([support_scalable_id]) as [support_scalable_id],
	[support_scalable]
FROM [dbo].[support_scalable]
WHERE [support_scalable] IS NOT NULL
AND LEN([support_scalable]) > 0
GROUP BY [support_scalable]
;
GO


DROP VIEW IF EXISTS vw_dropdown_date;
GO
CREATE VIEW vw_dropdown_date AS 

SELECT
	MIN([date_id]) as [date_id],
	FORMAT([full_date], 'MM/dd/yyy') as [full_date]
FROM [dbo].[date_dimension]
WHERE [date_id] >= 20200101
GROUP BY [full_date]
;
GO

DROP VIEW IF EXISTS vw_dropdown_years;
GO
CREATE VIEW vw_dropdown_years AS 

SELECT
	MIN([calendar_year]) as [calendar_year_id],
	[calendar_year]
FROM [dbo].[date_dimension]
WHERE [date_id] >= 20200101
GROUP BY [calendar_year]
;
GO

DROP VIEW IF EXISTS vw_dropdown_months;
GO
CREATE VIEW vw_dropdown_months AS 

SELECT
	MIN([month_of_year]) as [month_id],
	[month_name]
FROM [dbo].[date_dimension]
WHERE [date_id] >= 20200101
GROUP BY [month_name]
;
GO



DROP VIEW IF EXISTS vw_dropdown_cost_object;
GO
CREATE VIEW vw_dropdown_cost_object AS 

SELECT
	MIN([cost_object_code_id]) as [cost_object_code_id],
	[cost_object_code]
FROM [dbo].[cost_object_code]
WHERE [cost_object_code] IS NOT NULL
AND LEN([cost_object_code]) > 0
GROUP BY [cost_object_code]
;
GO


DROP VIEW IF EXISTS vw_dropdown_company_code;
GO
CREATE VIEW vw_dropdown_company_code AS 

SELECT
	MIN([company_code_id]) as [company_code_id],
	[company_code]
FROM [dbo].[company_code]
WHERE [company_code] IS NOT NULL
AND LEN([company_code]) > 0
GROUP BY [company_code]
;
GO


DROP VIEW IF EXISTS vw_dropdown_cost_center_code;
GO
CREATE VIEW vw_dropdown_cost_center_code AS 

SELECT
	MIN([cost_center_code_id]) as [cost_center_code_id],
	[cost_center_code]
FROM [dbo].[cost_center_code]
WHERE [cost_center_code] IS NOT NULL
AND LEN([cost_center_code]) > 0
GROUP BY [cost_center_code]
;
GO


DROP VIEW IF EXISTS vw_dropdown_project;
GO
CREATE VIEW vw_dropdown_project AS 

SELECT
	MIN([project_id]) as [project_id],
	[project]
FROM [dbo].[project]
WHERE [project] IS NOT NULL
AND LEN([project]) > 0
GROUP BY [project]
;
GO


DROP VIEW IF EXISTS vw_dropdown_expense_type;
GO
CREATE VIEW vw_dropdown_expense_type AS 

SELECT
	MIN([expense_type_id]) as [expense_type_id],
	[expense_type]
FROM [dbo].[expense_type]
WHERE [expense_type] IS NOT NULL
AND LEN([expense_type]) > 0
GROUP BY [expense_type]
;
GO


DROP VIEW IF EXISTS vw_dropdown_department;
GO
CREATE VIEW vw_dropdown_department AS 

SELECT
	MIN([department_id]) as [department_id],
	[department_long] as [department]
FROM [dbo].[deptartment]
WHERE [department_long] IS NOT NULL
AND LEN([department_long]) > 0
GROUP BY [department_long]
;
GO


DROP VIEW IF EXISTS vw_dropdown_account;
GO
CREATE VIEW vw_dropdown_account AS 

SELECT
	MIN([account_id]) as [account_id],
	[account_code] as [account_code]
FROM [dbo].[account]
WHERE [account_code] IS NOT NULL
AND LEN([account_code]) > 0
AND LEFT([account_code], 1) IN (5,6)
GROUP BY [account_code]
;
GO




DROP VIEW IF EXISTS vw_general_ledger_last_upload;
GO
CREATE VIEW vw_general_ledger_last_upload AS 

SELECT 
	FORMAT(MAX(max_date AT TIME ZONE 'UTC' AT TIME ZONE 'Mountain Standard Time'), 'MMM d, yyyy h:mm tt') as max_date
FROM
	(SELECT
		MAX([created_date]) as max_date
	FROM [dbo].[general_ledger]
	) as t
;
GO



DROP VIEW IF EXISTS vw_work_order_last_upload;
GO
CREATE VIEW vw_work_order_last_upload AS 

SELECT 
	FORMAT(MAX(max_date AT TIME ZONE 'UTC' AT TIME ZONE 'Mountain Standard Time'), 'MMM d, yyyy h:mm tt') as max_date
FROM
	(SELECT
		MAX([created_date]) as max_date
	FROM [dbo].[work_order]
	) as t
;
GO


DROP VIEW IF EXISTS vw_actualized_date;
GO
CREATE VIEW vw_actualized_date AS 

SELECT 
	dd.short_month_short_year as actualized_date
FROM
	(SELECT
		MAX([date_id]) as max_date
	FROM [dbo].[forecast_line_item]
	WHERE [is_actualized] = 1
	) as t
JOIN [dbo].[date_dimension] as dd
	ON t.max_date = dd.date_id
;
GO


--SELECT [date_id], [full_date] 
--        FROM [dbo].[vw_dropdown_date] 
--        WHERE [full_date] >= DATEADD(day, -90, CURRENT_TIMESTAMP)
--        AND [full_date] < CURRENT_TIMESTAMP
--        ORDER BY 1


DROP VIEW IF EXISTS vw_po_number_forecast_id;
GO
CREATE VIEW vw_po_number_forecast_id AS 

SELECT DISTINCT
    [purchase_order_number],
    [forecast_id]
FROM [dbo].[auto_tag]
WHERE is_deleted = 0
AND [purchase_order_number] IS NOT NULL
AND LEN([purchase_order_number]) > 0

UNION

SELECT DISTINCT
	[purchase_order_number],
	[forecast_id]
FROM [dbo].[general_ledger]
WHERE [forecast_id] IS NOT NULL
AND [purchase_order_number] IS NOT NULL
AND LEN([purchase_order_number]) > 0
;
GO