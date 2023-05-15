USE TEST
GO


-- ACCOUNT CODE
INSERT INTO [dbo].[account]
           ([account]
           ,[account_name]
           ,[raw]
)
SELECT DISTINCT
	TRY_CAST(a.[Account Code] as numeric),
	a.[Account Name],
	[Account Code]
FROM compiler.coa.account as a
JOIN [dbo].[account] as prd ON a.
ORDER BY 2
;
-- SELECT * FROM [dbo].[account]


-- Assignment reference is a GL only attribute, and sometimes contains Puchase Order Number when [Purchase Order Number] is null.
-- I create [Purchase Order Number] when it is not populated by filling it with [Assignment Reference] where like '4200%',
-- or where either description like '4200%', as the column from SAP is often incomplete.
INSERT INTO [dbo].[assignment_reference]
	([assignment_reference]
	,[assignment_reference_description]
	,[raw])
SELECT DISTINCT 
	 LTRIM(RTRIM(REPLACE([Assignment Reference], '"', '')))
	,LTRIM(RTRIM(REPLACE([Assignment Reference], '"', '')))
	,[Assignment Reference]
FROM [Compiler].[mart].[SAP GL Unformatted]
ORDER BY 1
;


-- BUDGET CODE
INSERT INTO [dbo].[budget_code]
           ([budget_code]
           ,[raw])
SELECT DISTINCT
	[Budget Code],
	[Budget Code]
FROM [Compiler].[mart].[RollingF]
WHERE [Budget Code] IS NOT NULL
AND [Budget Code] NOT IN ('', '0')
ORDER BY 1
;


-- BUSINESS UNIT
-- TRUNCATE TABLE [dbo].[business_unit];
INSERT INTO [dbo].[business_unit]
           ([business_unit]
           ,[raw])
SELECT * FROM
(SELECT 
	[business_unit], 
	[business_unit] AS raw
FROM [EID].[BUSPLAN].[prd_fg_business_unit]
UNION
SELECT 
	[Business Unit],
	[Business Unit] AS raw
FROM [staging].[work_order_detail]
) AS T
WHERE [business_unit] != 'Unknown'
ORDER BY 1
;


-- COMPANY CODE
INSERT INTO [dbo].[company_code]
           ([company_code]
           ,[company_description]
           ,[company_type]
           ,[legal_entity_name]
           ,[raw])
SELECT
      [company_code],
      [company_description],
      [company_type],
      [legal_entity_name],
      [company_code]
FROM [TEST].[staging].[company_code]
;


-- CONTRACTOR INFORMATION
INSERT INTO [dbo].[contractor]
           ([worker_id]
           ,[pid]
           ,[first_name]
           ,[last_name]
           ,[full_name]
           ,[worker_site]
           ,[raw])
SELECT
	[worker_id]
   ,[pid]
   ,[first_name]
   ,[last_name]
   ,[full_name]
   ,[worker_site]
   ,[raw]
FROM 
(SELECT
	[Worker ID] as worker_id,
	[PID] as pid,
	RIGHT([Worker],CHARINDEX(',',REVERSE([Worker]))-1) as first_name,
	LEFT([Worker], CHARINDEX(',', [Worker] + ',') - 1) as last_name,
	[Worker] as full_name,
	CONCAT('Worker Site: ', [Worker Site State/Province], ' - Country: ', [Country]) as worker_site,
	[Worker ID] as raw,
	ROW_NUMBER() OVER (PARTITION BY [Worker ID] ORDER BY [PID]) AS dedupe
FROM [staging].[work_order_detail]
) as T
WHERE dedupe = 1
ORDER BY 2
;


-- COST CENTER CODE
-- TRUNCATE TABLE [dbo].[cost_center_code];
INSERT INTO [dbo].[cost_center_code]
           ([cost_center_code]
           ,[cost_center]
           ,[company_code_id]
           ,[entity_code]
           ,[department_code]
           ,[raw])
SELECT DISTINCT
	TRY_CAST([Cost Center (Derv)] as numeric),
	[CC Name (Derv)],
	cc.company_code_id,
	TRY_CAST(SUBSTRING([Cost Center (Derv)], 4, 4) as numeric),
	TRY_CAST(RIGHT([Cost Center (Derv)], 3) as numeric),
	[Cost Center (Derv)]
