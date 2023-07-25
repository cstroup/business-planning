--USE TEST
--GO

USE PLANNING_APP
GO

--CREATE SCHEMA [audit];
--GO

--CREATE SCHEMA [etl];
--GO

--CREATE SCHEMA [snapshot];
--GO

--CREATE SCHEMA [staging];
--GO

--[account_id]
DROP TABLE IF EXISTS [dbo].[account];

CREATE TABLE [dbo].[account](
	[account_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[account_code] bigint NULL,
	[account_name] [nvarchar](254) NULL,
	[pl_rollup_level_1] [nvarchar](254) NULL,
	[pl_rollup_level_2] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_account_raw ON [dbo].[account] ([raw]);
SET IDENTITY_INSERT [dbo].[account] ON
INSERT INTO [dbo].[account]
           ([account_id]
		   ,[account_code]
           ,[account_name]
		   ,[pl_rollup_level_1]
		   ,[pl_rollup_level_2]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL,  NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[account] OFF



--[assignment_reference]
DROP TABLE IF EXISTS [dbo].[assignment_reference];
CREATE TABLE [dbo].[assignment_reference](
	[assignment_reference_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[assignment_reference] [nvarchar](100) NULL,
	[assignment_reference_description] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_assignment_reference_raw ON [dbo].[assignment_reference] ([raw]);
SET IDENTITY_INSERT [dbo].[assignment_reference] ON
INSERT INTO [dbo].[assignment_reference]
           ([assignment_reference_id]
		   ,[assignment_reference]
           ,[assignment_reference_description]
		   ,[raw])
     VALUES
           (0, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[assignment_reference] OFF


--[budget_code]
DROP TABLE IF EXISTS [dbo].[budget_code];
CREATE TABLE [dbo].[budget_code](
	[budget_code_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[segmentation_id] bigint NULL,
	[platform_id] bigint NULL,
	[budget_code] [nvarchar](100) NULL,
	[budget_name] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_budget_code_raw ON [dbo].[budget_code] ([raw]);
SET IDENTITY_INSERT [dbo].[budget_code] ON
INSERT INTO [dbo].[budget_code]
           ([budget_code_id]
		   ,[segmentation_id]
		   ,[platform_id]
		   ,[budget_code]
		   ,[budget_name]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[budget_code] OFF


-- BUSINESS UNIT
DROP TABLE IF EXISTS [dbo].[business_unit];
CREATE TABLE [dbo].[business_unit](
	[business_unit_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[business_unit] [nvarchar](254) NULL,
	[raw] [nvarchar](100) NULL
) ON [PRIMARY]
GO
;
CREATE INDEX idx_business_unit_raw ON [dbo].[business_unit] ([raw]);
SET IDENTITY_INSERT [dbo].[business_unit] ON
INSERT INTO [dbo].[business_unit]
           ([business_unit_id]
		   ,[business_unit]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[business_unit] OFF


--[company_code]
DROP TABLE IF EXISTS [dbo].[company_code];
CREATE TABLE [dbo].[company_code](
	[company_code_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[company_code] bigint NULL,
	[company_description] [nvarchar](100) NULL,
	[company_type] [nvarchar](100) NULL,
	[legal_entity_name] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_company_code_raw ON [dbo].[company_code] ([raw]);
SET IDENTITY_INSERT [dbo].[company_code] ON
INSERT INTO [dbo].[company_code]
           ([company_code_id]
		   ,[company_code]
           ,[company_description]
           ,[company_type]
           ,[legal_entity_name]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL, NULL, '0')
;
SET IDENTITY_INSERT [dbo].[company_code] OFF



--[contractor]
DROP TABLE IF EXISTS [dbo].[contractor];
CREATE TABLE [dbo].[contractor](
	[contractor_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[worker_id] [nvarchar](100) NULL,
	[pid] [nvarchar](100) NULL,
	[first_name] [nvarchar](100) NULL,
	[last_name] [nvarchar](100) NULL,
	[full_name] [nvarchar](100) NULL,
	[worker_site] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_contractor_raw ON [dbo].[contractor] ([raw]);
CREATE INDEX idx_contractor_pid ON [dbo].[contractor] ([pid]);
SET IDENTITY_INSERT [dbo].[contractor] ON
INSERT INTO [dbo].[contractor]
           ([contractor_id]
		   ,[worker_id]
           ,[pid]
           ,[first_name]
           ,[last_name]
           ,[full_name]
           ,[worker_site]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL, NULL,
		   NULL, NULL, NULL)
;
SET IDENTITY_INSERT [dbo].[contractor] OFF

UPDATE [dbo].[contractor]
SET [raw] = 'Unknown'
WHERE [contractor_id] = 0
;



--[cost_center_code_id]
DROP TABLE IF EXISTS [dbo].[cost_center_code];
CREATE TABLE [dbo].[cost_center_code](
	[cost_center_code_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[cost_center_code] bigint NULL,
	[cost_center] [nvarchar](254) NULL,
	[company_code_id] bigint NULL, -- FK to company_code; left 3 of cc code
	[entity_code] bigint NULL, -- middle 4 of cc code
	[department_code] bigint NULL, -- last 3 of cc code
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_cost_center_code_raw ON [dbo].[cost_center_code] ([raw]);
SET IDENTITY_INSERT [dbo].[cost_center_code] ON
INSERT INTO [dbo].[cost_center_code]
           ([cost_center_code_id]
		   ,[cost_center_code]
           ,[cost_center]
           ,[company_code_id]
           ,[entity_code]
           ,[department_code]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL, NULL, NULL, '0')
;
SET IDENTITY_INSERT [dbo].[cost_center_code] OFF


--[wbs_code_id] / cost object code
DROP TABLE IF EXISTS [dbo].[cost_object_code];
CREATE TABLE [dbo].[cost_object_code](
	[cost_object_code_id] int IDENTITY(1000,1) PRIMARY KEY,
	[cost_object_code] [nvarchar](100) NULL,
	[cost_object_name] [nvarchar](254) NULL,
	[appropriation_request] [nvarchar](254) NULL,
	[initiative] [nvarchar](254) NULL,
	[bu_initiative] [nvarchar](254) NULL,
	[funding_group] [nvarchar](254) NULL,
	[planner] [nvarchar](254) NULL,
	[business_owner] [nvarchar](254) NULL,
	[is_opex] bit NULL,
	[budget_code] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_cost_object_code_raw ON [dbo].[cost_object_code] ([raw]);
SET IDENTITY_INSERT [dbo].[cost_object_code] ON
INSERT INTO [dbo].[cost_object_code]
           ([cost_object_code_id]
		   ,[cost_object_code]
           ,[cost_object_name]
           ,[appropriation_request]
           ,[initiative]
           ,[bu_initiative]
           ,[funding_group]
           ,[planner]
           ,[business_owner]
           ,[is_opex]
           ,[budget_code]
           ,[raw])
     VALUES
           (0,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   0,
		   NULL,
		   'Unknown')
;
SET IDENTITY_INSERT [dbo].[cost_object_code] OFF


-- DATE
DROP TABLE IF EXISTS [dbo].[date_dimension];
CREATE TABLE [dbo].[date_dimension](
	[date_id] bigint NOT NULL,
	[full_date] [date] NULL,
	[day_of_week_sunday] [int] NULL,
	[day_of_week_monday] [int] NULL,
	[day_name_of_week] [varchar](50) NULL,
	[day_of_month] [int] NULL,
	[day_of_year] [int] NULL,
	[weekday_weekend] [varchar](50) NULL,
	[week_of_month] [int] NULL,
	[week_of_year_sunday] [int] NULL,
	[week_of_year_monday] [int] NULL,
	[month_name] [varchar](50) NULL,
	[month_of_year] [int] NULL,
	[is_last_day_of_month] [int] NULL,
	[is_holiday] [int] NULL,
	[holiday_name] [varchar](50) NULL,
	[calendar_quarter] [int] NULL,
	[calendar_year] [int] NULL,
	[calendar_year_month] [varchar](50) NULL,
	[calendar_year_qtr] [varchar](50) NULL,
	[is_company_holiday] [int] NULL,
	[is_estimated_pto] [int] NOT NULL,
	[onshore_work_hours] [int] NULL,
	[offshore_work_hours] [int] NULL,
	[forecasting_month] [varchar](50) NULL,
	[fiscal_period] [int] NULL,
	[short_month_short_year] [varchar](50) NULL,
	[year_month] [int] NULL,
	[first_of_month_date_key] [int] NULL
) ON [PRIMARY]
GO
;
CREATE CLUSTERED INDEX idx_full_date ON [dbo].[date_dimension] ([full_date]);



-- DEPARTMENT
DROP TABLE IF EXISTS [dbo].[deptartment];
CREATE TABLE [dbo].[deptartment](
	[department_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[segmentation_id] bigint NULL,
	[platform_id] bigint NULL,
	[department_code] [nvarchar](254) NULL,
	[department] [nvarchar](254) NULL,
	[department_long] [nvarchar](254) NULL, -- Video Delivery (782)
	[raw] [nvarchar](254) NULL,
	[essbase_name] VARCHAR(255) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_department_raw ON [dbo].[deptartment] ([raw]);
CREATE INDEX idx_department_essbase_name ON [dbo].[deptartment] ([essbase_name]);
CREATE INDEX idx_department_segmentation_id ON [dbo].[deptartment] ([segmentation_id]);
CREATE INDEX idx_department_platform ON [dbo].[deptartment] ([platform_id]);
SET IDENTITY_INSERT [dbo].[deptartment] ON
INSERT INTO [dbo].[deptartment]
           ([department_id]
		   ,[segmentation_id]
		   ,[platform_id]
		   ,[department_code]
           ,[department]
           ,[department_long]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[deptartment] OFF


-- DEPARTMENT TO BUSINESS UNIT LOOKUP
DROP TABLE IF EXISTS [dbo].[deptartment_business_unit];
CREATE TABLE [dbo].[deptartment_business_unit](
	[department_bu_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[department_id] [nvarchar](254) NOT NULL,
	[business_unit_id] int NOT NULL
) ON [PRIMARY]
GO
;
CREATE INDEX idx_department_id ON [dbo].[deptartment_business_unit] ([department_id]);
CREATE INDEX idx_business_unit_id ON [dbo].[deptartment_business_unit] ([business_unit_id]);
SET IDENTITY_INSERT [dbo].[deptartment_business_unit] ON
INSERT INTO [dbo].[deptartment_business_unit]
           ([department_bu_id]
		   ,[department_id]
		   ,[business_unit_id]
		   )
     VALUES
           (0, 0, 0)
;
SET IDENTITY_INSERT [dbo].[deptartment_business_unit] OFF



--[employee] (includes department leader, team leader, business owner, primary contact, job posting contact, job posting approver, etc...)
DROP TABLE IF EXISTS [dbo].[employee];
CREATE TABLE [dbo].[employee](
	[employee_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[employee] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_employee_raw ON [dbo].[employee] ([raw]);
SET IDENTITY_INSERT [dbo].[employee] ON
INSERT INTO [dbo].[employee]
           ([employee_id]
		   ,[employee]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[employee] OFF


-- ENTITY
-- Company Code	Company Name	Entity Code	Entity Name	Combination
DROP TABLE IF EXISTS [dbo].[entity];
CREATE TABLE [dbo].[entity](
	[entity_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[company_code_id] bigint,
	[entity_code] [nvarchar](100) NULL,
	[entity_name] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_entity_raw ON [dbo].[entity] ([raw]);
SET IDENTITY_INSERT [dbo].[entity] ON
INSERT INTO [dbo].[entity]
           ([entity_id]
		   ,[company_code_id]
		   ,[entity_code]
		   ,[entity_name]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[entity] OFF




--[expense_classification]
DROP TABLE IF EXISTS [dbo].[expense_classification];
CREATE TABLE [dbo].[expense_classification](
	[expense_classification_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[expense_classification] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_expense_classification_raw ON [dbo].[expense_classification] ([raw]);
SET IDENTITY_INSERT [dbo].[expense_classification] ON
INSERT INTO [dbo].[expense_classification]
           ([expense_classification_id]
		   ,[expense_classification]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[expense_classification] OFF


--[expense_type_id]
DROP TABLE IF EXISTS [dbo].[expense_type];
CREATE TABLE [dbo].[expense_type](
	[expense_type_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[expense_type] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_expense_type_raw ON [dbo].[expense_type] ([raw]);
SET IDENTITY_INSERT [dbo].[expense_type] ON
INSERT INTO [dbo].[expense_type]
           ([expense_type_id]
		   ,[expense_type]
		   ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[expense_type] OFF


--[function]
DROP TABLE IF EXISTS [dbo].[function];
CREATE TABLE [dbo].[function](
	[function_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[function] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_function_raw ON [dbo].[function] ([raw]);
SET IDENTITY_INSERT [dbo].[function] ON
INSERT INTO [dbo].[function]
           ([function_id]
		   ,[function]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[function] OFF


--[journal_entry_type]
DROP TABLE IF EXISTS [dbo].[journal_entry_type];
CREATE TABLE [dbo].[journal_entry_type](
	[journal_entry_type_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[journal_entry_type] [nvarchar](100) NULL,
	[journal_entry_type_description] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_journal_entry_type_raw ON [dbo].[journal_entry_type] ([raw]);
SET IDENTITY_INSERT [dbo].[journal_entry_type] ON
INSERT INTO [dbo].[journal_entry_type]
           ([journal_entry_type_id]
		   ,[journal_entry_type]
           ,[journal_entry_type_description]
           ,[raw])
     VALUES
           (0, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[journal_entry_type] OFF



/*
--[leader] (includes department leader, team leader, business owner)
DROP TABLE IF EXISTS [dbo].[leader];
CREATE TABLE [dbo].[leader](
	[leader_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[leader] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_leader_raw ON [dbo].[leader] ([raw]);
SET IDENTITY_INSERT [dbo].[leader] ON
INSERT INTO [dbo].[leader]
           ([leader_id]
		   ,[leader]
           ,[raw])
     VALUES
           (0, 'Unknown', 'Unknown')
;
SET IDENTITY_INSERT [dbo].[leader] OFF
*/



--[location]
DROP TABLE IF EXISTS [dbo].[location];
CREATE TABLE [dbo].[location](
	[location_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[location] [nvarchar](100) NULL,
	[local] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_location_raw ON [dbo].[location] ([raw]);
SET IDENTITY_INSERT [dbo].[location] ON
INSERT INTO [dbo].[location]
           ([location_id]
		   ,[location]
		   ,[local]
           ,[raw])
     VALUES
           (0, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[location] OFF


--[main_document_title]
DROP TABLE IF EXISTS [dbo].[main_document_title];
CREATE TABLE [dbo].[main_document_title](
	[main_document_title_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[main_document_title] [nvarchar](1000) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_main_document_title_raw ON [dbo].[main_document_title] ([raw]);
SET IDENTITY_INSERT [dbo].[main_document_title] ON
INSERT INTO [dbo].[main_document_title]
           ([main_document_title_id]
		   ,[main_document_title]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[main_document_title] OFF


--[platform]
DROP TABLE IF EXISTS [dbo].[platform];
CREATE TABLE [dbo].[platform](
	[platform_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[platform] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_platform_raw ON [dbo].[platform] ([raw]);
SET IDENTITY_INSERT [dbo].[platform] ON
INSERT INTO [dbo].[platform]
           ([platform_id]
		   ,[platform]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[platform] OFF


/*
--[primary_contact]
DROP TABLE IF EXISTS [dbo].[primary_contact];
CREATE TABLE [dbo].[primary_contact](
	[primary_contact_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[primary_contact] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_primary_contact_raw ON [dbo].[primary_contact] ([raw]);
SET IDENTITY_INSERT [dbo].[primary_contact] ON
INSERT INTO [dbo].[primary_contact]
           ([primary_contact_id]
		   ,[primary_contact]
           ,[raw])
     VALUES
           (0, 'Unknown', 'Unknown')
;
SET IDENTITY_INSERT [dbo].[primary_contact] OFF
*/


--[profit_center]
DROP TABLE IF EXISTS [dbo].[profit_center];
CREATE TABLE [dbo].[profit_center](
	[profit_center_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[profit_center] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_profit_center_raw ON [dbo].[profit_center] ([raw]);
SET IDENTITY_INSERT [dbo].[profit_center] ON
INSERT INTO [dbo].[profit_center]
           ([profit_center_id]
		   ,[profit_center]
		   ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[profit_center] OFF


--[project]
DROP TABLE IF EXISTS [dbo].[project];
CREATE TABLE [dbo].[project](
	[project_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[project] [nvarchar](100) NULL,
	[project_name] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_project_raw ON [dbo].[project] ([raw]);
SET IDENTITY_INSERT [dbo].[project] ON
INSERT INTO [dbo].[project]
           ([project_id]
		   ,[project]
           ,[project_name]
		   ,[raw])
     VALUES
           (0, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[project] OFF

ALTER TABLE [dbo].[project]
add [budget_code_id] bigint NULL
;
CREATE INDEX idx_project_budget_code_id ON [dbo].[project] ([budget_code_id]);


--[project_type]
DROP TABLE IF EXISTS [dbo].[project_type];
CREATE TABLE [dbo].[project_type](
	[project_type_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[project_type] [nvarchar](100) NULL,
	[project_type_description] [nvarchar](254) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_project_type_raw ON [dbo].[project_type] ([raw]);
SET IDENTITY_INSERT [dbo].[project_type] ON
INSERT INTO [dbo].[project_type]
           ([project_type_id]
		   ,[project_type]
           ,[project_type_description]
		   ,[raw])
     VALUES
           (0, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[project_type] OFF


--[segmentation]
DROP TABLE IF EXISTS [dbo].[segmentation];
CREATE TABLE [dbo].[segmentation](
	[segmentation_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[segmentation] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_segmentation_raw ON [dbo].[segmentation] ([raw]);
SET IDENTITY_INSERT [dbo].[segmentation] ON
INSERT INTO [dbo].[segmentation]
           ([segmentation_id]
		   ,[segmentation]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[segmentation] OFF


/*
--[site]
DROP TABLE IF EXISTS [dbo].[site];
CREATE TABLE [dbo].[site](
	[site_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[site] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_site_raw ON [dbo].[site] ([raw]);
SET IDENTITY_INSERT [dbo].[site] ON
INSERT INTO [dbo].[site]
           ([site_id]
		   ,[site]
           ,[raw])
     VALUES
           (0, 'Unknown', 'Unknown')
;
SET IDENTITY_INSERT [dbo].[site] OFF
*/


--[supplier_id]
DROP TABLE IF EXISTS [dbo].[supplier];
CREATE TABLE [dbo].[supplier](
	[supplier_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[supplier_code] [nvarchar](100) NULL,
	[supplier] [nvarchar](254) NULL,
	[supplier_long] [nvarchar](254) NULL, -- 8101540 - COGNIZANT WORLDWIDE LIMITED
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_supplier_raw ON [dbo].[supplier] ([raw]);
SET IDENTITY_INSERT [dbo].[supplier] ON
INSERT INTO [dbo].[supplier]
           ([supplier_id]
		   ,[supplier_code]
           ,[supplier]
           ,[supplier_long]
           ,[raw])
     VALUES
           (0, NULL, NULL, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[supplier] OFF


--[support_scalable]
DROP TABLE IF EXISTS [dbo].[support_scalable];
CREATE TABLE [dbo].[support_scalable](
	[support_scalable_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[support_scalable] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_support_scalable_raw ON [dbo].[support_scalable] ([raw]);
SET IDENTITY_INSERT [dbo].[support_scalable] ON
INSERT INTO [dbo].[support_scalable]
           ([support_scalable_id]
		   ,[support_scalable]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[support_scalable] OFF



-- USER SPECIFIC TABLES
DROP TABLE IF EXISTS [dbo].[user];
CREATE TABLE [dbo].[user](
	[user_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[name] [nvarchar](245) NOT NULL,
	[username] [nvarchar](254) NOT NULL,
	[pid] [nvarchar](254) NOT NULL,
	[is_admin] bit DEFAULT 0
) ON [PRIMARY]
GO
;


DROP TABLE IF EXISTS [dbo].[user_access];
CREATE TABLE [dbo].[user_access](
	[user_access_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[user_id] bigint,
	[department_bu_id] bigint,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_user_access_user_id ON [dbo].[user_access] ([user_id]);
CREATE INDEX idx_user_acces_department_bu_id ON [dbo].[user_access] ([department_bu_id]);



--[wo_category]
DROP TABLE IF EXISTS [dbo].[work_order_category];
CREATE TABLE [dbo].[work_order_category](
	[work_order_category_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[work_order_category] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_work_order_category_raw ON [dbo].[work_order_category] ([raw]);
SET IDENTITY_INSERT [dbo].[work_order_category] ON
INSERT INTO [dbo].[work_order_category]
           ([work_order_category_id]
		   ,[work_order_category]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[work_order_category] OFF



--[work order status]
DROP TABLE IF EXISTS [dbo].[work_order_status];
CREATE TABLE [dbo].[work_order_status](
	[work_order_status_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[work_order_status] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_work_order_status_raw ON [dbo].[work_order_status] ([raw]);
SET IDENTITY_INSERT [dbo].[work_order_status] ON
INSERT INTO [dbo].[work_order_status]
           ([work_order_status_id]
		   ,[work_order_status]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[work_order_status] OFF



--[work_type]
DROP TABLE IF EXISTS [dbo].[work_type];
CREATE TABLE [dbo].[work_type](
	[work_type_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[work_type] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_work_type_raw ON [dbo].[work_type] ([raw]);
SET IDENTITY_INSERT [dbo].[work_type] ON
INSERT INTO [dbo].[work_type]
           ([work_type_id]
		   ,[work_type]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[work_type] OFF


--[worker_status]
DROP TABLE IF EXISTS [dbo].[worker_status];
CREATE TABLE [dbo].[worker_status](
	[worker_status_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[worker_status] [nvarchar](100) NULL,
	[raw] [nvarchar](254) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_worker_status_raw ON [dbo].[worker_status] ([raw]);
SET IDENTITY_INSERT [dbo].[worker_status] ON
INSERT INTO [dbo].[worker_status]
           ([worker_status_id]
		   ,[worker_status]
           ,[raw])
     VALUES
           (0, NULL, 'Unknown')
;
SET IDENTITY_INSERT [dbo].[worker_status] OFF





CREATE INDEX idx_account_account_code ON [dbo].[account] ([account_code]);
CREATE INDEX idx_department_department_long ON [dbo].[deptartment] ([department_long]);
CREATE INDEX idx_supplier_supplier ON [dbo].[supplier] ([supplier]);
CREATE INDEX idx_forecast_description ON [dbo].[forecast] ([description]);