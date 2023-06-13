--	CREATE STAGING TABLES
USE TEST
GO
;

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