FROM [staging].[sap_general_ledger] as gl
JOIN [dbo].[company_code] as cc
	ON LEFT(gl.[Cost Center (Derv)], 3) = cc.[raw]
ORDER BY 1
;

INSERT INTO [dbo].[cost_center_code]
           ([cost_center_code]
           ,[cost_center]
           ,[company_code_id]
           ,[entity_code]
           ,[department_code]
           ,[raw])
SELECT DISTINCT
	TRY_CAST([Cost Center Code] as numeric),
	NULL,
	cc.company_code_id,
	TRY_CAST(SUBSTRING([Cost Center Code], 4, 4)as numeric),
	TRY_CAST(RIGHT([Cost Center Code], 3) as numeric),
	[Cost Center Code]
FROM [Compiler].[mart].[RollingF] as r
JOIN [dbo].[company_code] as cc
	ON LEFT(r.[Cost Center Code], 3) = cc.[raw]
LEFT JOIN [dbo].[cost_center_code] as ccc
	ON r.[Cost Center Code] = ccc.raw
WHERE ccc.cost_center_code_id IS NULL
AND r.[Cost Center Code] IS NOT NULL
AND r.[Cost Center Code] NOT IN ('','0')
;

 
-- COST OBJECT CODE
INSERT INTO [dbo].[cost_object_code]
           ([cost_object_code]
           ,[cost_object_name]
           ,[is_opex]
           ,[raw])
SELECT DISTINCT
	[WBS Element],
	[WBS Name],
	CASE
		WHEN [WBS Element] LIKE 'FG%'
		THEN 1
		ELSE 0
	END as [is_opex],
	[WBS Element]
FROM [TEST].[staging].[sap_general_ledger]
WHERE [WBS Element] IS NOT NULL
ORDER BY 1
;

INSERT INTO [dbo].[cost_object_code]
           ([cost_object_code]
           ,[cost_object_name]
           ,[is_opex]
           ,[raw])
SELECT DISTINCT
	LTRIM([Cost Object Code]),
	NULL,
	CASE
		WHEN [Cost Object Code] LIKE 'FG%'
		THEN 1
		ELSE 0
	END as [is_opex],
	[Cost Object Code]
FROM [Compiler].[mart].[RollingF] as r
LEFT JOIN [dbo].[cost_object_code] as coc
	ON r.[Cost Object Code] = coc.[raw]
WHERE [Cost Object Code] IS NOT NULL
AND coc.[cost_object_code] IS NULL
AND [Cost Object Code] NOT IN
	('', 'Agent OS Platform',
	'Industrial Design Studio',
	'IP Video Delivery', 'Online Ordering',
	'Portals Resiliency & Feature Capacity'
	)
ORDER BY 1
;


--TRUNCATE TABLE [dbo].[date_dimension];
INSERT INTO [dbo].[date_dimension]
           ([date_id]
           ,[full_date]
           ,[day_of_week_sunday]
           ,[day_of_week_monday]
           ,[day_name_of_week]
           ,[day_of_month]
           ,[day_of_year]
           ,[weekday_weekend]
           ,[week_of_month]
           ,[week_of_year_sunday]
           ,[week_of_year_monday]
           ,[month_name]
           ,[month_of_year]
           ,[is_last_day_of_month]
           ,[is_holiday]
           ,[holiday_name]
           ,[calendar_quarter]
           ,[calendar_year]
           ,[calendar_year_month]
           ,[calendar_year_qtr]
           ,[is_company_holiday]
           ,[is_estimated_pto]
           ,[onshore_work_hours]
           ,[offshore_work_hours]
           ,[forecasting_month]
		   ,[fiscal_period]
		   ,[short_month_short_year] -- this is the typical forecast header for month
		   )
