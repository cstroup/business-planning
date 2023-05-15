DROP PROCEDURE IF EXISTS [etl].[sp_inital_migration_v2];
GO
CREATE PROCEDURE [etl].[sp_inital_migration_v2]
AS
BEGIN
    SET NOCOUNT ON;

	
-- FACT TABLES
DROP TABLE IF EXISTS #TMP_WORK_ORDER;
SELECT DISTINCT
	IIF(wos.[work_order_status_id] IS NULL, 0, wos.[work_order_status_id]) as [work_order_status_id],
	IIF(jpc.[employee_id] IS NULL, 0, jpc.[employee_id]) as [job_posting_creator_id],
	IIF(jpa.[employee_id] IS NULL, 0, jpa.[employee_id]) as [job_posting_approver_id],
	IIF(svp.[employee_id] IS NULL, 0, svp.[employee_id]) as [svp_id],
	IIF(wt.[work_type_id] IS NULL, 0, wt.[work_type_id]) as [worker_type_id],
	IIF(ws.[worker_status_id] IS NULL, 0, ws.[worker_status_id]) as [worker_status_id],
	IIF(mdt.[main_document_title_id] IS NULL, 0, mdt.[main_document_title_id]) as [main_document_title_id],
	IIF(start_d.[date_id] IS NULL, 0, start_d.[date_id]) as [worker_start_date_id],
	IIF(end_d.[date_id] IS NULL, 0, end_d.[date_id]) as [worker_end_date_id],
	IIF(pc.[employee_id] IS NULL, 0, pc.[employee_id]) as [primary_contact_id],
	IIF(d.[department_id] IS NULL, 0, d.[department_id]) as [department_id],
	IIF(s.[supplier_id] IS NULL, 0, s.[supplier_id]) as [supplier_id],
	IIF(bu.[business_unit_id] IS NULL, 0, bu.[business_unit_id]) as [business_unit_id],
	IIF(l.[location_id] IS NULL, 0, l.[location_id]) as [location_id],
	IIF(cc.[company_code_id] IS NULL, 0, cc.[company_code_id]) as [company_code_id],
	IIF(coc.[cost_object_code_id] IS NULL, 0, coc.[cost_object_code_id]) as [cost_object_code_id],
	IIF(con.[contractor_id] IS NULL, 0, con.[contractor_id]) as [contractor_id],
	wod.[Job Posting ID] as [job_posting_id],
	wod.[Work Order ID] as [work_order_id],
	wod.[Purchase Order Number] as [purchase_order_number],
	wod.[Revision #] as [revision_number],
	IIF(wod.[Current Bill Rate ST Hr] IS NULL, '0.0', wod.[Current Bill Rate ST Hr]) as [current_bill_rate],
	IIF(wod.[Hours per Week] IS NULL, '0.0', wod.[Hours per Week]) as [hours_per_week],
	IIF(wod.[Hours per Day] IS NULL, '0.0', wod.[Hours per Day]) as [hours_per_day],
	IIF(wod.[Allocation %] IS NULL, '0.0', wod.[Allocation %]) as [allocation_percentage],
	IIF(wod.[Cumulative Committed Spend] IS NULL, '0.0', wod.[Cumulative Committed Spend]) as [cumulative_committed_spend],
	IIF(wod.[Spend to Date] IS NULL, '0.0', wod.[Spend to Date])  as [spend_to_date],
	IIF(wod.[Other Pending Spend] IS NULL, '0.0', wod.[Other Pending Spend])  as [other_pending_spend],
	IIF(wod.[Remaining Spend] IS NULL, '0.0', wod.[Remaining Spend]) as [remaining_spend],
	IIF(wod.[Work Order Tenure] IS NULL, '0.0', wod.[Work Order Tenure]) as [work_order_tenure],
	CAST(CONCAT(wod.[Work Order ID], '-', RIGHT(REPLICATE('0', 5) + CAST(wod.[Revision #] AS VARCHAR(5)), 5), '-', wod.[Cost Object Code]) AS VARCHAR(250)) as [work_order_composite],
	CAST(CONCAT(wod.[Work Order ID], '-', wod.[Cost Object Code]) AS VARCHAR(250)) as [work_order_short_composite],
	0 as [is_deleted],
	CURRENT_USER AS [created_by],
	CURRENT_TIMESTAMP AS [created_date],
	CURRENT_USER AS [updated_by],
	CURRENT_TIMESTAMP AS [updated_date]
INTO #TMP_WORK_ORDER
FROM [staging].[work_order_detail] as wod
LEFT JOIN [dbo].[work_order_status] as wos
	ON wod.[Work Order Status] = wos.[raw]
LEFT JOIN [dbo].[employee] as jpc 
	ON wod.[Job Posting Creator] = jpc.[raw]
LEFT JOIN [dbo].[employee] as jpa
	ON wod.[Job Posting Approver] = jpa.[raw]
LEFT JOIN [dbo].[employee] as svp
	ON wod.[SVP] = svp.[raw]
LEFT JOIN [dbo].[work_type] as wt
	ON wod.[Worker Type] = wt.[raw]
LEFT JOIN [dbo].[worker_status] as ws
	ON wod.[Worker Status] = ws.[raw]
LEFT JOIN [dbo].[main_document_title] as mdt
	ON CAST(wod.[Main Document Title] as VARCHAR(254)) = mdt.[raw]
LEFT JOIN [dbo].[date_dimension] as start_d
	ON CONVERT(DATE, wod.[Worker Start Date], 101) = start_d.[full_date]
LEFT JOIN [dbo].[date_dimension] as end_d
	ON CONVERT(DATE, wod.[Worker End Date], 101) = end_d.[full_date]
LEFT JOIN [dbo].[employee] as pc
	ON wod.[Worker: New Primary Contact] = pc.[raw]
LEFT JOIN [dbo].[deptartment] as d
	ON wod.[Department of Hiring Manager] = d.[raw]
LEFT JOIN [dbo].[supplier] as s
	ON wod.[Supplier] = s.[raw]
LEFT JOIN [dbo].[business_unit] as bu
	ON wod.[Business Unit] = bu.[raw]
LEFT JOIN [dbo].[location] as l
	ON wod.[Country] = l.[raw]
LEFT JOIN [dbo].[company_code] as cc
	ON wod.[Company Code] = cc.[raw]
LEFT JOIN [dbo].[cost_object_code] as coc
	ON wod.[Cost Object Code] = coc.[raw]
LEFT JOIN [dbo].[contractor] as con
	ON wod.[Worker ID] = con.[raw]
ORDER BY wod.[Work Order ID], wod.[Revision #]
;

CREATE CLUSTERED INDEX idx_work_order_composite ON #TMP_WORK_ORDER ([work_order_composite])

--SELECT * FROM #TMP_WORK_ORDER

MERGE INTO [dbo].[work_order] AS PRD
USING #TMP_WORK_ORDER AS TMP
	ON PRD.[work_order_composite] = TMP.[work_order_composite]
WHEN MATCHED THEN
  UPDATE SET
  PRD.[current_bill_rate] = TMP.[current_bill_rate],
  PRD.[hours_per_week] = TMP.[hours_per_week],
  PRD.[hours_per_day] = TMP.[hours_per_day],
  PRD.[allocation_percentage] = TMP.[allocation_percentage],
  PRD.[cumulative_committed_spend] = TMP.[cumulative_committed_spend],
  PRD.[spend_to_date] = TMP.[spend_to_date],
  PRD.[other_pending_spend] = TMP.[other_pending_spend],
  PRD.[remaining_spend] = TMP.[remaining_spend],
  PRD.[work_order_tenure] = TMP.[work_order_tenure],
  PRD.[updated_by] = CURRENT_USER,
  PRD.[updated_date] = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
  INSERT (  [work_order_status_id]
           ,[job_posting_creator_id]
           ,[job_posting_approver_id]
           ,[svp_id]
           ,[worker_type_id]
           ,[worker_status_id]
           ,[main_document_title_id]
           ,[worker_start_date_id]
           ,[worker_end_date_id]
           ,[primary_contact_id]
           ,[department_id]
           ,[supplier_id]
           ,[business_unit_id]
           ,[location_id]
           ,[company_code_id]
           ,[cost_object_code_id]
           ,[contractor_id]
           ,[job_posting_id]
           ,[work_order_id]
           ,[purchase_order_number]
           ,[revision_number]
           ,[current_bill_rate]
           ,[hours_per_week]
           ,[hours_per_day]
           ,[allocation_percentage]
           ,[cumulative_committed_spend]
           ,[spend_to_date]
           ,[other_pending_spend]
           ,[remaining_spend]
           ,[work_order_tenure]
           ,[work_order_composite]
		   ,[work_order_short_composite]
           ,[is_deleted]
           ,[created_by]
           ,[created_date]
           ,[updated_by]
           ,[updated_date]) 
		   VALUES
		   (TMP.[work_order_status_id]
           ,TMP.[job_posting_creator_id]
           ,TMP.[job_posting_approver_id]
           ,TMP.[svp_id]
           ,TMP.[worker_type_id]
           ,TMP.[worker_status_id]
           ,TMP.[main_document_title_id]
           ,TMP.[worker_start_date_id]
           ,TMP.[worker_end_date_id]
           ,TMP.[primary_contact_id]
           ,TMP.[department_id]
           ,TMP.[supplier_id]
           ,TMP.[business_unit_id]
           ,TMP.[location_id]
           ,TMP.[company_code_id]
           ,TMP.[cost_object_code_id]
           ,TMP.[contractor_id]
           ,TMP.[job_posting_id]
           ,TMP.[work_order_id]
           ,TMP.[purchase_order_number]
           ,TMP.[revision_number]
           ,TMP.[current_bill_rate]
           ,TMP.[hours_per_week]
           ,TMP.[hours_per_day]
           ,TMP.[allocation_percentage]
           ,TMP.[cumulative_committed_spend]
           ,TMP.[spend_to_date]
           ,TMP.[other_pending_spend]
           ,TMP.[remaining_spend]
           ,TMP.[work_order_tenure]
           ,TMP.[work_order_composite]
		   ,TMP.[work_order_short_composite]
           ,TMP.[is_deleted]
           ,TMP.[created_by]
           ,TMP.[created_date]
           ,TMP.[updated_by]
           ,TMP.[updated_date]
		   )
;




-- GET UNIQUE CONTRACTORS TO HELP WITH FKs IN FORECAST
DROP TABLE IF EXISTS #TMP_UNIQUE_CONTRACTORS;
SELECT 
	[work_order_id],
	[current_bill_rate],
	[hours_per_week],
	[hours_per_day],
	[worker_start_date_id],
	[worker_end_date_id],
	[supplier_id],
	[location_id],
	[location],
	[local],
	[contractor_id],
	[worker_id],
	[first_name],
	[last_name],
	[full_name],
	[pid]
INTO #TMP_UNIQUE_CONTRACTORS
FROM
(
SELECT
	wo.[work_order_id],
	wo.[current_bill_rate],
	wo.[hours_per_week],
	wo.[hours_per_day],
	wo.[worker_start_date_id],
	wo.[worker_end_date_id],
	s.[supplier_id],
	l.[location_id],
	l.[location],
	l.[local],
	con.[contractor_id],
	con.[worker_id],
	con.[first_name],
	con.[last_name],
	con.[full_name],
	con.[pid],
	ROW_NUMBER() OVER (PARTITION BY wo.[work_order_id] ORDER BY wo.[worker_start_date_id] DESC) AS dedupe
FROM [dbo].[work_order] as wo
LEFT JOIN [dbo].[contractor] as con
	ON wo.[contractor_id] = con.[contractor_id]
LEFT JOIN [dbo].[location] as l
	ON wo.[location_id] = l.[location_id]
LEFT JOIN [dbo].[supplier] as s
	ON wo.[supplier_id] = s.[supplier_id]
) as T
WHERE dedupe =1
;

--SELECT * FROM #TMP_UNIQUE_CONTRACTORS

-- FORECAST
DROP TABLE IF EXISTS #TMP_FORECAST;
SELECT
	CASE 
		WHEN cc.[company_code_id] IS NOT NULL THEN cc.[company_code_id]
		WHEN cc2.[company_code_id] IS NOT NULL THEN cc2.[company_code_id]
		ELSE 0
	END as [company_code_id],
	IIF(bu.[business_unit_id] IS NULL, 0, bu.[business_unit_id]) as [business_unit_id],
	IIF(d.[department_id] IS NULL, 0, d.[department_id]) as [department_id],
	IIF(ccc.[cost_center_code_id] IS NULL, 0, ccc.[cost_center_code_id]) as [cost_center_code_id],
	IIF(dl.[employee_id] IS NULL, 0, dl.[employee_id]) as [department_leader_id],
	IIF(tl.[employee_id] IS NULL, 0, tl.[employee_id]) as [team_leader_id],
	IIF(bo.[employee_id] IS NULL, 0, bo.[employee_id]) as [business_owner_id],
	IIF(pc.[employee_id] IS NULL, 0, pc.[employee_id]) as [primary_contact_id],
	CASE
		WHEN tmp.[supplier_id] IS NOT NULL
		THEN tmp.[supplier_id]
		ELSE IIF(s.[supplier_id] IS NULL, 0, s.[supplier_id]) 
	END as [supplier_id],
	CASE 
		WHEN tmp.[contractor_id] IS NOT NULL
		THEN tmp.[contractor_id]
		ELSE IIF(con.[contractor_id] IS NULL, 0, con.[contractor_id])
	END as [contractor_id],
	IIF(start_d.[date_id] IS NULL, NULL, start_d.[date_id]) as [worker_start_date_id],
	IIF(end_d.[date_id] IS NULL, NULL, end_d.[date_id]) as [worker_end_date_id],
	NULL as [override_end_date_id],
	IIF(mdt.[main_document_title_id] IS NULL, 0, mdt.[main_document_title_id]) as [main_document_title_id],
	IIF(coc.[cost_object_code_id] IS NULL, 0, coc.[cost_object_code_id]) as [cost_object_code_id],
	IIF(tmp.[location_id] IS NULL, 0, tmp.[location_id]) as [site_id],
	IIF(acc.[account_id] IS NULL, 0, acc.[account_id]) as [account_code_id],
	IIF(wt.[work_type_id] IS NULL, 0, wt.[work_type_id]) as [work_type_id],
	IIF(ws.[worker_status_id] IS NULL, 0, ws.[worker_status_id]) as [worker_status_id],
	IIF(woc.[work_order_category_id] IS NULL, 0, woc.[work_order_category_id]) as [work_order_category_id],
	IIF(ec.[expense_classification_id] IS NULL, 0, ec.[expense_classification_id]) as [expense_classification_id],
	IIF(bc.[budget_code_id] IS NULL, 0, bc.[budget_code_id]) as [budget_code_id],
	IIF(seg.[segmentation_id] IS NULL, 0, seg.[segmentation_id]) as [segmentation_id],
	IIF(plat.[platform_id] IS NULL, 0, plat.[platform_id]) as [platform_id],
	IIF(fun.[function_id] IS NULL, 0, fun.[function_id]) as [function_id],
	IIF(ss.[support_scalable_id] IS NULL, 0, ss.[support_scalable_id]) as [support_scalable_id],
	IIF(LEN(rf.[Work Order ID]) < 1, NULL, rf.[Work Order ID]) as [work_order_id],
	IIF(LEN(rf.[Worker/Description]) < 1, NULL, rf.[Worker/Description]) as [description],
	IIF(rf.[Current Allocation %] IS NULL, '0', REPLACE(rf.[Current Allocation %], '%', '')) as [allocation],
	IIF(rf.[Current Bill Rate ST/Hr] IS NULL, '0', rf.[Current Bill Rate ST/Hr]) as [current_bill_rate_hr],
	IIF(rf.[Current Bill Rate ST/Day] IS NULL, '0', rf.[Current Bill Rate ST/Day]) as [current_bill_rate_day],
	TMP.first_name as [contractor_first_name],
	TMP.last_name as [contractor_last_name],
	NULL as [comment],
	rf.FCSTID AS [old_forecast_id],
	IIF(rf.[DelFlag] = '1' OR rf.[DelFlag] IN ('Y', 'x'), 1, 0) as [is_deleted],
	CURRENT_USER AS [created_by],
	CURRENT_TIMESTAMP AS [created_date],
	CURRENT_USER AS [updated_by],
	CURRENT_TIMESTAMP AS [updated_date],
	ROW_NUMBER() OVER (PARTITION BY rf.FCSTID ORDER BY rf.FCSTID) AS dedupe
INTO #TMP_FORECAST
FROM [Compiler].[mart].[RollingF] as rf
LEFT JOIN #TMP_UNIQUE_CONTRACTORS as tmp -- first take work order
	ON rf.[Work Order ID] = tmp.[work_order_id]
LEFT JOIN [dbo].[company_code] as cc
	ON LEFT(rf.[Company Code], 3) = cc.[raw]
LEFT JOIN [dbo].[company_code] as cc2 -- when [Company Code] is null
	ON LEFT(rf.[Cost Center Code], 3) = cc.[raw]
LEFT JOIN [dbo].[business_unit] as bu
	ON rf.[Business Unit] = bu.[raw]
LEFT JOIN [dbo].[deptartment] as d
	ON rf.[Department of Hiring Manager] = d.[raw]
LEFT JOIN [dbo].[cost_center_code] as ccc
	ON rf.[Cost Center Code] = ccc.[raw]
LEFT JOIN [dbo].[employee] as dl
	ON rf.[Department Leader] = dl.[raw]
LEFT JOIN [dbo].[employee] as tl
	ON rf.[Team Leader]= tl.[raw]
LEFT JOIN [dbo].[employee] as bo
	ON rf.[Business Owner] = bo.[raw]
LEFT JOIN [dbo].[employee] as pc
	ON rf.[Worker: New Primary Contact] = pc.[raw]
LEFT JOIN [dbo].[supplier] as s
	ON rf.[Supplier] = s.[raw]
LEFT JOIN [dbo].[contractor] as con
	ON rf.[Worker ID] = con.[raw]
LEFT JOIN [dbo].[date_dimension] as start_d
	ON rf.[Worker Start Date] = start_d.[full_date]
LEFT JOIN [dbo].[date_dimension] as end_d
	ON rf.[Worker End Date] = end_d.[full_date]
LEFT JOIN [dbo].[main_document_title] as mdt
	ON rf.[Main Document Title] = mdt.[raw]
LEFT JOIN [dbo].[cost_object_code] as coc
	ON rf.[Cost Object Code] = coc.[raw]
LEFT JOIN [dbo].[account] as acc
	ON rf.[Account Code] = acc.[raw]
LEFT JOIN [dbo].[work_type] as wt 
	ON rf.[Work Type] = wt.[raw]
LEFT JOIN [dbo].[worker_status] as ws
	ON rf.[Worker Status] = ws.[raw]
LEFT JOIN [dbo].[work_order_category] as woc
	ON rf.[WO Category] = woc.[raw]
LEFT JOIN [dbo].[expense_classification] as ec
	ON rf.[Expense Classification] = ec.[raw]
LEFT JOIN [dbo].[budget_code] as bc
	ON rf.[Budget Code] = bc.[raw]
LEFT JOIN [dbo].[segmentation] as seg
	ON rf.[Segmentation] = seg.[raw]
LEFT JOIN [dbo].[platform] as plat
	ON rf.[Platform] = plat.[raw]
LEFT JOIN [dbo].[function] as fun
	ON rf.[Function] = fun.[raw]
LEFT JOIN [dbo].[support_scalable] as ss
	ON rf.[Support/Scalable] = ss.[raw]
; 




--SELECT * FROM #TMP_FORECAST ORDER BY [old_forecast_id];

INSERT INTO [dbo].[forecast]
           ([company_code_id]
           ,[business_unit_id]
           ,[department_id]
           ,[cost_center_code_id]
           ,[department_leader_id]
           ,[team_leader_id]
           ,[business_owner_id]
           ,[primary_contact_id]
           ,[supplier_id]
           ,[contractor_id]
           ,[worker_start_date_id]
           ,[worker_end_date_id]
           ,[override_end_date_id]
           ,[main_document_title_id]
           ,[cost_object_code_id]
           ,[site_id]
           ,[account_code_id]
           ,[work_type_id]
           ,[worker_status_id]
           ,[work_order_category_id]
           ,[expense_classification_id]
           ,[budget_code_id]
           ,[segmentation_id]
           ,[platform_id]
           ,[function_id]
           ,[work_order_id]
           ,[description]
           ,[allocation]
           ,[current_bill_rate_hr]
           ,[current_bill_rate_day]
           ,[contractor_first_name]
           ,[contractor_last_name]
           ,[comment]
           ,[old_forecast_id]
           ,[is_deleted]
           ,[created_by]
           ,[created_date]
           ,[updated_by]
           ,[updated_date])
SELECT
	[company_code_id]
	,[business_unit_id]
	,[department_id]
	,[cost_center_code_id]
	,[department_leader_id]
	,[team_leader_id]
	,[business_owner_id]
	,[primary_contact_id]
	,[supplier_id]
	,[contractor_id]
	,[worker_start_date_id]
	,[worker_end_date_id]
	,[override_end_date_id]
	,[main_document_title_id]
	,[cost_object_code_id]
	,[site_id]
	,[account_code_id]
	,[work_type_id]
	,[worker_status_id]
	,[work_order_category_id]
	,[expense_classification_id]
	,[budget_code_id]
	,[segmentation_id]
	,[platform_id]
	,[function_id]
	,[work_order_id]
	,[description]
	,[allocation]
	,[current_bill_rate_hr]
	,[current_bill_rate_day]
	,[contractor_first_name]
	,[contractor_last_name]
	,[comment]
	,[old_forecast_id]
	,[is_deleted]
	,[created_by]
	,[created_date]
	,[updated_by]
	,[updated_date]
FROM #TMP_FORECAST
WHERE dedupe = 1
ORDER BY [old_forecast_id]
;


INSERT INTO [dbo].[forecast_line_item]
           ([forecast_id]
           ,[date_id]
           ,[amount]
           ,[is_actual]
           ,[is_deleted]
           ,[created_by]
           ,[created_date]
           ,[updated_by]
           ,[updated_date])
SELECT
	f.[forecast_id],
	dd.[date_id],
	rf.value as [amount],
	CASE
		WHEN dd.[date_id] <= 20230301
		THEN 1
		ELSE 0
	END as [is_actual],
	0 as [is_deleted], 
	CURRENT_USER AS [created_by],
	CURRENT_TIMESTAMP AS [created_date],
	CURRENT_USER AS [updated_by],
	CURRENT_TIMESTAMP AS [updated_date]
FROM [dbo].[forecast] as f
JOIN
(
	SELECT 
		FCSTID, 
		month_name, 
		value
	FROM [Compiler].[mart].[RollingF]
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







-- SELECT * FROM [dbo].[work_order]
DROP TABLE IF EXISTS #TMP_WORK_ORDER_TRIMMED;
SELECT DISTINCT
	f.forecast_id,
	f.work_order_id,
	con.worker_id,
	con.pid,
	coc.cost_object_code,
	CAST(CONCAT(f.work_order_id, '-', coc.cost_object_code) AS VARCHAR(250)) as [work_order_short_composite]
INTO #TMP_WORK_ORDER_TRIMMED
FROM [dbo].[forecast] as f
LEFT JOIN [dbo].[cost_object_code] as coc
	ON f.[cost_object_code_id] = coc.[cost_object_code_id]
LEFT JOIN [dbo].[contractor] as con
	ON f.[contractor_id] = con.[contractor_id]
WHERE f.work_order_id IS NOT NULL
AND LEFT(f.work_order_id, 6) = 'CHTRWO'
AND coc.cost_object_code_id > 0
;
CREATE CLUSTERED INDEX idx_work_order_short_composite ON #TMP_WORK_ORDER_TRIMMED ([work_order_short_composite]);


-- UPSERT FOR INSERTING WORK ORDERS
DROP TABLE IF EXISTS #TMP_UPSERT;
SELECT DISTINCT
	PRD.[id] as [work_order_id],
	0 as [is_added],
	0 as [is_ignored],
	0 as [is_deleted],
	NULL as [action_by],
	NULL as [action_date],
	CURRENT_USER AS [created_by],
	CURRENT_TIMESTAMP AS [created_date],
	CURRENT_USER AS [updated_by],
	CURRENT_TIMESTAMP AS [updated_date]
INTO #TMP_UPSERT
FROM  [dbo].[work_order] AS PRD
LEFT JOIN #TMP_WORK_ORDER_TRIMMED AS TMP
	ON PRD.[work_order_short_composite] = TMP.[work_order_short_composite]
WHERE TMP.forecast_id IS NULL -- WORK ORDERS THAT DON'T EXIST IN FORECAST
AND worker_start_date_id > 20230101
;
CREATE CLUSTERED INDEX idx_work_order_id ON #TMP_UPSERT ([work_order_id]);

--SELECT * FROM #TMP_UPSERT;


MERGE INTO [dbo].[work_order_add_to_forecast] AS PRD
USING #TMP_UPSERT AS TMP
	ON PRD.[work_order_id] = TMP.[work_order_id]
WHEN MATCHED THEN
  UPDATE SET
  PRD.[updated_by] = CURRENT_USER,
  PRD.[updated_date] = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
  INSERT (  [work_order_id]
           ,[is_added]
           ,[is_ignored]
           ,[is_deleted]
           ,[action_by]
           ,[action_date]
           ,[created_by]
           ,[created_date]
           ,[updated_by]
           ,[updated_date]) 
		   VALUES
		   (TMP.[work_order_id]
           ,TMP.[is_added]
           ,TMP.[is_ignored]
           ,TMP.[is_deleted]
           ,TMP.[action_by]
           ,TMP.[action_date]
           ,TMP.[created_by]
           ,TMP.[created_date]
           ,TMP.[updated_by]
           ,TMP.[updated_date]
		   )
;
END
;
GO