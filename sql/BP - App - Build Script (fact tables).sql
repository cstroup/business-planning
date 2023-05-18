USE TEST
GO

--[forecast_id]
DROP TABLE IF EXISTS [dbo].[forecast];
CREATE TABLE [dbo].[forecast](
	[forecast_id] bigint IDENTITY(1000,1) PRIMARY KEY,
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
	[contractor_first_name] [nvarchar](100) NULL,
	[contractor_last_name] [nvarchar](100) NULL,
	[comment] [nvarchar](1000) NULL,
	[old_forecast_id] bigint NULL, -- this is for the migration
	[is_deleted] bit DEFAULT 0,
	[created_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[created_date] DATETIME DEFAULT GETDATE(),
	[updated_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[updated_date] DATETIME DEFAULT GETDATE(),
) ON [PRIMARY]
GO
;
CREATE INDEX idx_forecast_company_code_id ON [dbo].[forecast] ([company_code_id]);
CREATE INDEX idx_forecast_business_unit_id ON [dbo].[forecast] ([business_unit_id]);
CREATE INDEX idx_forecast_department_id ON [dbo].[forecast] ([department_id]);
CREATE INDEX idx_forecast_cost_center_code_id ON [dbo].[forecast] ([cost_center_code_id]);
CREATE INDEX idx_forecast_department_leader_id ON [dbo].[forecast] ([department_leader_id]);
CREATE INDEX idx_forecast_team_leader_id ON [dbo].[forecast] ([team_leader_id]);
CREATE INDEX idx_forecast_business_owner_id ON [dbo].[forecast] ([business_owner_id]);
CREATE INDEX idx_forecast_primary_contact_id ON [dbo].[forecast] ([primary_contact_id]);
CREATE INDEX idx_forecast_supplier_id ON [dbo].[forecast] ([supplier_id]);
CREATE INDEX idx_forecast_contractor_id ON [dbo].[forecast] ([contractor_id]);
CREATE INDEX idx_forecast_worker_start_date_id ON [dbo].[forecast] ([worker_start_date_id]);
CREATE INDEX idx_forecast_worker_end_date_id ON [dbo].[forecast] ([worker_end_date_id]);
CREATE INDEX idx_forecast_override_end_date_id ON [dbo].[forecast] ([override_end_date_id]);
CREATE INDEX idx_forecast_main_document_title_id ON [dbo].[forecast] ([main_document_title_id]);
CREATE INDEX idx_forecast_cost_object_code_id ON [dbo].[forecast] ([cost_object_code_id]);
CREATE INDEX idx_forecast_site_id ON [dbo].[forecast] ([site_id]);
CREATE INDEX idx_forecast_account_code_id ON [dbo].[forecast] ([account_code_id]);
CREATE INDEX idx_forecast_work_type_id ON [dbo].[forecast] ([work_type_id]);
CREATE INDEX idx_forecast_worker_status_id ON [dbo].[forecast] ([worker_status_id]);
CREATE INDEX idx_forecast_work_order_category_id ON [dbo].[forecast] ([work_order_category_id]);
CREATE INDEX idx_forecast_expense_classification_id ON [dbo].[forecast] ([expense_classification_id]);
CREATE INDEX idx_forecast_budget_code_id ON [dbo].[forecast] ([budget_code_id]);
CREATE INDEX idx_forecast_segmentation_id ON [dbo].[forecast] ([segmentation_id]);
CREATE INDEX idx_forecast_platform_id ON [dbo].[forecast] ([platform_id]);
CREATE INDEX idx_forecast_function_id ON [dbo].[forecast] ([function_id]);
CREATE INDEX idx_forecast_old_forecast_id ON [dbo].[forecast] ([old_forecast_id]);
CREATE INDEX idx_forecast_support_scalable_id ON [dbo].[forecast] ([support_scalable_id]);



--DROP TABLE IF EXISTS [dbo].[forecast_line_item];
--CREATE TABLE [dbo].[forecast_line_item](
--	[forecast_line_item_id] [bigint] IDENTITY(1000,1) NOT NULL,
--	[forecast_id] [bigint] NOT NULL,
--	[date_id] [bigint] NOT NULL,
--	[amount] [decimal](20, 2) NOT NULL DEFAULT 0,
--	[is_actual] [bit] NULL DEFAULT 0,
--	[is_deleted] [bit] NULL DEFAULT 0,
--	[created_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
--	[created_date] DATETIME DEFAULT GETDATE(),
--	[updated_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
--	[updated_date] DATETIME DEFAULT GETDATE(),
--) ON [PRIMARY]
--CREATE INDEX idx_forecast_line_item_forecast_id ON [dbo].[forecast_line_item] ([forecast_id]);
--CREATE INDEX idx_forecast_line_item_date_id ON [dbo].[forecast_line_item] ([date_id]);



DROP TABLE IF EXISTS [dbo].[forecast_line_item_v2];
CREATE TABLE [dbo].[forecast_line_item_v2](
	[forecast_line_item_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[forecast_id] bigint NOT NULL,
	[date_id] bigint NOT NULL,
	[amount] decimal(20,2) NOT NULL DEFAULT 0, -- the same as forecast?
	[forecast] decimal(20,2) NOT NULL DEFAULT 0,
	[budget] decimal(20,2) NOT NULL DEFAULT 0,
	[q1f] decimal(20,2) NOT NULL DEFAULT 0,
	[q2f] decimal(20,2) NOT NULL DEFAULT 0,
	[q3f] decimal(20,2) NOT NULL DEFAULT 0,
	[forecast_spring] decimal(20,2) NOT NULL DEFAULT 0,
	[forecast_summer] decimal(20,2) NOT NULL DEFAULT 0,
	[actual] decimal(20,2) NOT NULL DEFAULT 0,
	[is_deleted] bit DEFAULT 0,
	[is_actualized] bit DEFAULT 0,
	[created_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[created_date] DATETIME DEFAULT GETDATE(),
	[updated_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[updated_date] DATETIME DEFAULT GETDATE(),
) ON [PRIMARY]
GO
;
CREATE INDEX idx_forecast_line_item_forecast_id ON [dbo].[forecast_line_item_v2] ([forecast_id]);
CREATE INDEX idx_forecast_line_item_date_id ON [dbo].[forecast_line_item_v2] ([date_id]);



DROP TABLE IF EXISTS [dbo].[general_ledger];
CREATE TABLE [dbo].[general_ledger](
	[general_ledger_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[journal_entry_date_id] bigint NULL,
	[posting_date_id] bigint NULL,
	[journal_entry_type_id] bigint NULL,
	[assignment_reference_id] bigint NULL,
	[account_id] bigint NULL, -- gl name & gl account
	[department_id] bigint NULL,
	[profit_center_id] bigint NULL,
	[cost_center_code_id] bigint NULL,
	[wbs_code_id] bigint NULL, -- cost object code
	[project_type_id] bigint NULL,
	[project_id] bigint NULL,
	[supplier_id] bigint NULL,
	[expense_type_id] bigint NULL,
	[forecast_id] bigint NULL,
	[auto_tag_id] bigint NULL,

	[actual_amount]  DECIMAL(20,2) NULL,
	[purchase_order_number] [nvarchar](254),
	[po_composite] [nvarchar](254),
	[po_cost_object_composite] [nvarchar](254),
	[header_text] [nvarchar](254),
	[item_text] [nvarchar](254),
	[journal_entry_created_by] [nvarchar](254),
	[journal_entry] bigint,
	[journal_entry_item] bigint,
	[journal_entry_composite] [nvarchar](254), -- this is like a natural key [journal_entry] + [journal_entry_item]
	[comment] [nvarchar](1000) NULL,
	[is_deleted] bit DEFAULT 0,
	[created_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[created_date] DATETIME DEFAULT GETDATE(),
	[updated_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[updated_date] DATETIME DEFAULT GETDATE(),
) ON [PRIMARY]
GO
;
CREATE INDEX idx_gl_purchasing_order_number ON [dbo].[general_ledger] ([purchase_order_number]); -- str
CREATE INDEX idx_gl_po_composite ON [dbo].[general_ledger] ([po_composite]); -- str
CREATE INDEX idx_gl_je_composite ON [dbo].[general_ledger] ([journal_entry_composite]); -- str
CREATE INDEX idx_gl_journal_entry_date_id ON [dbo].[general_ledger] ([journal_entry_date_id]);
CREATE INDEX idx_gl_posting_date_id ON [dbo].[general_ledger] ([posting_date_id]);
CREATE INDEX idx_gl_journal_entry_type_id ON [dbo].[general_ledger] ([journal_entry_type_id]);
CREATE INDEX idx_gl_assignment_reference_id ON [dbo].[general_ledger] ([assignment_reference_id]);
CREATE INDEX idx_gl_account_id ON [dbo].[general_ledger] ([account_id]);
CREATE INDEX idx_gl_department_id ON [dbo].[general_ledger] ([department_id]);
CREATE INDEX idx_gl_profit_center_id ON [dbo].[general_ledger] ([profit_center_id]);
CREATE INDEX idx_gl_wbs_code_id ON [dbo].[general_ledger] ([wbs_code_id]);
CREATE INDEX idx_gl_project_type_id ON [dbo].[general_ledger] ([project_type_id]);
CREATE INDEX idx_gl_project_id ON [dbo].[general_ledger] ([project_id]);
CREATE INDEX idx_gl_supplier_id ON [dbo].[general_ledger] ([supplier_id]);
CREATE INDEX idx_expense_type_id ON [dbo].[general_ledger] ([expense_type_id]);
CREATE INDEX idx_forecast_id ON [dbo].[general_ledger] ([forecast_id]);
CREATE INDEX idx_auto_tag_id ON [dbo].[general_ledger] ([auto_tag_id]);
CREATE INDEX idx_po_cost_object_composite ON [dbo].[general_ledger] ([po_cost_object_composite]);
CREATE INDEX idx_created_date ON [dbo].[general_ledger] ([created_date]);



DROP TABLE IF EXISTS [dbo].[auto_tag];
CREATE TABLE [dbo].[auto_tag](
	[auto_tag_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[cost_center_code_id] bigint,
	[account_code_id] bigint,
	[cost_object_code_id] bigint,
	[purchase_order_number] [nvarchar](254),
	[po_composite] [nvarchar](254),
	[po_cost_object_composite] [nvarchar](254),
	[forecast_id] bigint,
	[old_auto_tag_id] bigint NULL, -- this is for the migration
	[is_deleted] bit DEFAULT 0,
	[created_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[created_date] DATETIME DEFAULT GETDATE(),
	[updated_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[updated_date] DATETIME DEFAULT GETDATE(),
) ON [PRIMARY]
GO
;
CREATE INDEX idx_auto_tag_cost_center_code_id ON [dbo].[auto_tag] ([cost_center_code_id]);
CREATE INDEX idx_auto_tag_account_code_id ON [dbo].[auto_tag] ([account_code_id]);
CREATE INDEX idx_cost_center_code_id ON [dbo].[auto_tag] ([cost_center_code_id]);
CREATE INDEX idx_purchase_order_number ON [dbo].[auto_tag] ([purchase_order_number]);
CREATE INDEX idx_po_composite ON [dbo].[auto_tag] ([po_composite]);
CREATE INDEX idx_forecast_id ON [dbo].[auto_tag] ([forecast_id]);
CREATE INDEX idx_cost_object_code_id ON [dbo].[auto_tag] ([cost_object_code_id]);
CREATE INDEX idx_po_cost_object_composite ON [dbo].[auto_tag] ([po_cost_object_composite]);
CREATE INDEX idx_old_auto_tag_id ON [dbo].[auto_tag] ([old_auto_tag_id]);



-- work orders history
DROP TABLE IF EXISTS [dbo].[work_order];
CREATE TABLE [dbo].[work_order](
	[id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[work_order_status_id] bigint, 
	[job_posting_creator_id] bigint, -- employee_id
	[job_posting_approver_id] bigint, -- employee_id
	[svp_id] bigint NULL, -- employee_id
	[worker_type_id] bigint, -- same as work_type
	[worker_status_id] bigint,
	[main_document_title_id] bigint NULL,
	[worker_start_date_id] bigint NULL,
	[worker_end_date_id] bigint NULL,
	[primary_contact_id] bigint NULL,
	[department_id] bigint NULL,
	[supplier_id] bigint NULL,
	[business_unit_id] bigint NULL,
	[location_id] bigint NULL,
	[company_code_id] bigint NULL,
	[cost_object_code_id] bigint NULL,
	[contractor_id] bigint NULL,
	-- non fk
	[job_posting_id] [nvarchar](254),
	[work_order_id] [nvarchar](254),
	[purchase_order_number] [nvarchar](254), 
	[revision_number] int,
	[current_bill_rate] decimal(20,2) NOT NULL DEFAULT 0,
	[hours_per_week] decimal(20,2) NOT NULL DEFAULT 0,
	[hours_per_day] decimal(20,2) NOT NULL DEFAULT 0,
	[allocation_percentage] decimal(20,2) NOT NULL DEFAULT 0,
	[cumulative_committed_spend] decimal(20,2) NOT NULL DEFAULT 0,
	[spend_to_date] decimal(20,2) NOT NULL DEFAULT 0,
	[other_pending_spend] decimal(20,2) NOT NULL DEFAULT 0,
	[remaining_spend] decimal(20,2) NOT NULL DEFAULT 0,
	[work_order_tenure] int,
	[work_order_composite] [nvarchar](254),
	[work_order_short_composite] [nvarchar](254),
	[is_deleted] bit DEFAULT 0,
	[created_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[created_date] DATETIME DEFAULT GETDATE(),
	[updated_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[updated_date] DATETIME DEFAULT GETDATE(),
) ON [PRIMARY]
GO
;
CREATE INDEX idx__work_order_work_order_status ON [dbo].[work_order] ([work_order_status_id]);
CREATE INDEX idx__work_order_job_posting_creator_id ON [dbo].[work_order] ([job_posting_creator_id]);
CREATE INDEX idx__work_order_job_approver_creator_id ON [dbo].[work_order] ([job_posting_approver_id]);
CREATE INDEX idx__work_order_svp_id ON [dbo].[work_order] ([svp_id]);
CREATE INDEX idx__work_order_worker_type_id ON [dbo].[work_order] ([worker_type_id]);
CREATE INDEX idx__work_order_worker_status_id ON [dbo].[work_order] ([worker_status_id]);
CREATE INDEX idx__work_order_main_document_title_id ON [dbo].[work_order] ([main_document_title_id]);
CREATE INDEX idx__work_order_worker_start_date_id ON [dbo].[work_order] ([worker_start_date_id]);
CREATE INDEX idx__work_order_worker_end_date_id ON [dbo].[work_order] ([worker_end_date_id]);
CREATE INDEX idx__work_order_primary_contact_id ON [dbo].[work_order] ([primary_contact_id]);
CREATE INDEX idx__work_order_department_id ON [dbo].[work_order] ([department_id]);
CREATE INDEX idx__work_order_supplier_id ON [dbo].[work_order] ([supplier_id]);
CREATE INDEX idx__work_order_business_unit_id ON [dbo].[work_order] ([business_unit_id]);
CREATE INDEX idx__work_order_location_id ON [dbo].[work_order] ([location_id]);
CREATE INDEX idx__work_order_company_code_id ON [dbo].[work_order] ([company_code_id]);
CREATE INDEX idx__work_order_cost_object_code_id ON [dbo].[work_order] ([cost_object_code_id]);
CREATE INDEX idx__work_order_contractor_id ON [dbo].[work_order] ([contractor_id]);
CREATE INDEX idx__work_order_work_order_composite ON [dbo].[work_order] ([work_order_composite]);
CREATE INDEX idx__work_order_work_order_short_composite ON [dbo].[work_order] ([work_order_short_composite]);


-- work orders not in forecast
-- prompt user if wanting to add the work order to forecast
DROP TABLE IF EXISTS [dbo].[work_order_add_to_forecast];
CREATE TABLE [dbo].[work_order_add_to_forecast](
	[work_order_add_to_forecast_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	[work_order_id] bigint, -- this is id from work_order
	[is_added] bit DEFAULT 0,
	[is_ignored] bit DEFAULT 0,
	[is_deleted] bit DEFAULT 0,
	[action_by] [nvarchar](100) NULL,
	[action_date] DATETIME NULL,
	[created_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[created_date] DATETIME DEFAULT GETDATE(),
	[updated_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[updated_date] DATETIME DEFAULT GETDATE()
)
GO
;
CREATE INDEX idx_work_order_add_to_forecast_work_order_id ON [dbo].[work_order_add_to_forecast] ([work_order_id]);