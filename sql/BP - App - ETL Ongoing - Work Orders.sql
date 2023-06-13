USE TEST
GO

-- WORK ORDER

DROP PROCEDURE IF EXISTS [dbo].[sp_etl_work_order];
GO
CREATE PROCEDURE [dbo].[sp_etl_work_order]
AS
BEGIN
    SET NOCOUNT ON;

MERGE INTO [dbo].[work_type] AS TGT
USING (
	SELECT DISTINCT
		[Worker Type] as [data_value]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([work_type], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[employee] AS TGT
USING (
	SELECT DISTINCT
		[Job Posting Creator] as [data_value]
	FROM [staging].[work_order_detail]
	UNION
	SELECT DISTINCT
		[Job Posting Approver] as [data_value]
	FROM [staging].[work_order_detail]
	UNION
	SELECT DISTINCT
		[Worker: New Primary Contact] as [data_value]
	FROM [staging].[work_order_detail]
	UNION
	SELECT DISTINCT
		[SVP] as [data_value]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([employee], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[work_order_status] AS TGT
USING (
	SELECT DISTINCT
		[Work Order Status] as [data_value]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([work_order_status], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[contractor] AS TGT
USING (
	SELECT * FROM
	(SELECT DISTINCT
		[Worker ID] as worker_id,
		[PID] as pid,
		RIGHT([Worker],CHARINDEX(',',REVERSE([Worker]))-1) as first_name,
		LEFT([Worker], CHARINDEX(',', [Worker] + ',') - 1) as last_name,
		[Worker] as full_name,
		CONCAT('Worker Site: ', [Worker Site State/Province], ' - Country: ', [Country]) as worker_site,
		[Worker ID] as [raw],
		ROW_NUMBER() OVER (PARTITION BY [Worker ID] ORDER BY [PID]) AS dedupe
	FROM [staging].[work_order_detail]
	) AS t
	WHERE t.dedupe = 1
) AS SRC
ON TGT.[raw] = SRC.[raw]
WHEN NOT MATCHED THEN
	INSERT ([worker_id], [pid], [first_name], [last_name], [full_name], [worker_site], [raw]) 
	VALUES (SRC.worker_id, SRC.pid, SRC.first_name, SRC.last_name, SRC.full_name, SRC.worker_site, SRC.[raw])
;


MERGE INTO [dbo].[worker_status] AS TGT
USING (
	SELECT DISTINCT
		[Worker Status] as [data_value]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([worker_status], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[main_document_title] AS TGT
USING (
	SELECT DISTINCT
		[Main Document Title] as [data_value]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([main_document_title], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[deptartment] AS TGT
USING (
	SELECT DISTINCT
		[Department of Hiring Manager Code] as [code],
		[Department of Hiring Manager] as [name]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.[name]
WHEN NOT MATCHED THEN
	INSERT ([department_code], [department], [department_long], [raw]) 
	VALUES (SRC.[code], SRC.[name], CONCAT(SRC.[name], ' (', SRC.[code], ')'), SRC.[name])
;


MERGE INTO [dbo].[supplier] AS TGT
USING (
	SELECT DISTINCT
		[Supplier Code] as [code],
		[Supplier] as [name]
	FROM [staging].[work_order_detail]
	WHERE [Supplier] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[name]
WHEN NOT MATCHED THEN
	INSERT ([supplier_code], [supplier], [supplier_long],  [raw]) 
	VALUES (SRC.[code], SRC.[name], CONCAT(SRC.[code], ' - ', SRC.[name]), SRC.[name])
;


MERGE INTO [dbo].[business_unit] AS TGT
USING (
	SELECT DISTINCT
		[Business Unit] as [data_value]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([business_unit], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[location] AS TGT
USING (
	SELECT DISTINCT
		LEFT([Country], CHARINDEX('|', [Country] + '|') - 1) as [location],
		CASE
			WHEN RIGHT([Country],CHARINDEX('|',REVERSE([Country]))-1) = 'USA'
			THEN 'Onshore'
			WHEN RIGHT([Country],CHARINDEX('|',REVERSE([Country]))-1) IN ('CAN', 'MEX')
			THEN 'Nearshore'
			ELSE 'Offshore'
		END as locale,
		[Country] as [raw]
	FROM [staging].[work_order_detail]
	WHERE [Country] is not null
) AS SRC
ON TGT.[raw] = SRC.[raw]
WHEN NOT MATCHED THEN
	INSERT ([location], [local], [raw]) 
	VALUES (SRC.[location], SRC.locale, SRC.[raw])
;


-- SELECT * FROM  [dbo].[company_code]

MERGE INTO [dbo].[company_code] AS TGT
USING (
	SELECT DISTINCT
		[Company Code] as [data_value]
	FROM [staging].[work_order_detail]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([company_code], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[cost_object_code]  AS TGT
USING (
	SELECT DISTINCT
		[Cost Object Code] as [code]
	FROM [staging].[work_order_detail]
	WHERE [Cost Object Code] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[code]
WHEN NOT MATCHED THEN
	INSERT ([cost_object_code], [is_opex], [raw]) 
	VALUES (SRC.[code], IIF(LEFT(SRC.[code], 2) = 'FG', 1, 0), SRC.[code])
;




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
	IIF(wod.[Current Bill Rate ST Hr [ST/Hr]]] IS NULL, '0.0', wod.[Current Bill Rate ST Hr [ST/Hr]]]) as [current_bill_rate],
	IIF(wod.[Hours per Week] IS NULL, '0.0', wod.[Hours per Week]) as [hours_per_week],
	IIF(wod.[Hours per Day] IS NULL, '0.0', wod.[Hours per Day]) as [hours_per_day],
	IIF(wod.[Allocation %] IS NULL, '0.0', wod.[Allocation %]) as [allocation_percentage],
	IIF(wod.[Cumulative Committed Spend] IS NULL, '0.0', wod.[Cumulative Committed Spend]) as [cumulative_committed_spend],
	IIF(wod.[Spend to Date] IS NULL, '0.0', wod.[Spend to Date]) as [spend_to_date],
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
CREATE CLUSTERED INDEX idx_work_order_composite ON #TMP_WORK_ORDER ([work_order_composite]);

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