SELECT REPLACE(CAST([full_date] AS VARCHAR), '-', '') AS ID
      ,[full_date]
      ,[day_of_week_sunday]
      ,[day_of_week_monday]
      ,[day_name_of_week]
      ,[day_of_month]
      ,[day_of_year]
      ,[weekday_weekend]
      ,[week_of_month]
      ,[week_of_year_sunday]
      ,[week_of_year_monday]
      ,[month_name]
      ,[month_of_year]
      ,[is_last_day_of_month]
      ,[is_holiday]
      ,[holiday_name]
      ,[calendar_quarter]
      ,[calendar_year]
      ,[calendar_year_month]
      ,[calendar_year_qtr]
      ,[is_company_holiday]
      ,[is_estimated_pto]
      ,[onshore_work_hours]
      ,[offshore_work_hours]
      ,[forecasting_month]
	  ,CASE
		WHEN MONTH([full_date]) IN (1,2,3)
		THEN 2
		WHEN MONTH([full_date]) IN (4,5,6)
		THEN 3
		WHEN MONTH([full_date]) IN (7,8,9)
		THEN 4
		WHEN MONTH([full_date]) IN (10,11,12)
		THEN 1
	  END
	  ,CONCAT(FORMAT([full_date], 'MMM'), '-', RIGHT([calendar_year], 2))
  FROM [EID].[BUSPLAN].[date_dimension]
ORDER BY full_date
;


-- DEPARTMENT
-- TRUNCATE TABLE [dbo].[deptartment];
INSERT INTO [dbo].[deptartment]
           ([department_code]
           ,[department]
           ,[department_long]
           ,[raw])
SELECT * FROM
(SELECT DISTINCT
	department_code,
	department,
	CONCAT(department, ' (', department_code, ')') as department_long,
	department as raw
FROM [EID].[BUSPLAN].[prd_fg_department]
UNION
SELECT DISTINCT
	[Dept (Derv)],
	[Dept Name (Derv)],
	CONCAT([Dept Name (Derv)], ' (', [Dept (Derv)], ')') as department_long,
	[Dept Name (Derv)] as raw
FROM [staging].[sap_general_ledger] AS gl
) as T
WHERE T.department != 'Unknown'
ORDER BY 1,2,3
;


/*
INSERT INTO [dbo].[deptartment]
           ([department_code]
           ,[department]
           ,[department_long]
           ,[raw])
SELECT DISTINCT
	NULL,
	[Department of Hiring Manager],
	[Department of Hiring Manager],
	[Department of Hiring Manager]
FROM [EID].[SHARE].[BusPlanContractorDetails] as bp
LEFT JOIN [dbo].[deptartment] as d
	ON bp.[Department of Hiring Manager] = d.raw
WHERE d.department_id IS NULL -- new value
ORDER BY 1,2,3
;
*/


--employee
INSERT INTO [dbo].[employee]
           ([employee]
           ,[raw])
SELECT DISTINCT
	[Department Leader] as employee,
	[Department Leader] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Department Leader] IS NOT NULL
AND [Department Leader] NOT IN ('')
UNION
SELECT DISTINCT
	[Team Leader] as employee,
	[Team Leader] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Team Leader] IS NOT NULL
AND [Team Leader] NOT IN ('')
UNION
SELECT DISTINCT
	[Business Owner] as employee,
	[Business Owner] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Business Owner] IS NOT NULL
AND [Business Owner] NOT IN ('')
UNION
SELECT DISTINCT
	[Worker: New Primary Contact],
	[Worker: New Primary Contact]
FROM [Compiler].[mart].[RollingF]
WHERE [Worker: New Primary Contact] IS NOT NULL
AND [Worker: New Primary Contact] NOT IN ('', '0')
ORDER BY 1
;


-- EXPENSE CLASSIFICATION
INSERT INTO [dbo].[expense_classification]
           ([expense_classification]
           ,[raw])
SELECT DISTINCT
	[Expense Classification],
	[Expense Classification]
FROM [Compiler].[mart].[RollingF]
WHERE [Expense Classification] IS NOT NULL
AND [Expense Classification] NOT IN ('')
ORDER BY 1
;


-- EXPENSE TYPE
INSERT INTO [dbo].[expense_type]
           ([expense_type],
		   [raw])
VALUES
	('Unknown', 'Unknown'),
	('Direct', 'Direct'), -- OPEX
	('Indirect', 'Indirect'),
	('Indirect-CAPEX', 'Indirect-CAPEX'),
	('Indirect-OPEX', 'Indirect-OPEX'),
	('Indirect-Contractors (CAPEX)', 'Indirect-Contractors (CAPEX)'),
	('Indirect-Contractors (OPEX)', 'Indirect-Contractors (OPEX)')
