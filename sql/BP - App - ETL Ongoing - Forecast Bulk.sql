USE [TEST]
;

--USE [PLANNING_APP]
--;


DROP PROCEDURE IF EXISTS [dbo].[sp_etl_bulk_forecast];
GO
CREATE PROCEDURE [dbo].[sp_etl_bulk_forecast]
AS
BEGIN
SET NOCOUNT ON;


MERGE INTO [dbo].[company_code] AS TGT
USING (
	SELECT DISTINCT
		CASE
			WHEN CHARINDEX('.', [Company Code]) > 0 
			THEN RTRIM(LEFT([Company Code], CHARINDEX('.', [Company Code]) - 1))
			ELSE [Company Code]
		END as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Company Code] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([company_code], [company_description], [company_type], [legal_entity_name], [raw]) 
	VALUES (SRC.data_value, NULL, NULL, NULL, SRC.data_value)
;


MERGE INTO [dbo].[cost_center_code] AS TGT
USING (
	SELECT DISTINCT
		CASE
			WHEN CHARINDEX('.', b.[Cost Center Code]) > 0 
			THEN RTRIM(LEFT(b.[Cost Center Code], CHARINDEX('.', b.[Cost Center Code]) - 1))
			ELSE b.[Cost Center Code]
		END as [code],
		NULL as [name],
		IIF(cc.[company_code_id] IS NULL, 0, cc.[company_code_id]) as [company_code_id],
		RIGHT(LEFT(b.[Cost Center Code], 7), 4) as [entity_code],
		CASE
			WHEN CHARINDEX('.', b.[Cost Center Code]) > 0 
			THEN RIGHT(RTRIM(LEFT(b.[Cost Center Code], CHARINDEX('.', b.[Cost Center Code]) - 1)), 3)
			ELSE RIGHT(b.[Cost Center Code], 3)
		END as [department_code]
	FROM [staging].[bulk_update_forecast] as b
	LEFT JOIN [dbo].[company_code] as cc
		ON LEFT(b.[Cost Center Code], 3) = cc.[raw]
	WHERE b.[Cost Center Code] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[code]
WHEN NOT MATCHED THEN
	INSERT ([cost_center_code], [cost_center], [company_code_id], [entity_code], [department_code], [raw]) 
	VALUES (SRC.[code], SRC.[name], SRC.[company_code_id], SRC.[entity_code], SRC.[department_code], SRC.[code])
;


MERGE INTO [dbo].[account] AS TGT
USING (
	SELECT DISTINCT
		CASE
			WHEN CHARINDEX('.', [Account Code]) > 0 
			THEN RTRIM(LEFT([Account Code], CHARINDEX('.', [Account Code]) - 1))
			ELSE [Account Code]
		END as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Account Code] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([account_code], [account_name], [pl_rollup_level_1], [pl_rollup_level_2], [raw]) 
	VALUES (SRC.data_value, NULL, NULL, NULL, SRC.data_value)
;


/**/


MERGE INTO [dbo].[business_unit] AS TGT
USING (
	SELECT DISTINCT
		[Business Unit] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Business Unit] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([business_unit], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[deptartment] AS TGT
USING (
	SELECT DISTINCT
		[Department] as [name_long],
		RTRIM(LEFT([Department], CHARINDEX('(', [Department]) - 1)) as [name],
		RTRIM(REPLACE(RIGHT([Department],NULLIF(CHARINDEX('(',REVERSE([Department])),0)-1), ')', '')) as [code]
	FROM [staging].[bulk_update_forecast] as b
	WHERE [Department] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[name]
WHEN NOT MATCHED THEN
	INSERT ([segmentation_id], [platform_id], [department_code], [department], [department_long], [raw]) 
	VALUES (0, 0, SRC.[code], SRC.[name], SRC.[name_long], SRC.[name])
;


MERGE INTO [dbo].[employee] AS TGT
USING (
	SELECT DISTINCT
		[Department Leader] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Department Leader] IS NOT NULL
	UNION
	SELECT DISTINCT
		[Team Leader] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Team Leader] IS NOT NULL
	UNION
	SELECT DISTINCT
		[Business Owner] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Business Owner] IS NOT NULL
	UNION
	SELECT DISTINCT
		[Primary Contact] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Primary Contact] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([employee], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[supplier] AS TGT
USING (
	SELECT DISTINCT
		[Supplier] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Supplier] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([supplier_code], [supplier], [supplier_long], [raw]) 
	VALUES (NULL, SRC.data_value, SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[contractor] AS TGT
USING (
	SELECT * FROM
	(SELECT DISTINCT
		[Worker ID] as worker_id,
		[PID] as pid,
		RIGHT([Contractor],CHARINDEX(',',REVERSE([Contractor]))-1) as first_name,
		LEFT([Contractor], CHARINDEX(',', [Contractor] + ',') - 1) as last_name,
		[Contractor] as full_name,
		CONCAT('Worker Site: ', [Site]) as worker_site,
		[Worker ID] as [raw],
		ROW_NUMBER() OVER (PARTITION BY [Worker ID] ORDER BY [PID]) AS dedupe
	FROM [staging].[bulk_update_forecast]
	WHERE [Worker ID] IS NOT NULL
	) AS t
	WHERE t.dedupe = 1
) AS SRC
ON TGT.[raw] = SRC.[raw]
WHEN NOT MATCHED THEN
	INSERT ([worker_id], [pid], [first_name], [last_name], [full_name], [worker_site], [raw]) 
	VALUES (SRC.worker_id, SRC.pid, SRC.first_name, SRC.last_name, SRC.full_name, SRC.worker_site, SRC.[raw])
;


MERGE INTO [dbo].[main_document_title] AS TGT
USING (
	SELECT DISTINCT
		[Main Document Title] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Main Document Title] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([main_document_title], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[cost_object_code]  AS TGT
USING (
	SELECT DISTINCT
		[Cost Object Code] as [code]
	FROM [staging].[bulk_update_forecast]
	WHERE [Cost Object Code] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[code]
WHEN NOT MATCHED THEN
	INSERT ([cost_object_code], [is_opex], [raw]) 
	VALUES (SRC.[code], IIF(LEFT(SRC.[code], 2) = 'FG', 1, 0), SRC.[code])
;


MERGE INTO [dbo].[location] AS TGT
USING (
	SELECT DISTINCT
		[Site] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Site] IS NOT NULL
) AS SRC
ON TGT.[location] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([location], [local], [raw]) 
	VALUES (SRC.data_value, 'Offshore', SRC.data_value)
;


MERGE INTO [dbo].[work_type] AS TGT
USING (
	SELECT DISTINCT
		[Work Type] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Work Type] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([work_type], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[worker_status] AS TGT
USING (
	SELECT DISTINCT
		[Worker Status] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Worker Status] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([worker_status], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[work_order_category] AS TGT
USING (
	SELECT DISTINCT
		[Work Order Category] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Work Order Category] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([work_order_category], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[expense_classification] AS TGT
USING (
	SELECT DISTINCT
		[Expense Classification] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Expense Classification] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([expense_classification], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[segmentation] AS TGT
USING (
	SELECT DISTINCT
		[Segmentation] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Segmentation] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([segmentation], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[platform] AS TGT
USING (
	SELECT DISTINCT
		[Platform] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Platform] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([platform], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[budget_code] AS TGT
USING (
	SELECT * FROM
		(SELECT DISTINCT
			[Budget Code] as [data_value],
			IIF(s.[segmentation_id] IS NULL, 0, s.[segmentation_id]) as [segmentation_id],
			IIF(p.[platform_id] IS NULL, 0, p.[platform_id]) as [platform_id], 
			ROW_NUMBER() OVER (PARTITION BY [Budget Code] ORDER BY [Budget Code], s.[segmentation_id], p.[platform_id]) AS dedupe
		FROM [staging].[bulk_update_forecast] as b
		LEFT JOIN [dbo].[segmentation] as s ON b.[Segmentation] = s.[raw]
		LEFT JOIN [dbo].[platform] as p ON b.[Platform] = p.[raw]
		WHERE [Budget Code] IS NOT NULL
		) as t
	WHERE dedupe = 1 
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([segmentation_id], [platform_id], [budget_code], [budget_name], [raw]) 
	VALUES (SRC.[segmentation_id], SRC.[platform_id], SRC.data_value, SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[function] AS TGT
USING (
	SELECT DISTINCT
		[Function] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Function] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([function], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[support_scalable] AS TGT
USING (
	SELECT DISTINCT
		[Support/Scalable] as [data_value]
	FROM [staging].[bulk_update_forecast]
	WHERE [Support/Scalable] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([support_scalable], [raw]) 
	VALUES (NULL, SRC.data_value)
;


DROP TABLE IF EXISTS #TMP_FORECAST_CLEANED;
SELECT
	CAST([Forecast ID] AS BIGINT) as [Forecast ID],
	CASE
		WHEN CHARINDEX('.', [Company Code]) > 0 
		THEN RTRIM(LEFT([Company Code], CHARINDEX('.', [Company Code]) - 1))
		ELSE [Company Code]
	END as [Company Code],
	[Business Unit],
	[Department] as [Department Long],
	RTRIM(LEFT([Department], CHARINDEX('(', [Department]) - 1)) as [Department],
	CAST(RTRIM(REPLACE(RIGHT([Department],NULLIF(CHARINDEX('(',REVERSE([Department])),0)-1), ')', '')) as VARCHAR(255)) as [Deparment Code],
	CASE
		WHEN CHARINDEX('.', [Cost Center Code]) > 0 
		THEN CAST(RTRIM(LEFT([Cost Center Code], CHARINDEX('.', [Cost Center Code]) - 1)) as VARCHAR(255))
		ELSE [Cost Center Code]
	END as [Cost Center Code],
	[Department Leader],
	[Team Leader],
	[Business Owner],
	[Primary Contact],
	[Supplier],
	[Worker ID],
	[Worker Start Date],
	[Worker End Date],
	[Override End Date],
	--CAST([Worker Start Date] as date) as [Worker Start Date],
	--CAST([Worker End Date] as date) as [Worker End Date],
	--CAST([Override End Date] as date) as [Override End Date],
	[Main Document Title],
	[Cost Object Code],
	[Site],
	CASE
		WHEN CHARINDEX('.', [Account Code]) > 0 
		THEN CAST(RTRIM(LEFT([Account Code], CHARINDEX('.', [Account Code]) - 1)) as VARCHAR(255))
		ELSE [Account Code]
	END as [Account Code],
	[Work Type],
	[Worker Status],
	[Work Order Category],
	[Expense Classification],
	[Budget Code],
	[Segmentation],
	[Platform],
	[Function],
	[Support/Scalable],
	[Work Order ID],
	[Description],
	CAST([Allocation] AS DECIMAL(10, 2)) as [Allocation],
	CAST([Current Bill Rate (Hr)] AS DECIMAL(10, 2)) as [Current Bill Rate (Hr)],
	CAST([Current Bill Rate (Day)] AS DECIMAL(10, 2)) as [Current Bill Rate (Day)],
	[Comment]
INTO #TMP_FORECAST_CLEANED
FROM [staging].[bulk_update_forecast]
--ORDER BY [Current Bill Rate (Day)]
;

CREATE NONCLUSTERED INDEX idx_forecast_id ON #TMP_FORECAST_CLEANED ([Forecast ID]);
CREATE NONCLUSTERED INDEX idx_cc ON #TMP_FORECAST_CLEANED ([Company Code]);
CREATE NONCLUSTERED INDEX idx_bu ON #TMP_FORECAST_CLEANED ([Business Unit]);
CREATE NONCLUSTERED INDEX idx_dl ON #TMP_FORECAST_CLEANED ([Department Long]);
CREATE NONCLUSTERED INDEX idx_d ON #TMP_FORECAST_CLEANED ([Department]);
CREATE NONCLUSTERED INDEX idx_dc ON #TMP_FORECAST_CLEANED ([Deparment Code]);
CREATE NONCLUSTERED INDEX idx_ccc ON #TMP_FORECAST_CLEANED ([Cost Center Code]);
CREATE NONCLUSTERED INDEX idx_dlead ON #TMP_FORECAST_CLEANED ([Department Leader]);
CREATE NONCLUSTERED INDEX idx_tlead ON #TMP_FORECAST_CLEANED ([Team Leader]);
CREATE NONCLUSTERED INDEX idx_bo ON #TMP_FORECAST_CLEANED ([Business Owner]);
CREATE NONCLUSTERED INDEX idx_pc ON #TMP_FORECAST_CLEANED ([Primary Contact]);
CREATE NONCLUSTERED INDEX idx_sup ON #TMP_FORECAST_CLEANED ([Supplier]);
CREATE NONCLUSTERED INDEX idx_workid ON #TMP_FORECAST_CLEANED ([Worker ID]);
CREATE NONCLUSTERED INDEX idx_mdt ON #TMP_FORECAST_CLEANED ([Main Document Title]);
CREATE NONCLUSTERED INDEX idx_coc ON #TMP_FORECAST_CLEANED ([Cost Object Code]);
CREATE NONCLUSTERED INDEX idx_s ON #TMP_FORECAST_CLEANED ([Site]);
CREATE NONCLUSTERED INDEX idx_ac ON #TMP_FORECAST_CLEANED ([Account Code]);
CREATE NONCLUSTERED INDEX idx_wt ON #TMP_FORECAST_CLEANED ([Work Type]);
CREATE NONCLUSTERED INDEX idx_ws ON #TMP_FORECAST_CLEANED ([Worker Status]);
CREATE NONCLUSTERED INDEX idx_wc ON #TMP_FORECAST_CLEANED ([Work Order Category]);
CREATE NONCLUSTERED INDEX idx_ec ON #TMP_FORECAST_CLEANED ([Expense Classification]);
CREATE NONCLUSTERED INDEX idx_bc ON #TMP_FORECAST_CLEANED ([Budget Code]);
CREATE NONCLUSTERED INDEX idx_seg ON #TMP_FORECAST_CLEANED ([Segmentation]);
CREATE NONCLUSTERED INDEX idx_p ON #TMP_FORECAST_CLEANED ([Platform]);
CREATE NONCLUSTERED INDEX idx_fun ON #TMP_FORECAST_CLEANED ([Function]);
CREATE NONCLUSTERED INDEX idx_ss ON #TMP_FORECAST_CLEANED ([Support/Scalable]);


TRUNCATE TABLE [staging].[bulk_update_forecast_cleansed];
INSERT INTO [staging].[bulk_update_forecast_cleansed]
           ([forecast_id]
           ,[company_code_id]
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
           ,[support_scalable_id]
           ,[work_order_id]
           ,[description]
           ,[allocation]
           ,[current_bill_rate_hr]
           ,[current_bill_rate_day]
           ,[comment]
           ,[action_flag]
           ,[reason])
SELECT
	t.[Forecast ID],
	IIF(c.[company_code_id] IS NULL, 0, c.[company_code_id]) as [company_code_id],
	IIF(bu.[business_unit_id] IS NULL, 0, bu.[business_unit_id]) as [business_unit_id],
	IIF(dept.[department_id] IS NULL, 0, dept.[department_id]) as [department_id],
	IIF(ccc.[cost_center_code_id] IS NULL, 0, ccc.[cost_center_code_id]) as [cost_center_code_id],
	IIF(dl.[employee_id] IS NULL, 0, dl.[employee_id]) as [department_leader_id],
	IIF(tl.[employee_id] IS NULL, 0, tl.[employee_id]) as [team_leader_id],
	IIF(bo.[employee_id] IS NULL, 0, bo.[employee_id]) as [business_owner_id],
	IIF(pc.[employee_id] IS NULL, 0, pc.[employee_id]) as [primary_contact_id],
	IIF(s.[supplier_id] IS NULL, 0, s.[supplier_id]) as [supplier_id],
	IIF(con.[contractor_id] IS NULL, 0, con.[contractor_id]) as [contractor_id],
	REPLACE(REPLACE([Worker Start Date], '-', ''), '/', '') as [worker_start_date_id],
	REPLACE(REPLACE([Worker End Date], '-', ''), '/', '') as [worker_end_date_id],
	REPLACE(REPLACE([Override End Date], '-', ''), '/', '') as [override_end_date_id],
	IIF(mdt.[main_document_title_id] IS NULL, 0, mdt.[main_document_title_id]) as [main_document_title_id],
	IIF(coc.[cost_object_code_id] IS NULL, 0, coc.[cost_object_code_id]) as [cost_object_code_id],
	IIF(l.[location_id] IS NULL, 0, l.[location_id]) as [location_id],
	IIF(a.[account_id] IS NULL, 0, a.[account_id]) as [account_code_id],
	IIF(wt.[work_type_id] IS NULL, 0, wt.[work_type_id]) as [work_type_id],
	IIF(ws.[worker_status_id] IS NULL, 0, ws.[worker_status_id]) as [worker_status_id],
	IIF(woc.[work_order_category_id] IS NULL, 0, woc.[work_order_category_id]) as [work_order_category_id],
	IIF(ec.[expense_classification_id] IS NULL, 0, ec.[expense_classification_id]) as [expense_classification_id],
	IIF(bc.[budget_code_id] IS NULL, 0, bc.[budget_code_id]) as [budget_code_id],
	IIF(seg.[segmentation_id] IS NULL, 0, seg.[segmentation_id]) as [segmentation_id],
	IIF(p.[platform_id] IS NULL, 0, p.[platform_id]) as [platform_id],
	IIF(fun.[function_id] IS NULL, 0, fun.[function_id]) as [function_id],
	IIF(ss.[support_scalable_id] IS NULL, 0, ss.[support_scalable_id]) as [support_scalable_id],
	t.[Work Order ID] as [work_order_id],
	t.[Description] as [description],
	t.[Allocation] as [allocation],
	t.[Current Bill Rate (Hr)] as [current_bill_rate_hr],
	t.[Current Bill Rate (Day)] as [current_bill_rate_day],
	t.[Comment] as [comment],
	CASE
		WHEN f.[forecast_id] IS NULL -- seen as new
		THEN 'I' -- insert
		WHEN f.[company_code_id] != IIF(c.[company_code_id] IS NULL, 0, c.[company_code_id])
		THEN 'U' -- update
		WHEN f.[business_unit_id] != IIF(bu.[business_unit_id] IS NULL, 0, bu.[business_unit_id])
		THEN 'U' -- update
		WHEN f.[department_id] != IIF(dept.[department_id] IS NULL, 0, dept.[department_id])
		THEN 'U' -- update
		WHEN f.[cost_center_code_id] != IIF(ccc.[cost_center_code_id] IS NULL, 0, ccc.[cost_center_code_id])
		THEN 'U' -- update
		WHEN f.[department_leader_id] != IIF(dl.[employee_id] IS NULL, 0, dl.[employee_id])
		THEN 'U' -- update
		WHEN f.[team_leader_id] != IIF(tl.[employee_id] IS NULL, 0, tl.[employee_id])
		THEN 'U' -- update
		WHEN f.[business_owner_id] != IIF(bo.[employee_id] IS NULL, 0, bo.[employee_id])
		THEN 'U' -- update
		WHEN f.[primary_contact_id] != IIF(pc.[employee_id] IS NULL, 0, pc.[employee_id])
		THEN 'U' -- update
		WHEN f.[supplier_id] != IIF(s.[supplier_id] IS NULL, 0, s.[supplier_id])
		THEN 'U' -- update
		WHEN f.[contractor_id] != IIF(con.[contractor_id] IS NULL, 0, con.[contractor_id])
		THEN 'U' -- update
		WHEN f.[worker_start_date_id] != REPLACE(REPLACE([Worker Start Date], '-', ''), '/', '')
		THEN 'U' -- update
		WHEN f.[worker_end_date_id] != REPLACE(REPLACE([Worker End Date], '-', ''), '/', '')
		THEN 'U' -- update
		WHEN f.[override_end_date_id] != REPLACE(REPLACE([Override End Date], '-', ''), '/', '') 
		THEN 'U' -- update
		WHEN f.[main_document_title_id] != IIF(mdt.[main_document_title_id] IS NULL, 0, mdt.[main_document_title_id])
		THEN 'U' -- update
		WHEN f.[cost_object_code_id] != IIF(coc.[cost_object_code_id] IS NULL, 0, coc.[cost_object_code_id])
		THEN 'U' -- update
		WHEN f.[site_id] != IIF(l.[location_id] IS NULL, 0, l.[location_id])
		THEN 'U' -- update
		WHEN f.[account_code_id] != IIF(a.[account_id] IS NULL, 0, a.[account_id])
		THEN 'U' -- update
		WHEN f.[work_type_id] != IIF(wt.[work_type_id] IS NULL, 0, wt.[work_type_id])
		THEN 'U' -- update
		WHEN f.[worker_status_id] != IIF(ws.[worker_status_id] IS NULL, 0, ws.[worker_status_id])
		THEN 'U' -- update
		WHEN f.[work_order_category_id] != IIF(woc.[work_order_category_id] IS NULL, 0, woc.[work_order_category_id])
		THEN 'U' -- update
		WHEN f.[expense_classification_id] != IIF(ec.[expense_classification_id] IS NULL, 0, ec.[expense_classification_id])
		THEN 'U' -- update
		WHEN f.[budget_code_id] != IIF(bc.[budget_code_id] IS NULL, 0, bc.[budget_code_id])
		THEN 'U' -- update
		WHEN f.[segmentation_id] != IIF(seg.[segmentation_id] IS NULL, 0, seg.[segmentation_id]) 
		THEN 'U' -- update
		WHEN f.[platform_id] != IIF(p.[platform_id] IS NULL, 0, p.[platform_id])
		THEN 'U' -- update
		WHEN f.[function_id] != IIF(fun.[function_id] IS NULL, 0, fun.[function_id])
		THEN 'U' -- update
		WHEN f.[support_scalable_id] != IIF(ss.[support_scalable_id] IS NULL, 0, ss.[support_scalable_id])
		THEN 'U' -- update
		WHEN f.[work_order_id] != t.[Work Order ID]
		THEN 'U' -- update
		WHEN f.[description] != t.[Description]
		THEN 'U' -- update
		WHEN f.[allocation] != t.[Allocation]
		THEN 'U' -- update
		WHEN f.[current_bill_rate_hr] != t.[Current Bill Rate (Hr)]
		THEN 'U' -- update
		WHEN f.[current_bill_rate_day] != t.[Current Bill Rate (Day)]
		THEN 'U' -- update
		WHEN f.[comment] != t.[Comment]
		THEN 'U' -- update
		ELSE 'N' -- nothing
	END as action_flag,
	CASE
		WHEN f.[forecast_id] IS NULL -- seen as new
		THEN 'New' -- insert
		WHEN f.[company_code_id] != IIF(c.[company_code_id] IS NULL, 0, c.[company_code_id])
		THEN 'Company Code' -- update
		WHEN f.[business_unit_id] != IIF(bu.[business_unit_id] IS NULL, 0, bu.[business_unit_id])
		THEN 'Business Unit' -- update
		WHEN f.[department_id] != IIF(dept.[department_id] IS NULL, 0, dept.[department_id])
		THEN 'Dept' -- update
		WHEN f.[cost_center_code_id] != IIF(ccc.[cost_center_code_id] IS NULL, 0, ccc.[cost_center_code_id])
		THEN 'Cost Center Code' -- update
		WHEN f.[department_leader_id] != IIF(dl.[employee_id] IS NULL, 0, dl.[employee_id])
		THEN 'Dept Leader' -- update
		WHEN f.[team_leader_id] != IIF(tl.[employee_id] IS NULL, 0, tl.[employee_id])
		THEN 'Team Leader' -- update
		WHEN f.[business_owner_id] != IIF(bo.[employee_id] IS NULL, 0, bo.[employee_id])
		THEN 'Business Owner' -- update
		WHEN f.[primary_contact_id] != IIF(pc.[employee_id] IS NULL, 0, pc.[employee_id])
		THEN 'Primary Contact' -- update
		WHEN f.[supplier_id] != IIF(s.[supplier_id] IS NULL, 0, s.[supplier_id])
		THEN 'Supplier' -- update
		WHEN f.[contractor_id] != IIF(con.[contractor_id] IS NULL, 0, con.[contractor_id])
		THEN 'Contractor' -- update
		WHEN f.[worker_start_date_id] != REPLACE(REPLACE([Worker Start Date], '-', ''), '/', '')
		THEN 'Worker Start Date' -- update
		WHEN f.[worker_end_date_id] != REPLACE(REPLACE([Worker End Date], '-', ''), '/', '')
		THEN 'Worker End Date' -- update
		WHEN f.[override_end_date_id] != REPLACE(REPLACE([Override End Date], '-', ''), '/', '') 
		THEN 'Override End Date' -- update
		WHEN f.[main_document_title_id] != IIF(mdt.[main_document_title_id] IS NULL, 0, mdt.[main_document_title_id])
		THEN 'Main Doc Title' -- update
		WHEN f.[cost_object_code_id] != IIF(coc.[cost_object_code_id] IS NULL, 0, coc.[cost_object_code_id])
		THEN 'Cost Object Code' -- update
		WHEN f.[site_id] != IIF(l.[location_id] IS NULL, 0, l.[location_id])
		THEN 'Site' -- update
		WHEN f.[account_code_id] != IIF(a.[account_id] IS NULL, 0, a.[account_id])
		THEN 'Account Code' -- update
		WHEN f.[work_type_id] != IIF(wt.[work_type_id] IS NULL, 0, wt.[work_type_id])
		THEN 'Work Type' -- update
		WHEN f.[worker_status_id] != IIF(ws.[worker_status_id] IS NULL, 0, ws.[worker_status_id])
		THEN 'Worker Status' -- update
		WHEN f.[work_order_category_id] != IIF(woc.[work_order_category_id] IS NULL, 0, woc.[work_order_category_id])
		THEN 'Work Order Category' -- update
		WHEN f.[expense_classification_id] != IIF(ec.[expense_classification_id] IS NULL, 0, ec.[expense_classification_id])
		THEN 'Expense Classification' -- update
		WHEN f.[budget_code_id] != IIF(bc.[budget_code_id] IS NULL, 0, bc.[budget_code_id])
		THEN 'Budget Code' -- update
		WHEN f.[segmentation_id] != IIF(seg.[segmentation_id] IS NULL, 0, seg.[segmentation_id]) 
		THEN 'Segmentation' -- update
		WHEN f.[platform_id] != IIF(p.[platform_id] IS NULL, 0, p.[platform_id])
		THEN 'Platform' -- update
		WHEN f.[function_id] != IIF(fun.[function_id] IS NULL, 0, fun.[function_id])
		THEN 'Function' -- update
		WHEN f.[support_scalable_id] != IIF(ss.[support_scalable_id] IS NULL, 0, ss.[support_scalable_id])
		THEN 'Support/Scalable' -- update
		WHEN f.[work_order_id] != t.[Work Order ID]
		THEN 'Work Order ID' -- update
		WHEN f.[description] != t.[Description]
		THEN 'Description' -- update
		WHEN f.[allocation] != t.[Allocation]
		THEN 'Allocation' -- update
		WHEN f.[current_bill_rate_hr] != t.[Current Bill Rate (Hr)]
		THEN 'Bill Rate HR' -- update
		WHEN f.[current_bill_rate_day] != t.[Current Bill Rate (Day)]
		THEN 'Bill Rate DAY' -- update
		WHEN f.[comment] != t.[Comment]
		THEN 'Comment' -- update
		ELSE NULL -- nothing
	END as reason
FROM #TMP_FORECAST_CLEANED as t
LEFT JOIN [dbo].[forecast] as f ON t.[Forecast ID] = f.[forecast_id]
LEFT JOIN [dbo].[company_code] as c ON t.[Company Code] = c.[raw]
LEFT JOIN [dbo].[business_unit] as bu ON t.[Business Unit] = bu.[raw]
LEFT JOIN [dbo].[deptartment] as dept ON t.[Department] = dept.[raw]
LEFT JOIN [dbo].[cost_center_code] as ccc ON t.[Cost Center Code] = ccc.[raw]
LEFT JOIN [dbo].[employee] as dl ON t.[Department Leader] = dl.[raw]
LEFT JOIN [dbo].[employee] as tl ON t.[Team Leader] = tl.[raw]
LEFT JOIN [dbo].[employee] as bo ON t.[Business Owner] = bo.[raw]
LEFT JOIN [dbo].[employee] as pc ON t.[Primary Contact] = pc.[raw]
LEFT JOIN [dbo].[supplier] as s ON t.[Supplier] = s.[raw]
LEFT JOIN [dbo].[contractor] as con ON t.[Worker ID] = con.[raw]
LEFT JOIN [dbo].[main_document_title] as mdt ON t.[Main Document Title] = mdt.[raw]
LEFT JOIN [dbo].[cost_object_code] as coc ON t.[Cost Object Code] = coc.[raw]
LEFT JOIN [dbo].[location] as l ON t.[Site] = l.[location]
LEFT JOIN [dbo].[account] as a ON t.[Account Code] = a.[raw]
LEFT JOIN [dbo].[work_type] as wt ON t.[Work Type] = wt.[raw]
LEFT JOIN [dbo].[worker_status] as ws ON t.[Worker Status] = ws.[raw]
LEFT JOIN [dbo].[work_order_category] as woc ON t.[Work Order Category] = woc.[raw]
LEFT JOIN [dbo].[expense_classification] as ec ON t.[Expense Classification] = ec.[raw]
LEFT JOIN [dbo].[budget_code] as bc ON t.[Budget Code] = bc.[raw]
LEFT JOIN [dbo].[segmentation] as seg ON t.[Segmentation] = seg.[raw]
LEFT JOIN [dbo].[platform] as p ON t.[Platform] = p.[raw]
LEFT JOIN [dbo].[function] as fun ON t.[Function] = fun.[raw]
LEFT JOIN [dbo].[support_scalable] as ss ON t.[Support/Scalable] = ss.[raw]
;


-- insert all the records after determining if we update/insert/do nothing
INSERT INTO [audit].[etl_bulk_edits]
           ([bulk_edit_job]
           ,[table_updating]
           ,[action_flag]
           ,[reason]
		   )
SELECT 
	'bulk_update_forecast', -- [bulk_edit_job]
	'[dbo].[forecast]', -- [bulk_edit_job]
	[action_flag],
	[reason]
FROM [staging].[bulk_update_forecast_cleansed]
;


MERGE INTO [dbo].[forecast] AS TGT
USING 
(
SELECT 
	 [forecast_id]
	,[company_code_id]
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
	,[support_scalable_id]
	,[work_order_id]
	,[description]
	,[allocation]
	,[current_bill_rate_hr]
	,[current_bill_rate_day]
	,[comment]
FROM [staging].[bulk_update_forecast_cleansed]
WHERE [action_flag] IN ('I', 'U')
) AS SRC
ON TGT.[forecast_id] = SRC.[forecast_id]
WHEN MATCHED THEN UPDATE SET
	TGT.[company_code_id] = SRC.[company_code_id],
	TGT.[business_unit_id] = SRC.[business_unit_id],
	TGT.[department_id] = SRC.[department_id],
	TGT.[cost_center_code_id] = SRC.[cost_center_code_id],
	TGT.[department_leader_id] = SRC.[department_leader_id],
	TGT.[team_leader_id] = SRC.[team_leader_id],
	TGT.[business_owner_id] = SRC.[business_owner_id],
	TGT.[primary_contact_id] = SRC.[primary_contact_id],
	TGT.[supplier_id] = SRC.[supplier_id],
	TGT.[contractor_id] = SRC.[contractor_id],
	TGT.[worker_start_date_id] = SRC.[worker_start_date_id],
	TGT.[worker_end_date_id] = SRC.[worker_end_date_id],
	TGT.[override_end_date_id] = SRC.[override_end_date_id],
	TGT.[main_document_title_id] = SRC.[main_document_title_id],
	TGT.[cost_object_code_id] = SRC.[cost_object_code_id],
	TGT.[site_id] = SRC.[site_id],
	TGT.[account_code_id] = SRC.[account_code_id],
	TGT.[work_type_id] = SRC.[work_type_id],
	TGT.[worker_status_id] = SRC.[worker_status_id],
	TGT.[work_order_category_id] = SRC.[work_order_category_id],
	TGT.[expense_classification_id] = SRC.[expense_classification_id],
	TGT.[budget_code_id] = SRC.[budget_code_id],
	TGT.[segmentation_id] = SRC.[segmentation_id],
	TGT.[platform_id] = SRC.[platform_id],
	TGT.[function_id] = SRC.[function_id],
	TGT.[support_scalable_id] = SRC.[support_scalable_id],
	TGT.[work_order_id] = SRC.[work_order_id],
	TGT.[description] = SRC.[description],
	TGT.[allocation] = SRC.[allocation],
	TGT.[current_bill_rate_hr] = SRC.[current_bill_rate_hr],
	TGT.[current_bill_rate_day] = SRC.[current_bill_rate_day],
	TGT.[comment] = SRC.[comment],
	TGT.[updated_by] = CURRENT_USER,
	TGT.[updated_date] = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
	INSERT (
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
	,[support_scalable_id]
	,[work_order_id]
	,[description]
	,[allocation]
	,[current_bill_rate_hr]
	,[current_bill_rate_day]
	,[comment]
	,[is_deleted]
	,[created_by]
	,[created_date]
	,[updated_by]
	,[updated_date]
	) 
	VALUES (
	 SRC.[company_code_id]
	,SRC.[business_unit_id]
	,SRC.[department_id]
	,SRC.[cost_center_code_id]
	,SRC.[department_leader_id]
	,SRC.[team_leader_id]
	,SRC.[business_owner_id]
	,SRC.[primary_contact_id]
	,SRC.[supplier_id]
	,SRC.[contractor_id]
	,SRC.[worker_start_date_id]
	,SRC.[worker_end_date_id]
	,SRC.[override_end_date_id]
	,SRC.[main_document_title_id]
	,SRC.[cost_object_code_id]
	,SRC.[site_id]
	,SRC.[account_code_id]
	,SRC.[work_type_id]
	,SRC.[worker_status_id]
	,SRC.[work_order_category_id]
	,SRC.[expense_classification_id]
	,SRC.[budget_code_id]
	,SRC.[segmentation_id]
	,SRC.[platform_id]
	,SRC.[function_id]
	,SRC.[support_scalable_id]
	,SRC.[work_order_id]
	,SRC.[description]
	,SRC.[allocation]
	,SRC.[current_bill_rate_hr]
	,SRC.[current_bill_rate_day]
	,SRC.[comment]
	,0 -- is_deleted
	,CURRENT_USER
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,CURRENT_TIMESTAMP
	)
;

END
;