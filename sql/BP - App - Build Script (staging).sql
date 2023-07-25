--CREATE STAGING TABLES
--USE TEST
--GO

USE PLANNING_APP
GO

--CREATE SCHEMA [staging];
--GO

DROP TABLE IF EXISTS [staging].[work_order_detail];
CREATE TABLE [staging].[work_order_detail](
	[Worker Type] [varchar](max) NULL,
	[Job Posting ID] [varchar](max) NULL,
	[Job Posting Creator] [varchar](max) NULL,
	[Job Posting Approver] [varchar](max) NULL,
	[Work Order ID] [varchar](max) NULL,
	[Work Order Status] [varchar](max) NULL,
	[Revision #] [int] NULL,
	[Worker ID] [varchar](max) NULL,
	[PID] [varchar](max) NULL,
	[Worker] [varchar](max) NULL,
	[Worker Status] [varchar](max) NULL,
	[Main Document Title] [varchar](max) NULL,
	[Worker Start Date] [varchar](max) NULL,
	[Worker End Date] [varchar](max) NULL,
	[Worker: New Primary Contact] [varchar](max) NULL,
	[Department of Hiring Manager] [varchar](max) NULL,
	[Department of Hiring Manager Code] [varchar](max) NULL,
	[Supplier] [varchar](max) NULL,
	[Supplier Code] [varchar](max) NULL,
	[Business Unit] [varchar](max) NULL,
	[SVP] [varchar](max) NULL,
	[Site] [varchar](max) NULL,
	[Worker Site State/Province] [varchar](max) NULL,
	[Country] [varchar](max) NULL,
	[Current Bill Rate ST Hr [ST/Hr]]] [varchar](max) NULL,
	--[Current Bill Rate ST DAILY Day] [varchar](max) NULL,
	[Hours per Week] [varchar](max) NULL,
	[Hours per Day] [varchar](max) NULL,
	[Company Code] [varchar](max) NULL,
	[Cost Object Code] [varchar](max) NULL,
	[Allocation %] [varchar](max) NULL,
	[Purchase Order Number] [varchar](max) NULL,
	[Cumulative Committed Spend] [varchar](max) NULL,
	[Spend to Date] [varchar](max) NULL,
	[Other Pending Spend] [varchar](max) NULL,
	[Remaining Spend] [varchar](max) NULL,
	[Work Order Tenure] [varchar](max) NULL,
) ON [PRIMARY]
GO
;


DROP TABLE IF EXISTS [staging].[sap_general_ledger];
CREATE TABLE [staging].[sap_general_ledger](
	[Journal Entry] [nvarchar](255) NULL,
	[Journal Entry Item] [nvarchar](255) NULL,
	[Journal Entry Type] [nvarchar](255) NULL,
	[Journal Entry Date] [nvarchar](255) NULL,
	[Fiscal Period] [nvarchar](255) NULL,
	[Assignment Reference] [nvarchar](255) NULL,
	[Posting Date] [nvarchar](255) NULL,
	[Company Code] [nvarchar](255) NULL,
	[GL Name] [nvarchar](255) NULL,
	[G/L Account] [nvarchar](255) NULL,
	[Dept (Derv)] [nvarchar](255) NULL,
	[Dept Name (Derv)] [nvarchar](255) NULL,
	[Cost Center (Derv)] [nvarchar](255) NULL,
	[CC Name (Derv)] [nvarchar](255) NULL,
	[PC Name] [nvarchar](255) NULL,
	[Cost Center] [nvarchar](255) NULL,
	[WBS Element] [nvarchar](255) NULL,
	[WBS Name] [nvarchar](255) NULL,
	[Project] [nvarchar](255) NULL,
	[Project Name] [nvarchar](255) NULL,
	[Project Type] [nvarchar](255) NULL,
	[Proj Typ Name] [nvarchar](255) NULL,
	[Amount] [nvarchar](255) NULL,
	[Purchasing Document] [nvarchar](255) NULL,
	[Item Text] [nvarchar](255) NULL,
	[Header Text] [nvarchar](255) NULL,
	[Supplier] [nvarchar](255) NULL,
	[Supplier Name] [nvarchar](255) NULL,
	[Journal Entry Created By] [nvarchar](255) NULL,
) ON [PRIMARY]
GO
;

