DROP PROCEDURE IF EXISTS [etl].[sp_inital_migration_v3];
GO
CREATE PROCEDURE [etl].[sp_inital_migration_v3]
AS
BEGIN
    SET NOCOUNT ON;

	-- GL
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









-- AUTO TAGGER
INSERT INTO [dbo].[auto_tag]
           ([cost_center_code_id]
           ,[account_code_id]
           ,[purchase_order_number]
           ,[po_composite]
           ,[forecast_id]
		   ,[old_auto_tag_id]
           ,[is_deleted]
           ,[created_by]
           ,[created_date]
           ,[updated_by]
           ,[updated_date])
SELECT DISTINCT
	IIF(ccc.[cost_center_code_id] IS NULL, 0, ccc.[cost_center_code_id]) as [cost_center_code_id],
	IIF(a.[account_id] IS NULL, 0, a.[account_id]) as [account_code_id],
	tag.[Purchase Order Number] as [purchase_order_number],
	CONCAT(tag.[Cost Center Code], '-', tag.[Account Code], '-', tag.[Purchase Order Number]) as [po_composite],
	FIRST_VALUE(f.[forecast_id]) OVER (PARTITION BY tag.[Cost Center Code], tag.[Account Code], tag.[Purchase Order Number] ORDER BY tag.FCSTPOID, f.[forecast_id]) as [forecast_id],
	FIRST_VALUE(tag.FCSTPOID) OVER (PARTITION BY tag.[Cost Center Code], tag.[Account Code], tag.[Purchase Order Number] ORDER BY tag.FCSTPOID) as [old_auto_tag_id],
	IIF(tag.[DelFlag] IS NULL, 0, tag.[DelFlag]) as [is_deleted],
	CURRENT_USER AS [created_by],
	CURRENT_TIMESTAMP AS [created_date],
	CURRENT_USER AS [updated_by],
	CURRENT_TIMESTAMP AS [updated_date]
FROM [Compiler].[mart].[FCSTID_PO] as tag
LEFT JOIN [dbo].[forecast] as f
	ON tag.[FCSTID] = f.[old_forecast_id]
LEFT JOIN [dbo].[cost_center_code] as ccc
	ON tag.[Cost Center Code] = ccc.[raw]
LEFT JOIN [dbo].[account] as a
	ON tag.[Account Code] = a.[raw]
JOIN [dbo].[general_ledger] as gl
	ON CONCAT(tag.[Cost Center Code], '-', tag.[Account Code], '-', tag.[Purchase Order Number]) = gl.[po_composite]
WHERE f.[is_deleted] = 0
ORDER BY [forecast_id]
;
END
;
GO