;

-- function
INSERT INTO [dbo].[function]
           ([function]
           ,[raw])
     VALUES
			('Development','Development'),
			('PM/BA','PM/BA'),
			('Lab Ops','Lab Ops'),
			('Software','Software'),
			('Testing','Testing'),
			('Direct Expense','Direct Expense'),
			('Consulting','Consulting'),
			('Hardware','Hardware'),
			('Other','Other'),
			('Design','Design')
;


-- Journal Entry Type denotes the SAP method by which the entry was created. 
-- For example, an automated accrual will have a different Type than a human entering the entry by hand via a certain SAP system.
-- Usually this only serves to fact find who to reach out to about details for why the entry was booked.
INSERT INTO [dbo].[journal_entry_type]
	([journal_entry_type]
	,[journal_entry_type_description]
	,[raw])
SELECT DISTINCT 
	 [Journal Entry Type]
	,[Journal Entry Type]
	,[Journal Entry Type]
FROM [Compiler].[mart].[SAP GL Unformatted]
ORDER BY 1
;


-- location and locale
INSERT INTO [dbo].[location]
           ([location]
           ,[local]
           ,[raw])
SELECT DISTINCT
	LEFT([Country], CHARINDEX('|', [Country] + '|') - 1) as [location],
	CASE
		WHEN RIGHT([Country],CHARINDEX('|',REVERSE([Country]))-1) = 'USA'
		THEN 'Onshore'
		WHEN RIGHT([Country],CHARINDEX('|',REVERSE([Country]))-1) IN ('CAN', 'MEX')
		THEN 'Nearshore'
		ELSE 'Offshore'
	END as locale,
	[Country] as raw
FROM [staging].[work_order_detail]
WHERE [Country] is not null
ORDER BY 1
;


-- MAIN DOCUMENT TITLE 
INSERT INTO [dbo].[main_document_title]
           ([main_document_title]
           ,[raw])
SELECT DISTINCT
	[Main Document Title],
	[Main Document Title]
FROM [staging].[work_order_detail]
UNION
SELECT DISTINCT
	[Main Document Title],
	[Main Document Title]
FROM [Compiler].[mart].[RollingF]
WHERE [Main Document Title] IS NOT NULL
AND [Main Document Title] NOT IN ('')
ORDER BY 1
;


-- PLATFORM
INSERT INTO [dbo].[platform]
           ([platform]
           ,[raw])
SELECT DISTINCT 
	[platform], 
	[platform] 
FROM [Compiler].[mart].[RollingF] 
WHERE len(Platform) > 1
ORDER BY 1
;


--I searched SAP for a Profit Center code and couldn't find it as a field to be in the GL.
--Its possible we can get this data from business when we ask for those definitions
Insert into [dbo].[profit_center]
	([profit_center],
	 [raw])
SELECT DISTINCT
	[PC Name],
	[PC Name]
FROM [Compiler].[mart].[SAP GL Unformatted]
WHERE [PC Name] IS NOT NULL
ORDER BY 1
;


--This is left([Cost Object Code],7), and is largely what business reports on.
INSERT INTO [dbo].[project]
	([project]
	,[project_name]
	,[raw])
SELECT DISTINCT
	[Project]
	,[Project Name]
	,[Project]
FROM [Compiler].[mart].[SAP GL Unformatted]
WHERE [Project] is not null
ORDER BY 1
;


--No idea what these types indicate
INSERT INTO [dbo].[project_type]
	([project_type]
	,[project_type_description]
	,[raw])
SELECT DISTINCT 
	 [Project Type]
	,[Proj Typ Name]
	,[Project Type]
FROM [Compiler].[mart].[SAP GL Unformatted]
WHERE [Project Type] is not null
ORDER BY 1
;


-- SEGMENTATION
INSERT INTO [dbo].[segmentation]
           ([segmentation]
           ,[raw])
SELECT DISTINCT 
	[Segmentation],
	[Segmentation]
FROM [Compiler].[mart].[RollingF]
WHERE [Segmentation] IS NOT NULL
AND [Segmentation] NOT IN ('')
ORDER BY 1
;