-- SELECT * FROM [staging].[rolling_forecast]
DROP TABLE IF EXISTS [staging].[rolling_forecast];
CREATE TABLE [staging].[rolling_forecast](
	[Work Type] [nvarchar](255) NULL,
	[Expense Classification] [nvarchar](255) NULL,
	[Work Order ID] [nvarchar](255) NULL,
	[Worker ID] [nvarchar](255) NULL,
	[PID] [nvarchar](255) NULL,
	[Worker/Description] [nvarchar](255) NULL,
	[Worker Status] [nvarchar](255) NULL,
	[Main Document Title] [nvarchar](255) NULL,
	[Worker Start Date] [nvarchar](255) NULL,
	[Worker End Date] [nvarchar](255) NULL,
	[Worker: New Primary Contact] [nvarchar](255) NULL,
	[Department of Hiring Manager Code] [nvarchar](255) NULL,
	[Department of Hiring Manager] [nvarchar](255) NULL,
	[Supplier] [nvarchar](255) NULL,
	[Business Unit] [nvarchar](255) NULL,
	[Department Leader] [nvarchar](255) NULL,
	[Team Leader] [nvarchar](255) NULL,
	[Business Owner] [nvarchar](255) NULL,
	[Site] [nvarchar](255) NULL,
	[Worker Site State/Province] [nvarchar](255) NULL,
	[WO Category] [nvarchar](255) NULL,
	[Current Bill Rate ST/Hr] [nvarchar](255)  NULL,
	[Current Bill Rate ST/Day] [nvarchar](255)  NULL,
	[Company Code] [nvarchar](255) NULL,
	[Cost Object Code] [nvarchar](255) NULL,
	[Account Code] [nvarchar](255) NULL,
	[Budget Code] [nvarchar](255) NULL,
	[Segmentation] [nvarchar](255) NULL,
	[Platform] [nvarchar](255) NULL,
	[Function] [nvarchar](255) NULL,
	[Support/Scalable] [nvarchar](255) NULL,
	[Current Allocation %] [nvarchar](255) NULL,
	[Jan] [nvarchar](255) NULL,
	[Feb] [nvarchar](255) NULL,
	[Mar] [nvarchar](255) NULL,
	[Apr] [nvarchar](255) NULL,
	[May] [nvarchar](255) NULL,
	[Jun] [nvarchar](255) NULL,
	[Jul] [nvarchar](255) NULL,
	[Aug] [nvarchar](255) NULL,
	[Sep] [nvarchar](255) NULL,
	[Oct] [nvarchar](255) NULL,
	[Nov] [nvarchar](255) NULL,
	[Dec] [nvarchar](255) NULL
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS [staging].[pcode_to_bcode];
CREATE TABLE [staging].[pcode_to_bcode](
	[Project Name ID] [nvarchar](255) NULL,
	[Project Name] [nvarchar](255) NULL,
	[Bcode/Investment Position ID] [nvarchar](255) NULL,
	[Bcode/Investment Position Name] [nvarchar](255) NULL,
	[P&T Segmentation] [nvarchar](255) NULL,
	[Platform] [nvarchar](255) NULL,
	[Business Leader] [nvarchar](255) NULL
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [staging].[opex_department_mapping];
CREATE TABLE [staging].[opex_department_mapping](
	[Department Code] [nvarchar] (255) NULL,
	[Project Name] [nvarchar] (255) NULL,
	[Bcode/Investment Position ID] [nvarchar] (255) NULL,
	[Bcode/Investment Position Name] [nvarchar] (255) NULL,
	[P&T Segmentation] [nvarchar] (255) NULL,
	[Platform] [nvarchar] (255) NULL,
	[Business Leader] [nvarchar] (255) NULL
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [staging].[account_mapping];
CREATE TABLE [staging].[account_mapping](
[Account Number] [nvarchar] (255) NULL,
[Account Name] [nvarchar] (255) NULL,
[P&L Rollup Level 1] [nvarchar] (255) NULL,
[P&L Rollup Level 2] [nvarchar] (255) NULL
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [staging].[company_entity];
CREATE TABLE [staging].[company_entity](
[Company Code] [nvarchar] (255) NULL,
[Company Name] [nvarchar] (255) NULL,
[Entity Code] [nvarchar] (255) NULL,
[Entity Name] [nvarchar] (255) NULL,
[Combination] [nvarchar] (255) NULL
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [staging].[company_code];
CREATE TABLE [staging].[company_code](
[Company Number] [nvarchar] (255) NULL,
[Company Code] [nvarchar] (255) NULL,
[Legal Entity Name] [nvarchar] (255) NULL,
[Company Type] [nvarchar] (255) NULL
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [staging].[sftp_general_ledger];
CREATE TABLE [staging].[sftp_general_ledger] (
   COMPANY_CODE nvarchar(255) NULL,
   CCODE_NAME nvarchar(255) NULL,
   PROFIT_CENTER nvarchar(255) NULL,
   COST_CENTER nvarchar(255) NULL,
   DEPARTMENT nvarchar(255) NULL,
   DEPT_NAME nvarchar(255) NULL,
   GL_ACCOUNT nvarchar(255) NULL,
   GL_ACCOUNT_NAME nvarchar(255) NULL,
   PROJECT nvarchar(255) NULL,
   PROJECT_NAME nvarchar(255) NULL,
   WBS_ELEMENT nvarchar(255) NULL,
   WBS_NAME nvarchar(255) NULL,
   PROJECT_TYPE_DESCRIPTION nvarchar(255) NULL,
   VENDOR nvarchar(255) NULL,
   VENDOR_NAME nvarchar(255) NULL,
   PURCHASING_DOCUMENT nvarchar(255) NULL,
   ITEM_TEXT nvarchar(255) NULL,
   JOURNAL_ENTRY nvarchar(255) NULL,
   JOURNAL_ENTRY_TYPE nvarchar(255) NULL,
   HEADER_TEXT nvarchar(255) NULL,
   JOURNAL_ENTRY_CREATED_BY nvarchar(255) NULL,
   POSTING_DATE nvarchar(255) NULL,
   ASSIGNMENT_REFERENCE nvarchar(255) NULL,
   JOURNAL_ENTRY_DATE nvarchar(255) NULL,
   PROJECT_TYPE_NODE nvarchar(255) NULL,
   FISCAL_PERIOD nvarchar(255) NULL,
   JOURNAL_ENTRY_ITEM nvarchar(255) NULL,
   AMOUNT nvarchar(255) NULL
) ON [PRIMARY]
GO


-- SELECT * FROM [staging].[bulk_update_forecast]


DROP TABLE IF EXISTS [staging].[bulk_update_forecast];
CREATE TABLE [staging].[bulk_update_forecast](
	[Forecast ID] [nvarchar](255) NOT NULL,
	[Company Code] [nvarchar](255) NULL,
	[Business Unit] [nvarchar](255) NULL,
	[Department] [nvarchar](255) NULL,
	[Cost Center Code] [nvarchar](255) NULL,
	[Department Leader] [nvarchar](255) NULL,
	[Team Leader] [nvarchar](255) NULL,
	[Business Owner] [nvarchar](255) NULL,
	[Primary Contact] [nvarchar](255) NULL,
	[Supplier] [nvarchar](255) NULL,
	[Contractor] [nvarchar](255) NULL,
	[Worker ID] [nvarchar](255) NULL,
	[PID] [nvarchar](255) NULL,
	[Worker Start Date] [nvarchar](255) NULL,
	[Worker End Date] [nvarchar](255) NULL,
	[Override End Date] [nvarchar](255) NULL,
	[Main Document Title] [nvarchar](255) NULL,
	[Cost Object Code] [nvarchar](255) NULL,
	[Site] [nvarchar](255) NULL,
	[Account Code] [nvarchar](255) NULL,
	[Work Type] [nvarchar](255) NULL,
	[Worker Status] [nvarchar](255) NULL,
	[Work Order Category] [nvarchar](255) NULL,
	[Expense Classification] [nvarchar](255) NULL,
	[Budget Code] [nvarchar](255) NULL,
	[Segmentation] [nvarchar](255) NULL,
	[Platform] [nvarchar](255) NULL,
	[Function] [nvarchar](255) NULL,
	[Support/Scalable] [nvarchar](255) NULL,
	[Work Order ID] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[Allocation] [nvarchar](255) NULL,
	[Current Bill Rate (Hr)] [nvarchar](255) NULL,
	[Current Bill Rate (Day)] [nvarchar](255) NULL,
	Comment [varchar](max) NULL
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [staging].[bulk_update_forecast_cleansed];
CREATE TABLE [staging].[bulk_update_forecast_cleansed](
	[forecast_id] bigint,
	--add FKs here
	[company_code_id] bigint NULL,
	[business_unit_id] bigint NULL,
	[department_id] bigint NULL,
	[cost_center_code_id] bigint NULL,
	[department_leader_id] bigint NULL, -- [employee_id]
	[team_leader_id] bigint NULL, -- [employee_id]
	[business_owner_id] bigint NULL, -- [employee_id]
	[primary_contact_id] bigint NULL, -- [employee_id]
	[supplier_id] bigint NULL,
	[contractor_id] bigint NULL,
	[worker_start_date_id] bigint NULL,
	[worker_end_date_id] bigint NULL,
	[override_end_date_id] bigint NULL, -- manual entry for end user to override end date
	[main_document_title_id] bigint NULL,
	[cost_object_code_id] bigint NULL,
	[site_id] bigint NULL,
	[account_code_id] bigint NULL,
	[work_type_id] bigint NULL,
	[worker_status_id] bigint NULL,
	[work_order_category_id] bigint NULL,
	[expense_classification_id] bigint NULL,
	[budget_code_id] bigint NULL,
	[segmentation_id] bigint NULL,
	[platform_id] bigint NULL,
	[function_id] bigint NULL,
	[support_scalable_id] bigint NULL,
	-- non FKs
	[work_order_id] [nvarchar](100) NULL,
	[description] [nvarchar](254) NULL,
	[allocation] decimal(10,2) NULL,
	[current_bill_rate_hr] decimal(10,2) NULL,
	[current_bill_rate_day] decimal(10,2) NULL,
	[comment] [nvarchar](1000) NULL,
	[action_flag] [nvarchar](100) NULL,
	[reason] [nvarchar](100) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_forecast_company_code_id ON [staging].[bulk_update_forecast_cleansed] ([company_code_id]);
CREATE INDEX idx_forecast_business_unit_id ON [staging].[bulk_update_forecast_cleansed] ([business_unit_id]);
CREATE INDEX idx_forecast_department_id ON [staging].[bulk_update_forecast_cleansed] ([department_id]);
CREATE INDEX idx_forecast_cost_center_code_id ON [staging].[bulk_update_forecast_cleansed] ([cost_center_code_id]);
CREATE INDEX idx_forecast_department_leader_id ON [staging].[bulk_update_forecast_cleansed] ([department_leader_id]);
CREATE INDEX idx_forecast_team_leader_id ON [staging].[bulk_update_forecast_cleansed] ([team_leader_id]);
CREATE INDEX idx_forecast_business_owner_id ON [staging].[bulk_update_forecast_cleansed] ([business_owner_id]);
CREATE INDEX idx_forecast_primary_contact_id ON [staging].[bulk_update_forecast_cleansed] ([primary_contact_id]);
CREATE INDEX idx_forecast_supplier_id ON [staging].[bulk_update_forecast_cleansed] ([supplier_id]);
CREATE INDEX idx_forecast_contractor_id ON [staging].[bulk_update_forecast_cleansed] ([contractor_id]);
CREATE INDEX idx_forecast_worker_start_date_id ON [staging].[bulk_update_forecast_cleansed] ([worker_start_date_id]);
CREATE INDEX idx_forecast_worker_end_date_id ON [staging].[bulk_update_forecast_cleansed] ([worker_end_date_id]);
CREATE INDEX idx_forecast_override_end_date_id ON [staging].[bulk_update_forecast_cleansed] ([override_end_date_id]);
CREATE INDEX idx_forecast_main_document_title_id ON [staging].[bulk_update_forecast_cleansed] ([main_document_title_id]);
CREATE INDEX idx_forecast_cost_object_code_id ON [staging].[bulk_update_forecast_cleansed] ([cost_object_code_id]);
CREATE INDEX idx_forecast_site_id ON [staging].[bulk_update_forecast_cleansed] ([site_id]);
CREATE INDEX idx_forecast_account_code_id ON [staging].[bulk_update_forecast_cleansed] ([account_code_id]);
CREATE INDEX idx_forecast_work_type_id ON [staging].[bulk_update_forecast_cleansed] ([work_type_id]);
CREATE INDEX idx_forecast_worker_status_id ON [staging].[bulk_update_forecast_cleansed] ([worker_status_id]);
CREATE INDEX idx_forecast_work_order_category_id ON [staging].[bulk_update_forecast_cleansed] ([work_order_category_id]);
CREATE INDEX idx_forecast_expense_classification_id ON [staging].[bulk_update_forecast_cleansed] ([expense_classification_id]);
CREATE INDEX idx_forecast_budget_code_id ON [staging].[bulk_update_forecast_cleansed] ([budget_code_id]);
CREATE INDEX idx_forecast_segmentation_id ON [staging].[bulk_update_forecast_cleansed] ([segmentation_id]);
CREATE INDEX idx_forecast_platform_id ON [staging].[bulk_update_forecast_cleansed] ([platform_id]);
CREATE INDEX idx_forecast_function_id ON [staging].[bulk_update_forecast_cleansed] ([function_id]);
CREATE INDEX idx_forecast_support_scalable_id ON [staging].[bulk_update_forecast_cleansed] ([support_scalable_id]);


DROP TABLE IF EXISTS [staging].[bulk_update_forecast_lineitems];
CREATE TABLE [staging].[bulk_update_forecast_lineitems](
	[Forecast Line Item ID] [nvarchar](255) NOT NULL,
	[Forecast ID] [nvarchar](255) NULL,
	[Forecast Description] [nvarchar](255) NULL,
	[Forecast Comment] [nvarchar](255) NULL,
	[Work Order ID] [nvarchar](255) NULL,
	[Allocation] [nvarchar](255) NULL,
	[Date] [nvarchar](255) NULL,
	[Forecast Value] [nvarchar](255) NULL,
	[Budget Value] [nvarchar](255) NULL,
	[Q1F Value] [nvarchar](255) NULL,
	[Q2F Value] [nvarchar](255) NULL,
	[Q3F Value] [nvarchar](255) NULL,
	[Spring Forecast Value] [nvarchar](255) NULL,
	[Summer Forecast Value] [nvarchar](255) NULL,
	[Is Actualized] [nvarchar](255) NULL
) ON [PRIMARY]
GO


--SELECT * FROM [staging].[bulk_update_forecast_lineitems]