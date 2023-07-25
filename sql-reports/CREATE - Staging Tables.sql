--USE [TEST]
--GO
USE [REPORTING]
GO

--CREATE SCHEMA [staging];
--GO

DROP TABLE IF EXISTS [staging].[allocations_timesheets];
CREATE TABLE [staging].[allocations_timesheets](
	[Time Sheet ID] [nvarchar](254) NULL,
	[PID] [nvarchar](254) NULL,
	[Worker] [nvarchar](254) NULL,
	[Work Order ID] [nvarchar](254) NULL,
	[Work Order Revision #] [nvarchar](254) NULL,
	[Allocation %] [nvarchar](254) NULL,
	[Work Order Status] [nvarchar](254) NULL,
	[Work Order Start Date] [nvarchar](254) NULL,
	[Work Order End Date] [nvarchar](254) NULL,
	[Purchase Order Number] [nvarchar](254) NULL,
	[Worker Supervisor] [nvarchar](254) NULL,
	[Business Unit] [nvarchar](254) NULL,
	[Job Posting Title] [nvarchar](254) NULL,
	[Main Document ID] [nvarchar](254) NULL,
	[Invoice ID] [nvarchar](254) NULL,
	[Time Sheet Billable Hours] [nvarchar](254) NULL,
	[Bill Rate [ST/Hr]]] [nvarchar](254) NULL,
	[Bill Rate [OT/Hr]]] [nvarchar](254) NULL,
	[Bill Rate [ST | DAILY/Day]]] [nvarchar](254) NULL,
	[Time Sheet Amount] [nvarchar](254) NULL,
	[Department of Hiring Manager] [nvarchar](254) NULL,
	[Supplier] [nvarchar](254) NULL,
	[Manager] [nvarchar](254) NULL,
	[Cost Object] [nvarchar](254) NULL,
	[Cost Object Code] [nvarchar](254) NULL,
	[Time Sheet Status] [nvarchar](254) NULL,
	[Time Sheet End Date] [nvarchar](254) NULL,
	[Time Sheet Submit Date] [nvarchar](254) NULL,
	[Revision #] [nvarchar](254) NULL,
	[Cumulative Spend to Date] [float] NULL,
	[Other Pending Spend] [float] NULL,
	[Remaining Estimated Hours] [float] NULL,
	[Spend to Date] [float] NULL,
	[Worker Type] [varchar](255) NULL
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [staging].[contractor_active_report];
CREATE TABLE [staging].[contractor_active_report](
	[Worker PID] [varchar](255) NULL,
	[Worker] [nvarchar](255) NULL,
	[Team Lead] [varchar](255) NULL,
	[Mgr Name] [varchar](255) NULL,
	[Supplier] [varchar](255) NULL,
	[Business Unit] [varchar](255) NULL,
	[Department Lead] [varchar](255) NULL,
	[EVP] [varchar](255) NULL,
	[Start Date] [date] NULL,
	[Worker End Date] [date] NULL,
	[Department Description] [varchar](255) NULL
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [staging].[contractor_details];
CREATE TABLE [staging].[contractor_details](
	[Worker] [nvarchar](255) NULL,
	[PID] [varchar](255) NULL,
	[Region] [varchar](255) NULL,
	[Supplier] [varchar](255) NULL,
	[Main Document Title] [nvarchar](255) NULL,
	[Latest Work Order Status] [varchar](255) NULL,
	[Business Unit] [varchar](255) NULL,
	[Sub Business Unit] [varchar](255) NULL,
	[Department of Hiring Manager] [varchar](255) NULL,
	[Worker: New Primary Contact] [varchar](255) NULL,
	[Work Order Owner Email] [varchar](255) NULL,
	[Worker: Worker Supervisor] [varchar](255) NULL,
	[Official Start Date] [date] NULL,
	[Cost Object Code] [varchar](255) NULL,
	[Current Allocation %] [float] NULL,
	[Revision #] [float] NULL,
	[Max Requested Bill Rate [ST/Hr]]] [float] NULL,
	[Max Template Bill Rate [ST/Hr]]] [float] NULL,
	[Current Bill Rate [ST/Hr]]] [float] NULL,
	[Country] [varchar](255) NULL,
	[Worker Work Location State/Provincee] [varchar](255) NULL,
	[Worker Site City] [varchar](255) NULL,
	[Work Order - Cumulative Committed Spend] [float] NULL,
	[Worker - Cumulative Committed Spend] [float] NULL,
	[Work Order End Date] [date] NULL,
	[Work Order Original End Date] [date] NULL,
	[Maximum Worker End Date] [varchar](255) NULL,
	[Cost Object] [varchar](255) NULL,
	[Cumulative Spend to Date] [float] NULL,
	[Other Pending Spend] [float] NULL,
	[Remaining Estimated Hours] [float] NULL,
	[Spend to Date] [float] NULL,
	[Worker Type] [varchar](255) NULL
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [staging].[wbs_codes];
CREATE TABLE [staging].[wbs_codes](
	[Year] [float] NULL,
	[Appropriation Request] [varchar](255) NULL,
	[Initiative] [nvarchar](255) NULL,
	[WBS Code] [varchar](255) NULL,
	[BU Initiative] [varchar](255) NULL,
	[Funding Group] [varchar](255) NULL,
	[Planner] [varchar](255) NULL,
	[Business Owner] [varchar](255) NULL
) ON [PRIMARY]
GO