-- SUPPLIER
INSERT INTO [dbo].[supplier]
           ([supplier_code]
		   ,[supplier]
		   ,[supplier_long]
           ,[raw])
SELECT DISTINCT
	[Supplier Code],
	[Supplier],
	CONCAT([Supplier Code], ' - ', [Supplier]),
	[Supplier]
FROM [staging].[work_order_detail]
;
/*
SELECT * FROM
(SELECT DISTINCT
	[Supplier],
	[Supplier] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Supplier] IS NOT NULL
AND [Supplier] != ''
UNION
SELECT [Supplier Name], [Supplier Name]
FROM [TEST].[staging].[sap_general_ledger]
WHERE [Supplier Name] IS NOT NULL
) as T
ORDER BY 1
;
*/


-- SUPPORT/SCALABLE
INSERT INTO [dbo].[support_scalable]
           ([support_scalable]
           ,[raw])
VALUES ('Support', 'Support'),
       ('Scalable', 'Scalable')
;


-- USER
--TRUNCATE TABLE [dbo].[user];
INSERT INTO [dbo].[user]
           ([name]
           ,[username]
           ,[pid]
           ,[is_admin])
SELECT
	emp_name,
	username,
	userPID,
	CASE
		WHEN username IN ('dev1', 'cstroup', 'kgiangrosso')
		THEN 1
		ELSE 0
	END as is_admin
FROM [Compiler].[mart].[perm_user]
ORDER BY 1
;


-- WORK ORDER CATEGORY
INSERT INTO [dbo].[work_order_category]
           ([work_order_category]
           ,[raw])
SELECT DISTINCT
	[WO Category],
	[WO Category]
FROM [Compiler].[mart].[RollingF]
WHERE [WO Category] IS NOT NULL
AND [WO Category] NOT IN ('', '0')
ORDER BY 1
;


-- WORK ORDER STATUS
INSERT INTO [dbo].[work_order_status]
           ([work_order_status]
           ,[raw])
SELECT DISTINCT
	[Work Order Status],
	[Work Order Status]
FROM [staging].[work_order_detail]
ORDER BY 1
;



--	WORK TYPE
INSERT INTO [dbo].[work_type]
           ([work_type]
           ,[raw])
SELECT DISTINCT
	[Worker Type],
	[Worker Type]
FROM [staging].[work_order_detail]
UNION
SELECT DISTINCT
	[Work Type],
	[Work Type]
FROM [Compiler].[mart].[RollingF]
WHERE [Work Type] IS NOT NULL
AND [Work Type] NOT IN ('15263')
ORDER BY 1
;


-- WORKER STATUS
INSERT INTO [dbo].[worker_status]
           ([worker_status]
           ,[raw])
SELECT DISTINCT
	[Worker Status],
	[Worker Status]
FROM [Compiler].[mart].[RollingF]
WHERE [Worker Status] IS NOT NULL
ORDER BY 1
;











SELECT DISTINCT *
FROM [staging].[work_order_detail]
ORDER BY 1
;

SELECT * FROM [dbo].[deptartment] ORDER BY 3;
SELECT * FROM [dbo].[business_unit] ORDER BY 2;


SELECT top 100 * FROM [Compiler].[mart].[RollingF]

SELECT TOP 100 * FROM [TEST].[staging].[sap_general_ledger]

SELECT * FROM [Compiler].[mart].[perm_dept]

SELECT * FROM [EID].[SHARE].[BusPlanContractorDetails]

/*
[PO Composite] = [Cost Center Code]+[Account Code]+[Purchase Order Number]
[Source] = 'Actuals'

[Expense Type] = 'Direct' where left([Account Code], 1) = '5';
[Expense Type] = 'Indirect' where left([Account Code], 1) = '6';
[Expense Type] = 'Capex' where left([WBS Element], 1) = 'P'
[Expense Type] = 'Capex' where [Short Description] like '%cap%' and left([Account Code], 1) = '6'
[Expense Type] = 'Indirect Contractor' where left([WBS Element], 2) = 'FG'

[Imported On] = 
set @utc_offset = (select try_cast(left([current_utc_offset],3)as int) from sys.time_zone_info where name = 'Mountain Standard Time')
dateadd(hour,@utc_offset,[Compiler].[raw].[SAP GL].[ImportedOn])
*/