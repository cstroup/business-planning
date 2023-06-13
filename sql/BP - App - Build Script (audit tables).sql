USE TEST
GO


DROP TABLE IF EXISTS [audit].[user_actions];
CREATE TABLE [audit].[user_actions](
	[user_actions_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	-- non FKs
	[action_type] [nvarchar](100) NULL,
	[action_sql] [nvarchar](MAX) NULL,
	[requested_by] [nvarchar](100) NOT NULL DEFAULT CURRENT_USER,
	[requested_date] DATETIME DEFAULT GETDATE(),
	[is_error] bit DEFAULT 0
) ON [PRIMARY]
GO
;
CREATE INDEX idx_user_actions_requested_date ON [audit].[user_actions] ([requested_date]);
CREATE INDEX idx_user_actions_requested_by ON [audit].[user_actions] ([requested_by]);


DROP TABLE IF EXISTS [audit].[etl_executions];
CREATE TABLE [audit].[etl_executions](
	[etl_executions_id] bigint IDENTITY(1000,1) PRIMARY KEY,
	-- non FKs
	[job_name] [nvarchar](100) NULL,
	[file_name] [nvarchar](1000) NULL,
	[requested_date] DATETIME DEFAULT GETDATE(),
	[completed_date] DATETIME NULL,
	[requested_by] [nvarchar](100) DEFAULT CURRENT_USER,
	[created_date] DATETIME DEFAULT CURRENT_TIMESTAMP,
	[is_error] bit DEFAULT 0,
	[error_message] [nvarchar](1000) NULL,
) ON [PRIMARY]
GO
;
CREATE INDEX idx_etl_executions_requested_date ON [audit].[etl_executions] ([requested_date]);
CREATE INDEX idx_etl_executions_completed_date ON [audit].[etl_executions] ([completed_date]);
        