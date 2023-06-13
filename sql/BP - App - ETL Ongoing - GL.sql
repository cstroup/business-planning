USE TEST
GO

-- GL

DROP PROCEDURE IF EXISTS [dbo].[sp_etl_general_ledger];
GO
CREATE PROCEDURE [dbo].[sp_etl_general_ledger]
AS
BEGIN
    SET NOCOUNT ON;

MERGE INTO [dbo].[journal_entry_type] AS TGT
USING (
	SELECT DISTINCT
		[Journal Entry Type] as [data_value]
	FROM [staging].[sap_general_ledger]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([journal_entry_type], [journal_entry_type_description], [raw]) 
	VALUES (SRC.data_value, SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[assignment_reference] AS TGT
USING (
	SELECT DISTINCT
		[Assignment Reference] as [data_value]
	FROM [staging].[sap_general_ledger]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([assignment_reference], [assignment_reference_description], [raw]) 
	VALUES (SRC.data_value, SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[company_code] AS TGT
USING (
	SELECT DISTINCT
		[Company Code] as [data_value]
	FROM [staging].[sap_general_ledger]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([company_code], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;


MERGE INTO [dbo].[account] AS TGT
USING (
	SELECT DISTINCT
		[G/L Account] as [data_value]
	FROM [staging].[sap_general_ledger]
) AS SRC
ON TGT.[raw] = SRC.data_value
WHEN NOT MATCHED THEN
	INSERT ([account_code], [raw]) 
	VALUES (SRC.data_value, SRC.data_value)
;

-- SELECT * FROM [dbo].[deptartment]

MERGE INTO [dbo].[deptartment] AS TGT
USING (
	SELECT DISTINCT
		[Dept (Derv)] as [code],
		[Dept Name (Derv)] as [name]
	FROM [staging].[sap_general_ledger]
) AS SRC
ON TGT.[raw] = SRC.[name]
WHEN NOT MATCHED THEN
	INSERT ([department_code], [department], [department_long], [raw]) 
	VALUES (SRC.[code], SRC.[name], CONCAT(SRC.[name], ' (', SRC.[code], ')'), SRC.[name])
;

-- SELECT * FROM [dbo].[cost_center_code]
-- SELECT * FROM [dbo].[company_code]
-- SELECT * FROM [dbo].[entity]

MERGE INTO [dbo].[cost_center_code] AS TGT
USING (
	SELECT DISTINCT
		gl.[Cost Center (Derv)] AS [code],
		gl.[CC Name (Derv)] as [name],
		IIF(cc.[company_code_id] IS NULL, 0, cc.[company_code_id]) as [company_code_id],
		RIGHT(LEFT(gl.[Cost Center (Derv)], 7), 4) as [entity_code],
		RIGHT(gl.[Cost Center (Derv)], 3) as [department_code]
	FROM [staging].[sap_general_ledger] as gl
	LEFT JOIN [dbo].[company_code] as cc
		ON LEFT(gl.[Cost Center (Derv)], 3) = cc.[raw]
) AS SRC
ON TGT.[raw] = SRC.[code]
WHEN NOT MATCHED THEN
	INSERT ([cost_center_code], [cost_center], [company_code_id], [entity_code], [department_code], [raw]) 
	VALUES (SRC.[code], SRC.[name], SRC.[company_code_id], SRC.[entity_code], SRC.[department_code], SRC.[code])
;
-- SELECT * FROM [dbo].[cost_object_code]

MERGE INTO [dbo].[cost_object_code]  AS TGT
USING (
	SELECT DISTINCT
		[WBS Element] as [code],
		[WBS Name] as [name]
	FROM [staging].[sap_general_ledger]
	WHERE [WBS Element] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[code]
WHEN NOT MATCHED THEN
	INSERT ([cost_object_code], [cost_object_name], [is_opex], [raw]) 
	VALUES (SRC.[code], SRC.[name], IIF(LEFT(SRC.[code], 2) = 'FG', 1, 0), SRC.[code])
;

-- SELECT * FROM [dbo].[project]

MERGE INTO [dbo].[project]  AS TGT
USING (
	SELECT DISTINCT
		[Project] as [code],
		[Project Name] as [name]
	FROM [staging].[sap_general_ledger]
	WHERE [Project] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[code]
WHEN NOT MATCHED THEN
	INSERT ([project], [project_name], [raw]) 
	VALUES (SRC.[code], SRC.[name], SRC.[code])
;

-- SELECT * FROM [dbo].[project_type]

MERGE INTO [dbo].[project_type] AS TGT
USING (
	SELECT DISTINCT
		[Project Type] as [code],
		[Proj Typ Name] as [name]
	FROM [staging].[sap_general_ledger]
	WHERE [Project Type] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[code]
WHEN NOT MATCHED THEN
	INSERT ([project_type], [project_type_description], [raw]) 
	VALUES (SRC.[code], SRC.[name], SRC.[code])
;

-- SELECT * FROM [dbo].[supplier]

MERGE INTO [dbo].[supplier] AS TGT
USING (
	SELECT DISTINCT
		LEFT([Supplier], CHARINDEX('.', [Supplier]) - 1) as [code],
		[Supplier Name] as [name]
	FROM [staging].[sap_general_ledger]
	WHERE [Supplier] IS NOT NULL
) AS SRC
ON TGT.[raw] = SRC.[name]
WHEN NOT MATCHED THEN
	INSERT ([supplier_code], [supplier], [supplier_long],  [raw]) 
	VALUES (SRC.[code], SRC.[name], CONCAT(SRC.[code], ' - ', SRC.[name]), SRC.[name])
;




DROP TABLE IF EXISTS #TMP_GL;
SELECT DISTINCT
	IIF(je_date.[date_id] IS NULL, 0, je_date.[date_id]) as [journal_entry_date_id],
	IIF(post_date.[date_id] IS NULL, 0, post_date.[date_id]) as [posting_date_id],
	IIF(jet.[journal_entry_type_id] IS NULL, 0, jet.[journal_entry_type_id]) as [journal_entry_type_id],
	IIF(ar.[assignment_reference_id] IS NULL, 0, ar.[assignment_reference_id]) as [assignment_reference_id],
	IIF(a.[account_id] IS NULL, 0, a.[account_id]) as [account_id],
	IIF(d.[department_id] IS NULL, 0, d.[department_id]) as [department_id],
	IIF(pc.[profit_center_id] IS NULL, 0, pc.[profit_center_id]) as [profit_center_id],
	IIF(ccc.[cost_center_code_id] IS NULL, 0, ccc.[cost_center_code_id]) as [cost_center_code_id],
	IIF(coc.[cost_object_code_id] IS NULL, 0, coc.[cost_object_code_id]) as [wbs_code_id],
	IIF(pt.[project_type_id] IS NULL, 0, pt.[project_type_id]) as [project_type_id],
	IIF(p.[project_id] IS NULL, 0, p.[project_id]) as [project_id],
	IIF(supe.[supplier_id] IS NULL, 0, supe.[supplier_id]) as [supplier_id],
	CASE
		-- need to figure out other gl account codes
		-- all gl account codes of 5 are the same
		WHEN gl.[G/L Account] LIKE '5%'
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Direct') -- always OPEX
		-- this is definitely a contractor
		WHEN gl.[G/L Account] LIKE '6%' 
			AND LEFT(UPPER(gl.[WBS Element]), 1) = 'P' 
			AND gl.[Header Text] LIKE 'CHTRIN%'
			AND gl.[G/L Account] IN ('64019999', '61520000')
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Indirect - Contractors (CAPEX)')
		-- same as above but without the invoice character; IN contract labor accounts
		WHEN gl.[G/L Account] LIKE '6%' 
			AND LEFT(UPPER(gl.[WBS Element]), 1) = 'P' 
			AND gl.[G/L Account] IN ('64019999', '61520000')
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Indirect - Contractors (CAPEX)')
		-- p code with the text of cap short for capital expense; NOT in contract labor accounts
		WHEN gl.[G/L Account] LIKE '6%'
			AND LEFT(UPPER(gl.[WBS Element]), 1) = 'P' 
			AND LOWER(gl.[Header Text]) LIKE '%cap%'
			AND gl.[G/L Account] NOT IN ('64019999', '61520000')
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Indirect - CAPEX')
		-- less specific than above for accounts starting with 6
		WHEN gl.[G/L Account] LIKE '6%' 
			AND LEFT(UPPER(gl.[WBS Element]), 1) = 'P' 
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Indirect - CAPEX')
		-- fg wbs element and still accounts starting with 6
		WHEN gl.[G/L Account] LIKE '6%' 
			AND LEFT(UPPER(gl.[WBS Element]), 2) = 'FG'
			AND gl.[G/L Account] IN ('64019999', '61520000')
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Indirect - Contractors (OPEX)')
		-- essentially everything not p codes and not fg codes
		WHEN gl.[G/L Account] LIKE '6%' 
			AND LEFT(UPPER(gl.[WBS Element]), 1) != 'P'
			AND LEFT(UPPER(gl.[WBS Element]), 2) != 'FG'
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Indirect - OPEX')
		WHEN gl.[G/L Account] LIKE '6%' 
			AND gl.[WBS Element] IS NULL
		THEN (SELECT MIN(expense_type_id) FROM [dbo].[expense_type] WHERE [raw] = 'Indirect - OPEX')
		ELSE 0
	END as [expense_type_id],
	NULL as [forecast_id],
	NULL as [auto_tag_id],
	gl.[Amount] as [actual_amount],
	LEFT(gl.[Purchasing Document], CHARINDEX('.', gl.[Purchasing Document] + '.') - 1) as [purchase_order_number],
	CONCAT(gl.[Cost Center (Derv)], '-', gl.[G/L Account], '-', LEFT(gl.[Purchasing Document], CHARINDEX('.', gl.[Purchasing Document] + '.') - 1)) as [po_composite],
	CAST(CONCAT(LEFT(gl.[Purchasing Document], CHARINDEX('.', gl.[Purchasing Document] + '.') - 1), '-', gl.[WBS Element]) AS VARCHAR(250)) as [po_cost_object_composite],
	gl.[Header Text] as [header_text],
	gl.[Item Text] as [item_text],
	gl.[Journal Entry Created By] as [journal_entry_created_by],
 	gl.[Journal Entry] as [journal_entry],
	gl.[Journal Entry Item] as [journal_entry_item],
		CAST(CONCAT(RIGHT(REPLICATE('0', 20) + CAST([Journal Entry] AS VARCHAR(20)), 20), '-', 
		RIGHT(REPLICATE('0', 10) + CAST([Journal Entry Item] AS VARCHAR(10)), 10)) AS VARCHAR(250)) as [journal_entry_composite],
	NULL as [comment],
	0 as [is_deleted],
	CURRENT_USER AS [created_by],
	CURRENT_TIMESTAMP AS [created_date],
	CURRENT_USER AS [updated_by],
	CURRENT_TIMESTAMP AS [updated_date]
INTO #TMP_GL
FROM [staging].[sap_general_ledger] as gl
LEFT JOIN [dbo].[date_dimension] as je_date
	ON CONVERT(DATE, gl.[Journal Entry Date], 23) = je_date.[full_date]
LEFT JOIN [dbo].[date_dimension] as post_date
	ON CONVERT(DATE, gl.[Posting Date], 23) = post_date.[full_date]
LEFT JOIN [dbo].[journal_entry_type] as jet
	ON gl.[Journal Entry Type] = jet.[raw]
LEFT JOIN [dbo].[assignment_reference] as ar
	ON gl.[Assignment Reference] = ar.[raw]
LEFT JOIN [dbo].[account] as a
	ON gl.[G/L Account] = a.[raw]
LEFT JOIN [dbo].[deptartment] as d
	ON gl.[Dept Name (Derv)] = d.[raw]
LEFT JOIN [dbo].[profit_center] as pc
	ON gl.[PC Name] = pc.[raw]
LEFT JOIN [dbo].[cost_center_code] as ccc
	ON gl.[Cost Center (Derv)] = ccc.[raw]
LEFT JOIN [dbo].[cost_object_code] as coc
	ON gl.[WBS Element] = coc.[raw]
LEFT JOIN [dbo].[project_type] as pt 
	ON gl.[Project Type] = pt.[raw]
LEFT JOIN [dbo].[project] as p
	ON gl.[Project] = p.[raw]
LEFT JOIN [dbo].[supplier] as supe
	ON gl.[Supplier Name] = supe.[raw]
--ORDER BY je_date.[full_date], [journal_entry_composite]
;

CREATE CLUSTERED INDEX idx_journal_entry_composite ON #TMP_GL ([journal_entry_composite]);

--SELECT * FROM #TMP_GL

MERGE INTO [dbo].[general_ledger] AS PRD
USING #TMP_GL AS TMP
	ON PRD.[journal_entry_composite] = TMP.[journal_entry_composite]
WHEN MATCHED THEN
  UPDATE SET
  PRD.[updated_by] = CURRENT_USER,
  PRD.[updated_date] = CURRENT_TIMESTAMP,
  PRD.[supplier_id] = TMP.[supplier_id]
WHEN NOT MATCHED THEN
  INSERT (  [journal_entry_date_id]
           ,[posting_date_id]
           ,[journal_entry_type_id]
           ,[assignment_reference_id]
           ,[account_id]
           ,[department_id]
           ,[profit_center_id]
           ,[cost_center_code_id]
           ,[wbs_code_id]
           ,[project_type_id]
           ,[project_id]
           ,[supplier_id]
           ,[expense_type_id]
           ,[forecast_id]
           ,[auto_tag_id]
           ,[actual_amount]
           ,[purchase_order_number]
           ,[po_composite]
		   ,[po_cost_object_composite]
           ,[header_text]
           ,[item_text]
           ,[journal_entry_created_by]
           ,[journal_entry]
           ,[journal_entry_item]
           ,[journal_entry_composite]
           ,[comment]
           ,[is_deleted]
           ,[created_by]
           ,[created_date]
           ,[updated_by]
           ,[updated_date]) 
		   VALUES
		   (TMP.[journal_entry_date_id]
           ,TMP.[posting_date_id]
           ,TMP.[journal_entry_type_id]
           ,TMP.[assignment_reference_id]
           ,TMP.[account_id]
           ,TMP.[department_id]
           ,TMP.[profit_center_id]
           ,TMP.[cost_center_code_id]
           ,TMP.[wbs_code_id]
           ,TMP.[project_type_id]
           ,TMP.[project_id]
           ,TMP.[supplier_id]
           ,TMP.[expense_type_id]
           ,TMP.[forecast_id]
           ,TMP.[auto_tag_id]
           ,TMP.[actual_amount]
           ,TMP.[purchase_order_number]
           ,TMP.[po_composite]
		   ,TMP.[po_cost_object_composite]
           ,TMP.[header_text]
           ,TMP.[item_text]
           ,TMP.[journal_entry_created_by]
           ,TMP.[journal_entry]
           ,TMP.[journal_entry_item]
           ,TMP.[journal_entry_composite]
           ,TMP.[comment]
           ,TMP.[is_deleted]
           ,TMP.[created_by]
           ,TMP.[created_date]
           ,TMP.[updated_by]
           ,TMP.[updated_date]
		   )
;

-- UPDATE AUTO TAGGER INFO

-- find all the work orders and their po numbers
-- we don't have a forecast id yet
DROP TABLE IF EXISTS #TMP_PO_COC;
SELECT DISTINCT
	wo.[work_order_id],
	coc.[cost_object_code],
	wo.[purchase_order_number],
	CAST(CONCAT(wo.[purchase_order_number], '-',coc.[cost_object_code]) AS VARCHAR(250)) as [po_cost_object_composite],
	CAST(CONCAT(wo.[work_order_id], '-',coc.[cost_object_code]) AS VARCHAR(250)) as [work_order_cost_object_composite]
INTO #TMP_PO_COC
FROM [dbo].[work_order] as wo
JOIN [dbo].[cost_object_code] as coc
	ON wo.[cost_object_code_id] = coc.[cost_object_code_id]
WHERE wo.[is_deleted] = 0
AND wo.[purchase_order_number] IS NOT NULL
AND coc.[cost_object_code] IS NOT NULL
;

-- now go to the forecast and find work order ids with cost object codes
-- since po numbers don't exist in the forecast, we need to tie it back based on work order and cost object
-- based on the [work_order_cost_object_composite] this will get tied back to a po number
DROP TABLE IF EXISTS #TMP_FORECAST_WO_COC;
SELECT DISTINCT
	f.[forecast_id],
	f.[work_order_id],
	f.[cost_object_code_id],
	coc.[cost_object_code],
	f.[cost_center_code_id],
	f.[account_code_id],
	CAST(CONCAT(f.[work_order_id], '-',coc.[cost_object_code]) AS VARCHAR(250)) as [work_order_cost_object_composite],
	ROW_NUMBER() OVER (PARTITION BY f.[work_order_id], coc.[cost_object_code] ORDER BY f.[forecast_id]) as dedupe
INTO #TMP_FORECAST_WO_COC
FROM [dbo].[forecast] as f
JOIN [dbo].[cost_object_code] as coc
	ON f.[cost_object_code_id] = coc.[cost_object_code_id]
WHERE f.[is_deleted] = 0
AND f.[work_order_id] IS NOT NULL
AND coc.[cost_object_code] IS NOT NULL
AND f.[work_order_id] LIKE 'CHTRWO%'
;
 
-- now join the tables together to get a full picture of cost object, po number, and forecast id
-- there's an issue with dupes meaning duplicates in the forecast with the same work order id & cost object
DROP TABLE IF EXISTS #TMP_FORECAST_PO_COC;
SELECT 
	f.[forecast_id],
	f.[work_order_id],
	f.[cost_object_code_id],
	f.[cost_object_code],
	f.[cost_center_code_id],
	f.[account_code_id],
	wo.[purchase_order_number],
	wo.[po_cost_object_composite],
	ROW_NUMBER() OVER (PARTITION BY wo.[po_cost_object_composite] ORDER BY f.[forecast_id]) as dedupe
INTO #TMP_FORECAST_PO_COC
FROM #TMP_FORECAST_WO_COC as f
JOIN #TMP_PO_COC as wo
	ON f.[work_order_cost_object_composite] = wo.[work_order_cost_object_composite]
ORDER BY 4
;

-- insert records
INSERT INTO [dbo].[auto_tag]
           ([cost_center_code_id]
		   ,[account_code_id]
		   ,[cost_object_code_id]
           ,[purchase_order_number]
           ,[po_cost_object_composite]
           ,[forecast_id]
		   )
SELECT
	t.[cost_center_code_id], 
	t.[account_code_id],
	t.[cost_object_code_id],
	t.[purchase_order_number],
	t.[po_cost_object_composite],
	t.[forecast_id]
FROM #TMP_FORECAST_PO_COC as t
LEFT JOIN [dbo].[auto_tag] as tag
	ON t.[po_cost_object_composite] = tag.[po_cost_object_composite]
WHERE t.dedupe = 1
AND tag.[auto_tag_id] IS NULL -- doesn't exist
ORDER BY 4


-- this should only update contractors
-- the po number to cost object should only apply to contractors and takes priority
UPDATE [dbo].[general_ledger]
SET [general_ledger].[auto_tag_id] = tag.[auto_tag_id]
FROM [dbo].[auto_tag] as tag, [dbo].[general_ledger] 
WHERE [general_ledger].[po_cost_object_composite] = tag.[po_cost_object_composite]
AND [general_ledger].[auto_tag_id] IS NULL -- only ones that haven't been tagged
AND tag.[is_deleted] = 0
AND tag.[po_cost_object_composite] IS NOT NULL
AND tag.[forecast_id] NOT IN (SELECT forecast_id FROM [dbo].[forecast] WHERE [is_deleted] = 1)
;


-- this should update everything not contractor based
UPDATE [dbo].[general_ledger]
SET [general_ledger].[auto_tag_id] = tag.[auto_tag_id]
FROM [dbo].[auto_tag] as tag, [dbo].[general_ledger] 
WHERE [general_ledger].[po_composite] = tag.[po_composite]
AND [general_ledger].[auto_tag_id] IS NULL -- only ones that haven't been tagged
AND tag.[is_deleted] = 0
AND tag.[po_composite] IS NOT NULL
AND tag.[forecast_id] NOT IN (SELECT forecast_id FROM [dbo].[forecast] WHERE [is_deleted] = 1)
;

END
;
GO