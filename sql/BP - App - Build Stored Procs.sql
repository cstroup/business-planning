USE TEST;
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_insert_record_auto_tag];
GO
CREATE PROCEDURE [dbo].[sp_insert_record_auto_tag]
    @gl_id BIGINT,
    @forecast_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;

	-- insert into user actions table
	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('execute_sp_insert_record_auto_tag', 'EXEC [dbo].[sp_insert_record_auto_tag]
	' + CONVERT(varchar(100), IIF(@gl_id IS NULL, -1, @gl_id)) + ',
	' + CONVERT(varchar(100), IIF(@forecast_id IS NULL, -1, @forecast_id)) + ''
	)
	;

	DECLARE @cost_center_code_id BIGINT
	DECLARE @account_code_id BIGINT
	DECLARE @cost_object_code_id BIGINT
	DECLARE @purchase_order_number VARCHAR(200)
	DECLARE @po_composite VARCHAR(200)
	DECLARE @po_cost_object_composite VARCHAR(200)
	DECLARE @new_auto_tag_id BIGINT

	-- first we need the cost center code, account code, cost object code
	-- then we can build all the parts
	-- it should only be one record based on gl_id but limit to top 1 just in case
	-- in the gl if the expense type is for a contractor, we want to use [po_cost_object_composite] else use [po_composite]
	DROP TABLE IF EXISTS #TMP_GL_RECORD;
	SELECT TOP 1
		gl.[cost_center_code_id],
		gl.[account_id] as [account_code_id],
		gl.[wbs_code_id] as [cost_object_code_id],
		gl.[purchase_order_number],
		CASE
			WHEN lower(et.[expense_type]) LIKE '%contractors%'
			THEN NULL
			ELSE gl.[po_composite]
		END as [po_composite],
		CASE
			WHEN lower(et.[expense_type]) LIKE '%contractors%'
			THEN gl.[po_cost_object_composite]
			ELSE NULL
		END as [po_cost_object_composite],
		@forecast_id as [forecast_id]
	INTO #TMP_GL_RECORD
	FROM [dbo].[general_ledger] as gl
	JOIN [dbo].[expense_type] as et
		ON gl.[expense_type_id] = et.[expense_type_id]
	WHERE [general_ledger_id] = @gl_id
	;

	-- set all the variables to what was found in the temp table
	SELECT @cost_center_code_id = (SELECT [cost_center_code_id] FROM #TMP_GL_RECORD);
	SELECT @account_code_id = (SELECT [account_code_id] FROM #TMP_GL_RECORD);
	SELECT @cost_object_code_id = (SELECT [cost_object_code_id] FROM #TMP_GL_RECORD);
	SELECT @purchase_order_number = (SELECT [purchase_order_number] FROM #TMP_GL_RECORD);
	SELECT @po_composite = (SELECT [po_composite] FROM #TMP_GL_RECORD);
	SELECT @po_cost_object_composite = (SELECT [po_cost_object_composite] FROM #TMP_GL_RECORD);

	-- insert new record
	INSERT INTO [dbo].[auto_tag]
		([cost_center_code_id]
		,[account_code_id]
		,[cost_object_code_id]
		,[purchase_order_number]
		,[po_composite]
		,[po_cost_object_composite]
		,[forecast_id])
	SELECT 
		[cost_center_code_id],
		[account_code_id],
		[cost_object_code_id],
		[purchase_order_number],
		[po_composite],
		[po_cost_object_composite],
		[forecast_id]
	FROM #TMP_GL_RECORD
	;

	-- insert into user actions table
	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('insert_new_auto_tag', 'INSERT INTO [dbo].[auto_tag]
	([cost_center_code_id]
	,[account_code_id]
	,[cost_object_code_id]
	,[purchase_order_number]
	,[po_composite]
	,[po_cost_object_composite]
	,[forecast_id])
	(' + CONVERT(varchar(100), IIF(@cost_center_code_id IS NULL, -1, @cost_center_code_id)) + ',
	' + CONVERT(varchar(100), IIF(@account_code_id IS NULL, -1, @account_code_id)) + ',
	' + CONVERT(varchar(100), IIF(@cost_object_code_id IS NULL, -1, @cost_object_code_id)) + ',
	''' + CONVERT(varchar(200), IIF(@purchase_order_number IS NULL, '', @purchase_order_number)) + ''',
	''' + CONVERT(varchar(200), IIF(@po_composite IS NULL, '', @po_composite)) + ''',
	''' + CONVERT(varchar(200), IIF(@po_cost_object_composite IS NULL, '', @po_cost_object_composite)) + ''',
	' + CONVERT(varchar(100), IIF(@forecast_id IS NULL, -1, @forecast_id)) + ')
	;')

	-- get most recently created record based on user
	SELECT @new_auto_tag_id = (SELECT MAX(auto_tag_id) FROM [dbo].[auto_tag] WHERE [created_by] = CURRENT_USER)
	;

	-- first find out if we should update based on [po_cost_object_composite] or [po_composite]
	IF EXISTS (
	SELECT 1 
	FROM [dbo].[auto_tag] 
	WHERE [auto_tag_id] = @new_auto_tag_id 
	AND [po_cost_object_composite] IS NOT NULL
	AND [is_deleted] = 0
	)
	-- if returns 1
	BEGIN
		-- UPDATE based on [po_cost_object_composite]
		UPDATE [dbo].[general_ledger]
		SET [general_ledger].[auto_tag_id] = tag.[auto_tag_id],
			[general_ledger].[updated_by] = CURRENT_USER,
			[general_ledger].[updated_date] = CURRENT_TIMESTAMP
		FROM [dbo].[general_ledger] gl
		JOIN [dbo].[auto_tag] as tag
			ON gl.[po_cost_object_composite] = tag.[po_cost_object_composite]
		WHERE tag.[auto_tag_id] = @new_auto_tag_id
		AND gl.[auto_tag_id] IS NULL

		INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
		VALUES ('update_gl_with_auto_tag_po_cost_object_composite', 'UPDATE [dbo].[general_ledger]
		SET [general_ledger].[auto_tag_id] = tag.[auto_tag_id],
			[general_ledger].[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''',
			[general_ledger].[updated_date] = ''' +  CONVERT(varchar(50), CURRENT_TIMESTAMP) + '''
		FROM [dbo].[general_ledger] gl
		JOIN [dbo].[auto_tag] as tag
			ON gl.[po_cost_object_composite] = tag.[po_cost_object_composite]
		WHERE tag.[auto_tag_id] = ' + CONVERT(varchar(50), @new_auto_tag_id) + '
		AND gl.[auto_tag_id] IS NULL
		;')
	END

	ELSE
	-- returns empty
	BEGIN
		-- UPDATE based on [po_composite]
		UPDATE [dbo].[general_ledger]
		SET [general_ledger].[auto_tag_id] = tag.[auto_tag_id],
			[general_ledger].[updated_by] = CURRENT_USER,
			[general_ledger].[updated_date] = CURRENT_TIMESTAMP
		FROM [dbo].[general_ledger] gl
		JOIN [dbo].[auto_tag] as tag
			ON gl.[po_composite] = tag.[po_composite]
		WHERE tag.[auto_tag_id] = @new_auto_tag_id
		AND gl.[auto_tag_id] IS NULL
		;

		INSERT INTO [audit].[user_actions]
			([action_type], [action_sql])
		VALUES ('update_gl_with_auto_tag_po_composite', 'UPDATE [dbo].[general_ledger]
		SET [general_ledger].[auto_tag_id] = tag.[auto_tag_id],
			[general_ledger].[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''',
			[general_ledger].[updated_date] = ''' +  CONVERT(varchar(50), CURRENT_TIMESTAMP) + '''
		FROM [dbo].[general_ledger] gl
		JOIN [dbo].[auto_tag] as tag
			ON gl.[po_composite] = tag.[po_composite]
		WHERE tag.[auto_tag_id] = ' + CONVERT(varchar(50), @new_auto_tag_id) + '
		AND gl.[auto_tag_id] IS NULL
		;')
		;

	END
END
;
GO


-- EXEC [dbo].[sp_delete_record_auto_tag] {auto_tag_id}

DROP PROCEDURE IF EXISTS [dbo].[sp_delete_record_auto_tag];
GO
CREATE PROCEDURE [dbo].[sp_delete_record_auto_tag]
    @auto_tag_id INT
AS
BEGIN
    SET NOCOUNT ON;

	-- insert into user actions table
	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('execute_sp_delete_record_auto_tag', 'EXEC [dbo].[sp_delete_record_auto_tag]
	' + CONVERT(varchar(100), IIF(@auto_tag_id IS NULL, -1, @auto_tag_id)) + ''
	)
	;

	UPDATE [dbo].[auto_tag] 
    SET [is_deleted] = 1,
		[updated_by] = CURRENT_USER,
		[updated_date] = CURRENT_TIMESTAMP
    WHERE [auto_tag_id] = @auto_tag_id
	;

	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('delete_auto_tag',
	'UPDATE [dbo].[auto_tag] 
    SET [is_deleted] = 1,
		[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''',
		[updated_date] = ''' + CONVERT(varchar(50), CURRENT_TIMESTAMP) + '''
    WHERE [auto_tag_id] = ' + CONVERT(varchar(50), @auto_tag_id) + ' 
	;')
	;

	UPDATE [dbo].[general_ledger]
	SET [auto_tag_id] = NULL,
		[updated_by] = CURRENT_USER,
		[updated_date] = CURRENT_TIMESTAMP
	WHERE [auto_tag_id] = @auto_tag_id
	;

	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('delete_auto_tag_from_gl',
	'UPDATE [dbo].[general_ledger]
	SET [auto_tag_id] = NULL,
		[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''',
		[updated_date] = ''' + CONVERT(varchar(50), CURRENT_TIMESTAMP) + '''
	WHERE [auto_tag_id] = ' + CONVERT(varchar(50), @auto_tag_id) + '
	;')
	;
END
;
GO




-- EXEC [dbo].[sp_delete_forecast_and_forecast_line_item] {forecast_id}

DROP PROCEDURE IF EXISTS [dbo].[sp_delete_forecast_and_forecast_line_item];
GO
CREATE PROCEDURE [dbo].[sp_delete_forecast_and_forecast_line_item]
    @forecast_id INT
AS
BEGIN
    SET NOCOUNT ON;

	-- insert into user actions table
	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('execute_sp_delete_forecast_and_forecast_line_item', 'EXEC [dbo].[sp_delete_forecast_and_forecast_line_item]
	' + CONVERT(varchar(100), IIF(@forecast_id IS NULL, -1, @forecast_id)) + ''
	)
	;

	UPDATE [dbo].[forecast]
	SET [is_deleted] = 1,
		[updated_by] = CURRENT_USER,
		[updated_date] = CURRENT_TIMESTAMP
	WHERE [forecast_id] = @forecast_id
	;

	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('delete_forecast_record',
	'UPDATE [dbo].[forecast] SET [is_deleted] = 1,
		[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''',
		[updated_date] = ''' + CONVERT(varchar(50), CURRENT_TIMESTAMP) + '''
	WHERE [forecast_id] = ' + CONVERT(varchar(50), @forecast_id) + '
	;')
	;

	UPDATE [dbo].[forecast_line_item]
	SET [is_deleted] = 1,
		[updated_by] = CURRENT_USER,
		[updated_date] = CURRENT_TIMESTAMP
	WHERE [forecast_id] = @forecast_id
	;

	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('delete_forecast_lineitem_record', 'UPDATE [dbo].[forecast_line_item]
	SET [is_deleted] = 1,
		[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''',
		[updated_date] = ''' + CONVERT(varchar(50), CURRENT_TIMESTAMP) + '''
	WHERE [forecast_id] = ''' + CONVERT(varchar(50), @forecast_id) + '''
	;')
	;

END
;
GO

--SELECT * FROM [audit].[user_actions] ORDER BY 1 DESC

--SELECT * FROM [dbo].[forecast] ORDER BY [updated_date] DESC

--SELECT * FROM [dbo].[forecast_line_item] ORDER BY 1 DESC




-- EXEC [dbo].[sp_update_record_general_ledger] {@general_ledger_id}, {@forecast_id}, '{@comment}'

DROP PROCEDURE IF EXISTS [dbo].[sp_update_record_general_ledger];
GO
CREATE PROCEDURE [dbo].[sp_update_record_general_ledger]
	@general_ledger_id VARCHAR(100),
	@forecast_id VARCHAR(100),
    @comment VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

	-- insert into user actions table
	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('execute_sp_update_record_general_ledger', 'EXEC [dbo].[sp_update_record_general_ledger]
	''' + CONVERT(varchar(100), IIF(@general_ledger_id IS NULL, '', @general_ledger_id)) + ''',
	''' + CONVERT(varchar(100), IIF(@forecast_id IS NULL, '', @forecast_id)) + ''',
	''' + CONVERT(varchar(1000), IIF(@comment IS NULL, '', @comment)) + ''''
	)
	;

	DECLARE @comment_cleaned VARCHAR(1000)
	DECLARE @forecast_id_cleaned INT
	DECLARE @general_ledger_id_cleaned  INT

	SELECT @comment_cleaned = IIF(LEN(@comment) = 0, NULL, @comment);
	SELECT @forecast_id_cleaned = IIF(LEN(@forecast_id) = 0, NULL, @forecast_id);
	SELECT @general_ledger_id_cleaned = @general_ledger_id;

	UPDATE [dbo].[general_ledger]
	SET [comment] = @comment_cleaned,
		[forecast_id] = @forecast_id_cleaned,
		[updated_by] = CURRENT_USER,
		[updated_date] = CURRENT_TIMESTAMP
	WHERE [general_ledger_id] = @general_ledger_id_cleaned
	;

	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('update_gl_record', 'UPDATE [dbo].[general_ledger]
	SET [comment] = ''' + CONVERT(varchar(50), IIF(@comment_cleaned IS NULL, '', @comment_cleaned)) + ''',
		[forecast_id] = ' + CONVERT(varchar(50), IIF(@forecast_id_cleaned IS NULL, -1, @forecast_id_cleaned)) + ',
		[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''', 
		[updated_date] = ''' + CONVERT(varchar(50), CURRENT_TIMESTAMP) + ''' 
	WHERE [general_ledger_id] = ' + CONVERT(varchar(50), @general_ledger_id_cleaned) + '
	;')
	;
END
;
GO



--EXEC [dbo].[sp_select_work_order_details] '{@work_order_id}'

--EXEC [dbo].[sp_select_work_order_details] '80632'

-- EXEC [dbo].[sp_select_work_order_details] '79247'

DROP PROCEDURE IF EXISTS [dbo].[sp_select_work_order_details];
GO
CREATE PROCEDURE [dbo].[sp_select_work_order_details]
	@work_order_id VARCHAR(100)
AS
BEGIN


SELECT
	MIN(full_date) as [Year Month],
	[forecasting_month] as [Month Year],
	SUM(is_weekend) as [Weekends],
	SUM(is_company_holiday) as [Holiday],
	SUM(is_estimated_pto) as [Estimated PTO],
	SUM(workdays) as [Total Work Days],
	SUM(work_order_workdays) as [Work Order Work Days],
	ROUND(SUM(payments), 2) as [Forecasted Cost]
FROM 
	(SELECT
		wo.[id],
		dates.[full_date],
		dates.[short_month_short_year],
		dates.[calendar_year_month],
		dates.[forecasting_month],
		start_d.[full_date] as worker_start_date,
		end_d.[full_date] as worker_end_date,
		wo.[allocation_percentage],
		wo.[current_bill_rate],
		wo.[hours_per_day],
		wo.[hours_per_week],
		l.[local] as locale,
		coc.[cost_object_code],
		IIF(dates.[weekday_weekend] = 'Weekend', 1, 0) as is_weekend,
		dates.is_company_holiday,
		dates.is_estimated_pto,
		CASE
			WHEN dates.[weekday_weekend] != 'Weekend'
				AND dates.is_company_holiday = 0
				AND dates.is_estimated_pto = 0
			THEN 1
			ELSE 0
		END as workdays,
		CASE
			WHEN dates.[weekday_weekend] != 'Weekend'
				AND dates.is_company_holiday = 0
				AND dates.is_estimated_pto = 0
				AND dates.[full_date] BETWEEN start_d.[full_date] AND end_d.[full_date]
			THEN 1
			ELSE 0
		END as work_order_workdays,
		CASE
			WHEN dates.[full_date] BETWEEN start_d.[full_date] AND end_d.[full_date] -- AND l.[local] IS NULL -- unknown
				AND dates.[weekday_weekend] != 'Weekend'
				AND dates.is_company_holiday = 0
				AND dates.is_estimated_pto = 0
				AND dates.[full_date] BETWEEN start_d.[full_date] AND end_d.[full_date]
			THEN wo.current_bill_rate * (wo.allocation_percentage/100) * wo.[hours_per_day]
			ELSE 0
		END as payments
	FROM [dbo].[work_order] as wo
	LEFT JOIN [dbo].[date_dimension] as start_d
		ON wo.[worker_start_date_id] = start_d.[date_id]
	LEFT JOIN [dbo].[date_dimension] as end_d
		ON wo.[worker_end_date_id] = end_d.[date_id]
	JOIN [dbo].[date_dimension] as dates
		ON dates.calendar_year = end_d.calendar_year -- pull all dates for same year
	LEFT JOIN [dbo].[location] as l
		ON wo.[location_id] = l.[location_id]
	JOIN [dbo].[cost_object_code] as coc
		ON wo.[cost_object_code_id] = coc.[cost_object_code_id]
	WHERE wo.[id] = @work_order_id
	) AS t
GROUP BY [forecasting_month]
HAVING RIGHT(YEAR(MIN(full_date)),2) = RIGHT([forecasting_month],2)
ORDER BY [Year Month]
;

END
;
GO


-- EXEC [dbo].[sp_delete_record_new_work_order] {work_order_pk}

DROP PROCEDURE IF EXISTS [dbo].[sp_delete_record_new_work_order];
GO
CREATE PROCEDURE [dbo].[sp_delete_record_new_work_order]
    @work_order_pk INT
AS
BEGIN
    SET NOCOUNT ON;

	-- insert into user actions table
	INSERT INTO [audit].[user_actions]
				([action_type], [action_sql])
	VALUES ('execute_sp_delete_record_new_work_order', 'EXEC [dbo].[sp_delete_record_new_work_order]
	' + CONVERT(varchar(100), IIF(@work_order_pk IS NULL, -1, @work_order_pk)) + ''
	)
	;

	UPDATE [dbo].[work_order_add_to_forecast]
    SET [is_ignored] = 1,
		[is_deleted] = 1,
		[updated_by] = CURRENT_USER,
		[updated_date] = CURRENT_TIMESTAMP
    WHERE [work_order_id] = @work_order_pk
	;

	INSERT INTO [audit].[user_actions]
			   ([action_type], [action_sql])
    VALUES ('ignore_new_work_order',
	'UPDATE [dbo].[work_order_add_to_forecast]
    SET [is_ignored] = 1,
		[is_deleted] = 1,
		[updated_by] = ''' + CONVERT(varchar(50), CURRENT_USER) + ''',
		[updated_date] = ''' + CONVERT(varchar(50), CURRENT_TIMESTAMP) + '''
    WHERE [work_order_id] = ' + CONVERT(varchar(50), @work_order_pk) + '
	;')
	;
END
;
GO





-- EXEC [dbo].[sp_select_filtered_forecast_line_item]

DROP PROCEDURE IF EXISTS [dbo].[sp_select_filtered_forecast_line_item];
GO
CREATE PROCEDURE [dbo].[sp_select_filtered_forecast_line_item]
AS
BEGIN
    SET NOCOUNT ON;

	SELECT DISTINCT
		f.[Forecast ID],
		f.[Work Order ID],
		f.[Worker ID],
		f.[PID],
		f.[Business Unit],
		f.[Department],
		f.[Cost Center Code],
		f.[Cost Object Code],
		f.[Worker Start Date],
		f.[Worker End Date],
		f.[Allocation],
		f.[Current Bill Rate (Hr)],
		f.[Current Bill Rate (Day)],
		IIF(fli.[Jan] IS NULL, 0.00, fli.[Jan]) as [Jan-{current_year}],
		IIF(fli.[Feb] IS NULL, 0.00, fli.[Feb]) as [Feb-{current_year}],
		IIF(fli.[Mar] IS NULL, 0.00, fli.[Mar]) as [Mar-{current_year}],
		IIF(fli.[Apr] IS NULL, 0.00, fli.[Apr]) as [Apr-{current_year}],
		IIF(fli.[May] IS NULL, 0.00, fli.[May]) as [May-{current_year}],
		IIF(fli.[Jun] IS NULL, 0.00, fli.[Jun]) as [Jun-{current_year}],
		IIF(fli.[Jul] IS NULL, 0.00, fli.[Jul]) as [Jul-{current_year}],
		IIF(fli.[Aug] IS NULL, 0.00, fli.[Aug]) as [Aug-{current_year}],
		IIF(fli.[Sep] IS NULL, 0.00, fli.[Sep]) as [Sep-{current_year}],
		IIF(fli.[Oct] IS NULL, 0.00, fli.[Oct]) as [Oct-{current_year}],
		IIF(fli.[Nov] IS NULL, 0.00, fli.[Nov]) as [Nov-{current_year}],
		IIF(fli.[Dec] IS NULL, 0.00, fli.[Dec]) as [Dec-{current_year}],
		f.[Comment]
	FROM [dbo].[vw_forecast_full] as f
	JOIN [dbo].[vw_forecast_line_items] as fli
		ON f.[Forecast ID] = fli.[forecast_id]
	JOIN [dbo].[vw_work_orders_new] as wo
		ON f.[PID] = wo.[PID]
	--WHERE f.[PID] IN (SELECT [PID] FROM [dbo].[vw_work_orders_new]) -- 'P2942060' -- IS NOT NULL -- 'P3098826'--'P3191417'
;
END
;
GO



-- EXEC [dbo].[sp_select_full_forecast_metrics] 2023;


DROP PROCEDURE IF EXISTS [dbo].[sp_select_full_forecast_metrics];
GO
CREATE PROCEDURE [dbo].[sp_select_full_forecast_metrics]
    @var_year INT
AS
BEGIN

WITH TMP_FORECAST_MONTHS AS (
SELECT 
	[forecast_id], 
	[calendar_year], 
	[Jan], [Feb], [Mar], [Apr], 
	[May], [Jun], [Jul], [Aug], 
	[Sep], [Oct], [Nov], [Dec]
FROM (
		SELECT
			fli.[forecast_id],
			dd.[calendar_year],
			LEFT(dd.[month_name], 3) as [date_type],
			CASE
				WHEN fli.[is_actualized] = 1
				THEN fli.[actual]
				ELSE fli.[amount]
			END as amount
		FROM [dbo].[forecast_line_item] as fli
		JOIN [dbo].[date_dimension] as dd
			ON fli.[date_id] = dd.[date_id]
		WHERE fli.[is_deleted] = 0
		AND dd.[calendar_year] = @var_year
	) as t
	PIVOT (
    SUM([amount])
    FOR [date_type] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
  ) piv
),
TMP_FORECAST_FY_METRICS AS (
SELECT
	LEFT(frcst.[date_id], 4) as [calendar_year],
	frcst.[forecast_id],
	SUM(CASE
		WHEN frcst.[is_actualized] = 1
		THEN frcst.[actual]
		ELSE frcst.[amount]
	END) as fy_forecast,
	SUM(frcst.[budget]) as fy_budget,
	SUM(CASE
		WHEN frcst.[is_actualized] = 1
		THEN frcst.[actual] - frcst.[budget]
		ELSE frcst.[amount] - frcst.[budget]
	END) as fy_forecast_budget_var,
	SUM(frcst.[q1f]) as fy_q1f,
	SUM(frcst.[q2f]) as fy_q2f,
	SUM(frcst.[q3f]) as fy_q3f,
	SUM(0) as prev_fy_budget,
	SUM(0) as prev_fy_q1f,
	SUM(0) as prev_fy_q2f,
	SUM(0) as prev_fy_q3f
FROM [dbo].[forecast_line_item] as frcst
WHERE LEFT(frcst.[date_id], 4) = @var_year
GROUP BY LEFT(frcst.[date_id], 4), frcst.[forecast_id]
),
TMP_FORECAST_QUARTER_METRICS AS (
SELECT
	[calendar_year],
	[forecast_id],
	SUM([Jan] + [Feb] + [Mar]) as q1_total,
	SUM([Apr] + [May] + [Jun]) as q2_total,
	SUM([Jul] + [Aug] + [Sep]) as q3_total,
	SUM([Oct] + [Nov] + [Dec]) as q4_total
FROM TMP_FORECAST_MONTHS
GROUP BY [calendar_year], [forecast_id]
)
-- JOIN IT ALL TOGETHER
SELECT
	t.[forecast_id] as [Forecast ID],
	f.[description] as [Description],
	IIF(t.[Jan] IS NULL, 0.00, t.[Jan]) as [Jan-{current_year}],
	IIF(t.[Feb] IS NULL, 0.00, t.[Feb]) as [Feb-{current_year}],
	IIF(t.[Mar] IS NULL, 0.00, t.[Mar]) as [Mar-{current_year}],
	IIF(t.[Apr] IS NULL, 0.00, t.[Apr]) as [Apr-{current_year}],
	IIF(t.[May] IS NULL, 0.00, t.[May]) as [May-{current_year}],
	IIF(t.[Jun] IS NULL, 0.00, t.[Jun]) as [Jun-{current_year}],
	IIF(t.[Jul] IS NULL, 0.00, t.[Jul]) as [Jul-{current_year}],
	IIF(t.[Aug] IS NULL, 0.00, t.[Aug]) as [Aug-{current_year}],
	IIF(t.[Sep] IS NULL, 0.00, t.[Sep]) as [Sep-{current_year}],
	IIF(t.[Oct] IS NULL, 0.00, t.[Oct]) as [Oct-{current_year}],
	IIF(t.[Nov] IS NULL, 0.00, t.[Nov]) as [Nov-{current_year}],
	IIF(t.[Dec] IS NULL, 0.00, t.[Dec]) as [Dec-{current_year}],
	fy.[fy_forecast] as [FY-{current_year} Forecast],
	fy.[fy_budget] as [FY-{current_year} Budget],
	fy.[fy_forecast_budget_var] as [FY-{current_year} F/B Var],
	fy.[fy_q1f] as [FY-{current_year} Q1F],
	fy.[fy_q2f] as [FY-{current_year} Q2F],
	fy.[fy_q3f] as [FY-{current_year} Q3F],
	fy.[prev_fy_budget] as [FY-{prev_year} Budget],
	fy.[prev_fy_q1f] as [FY-{prev_year} Q1F],
	fy.[prev_fy_q2f] as [FY-{prev_year} Q2F],
	fy.[prev_fy_q3f] as [FY-{prev_year} Q3F],
	IIF(qu.[q1_total] IS NULL, 0.00, qu.[q1_total]) as [Q1-{current_year} Total],
	IIF(qu.[q2_total] IS NULL, 0.00, qu.[q2_total]) as [Q2-{current_year} Total],
	IIF(qu.[q3_total] IS NULL, 0.00, qu.[q3_total]) as [Q3-{current_year} Total],
	IIF(qu.[q4_total] IS NULL, 0.00, qu.[q4_total]) as [Q4-{current_year} Total]
FROM TMP_FORECAST_MONTHS as t
JOIN [dbo].[forecast] as f
	ON t.forecast_id = f.forecast_id
LEFT JOIN TMP_FORECAST_FY_METRICS as fy
	ON t.forecast_id = fy.[forecast_id]
	AND t.calendar_year = fy.calendar_year
LEFT JOIN TMP_FORECAST_QUARTER_METRICS as qu
	ON t.forecast_id = qu.[forecast_id]
	AND t.calendar_year = qu.calendar_year
WHERE f.[is_deleted] = 0
ORDER BY 1 DESC
;
END
;
GO

-- EXEC [dbo].[sp_select_full_forecast_metrics] 2023, 'May';



DROP PROCEDURE IF EXISTS [dbo].[sp_select_gl_from_forecast];
GO
CREATE PROCEDURE [dbo].[sp_select_gl_from_forecast]
    @gl_id INT
AS
BEGIN
SELECT TOP 1
	 [PO Cost Obj. Composite]
	,[PO Composite]
	,[Assignment Ref]
	,[Account Code]
	,[Department]
	,[Cost Center Code]
	,LEFT([Cost Center Code], 3) as [Company Code]
	,[Cost Object Code]
	,[Project Name]
	,[Supplier]
	,[Expense Type]
	,[Amount]
	,[PO Number]
	,[Item Text] as [Description]
	,[Comment]
	,NULL as [Business Unit]
	,NULL as [Department Leader]
	,NULL as [Team Leader]
    ,NULL as [Business Owner]
    ,NULL as [Primary Contact]
	,[Item Text] as [Contractor]
	,NULL as [Worker ID]
	,NULL as [PID]
	,NULL as [Worker Start Date]
	,NULL as [Worker End Date]
	,NULL as [Override End Date]
	,NULL as [Main Document Title]
	,NULL as [Location]
	,NULL as [Work Type]
	,NULL as [Worker Status]
	,NULL as [Work Order Category]
	,NULL as [Expense Classification]
	,NULL as [Budget Code]
	,NULL as [Segmentation]
	,NULL as [Platform]
	,NULL as [Function]
	,NULL as [Support/Scalable]
	,NULL as [Work Order ID]
	,NULL as [Allocation]
	,NULL as [Current Bill Rate (Hr)]
	,NULL as [Current Bill Rate (Day)]
FROM [dbo].[vw_general_ledger_full]
WHERE [GL ID] = @gl_id
;
END
;
GO


-- EXEC [dbo].[sp_select_gl_from_forecast] 41366;



DROP PROCEDURE IF EXISTS [dbo].[sp_insert_forecast_from_gl];
GO
CREATE PROCEDURE [dbo].[sp_insert_forecast_from_gl]
    @gl_id BIGINT,
    @comment VARCHAR(1000),
	@bu VARCHAR(255),
	@department_leader VARCHAR(255),
	@team_leader VARCHAR(255),
	@business_owner VARCHAR(255),
	@primary_contact VARCHAR(255),
	@contractor VARCHAR(255),
	@worker_id VARCHAR(255),
	@pid VARCHAR(255),
	@worker_start_date VARCHAR(255),
	@worker_end_date VARCHAR(255),
	@override_end_date VARCHAR(255),
	@main_doc_title VARCHAR(255),
	@site VARCHAR(255),
	@work_type VARCHAR(255),
	@worker_status VARCHAR(255),
	@work_order_category VARCHAR(255),
	@expense_class VARCHAR(255),
	@budget_code VARCHAR(255),
	@segmentation VARCHAR(255),
	@platform VARCHAR(255),
	@function VARCHAR(255),
	@support_scalable VARCHAR(255),
	@work_order_id VARCHAR(255),
	@allocation VARCHAR(255),
	@bill_rate_hr VARCHAR(255),
	@bill_rate_day VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

	-- department_leader,  team_leader, business_owner, primary_contact
	MERGE INTO [dbo].[employee] AS TGT
	USING (
		SELECT IIF(len(@department_leader) = 0, 'Unknown', @department_leader) as data_value
		UNION
		SELECT IIF(len(@team_leader) = 0, 'Unknown', @team_leader) as data_value
		UNION 
		SELECT IIF(len(@business_owner) = 0, 'Unknown', @business_owner) as data_value
		UNION 
		SELECT IIF(len(@primary_contact) = 0, 'Unknown', @primary_contact) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([employee], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;
	
	-- contractor: @contractor VARCHAR(255), @worker_id VARCHAR(255), @pid VARCHAR(255),
	MERGE INTO [dbo].[contractor] AS TGT
	USING (
		SELECT 
			wid.worker_id,
			pid.pid,
			w.worker,
			wfirst.first_name,
			wlast.last_name
		FROM (SELECT IIF(len(@worker_id) = 0, 'Unknown', @worker_id) as worker_id) as wid
		JOIN (SELECT IIF(len(@pid) = 0, NULL, @pid) as pid) as pid ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, @contractor) as worker) as w ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, RIGHT(@contractor,CHARINDEX(',',REVERSE(@contractor))-1)) as first_name) as wfirst ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, LEFT(@contractor, CHARINDEX(',', @contractor + ',') - 1) ) as last_name) as wlast ON 1=1
	) AS SRC
		ON TGT.[raw] = SRC.worker_id
	WHEN NOT MATCHED THEN
		INSERT (
			[worker_id]
           ,[pid]
           ,[first_name]
           ,[last_name]
           ,[full_name]
           ,[worker_site]
           ,[raw]
		) 
		VALUES (
			SRC.worker_id,
			SRC.pid,
			SRC.first_name,
			SRC.last_name,
			SRC.worker,
			CONCAT('Manual Entry: ', @site), -- worker_site
			SRC.worker_id -- raw
		)
	;

	-- 	@worker_start_date VARCHAR(255), @worker_end_date VARCHAR(255), @override_end_date VARCHAR(255),
	DECLARE @new_start_date DATE
	DECLARE @new_end_date DATE
	DECLARE @new_override_date DATE 

	SELECT @new_start_date = (SELECT TRY_PARSE(@worker_start_date AS DATE USING 'en-US'));
	SELECT @new_end_date = (SELECT TRY_PARSE(@worker_end_date AS DATE USING 'en-US'));
	SELECT @new_override_date = (SELECT TRY_PARSE(@override_end_date AS DATE USING 'en-US'));

	-- main doc title
	MERGE INTO [dbo].[main_document_title] AS TGT
	USING (
		SELECT IIF(len(@main_doc_title) = 0, 'Unknown', @main_doc_title) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([main_document_title], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;

	-- budget_code
	MERGE INTO [dbo].[budget_code] AS TGT
	USING (
		SELECT IIF(len(@budget_code) = 0, 'Unknown', @budget_code) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([segmentation_id], [platform_id], [budget_code], [budget_name], [raw]) 
		VALUES (0, 0, SRC.data_value, NULL, SRC.data_value)
	;


	INSERT INTO [dbo].[forecast]
	([company_code_id]
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
	)
	SELECT TOP 1
		(SELECT MIN([company_code_id]) FROM [dbo].[company_code] WHERE [raw] = LEFT(ccc.[cost_center_code],3)) as [company_code_id],
		IIF(LEN(@bu) = 0, 0, @bu) as [business_unit_id],
		gl.[department_id],
		gl.[cost_center_code_id],
		IIF(LEN(@department_leader) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @department_leader)) as [department_leader_id],
		IIF(LEN(@team_leader) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @team_leader)) as [team_leader_id],
		IIF(LEN(@business_owner) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @business_owner)) as [business_owner_id],
		IIF(LEN(@primary_contact) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @primary_contact)) as [primary_contact_id],
		gl.[supplier_id],
		IIF(LEN(@worker_id) = 0, 0, (SELECT MIN([contractor_id]) FROM [dbo].[contractor] WHERE [raw] = @worker_id)) as [contractor_id],
		IIF(@new_start_date IS NULL, NULL, (SELECT MIN([date_id]) FROM [dbo].[date_dimension] WHERE full_date = @new_start_date)) as [worker_start_date_id],
		IIF(@new_end_date IS NULL, NULL, (SELECT MIN([date_id]) FROM [dbo].[date_dimension] WHERE full_date = @new_end_date)) as [worker_end_date_id],
		IIF(@new_override_date IS NULL, NULL, (SELECT MIN([date_id]) FROM [dbo].[date_dimension] WHERE full_date = @new_override_date)) as [override_end_date_id],
		IIF(LEN(@main_doc_title) = 0, 0, (SELECT MIN([main_document_title_id]) FROM [dbo].[main_document_title] WHERE [raw] = @main_doc_title)) as [main_document_title_id],
		gl.[wbs_code_id] as [cost_object_code_id],
		IIF(LEN(@site) = 0, 0, @site) as [site_id],
		gl.[account_id],
		IIF(LEN(@work_type) = 0, 0, @work_type) as [work_type_id],
		IIF(LEN(@worker_status) = 0, 0, @worker_status) as [worker_status_id],
		IIF(LEN(@work_order_category) = 0, 0, @work_order_category) as [worker_status_id],
		IIF(LEN(@expense_class) = 0, 0, @expense_class) as [expense_classification_id],
		IIF(LEN(@budget_code) = 0, 0, (SELECT MIN([budget_code_id]) FROM [dbo].[budget_code] WHERE [raw] = @budget_code)) as [budget_code_id],
		IIF(LEN(@segmentation) = 0, 0, @segmentation) as [segmentation_id],
		IIF(LEN(@platform) = 0, 0, @platform) as [platform_id],
		IIF(LEN(@function) = 0, 0, @function) as [function_id],
		IIF(LEN(@support_scalable) = 0, 0, @support_scalable) as [support_scalable_id],
		IIF(LEN(@work_order_id) = 0, NULL, @work_order_id) as [work_order_id],
		gl.[item_text] as [description],
		IIF(LEN(@allocation) = 0, NULL, @allocation) as [allocation],
		IIF(LEN(@bill_rate_hr) = 0, NULL, @bill_rate_hr) as [current_bill_rate_hr],
		IIF(LEN(@bill_rate_day) = 0, NULL, @bill_rate_day) as [current_bill_rate_day],
		IIF(LEN(@comment) = 0, NULL, @comment) as [comment],
		0 as [is_deleted]
	FROM [dbo].[general_ledger] as gl
 	LEFT JOIN [dbo].[cost_center_code] as ccc
		ON gl.[cost_center_code_id] = ccc.[cost_center_code_id]
	WHERE gl.[general_ledger_id] = @gl_id
	;

	-- get most recently created record based on user
	DECLARE @new_forecast_id BIGINT
	SELECT @new_forecast_id = (SELECT MAX([forecast_id]) FROM [dbo].[forecast] WHERE [created_by] = CURRENT_USER)
	;

	-- insert dummy forecast line items
	INSERT INTO [dbo].[forecast_line_item]
           ([forecast_id]
           ,[date_id]
           ,[amount]
           ,[is_actualized]
           ,[is_deleted]
		   )
	SELECT DISTINCT
		@new_forecast_id as [forecast_id],
		[first_of_month_date_key],
		0 as [amount],
		0 as [is_actualized],
		0 as [is_deleted]
	FROM [dbo].[date_dimension]
	WHERE [calendar_year] = YEAR(GETDATE()) -- default to current year?
	;

	-- this should auto tag everything since we have all the info
	EXEC [dbo].[sp_insert_record_auto_tag] @gl_id, @new_forecast_id;

END
;
GO



-- EXEC [dbo].[sp_select_full_forecast_and_items] 8286, 2023, 'April'
-- this is for inserting new full forecast items 
DROP PROCEDURE IF EXISTS [dbo].[sp_select_full_forecast_and_items];
GO
CREATE PROCEDURE [dbo].[sp_select_full_forecast_and_items]
    @forecast_id BIGINT,
	@var_year INT
AS
BEGIN

WITH TMP_FORECAST_MONTHS AS (
SELECT 
	[forecast_id], 
	[calendar_year], 
	[Jan], [Feb], [Mar], [Apr], 
	[May], [Jun], [Jul], [Aug], 
	[Sep], [Oct], [Nov], [Dec]
FROM (
		SELECT
			fli.[forecast_id],
			dd.[calendar_year],
			LEFT(dd.[month_name], 3) as [date_type],
			CASE
				WHEN fli.[is_actualized] = 1
				THEN fli.[actual]
				ELSE fli.[amount]
			END as amount
		FROM [dbo].[forecast_line_item] as fli
		JOIN [dbo].[date_dimension] as dd
			ON fli.[date_id] = dd.[date_id]
		WHERE fli.[is_deleted] = 0
		AND dd.[calendar_year] = @var_year
		AND fli.forecast_id = @forecast_id
	) as t
	PIVOT (
    SUM([amount])
    FOR [date_type] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
  ) piv
),
TMP_FORECAST_FY_METRICS AS (
SELECT
	LEFT(frcst.[date_id], 4) as [calendar_year],
	frcst.[forecast_id],
	SUM(CASE
		WHEN frcst.[is_actualized] = 1
		THEN frcst.[actual]
		ELSE frcst.[amount]
	END) as fy_forecast,
	SUM(frcst.[budget]) as fy_budget,
	SUM(CASE
		WHEN frcst.[is_actualized] = 1
		THEN frcst.[actual] - frcst.[budget]
		ELSE frcst.[amount] - frcst.[budget]
	END) as fy_forecast_budget_var,
	SUM(frcst.[q1f]) as fy_q1f,
	SUM(frcst.[q2f]) as fy_q2f,
	SUM(frcst.[q3f]) as fy_q3f,
	SUM(0) as prev_fy_budget,
	SUM(0) as prev_fy_q1f,
	SUM(0) as prev_fy_q2f,
	SUM(0) as prev_fy_q3f
FROM [dbo].[forecast_line_item] as frcst
WHERE LEFT(frcst.[date_id], 4) = @var_year
AND frcst.forecast_id = @forecast_id
GROUP BY LEFT(frcst.[date_id], 4), frcst.[forecast_id]
),
TMP_FORECAST_QUARTER_METRICS AS (
SELECT
	[calendar_year],
	[forecast_id],
	SUM([Jan] + [Feb] + [Mar]) as q1_total,
	SUM([Apr] + [May] + [Jun]) as q2_total,
	SUM([Jul] + [Aug] + [Sep]) as q3_total,
	SUM([Oct] + [Nov] + [Dec]) as q4_total
FROM TMP_FORECAST_MONTHS
GROUP BY [calendar_year], [forecast_id]
)
-- JOIN IT ALL TOGETHER
SELECT
	 f.[Company Code]
	,f.[Business Unit]
	,f.[Department]
	,f.[Cost Center Code]
	,f.[Department Leader]
	,f.[Team Leader]
	,f.[Business Owner]
	,f.[Primary Contact]
	,f.[Supplier]
	,f.[Contractor]
	,f.[Worker ID]
	,f.[PID]
	,FORMAT(f.[Worker Start Date], 'MM/dd/yyy') as [Worker Start Date]
	,FORMAT(f.[Worker End Date], 'MM/dd/yyy') as [Worker End Date]
	,FORMAT(f.[Override End Date], 'MM/dd/yyy') as [Override End Date]
	,f.[Main Document Title]
	,f.[Cost Object Code]
	,f.[Site]
	,f.[Account Code]
	,f.[Work Type]
	,f.[Worker Status]
	,f.[Work Order Category]
	,f.[Expense Classification]
	,f.[Budget Code]
	,f.[Segmentation]
	,f.[Platform]
	,f.[Function]
	,f.[Support/Scalable]
	,f.[Work Order ID]
	,f.[Description]
	,f.[Allocation]
	,f.[Current Bill Rate (Hr)]
	,f.[Current Bill Rate (Day)]
	,f.[Comment],
	IIF(t.[Jan] IS NULL, 0.00, t.[Jan]) as [Jan-{current_year}],
	IIF(t.[Feb] IS NULL, 0.00, t.[Feb]) as [Feb-{current_year}],
	IIF(t.[Mar] IS NULL, 0.00, t.[Mar]) as [Mar-{current_year}],
	IIF(t.[Apr] IS NULL, 0.00, t.[Apr]) as [Apr-{current_year}],
	IIF(t.[May] IS NULL, 0.00, t.[May]) as [May-{current_year}],
	IIF(t.[Jun] IS NULL, 0.00, t.[Jun]) as [Jun-{current_year}],
	IIF(t.[Jul] IS NULL, 0.00, t.[Jul]) as [Jul-{current_year}],
	IIF(t.[Aug] IS NULL, 0.00, t.[Aug]) as [Aug-{current_year}],
	IIF(t.[Sep] IS NULL, 0.00, t.[Sep]) as [Sep-{current_year}],
	IIF(t.[Oct] IS NULL, 0.00, t.[Oct]) as [Oct-{current_year}],
	IIF(t.[Nov] IS NULL, 0.00, t.[Nov]) as [Nov-{current_year}],
	IIF(t.[Dec] IS NULL, 0.00, t.[Dec]) as [Dec-{current_year}]
	--fy.[fy_forecast] as [FY-{current_year} Forecast],
	--fy.[fy_budget] as [FY-{current_year} Budget],
	--fy.[fy_forecast_budget_var] as [FY-{current_year} F/B Var],
	--fy.[fy_q1f] as [FY-{current_year} Q1F],
	--fy.[fy_q2f] as [FY-{current_year} Q2F],
	--fy.[fy_q3f] as [FY-{current_year} Q3F],
	--fy.[prev_fy_budget] as [FY-{prev_year} Budget],
	--fy.[prev_fy_q1f] as [FY-{prev_year} Q1F],
	--fy.[prev_fy_q2f] as [FY-{prev_year} Q2F],
	--fy.[prev_fy_q3f] as [FY-{prev_year} Q3F],
	--IIF(qu.[q1_total] IS NULL, 0.00, qu.[q1_total]) as [Q1-{current_year} Total],
	--IIF(qu.[q2_total] IS NULL, 0.00, qu.[q2_total]) as [Q2-{current_year} Total],
	--IIF(qu.[q3_total] IS NULL, 0.00, qu.[q3_total]) as [Q3-{current_year} Total],
	--IIF(qu.[q4_total] IS NULL, 0.00, qu.[q4_total]) as [Q4-{current_year} Total]
FROM TMP_FORECAST_MONTHS as t
JOIN [dbo].[vw_forecast_full] as f
	ON t.forecast_id = f.[Forecast ID]
LEFT JOIN TMP_FORECAST_FY_METRICS as fy
	ON t.forecast_id = fy.[forecast_id]
	AND t.calendar_year = fy.calendar_year
LEFT JOIN TMP_FORECAST_QUARTER_METRICS as qu
	ON t.forecast_id = qu.[forecast_id]
	AND t.calendar_year = qu.calendar_year
WHERE f.[Forecast ID] = @forecast_id
END
;
GO





DROP PROCEDURE IF EXISTS [dbo].[sp_insert_new_forecast_from_copy];
GO
CREATE PROCEDURE [dbo].[sp_insert_new_forecast_from_copy]
    @var_year INT,
	@company_code VARCHAR(255),
	@bu VARCHAR(255),
	@dept VARCHAR(255),
	@cost_center_code VARCHAR(255),
	@department_leader VARCHAR(255),
	@team_leader VARCHAR(255),
	@business_owner VARCHAR(255),
	@primary_contact VARCHAR(255),
	@supplier VARCHAR(255),
	@contractor VARCHAR(255),
	@worker_id VARCHAR(255),
	@pid VARCHAR(255),
	@worker_start_date VARCHAR(255),
	@worker_end_date VARCHAR(255),
	@override_end_date VARCHAR(255),
	@main_doc_title VARCHAR(255),
	@cost_object_code VARCHAR(255),
	@site VARCHAR(255),
	@account VARCHAR(255),
	@work_type VARCHAR(255),
	@worker_status VARCHAR(255),
	@work_order_category VARCHAR(255),
	@expense_class VARCHAR(255),
	@budget_code VARCHAR(255),
	@segmentation VARCHAR(255),
	@platform VARCHAR(255),
	@function VARCHAR(255),
	@support_scalable VARCHAR(255),
	@work_order_id VARCHAR(255),
	@desc VARCHAR(255),
	@allocation VARCHAR(255),
	@bill_rate_hr VARCHAR(255),
	@bill_rate_day VARCHAR(255),
    @comment VARCHAR(1000),
	@jan VARCHAR(255),
	@feb VARCHAR(255),
	@mar VARCHAR(255),
	@apr VARCHAR(255),
	@may VARCHAR(255),
	@jun VARCHAR(255),
	@jul VARCHAR(255),
	@aug VARCHAR(255),
	@sep VARCHAR(255),
	@oct VARCHAR(255),
	@nov VARCHAR(255),
	@dec VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

	-- department_leader,  team_leader, business_owner, primary_contact
	MERGE INTO [dbo].[employee] AS TGT
	USING (
		SELECT IIF(len(@department_leader) = 0, 'Unknown', @department_leader) as data_value
		UNION
		SELECT IIF(len(@team_leader) = 0, 'Unknown', @team_leader) as data_value
		UNION 
		SELECT IIF(len(@business_owner) = 0, 'Unknown', @business_owner) as data_value
		UNION 
		SELECT IIF(len(@primary_contact) = 0, 'Unknown', @primary_contact) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([employee], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;

	-- supplier
	MERGE INTO [dbo].[supplier] AS TGT
	USING (
		SELECT IIF(len(@supplier) = 0, 'Unknown', @supplier) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([supplier_code], [supplier], [supplier_long], [raw]) 
		VALUES (NULL, SRC.data_value, SRC.data_value, SRC.data_value)
	;
	
	-- contractor: @contractor VARCHAR(255), @worker_id VARCHAR(255), @pid VARCHAR(255),
	MERGE INTO [dbo].[contractor] AS TGT
	USING (
		SELECT 
			wid.worker_id,
			pid.pid,
			w.worker,
			wfirst.first_name,
			wlast.last_name
		FROM (SELECT IIF(len(@worker_id) = 0, 'Unknown', @worker_id) as worker_id) as wid
		JOIN (SELECT IIF(len(@pid) = 0, NULL, @pid) as pid) as pid ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, @contractor) as worker) as w ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, RIGHT(@contractor,CHARINDEX(',',REVERSE(@contractor))-1)) as first_name) as wfirst ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, LEFT(@contractor, CHARINDEX(',', @contractor + ',') - 1) ) as last_name) as wlast ON 1=1
	) AS SRC
		ON TGT.[raw] = SRC.worker_id
	WHEN NOT MATCHED THEN
		INSERT (
			[worker_id]
           ,[pid]
           ,[first_name]
           ,[last_name]
           ,[full_name]
           ,[worker_site]
           ,[raw]
		) 
		VALUES (
			SRC.worker_id,
			SRC.pid,
			SRC.first_name,
			SRC.last_name,
			SRC.worker,
			CONCAT('Manual Entry: ', @site), -- worker_site
			SRC.worker_id -- raw
		)
	;

	-- main doc title
	MERGE INTO [dbo].[main_document_title] AS TGT
	USING (
		SELECT IIF(len(@main_doc_title) = 0, 'Unknown', @main_doc_title) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([main_document_title], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;

	-- @cost_object_code
	MERGE INTO [dbo].[cost_object_code] AS TGT
	USING (
		SELECT IIF(len(@cost_object_code) = 0, 'Unknown', @cost_object_code) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([cost_object_code], [is_opex], [raw]) 
		VALUES (SRC.data_value, IIF(LEFT(SRC.data_value, 2) = 'FG', 1, 0), SRC.data_value)
	;


	-- @account
	MERGE INTO [dbo].[account] AS TGT
	USING (
		SELECT IIF(len(@account) = 0, 'Unknown', @account) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([account_code], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;

	-- budget_code
	MERGE INTO [dbo].[budget_code] AS TGT
	USING (
		SELECT IIF(len(@budget_code) = 0, 'Unknown', @budget_code) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([segmentation_id], [platform_id], [budget_code], [budget_name], [raw]) 
		VALUES (0, 0, SRC.data_value, NULL, SRC.data_value)
	;


	INSERT INTO [dbo].[forecast]
	([company_code_id]
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
	)
	SELECT TOP 1
		IIF(LEN(@company_code) = 0, 0, @company_code) as [company_code_id],
		IIF(LEN(@bu) = 0, 0, @bu) as [business_unit_id],
		IIF(LEN(@dept) = 0, 0, @dept) as [department_id],
		IIF(LEN(@cost_center_code) = 0, 0, @cost_center_code) as [cost_center_code_id],
		IIF(LEN(@department_leader) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @department_leader)) as [department_leader_id],
		IIF(LEN(@team_leader) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @team_leader)) as [team_leader_id],
		IIF(LEN(@business_owner) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @business_owner)) as [business_owner_id],
		IIF(LEN(@primary_contact) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @primary_contact)) as [primary_contact_id],
		IIF(LEN(@supplier) = 0, 0, (SELECT MIN([supplier_id]) FROM [dbo].[supplier] WHERE [raw] = @supplier)) as [supplier_id],
		IIF(LEN(@worker_id) = 0, 0, (SELECT MIN([contractor_id]) FROM [dbo].[contractor] WHERE [raw] = @worker_id)) as [contractor_id],
		IIF(LEN(@worker_start_date) = 0, NULL, @worker_start_date) as [worker_start_date_id],
		IIF(LEN(@worker_end_date) = 0, 0, @worker_end_date) as [worker_end_date_id],
		IIF(LEN(@override_end_date) = 0, 0, @override_end_date) as [override_end_date_id],
		IIF(LEN(@main_doc_title) = 0, 0, (SELECT MIN([main_document_title_id]) FROM [dbo].[main_document_title] WHERE [raw] = @main_doc_title)) as [main_document_title_id],
		IIF(LEN(@cost_object_code) = 0, 0, (SELECT MIN([cost_object_code_id]) FROM [dbo].[cost_object_code] WHERE [raw] = @cost_object_code)) as [cost_object_code_id],
		IIF(LEN(@site) = 0, 0, @site) as [site_id],
		IIF(LEN(@account) = 0, 0, (SELECT MIN([account_id]) FROM [dbo].[account] WHERE [raw] = @account)) as [account_id],
		IIF(LEN(@work_type) = 0, 0, @work_type) as [work_type_id],
		IIF(LEN(@worker_status) = 0, 0, @worker_status) as [worker_status_id],
		IIF(LEN(@work_order_category) = 0, 0, @work_order_category) as [work_order_category_id],
		IIF(LEN(@expense_class) = 0, 0, @expense_class) as [expense_classification_id],
		IIF(LEN(@budget_code) = 0, 0, (SELECT MIN([budget_code_id]) FROM [dbo].[budget_code] WHERE [raw] = @budget_code)) as [budget_code_id],
		IIF(LEN(@segmentation) = 0, 0, @segmentation) as [segmentation_id],
		IIF(LEN(@platform) = 0, 0, @platform) as [platform_id],
		IIF(LEN(@function) = 0, 0, @function) as [function_id],
		IIF(LEN(@support_scalable) = 0, 0, @support_scalable) as [support_scalable_id],
		IIF(LEN(@work_order_id) = 0, NULL, @work_order_id) as [work_order_id],
		IIF(LEN(@desc) = 0, NULL, @desc) as [description],
		IIF(LEN(@allocation) = 0, NULL, TRY_CAST(@allocation AS FLOAT)) as [allocation],
		IIF(LEN(@bill_rate_hr) = 0, NULL, TRY_CAST(@bill_rate_hr AS FLOAT)) as [current_bill_rate_hr],
		IIF(LEN(@bill_rate_day) = 0, NULL, TRY_CAST(@bill_rate_day AS FLOAT)) as [current_bill_rate_day],
		IIF(LEN(@comment) = 0, NULL, @comment) as [comment],
		0 as [is_deleted]
	;

	-- get most recently created record based on user
	DECLARE @new_forecast_id BIGINT
	SELECT @new_forecast_id = (SELECT MAX([forecast_id]) FROM [dbo].[forecast] WHERE [created_by] = CURRENT_USER)
	;

	-- insert dummy forecast line items
	INSERT INTO [dbo].[forecast_line_item]
           ([forecast_id]
           ,[date_id]
           ,[amount]
           ,[is_actualized]
           ,[is_deleted]
		   )
	(
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@jan) = 0, 0.00, TRY_CAST(@jan AS FLOAT)), 0, 0
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 1
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@feb) = 0, 0.00, TRY_CAST(@feb AS FLOAT)), 0, 0
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 2
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@mar) = 0, 0.00, TRY_CAST(@mar AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 3
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@apr) = 0, 0.00, TRY_CAST(@apr AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 4
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@may) = 0, 0.00, TRY_CAST(@may AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 5
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@jun) = 0, 0.00, TRY_CAST(@jun AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 6
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@jul) = 0, 0.00, TRY_CAST(@jul AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 7
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@aug) = 0, 0.00, TRY_CAST(@aug AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 8
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@sep) = 0, 0.00, TRY_CAST(@sep AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 9
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@oct) = 0, 0.00, TRY_CAST(@oct AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 10
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@nov) = 0, 0.00, TRY_CAST(@nov AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 11
	UNION
	SELECT DISTINCT @new_forecast_id, dd.[first_of_month_date_key], IIF(LEN(@dec) = 0, 0.00, TRY_CAST(@dec AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 12
	)
	;

END
;
GO


            --EXEC [dbo].[sp_insert_new_forecast_from_copy]
            --     2023, -- year
            --    '1121', -- company code
            --    '1008', -- business unit
            --    '1164', -- department
            --    '1031', -- cost center code
            --    'Robinson, Jodi', -- department leader
            --    'Baldino, Michael', -- team leader
            --    'O''Donnell, Sean', -- business owner
            --    'O''Donnell, Sean', -- primary contact
            --    'UiPath Inc', -- supplier
            --    '', -- contractor
            --    '', -- worker id
            --    '', -- pid
            --    '0', -- start date
            --    '0', -- end date 
            --    '0', -- override date
            --    'UiPath - Tech Mobile Q-550143', -- main doc
            --    'P802358.C.000.01.44S1', -- cost object code
            --    '0', -- location/site
            --    '66760000', -- account code
            --    '1008', -- work type
            --    '1000', -- worker status
            --    '1021', -- work order category
            --    '1001', -- expense class 
            --    'B23000053631', -- budget code
            --    '1024', -- segmentation
            --    '1005', -- platform
            --    '1003', -- function
            --    '0', -- support/scalable
            --    'UiPath Q-550143', -- work order id
            --    'UiPath Inc - Tech Mobile', -- description
            --    '80.00', -- allocation
            --    '', -- bill rate hr
            --    '', -- bill rate day
            --    '', -- comment
            --    '', -- jan
            --    '', -- feb
            --    '', -- mar
            --    '87660.00', -- apr
            --    '', -- may
            --    '', -- jun
            --    '', -- jul
            --    '', -- aug
            --    '', -- sep
            --    '', -- oct
            --    '', -- nov
            --    '' -- dec


-- EXEC [dbo].[sp_select_full_forecast_and_items_for_update] 8358, 2023, 'April';
-- this is for update forecast items
DROP PROCEDURE IF EXISTS [dbo].[sp_select_full_forecast_and_items_for_update];
GO
CREATE PROCEDURE [dbo].[sp_select_full_forecast_and_items_for_update]
    @forecast_id BIGINT,
	@var_year INT
AS
BEGIN
WITH TMP_FORECAST_MONTHS AS (
SELECT 
	[forecast_id], 
	[calendar_year], 
	[Jan], [Feb], [Mar], [Apr], 
	[May], [Jun], [Jul], [Aug], 
	[Sep], [Oct], [Nov], [Dec]
FROM (
		SELECT
			fli.[forecast_id],
			dd.[calendar_year],
			LEFT(dd.[month_name], 3) as [date_type],
			CASE
				WHEN fli.[is_actualized] = 1
				THEN fli.[actual]
				ELSE fli.[amount]
			END as amount
		FROM [dbo].[forecast_line_item] as fli
		JOIN [dbo].[date_dimension] as dd
			ON fli.[date_id] = dd.[date_id]
		WHERE fli.[is_deleted] = 0
		AND dd.[calendar_year] = @var_year
		AND fli.forecast_id = @forecast_id
	) as t
	PIVOT (
    SUM([amount])
    FOR [date_type] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
  ) piv
),
TMP_FORECAST_FY_METRICS AS (
SELECT
	LEFT(frcst.[date_id], 4) as [calendar_year],
	frcst.[forecast_id],
	SUM(CASE
		WHEN frcst.[is_actualized] = 1
		THEN frcst.[actual]
		ELSE frcst.[amount]
	END) as fy_forecast,
	SUM(frcst.[budget]) as fy_budget,
	SUM(CASE
		WHEN frcst.[is_actualized] = 1
		THEN frcst.[actual] - frcst.[budget]
		ELSE frcst.[amount] - frcst.[budget]
	END) as fy_forecast_budget_var,
	SUM(frcst.[q1f]) as fy_q1f,
	SUM(frcst.[q2f]) as fy_q2f,
	SUM(frcst.[q3f]) as fy_q3f,
	SUM(0) as prev_fy_budget,
	SUM(0) as prev_fy_q1f,
	SUM(0) as prev_fy_q2f,
	SUM(0) as prev_fy_q3f
FROM [dbo].[forecast_line_item] as frcst
WHERE LEFT(frcst.[date_id], 4) = @var_year
AND frcst.forecast_id = @forecast_id
GROUP BY LEFT(frcst.[date_id], 4), frcst.[forecast_id]
),
TMP_FORECAST_QUARTER_METRICS AS (
SELECT
	[calendar_year],
	[forecast_id],
	SUM([Jan] + [Feb] + [Mar]) as q1_total,
	SUM([Apr] + [May] + [Jun]) as q2_total,
	SUM([Jul] + [Aug] + [Sep]) as q3_total,
	SUM([Oct] + [Nov] + [Dec]) as q4_total
FROM TMP_FORECAST_MONTHS
GROUP BY [calendar_year], [forecast_id]
)
-- JOIN IT ALL TOGETHER
SELECT
	 f.[Forecast ID]
	,f.[Company Code]
	,f.[Business Unit]
	,f.[Department]
	,f.[Cost Center Code]
	,f.[Department Leader]
	,f.[Team Leader]
	,f.[Business Owner]
	,f.[Primary Contact]
	,f.[Supplier]
	,f.[Contractor]
	,f.[Worker ID]
	,f.[PID]
	,FORMAT(f.[Worker Start Date], 'MM/dd/yyy') as [Worker Start Date]
	,FORMAT(f.[Worker End Date], 'MM/dd/yyy') as [Worker End Date]
	,FORMAT(f.[Override End Date], 'MM/dd/yyy') as [Override End Date]
	,f.[Main Document Title]
	,f.[Cost Object Code]
	,f.[Site]
	,f.[Account Code]
	,f.[Work Type]
	,f.[Worker Status]
	,f.[Work Order Category]
	,f.[Expense Classification]
	,f.[Budget Code]
	,f.[Segmentation]
	,f.[Platform]
	,f.[Function]
	,f.[Support/Scalable]
	,f.[Work Order ID]
	,f.[Description]
	,f.[Allocation]
	,f.[Current Bill Rate (Hr)]
	,f.[Current Bill Rate (Day)]
	,f.[Comment],
	IIF(t.[Jan] IS NULL, 0.00, t.[Jan]) as [Jan-{current_year}],
	IIF(t.[Feb] IS NULL, 0.00, t.[Feb]) as [Feb-{current_year}],
	IIF(t.[Mar] IS NULL, 0.00, t.[Mar]) as [Mar-{current_year}],
	IIF(t.[Apr] IS NULL, 0.00, t.[Apr]) as [Apr-{current_year}],
	IIF(t.[May] IS NULL, 0.00, t.[May]) as [May-{current_year}],
	IIF(t.[Jun] IS NULL, 0.00, t.[Jun]) as [Jun-{current_year}],
	IIF(t.[Jul] IS NULL, 0.00, t.[Jul]) as [Jul-{current_year}],
	IIF(t.[Aug] IS NULL, 0.00, t.[Aug]) as [Aug-{current_year}],
	IIF(t.[Sep] IS NULL, 0.00, t.[Sep]) as [Sep-{current_year}],
	IIF(t.[Oct] IS NULL, 0.00, t.[Oct]) as [Oct-{current_year}],
	IIF(t.[Nov] IS NULL, 0.00, t.[Nov]) as [Nov-{current_year}],
	IIF(t.[Dec] IS NULL, 0.00, t.[Dec]) as [Dec-{current_year}]
	--fy.[fy_forecast] as [FY-{current_year} Forecast],
	--fy.[fy_budget] as [FY-{current_year} Budget],
	--fy.[fy_forecast_budget_var] as [FY-{current_year} F/B Var],
	--fy.[fy_q1f] as [FY-{current_year} Q1F],
	--fy.[fy_q2f] as [FY-{current_year} Q2F],
	--fy.[fy_q3f] as [FY-{current_year} Q3F],
	--fy.[prev_fy_budget] as [FY-{prev_year} Budget],
	--fy.[prev_fy_q1f] as [FY-{prev_year} Q1F],
	--fy.[prev_fy_q2f] as [FY-{prev_year} Q2F],
	--fy.[prev_fy_q3f] as [FY-{prev_year} Q3F],
	--IIF(qu.[q1_total] IS NULL, 0.00, qu.[q1_total]) as [Q1-{current_year} Total],
	--IIF(qu.[q2_total] IS NULL, 0.00, qu.[q2_total]) as [Q2-{current_year} Total],
	--IIF(qu.[q3_total] IS NULL, 0.00, qu.[q3_total]) as [Q3-{current_year} Total],
	--IIF(qu.[q4_total] IS NULL, 0.00, qu.[q4_total]) as [Q4-{current_year} Total]
FROM TMP_FORECAST_MONTHS as t
JOIN [dbo].[vw_forecast_full] as f
	ON t.forecast_id = f.[Forecast ID]
LEFT JOIN TMP_FORECAST_FY_METRICS as fy
	ON t.forecast_id = fy.[forecast_id]
	AND t.calendar_year = fy.calendar_year
LEFT JOIN TMP_FORECAST_QUARTER_METRICS as qu
	ON t.forecast_id = qu.[forecast_id]
	AND t.calendar_year = qu.calendar_year
WHERE f.[Forecast ID] = @forecast_id
END
;
GO


--EXEC [dbo].[sp_select_full_forecast_and_items_for_update] 8318, 2023, 'April';


DROP PROCEDURE IF EXISTS [dbo].[sp_update_full_forecast_and_items];
GO
CREATE PROCEDURE [dbo].[sp_update_full_forecast_and_items]
    @forecast_id BIGINT,
	@var_year INT,
	@company_code VARCHAR(255),
	@bu VARCHAR(255),
	@dept VARCHAR(255),
	@cost_center_code VARCHAR(255),
	@department_leader VARCHAR(255),
	@team_leader VARCHAR(255),
	@business_owner VARCHAR(255),
	@primary_contact VARCHAR(255),
	@supplier VARCHAR(255),
	@contractor VARCHAR(255),
	@worker_id VARCHAR(255),
	@pid VARCHAR(255),
	@worker_start_date VARCHAR(255),
	@worker_end_date VARCHAR(255),
	@override_end_date VARCHAR(255),
	@main_doc_title VARCHAR(255),
	@cost_object_code VARCHAR(255),
	@site VARCHAR(255),
	@account VARCHAR(255),
	@work_type VARCHAR(255),
	@worker_status VARCHAR(255),
	@work_order_category VARCHAR(255),
	@expense_class VARCHAR(255),
	@budget_code VARCHAR(255),
	@segmentation VARCHAR(255),
	@platform VARCHAR(255),
	@function VARCHAR(255),
	@support_scalable VARCHAR(255),
	@work_order_id VARCHAR(255),
	@desc VARCHAR(255),
	@allocation VARCHAR(255),
	@bill_rate_hr VARCHAR(255),
	@bill_rate_day VARCHAR(255),
    @comment VARCHAR(1000),
	@jan VARCHAR(255),
	@feb VARCHAR(255),
	@mar VARCHAR(255),
	@apr VARCHAR(255),
	@may VARCHAR(255),
	@jun VARCHAR(255),
	@jul VARCHAR(255),
	@aug VARCHAR(255),
	@sep VARCHAR(255),
	@oct VARCHAR(255),
	@nov VARCHAR(255),
	@dec VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

	-- department_leader,  team_leader, business_owner, primary_contact
	MERGE INTO [dbo].[employee] AS TGT
	USING (
		SELECT IIF(len(@department_leader) = 0, 'Unknown', @department_leader) as data_value
		UNION
		SELECT IIF(len(@team_leader) = 0, 'Unknown', @team_leader) as data_value
		UNION 
		SELECT IIF(len(@business_owner) = 0, 'Unknown', @business_owner) as data_value
		UNION 
		SELECT IIF(len(@primary_contact) = 0, 'Unknown', @primary_contact) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([employee], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;

	-- supplier
	MERGE INTO [dbo].[supplier] AS TGT
	USING (
		SELECT IIF(len(@supplier) = 0, 'Unknown', @supplier) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([supplier_code], [supplier], [supplier_long], [raw]) 
		VALUES (NULL, SRC.data_value, SRC.data_value, SRC.data_value)
	;
	
	-- contractor: @contractor VARCHAR(255), @worker_id VARCHAR(255), @pid VARCHAR(255),
	MERGE INTO [dbo].[contractor] AS TGT
	USING (
		SELECT 
			wid.worker_id,
			pid.pid,
			w.worker,
			wfirst.first_name,
			wlast.last_name
		FROM (SELECT IIF(len(@worker_id) = 0, 'Unknown', @worker_id) as worker_id) as wid
		JOIN (SELECT IIF(len(@pid) = 0, NULL, @pid) as pid) as pid ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, @contractor) as worker) as w ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, RIGHT(@contractor,CHARINDEX(',',REVERSE(@contractor))-1)) as first_name) as wfirst ON 1=1
		JOIN (SELECT IIF(len(@contractor) = 0, NULL, LEFT(@contractor, CHARINDEX(',', @contractor + ',') - 1) ) as last_name) as wlast ON 1=1
	) AS SRC
		ON TGT.[raw] = SRC.worker_id
	WHEN NOT MATCHED THEN
		INSERT (
			[worker_id]
           ,[pid]
           ,[first_name]
           ,[last_name]
           ,[full_name]
           ,[worker_site]
           ,[raw]
		) 
		VALUES (
			SRC.worker_id,
			SRC.pid,
			SRC.first_name,
			SRC.last_name,
			SRC.worker,
			CONCAT('Manual Entry: ', @site), -- worker_site
			SRC.worker_id -- raw
		)
	;

	-- main doc title
	MERGE INTO [dbo].[main_document_title] AS TGT
	USING (
		SELECT IIF(len(@main_doc_title) = 0, 'Unknown', @main_doc_title) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([main_document_title], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;

	-- @cost_object_code
	MERGE INTO [dbo].[cost_object_code] AS TGT
	USING (
		SELECT IIF(len(@cost_object_code) = 0, 'Unknown', @cost_object_code) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([cost_object_code], [is_opex], [raw]) 
		VALUES (SRC.data_value, IIF(LEFT(SRC.data_value, 2) = 'FG', 1, 0), SRC.data_value)
	;

	-- @account
	MERGE INTO [dbo].[account] AS TGT
	USING (
		SELECT IIF(len(@account) = 0, 'Unknown', @account) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([account_code], [raw]) 
		VALUES (SRC.data_value, SRC.data_value)
	;

	-- budget_code
	MERGE INTO [dbo].[budget_code] AS TGT
	USING (
		SELECT IIF(len(@budget_code) = 0, 'Unknown', @budget_code) as data_value
	) AS SRC
		ON TGT.[raw] = SRC.data_value
	WHEN NOT MATCHED THEN
		INSERT ([segmentation_id], [platform_id], [budget_code], [budget_name], [raw]) 
		VALUES (0, 0, SRC.data_value, NULL, SRC.data_value)
	;

	DROP TABLE IF EXISTS #TMP_FORECAST_UPDATE;
	SELECT TOP 1
		@forecast_id as forecast_id,
		IIF(LEN(@company_code) = 0, 0, @company_code) as [company_code_id],
		IIF(LEN(@bu) = 0, 0, @bu) as [business_unit_id],
		IIF(LEN(@dept) = 0, 0, @dept) as [department_id],
		IIF(LEN(@cost_center_code) = 0, 0, @cost_center_code) as [cost_center_code_id],
		IIF(LEN(@department_leader) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @department_leader)) as [department_leader_id],
		IIF(LEN(@team_leader) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @team_leader)) as [team_leader_id],
		IIF(LEN(@business_owner) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @business_owner)) as [business_owner_id],
		IIF(LEN(@primary_contact) = 0, 0, (SELECT MIN([employee_id]) FROM [dbo].[employee] WHERE [raw] = @primary_contact)) as [primary_contact_id],
		IIF(LEN(@supplier) = 0, 0, (SELECT MIN([supplier_id]) FROM [dbo].[supplier] WHERE [raw] = @supplier)) as [supplier_id],
		IIF(LEN(@worker_id) = 0, 0, (SELECT MIN([contractor_id]) FROM [dbo].[contractor] WHERE [raw] = @worker_id)) as [contractor_id],
		IIF(LEN(@worker_start_date) = 0 OR @worker_start_date = '0', NULL, @worker_start_date) as [worker_start_date_id],
		IIF(LEN(@worker_end_date) = 0 OR @worker_end_date = '0', NULL, @worker_end_date) as [worker_end_date_id],
		IIF(LEN(@override_end_date) = 0 OR @override_end_date = '0', NULL, @override_end_date) as [override_end_date_id],
		IIF(LEN(@main_doc_title) = 0, 0, (SELECT MIN([main_document_title_id]) FROM [dbo].[main_document_title] WHERE [raw] = @main_doc_title)) as [main_document_title_id],
		IIF(LEN(@cost_object_code) = 0, 0, (SELECT MIN([cost_object_code_id]) FROM [dbo].[cost_object_code] WHERE [raw] = @cost_object_code)) as [cost_object_code_id],
		IIF(LEN(@site) = 0, 0, @site) as [site_id],
		IIF(LEN(@account) = 0, 0, (SELECT MIN([account_id]) FROM [dbo].[account] WHERE [raw] = @account)) as [account_id],
		IIF(LEN(@work_type) = 0, 0, @work_type) as [work_type_id],
		IIF(LEN(@worker_status) = 0, 0, @worker_status) as [worker_status_id],
		IIF(LEN(@work_order_category) = 0, 0, @work_order_category) as [work_order_category_id],
		IIF(LEN(@expense_class) = 0, 0, @expense_class) as [expense_classification_id],
		IIF(LEN(@budget_code) = 0, 0, (SELECT MIN([budget_code_id]) FROM [dbo].[budget_code] WHERE [raw] = @budget_code)) as [budget_code_id],
		IIF(LEN(@segmentation) = 0, 0, @segmentation) as [segmentation_id],
		IIF(LEN(@platform) = 0, 0, @platform) as [platform_id],
		IIF(LEN(@function) = 0, 0, @function) as [function_id],
		IIF(LEN(@support_scalable) = 0, 0, @support_scalable) as [support_scalable_id],
		IIF(LEN(@work_order_id) = 0, NULL, @work_order_id) as [work_order_id],
		IIF(LEN(@desc) = 0, NULL, @desc) as [description],
		IIF(LEN(@allocation) = 0, NULL, TRY_CAST(@allocation AS FLOAT)) as [allocation],
		IIF(LEN(@bill_rate_hr) = 0, NULL, TRY_CAST(@bill_rate_hr AS FLOAT)) as [current_bill_rate_hr],
		IIF(LEN(@bill_rate_day) = 0, NULL, TRY_CAST(@bill_rate_day AS FLOAT)) as [current_bill_rate_day],
		IIF(LEN(@comment) = 0, NULL, @comment) as [comment],
		0 as [is_deleted]
	INTO #TMP_FORECAST_UPDATE
	;

	UPDATE [dbo].[forecast]
	SET [company_code_id] = t.[company_code_id],
        [business_unit_id] = t.[business_unit_id],
        [department_id] = t.[department_id],
        [cost_center_code_id] = t.[cost_center_code_id],
        [department_leader_id] = t.[department_leader_id],
        [team_leader_id] = t.[team_leader_id],
        [business_owner_id] = t.[business_owner_id],
        [primary_contact_id] = t.[primary_contact_id],
        [supplier_id] = t.[supplier_id],
        [contractor_id] = t.[contractor_id],
        [worker_start_date_id] = t.[worker_start_date_id],
        [worker_end_date_id] = t.[worker_end_date_id],
        [override_end_date_id] = t.[override_end_date_id],
        [main_document_title_id] = t.[main_document_title_id],
        [cost_object_code_id] = t.[cost_object_code_id],
        [site_id] = t.[site_id],
        [account_code_id] = t.[account_id],
        [work_type_id] = t.[work_type_id],
        [worker_status_id] = t.[worker_status_id],
        [work_order_category_id] = t.[work_order_category_id],
        [expense_classification_id] = t.[expense_classification_id],
        [budget_code_id] = t.[budget_code_id],
        [segmentation_id] = t.[segmentation_id],
        [platform_id] = t.[platform_id],
        [function_id] = t.[function_id],
        [support_scalable_id] = t.[support_scalable_id],
        [work_order_id] = t.[work_order_id],
        [description] = t.[description],
        [allocation] = t.[allocation],
        [current_bill_rate_hr] = t.[current_bill_rate_hr],
        [current_bill_rate_day] = t.[current_bill_rate_day],
        [comment] = t.[comment]
	FROM [dbo].[forecast] as f
	JOIN #TMP_FORECAST_UPDATE as t
		ON t.[forecast_id] = f.[forecast_id]
	WHERE t.[forecast_id] = f.[forecast_id]
	;

	
	DROP TABLE IF EXISTS #TMP_FORECAST_LINE_ITEM_UPDATE;
	SELECT * 
	INTO #TMP_FORECAST_LINE_ITEM_UPDATE
	FROM
	(
	SELECT DISTINCT 
		@forecast_id as forecast_id,
		dd.[first_of_month_date_key] as date_id, 
		IIF(LEN(@jan) = 0, 0.00, TRY_CAST(@jan AS FLOAT)) as [amount], 
		0 as [is_actualized], 
		0 as is_deleted
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 1
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@feb) = 0, 0.00, TRY_CAST(@feb AS FLOAT)), 0, 0
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 2
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@mar) = 0, 0.00, TRY_CAST(@mar AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 3
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@apr) = 0, 0.00, TRY_CAST(@apr AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 4
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@may) = 0, 0.00, TRY_CAST(@may AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 5
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@jun) = 0, 0.00, TRY_CAST(@jun AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 6
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@jul) = 0, 0.00, TRY_CAST(@jul AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 7
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@aug) = 0, 0.00, TRY_CAST(@aug AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 8
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@sep) = 0, 0.00, TRY_CAST(@sep AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 9
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@oct) = 0, 0.00, TRY_CAST(@oct AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 10
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@nov) = 0, 0.00, TRY_CAST(@nov AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 11
	UNION
	SELECT DISTINCT @forecast_id, dd.[first_of_month_date_key], IIF(LEN(@dec) = 0, 0.00, TRY_CAST(@dec AS FLOAT)), 0, 0 
	FROM [dbo].[date_dimension] as dd WHERE [calendar_year] = @var_year AND [month_of_year] = 12
	) as t
	;

	UPDATE [dbo].[forecast_line_item]
	SET [amount] = t.[amount]
	FROM [dbo].[forecast_line_item] as f
	JOIN #TMP_FORECAST_LINE_ITEM_UPDATE as t
		ON t.[forecast_id] = f.[forecast_id]
		AND t.[date_id] = f.[date_id]
	WHERE t.[forecast_id] = f.[forecast_id]
		AND t.[date_id] = f.[date_id]
	;

END
;
GO



-- EXEC [dbo].[sp_insert_work_order_into_forecast] 71645, 2023, '486.40', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0';         

-- SELECT * FROM [dbo].[forecast] ORDER BY 1 DESC

--SELECT * FROM [dbo].[forecast_line_item_v2]
--WHERE forecast_id = (SELECT MAX(forecast_id) FROM [dbo].[forecast])

DROP PROCEDURE IF EXISTS [dbo].[sp_insert_work_order_into_forecast];
GO
CREATE PROCEDURE [dbo].[sp_insert_work_order_into_forecast]
    @wo_id INT,
	@jan VARCHAR(255),
	@feb VARCHAR(255),
	@mar VARCHAR(255),
	@apr VARCHAR(255),
	@may VARCHAR(255),
	@jun VARCHAR(255),
	@jul VARCHAR(255),
	@aug VARCHAR(255),
	@sep VARCHAR(255),
	@oct VARCHAR(255),
	@nov VARCHAR(255),
	@dec VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
        BEGIN TRANSACTION; -- Start the transaction

	INSERT INTO [dbo].[forecast]
			   ([company_code_id]
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
			   ,[contractor_first_name]
			   ,[contractor_last_name]
			   ,[comment]
			   ,[old_forecast_id]
			   ,[is_deleted]
			   ,[created_by]
			   ,[created_date]
			   ,[updated_by]
			   ,[updated_date])
		SELECT TOP 1
			wo.[company_code_id],
			wo.[business_unit_id],
			wo.[department_id],
			0 as [cost_center_code_id],
			wo.svp_id as [department_leader_id],
			0 as [team_leader_id],
			0 as [business_owner_id],
			wo.[primary_contact_id],
			wo.[supplier_id],
			wo.[contractor_id],
			wo.[worker_start_date_id],
			wo.[worker_end_date_id],
			NULL as [override_end_date_id],
			wo.[main_document_title_id],
			wo.[cost_object_code_id],
			wo.[location_id] as [site_id],
			0 as [account_code_id],
			(SELECT MIN(work_type_id) FROM [dbo].[work_type] WHERE work_type = 'Contingent') as [work_type_id],
			wo.[worker_status_id],
			0 as [work_order_category_id],
			0 as [expense_classification_id],
			0 as [budget_code_id],
			0 as [segmentation_id],
			0 as [platform_id],
			0 as [function_id],
			0 as [support_scalable_id],
			wo.[work_order_id],
			c.[full_name] as [description],
			wo.[allocation_percentage] as [allocation],
			wo.[current_bill_rate] as [current_bill_rate_hr],
			NULL as [current_bill_rate_day],
			c.[first_name] as [contractor_first_name],
			c.[last_name] as [contractor_last_name],
			NULL as [comment],
			NULL as [old_forecast_id],
			0 as [is_deleted],
			CURRENT_USER as [created_by],
			CURRENT_TIMESTAMP as [created_date],
			CURRENT_USER as [updated_by],
			CURRENT_TIMESTAMP as [updated_date]
		FROM [dbo].[work_order] as wo
		LEFT JOIN [dbo].[contractor] as c
			ON wo.[contractor_id] = c.[contractor_id]
		WHERE wo.[id] = @wo_id
	;

	UPDATE [dbo].[work_order_add_to_forecast]
	SET [is_added] = 1,
		[action_by] = CURRENT_USER,
		[action_date] = CURRENT_TIMESTAMP,
		[updated_by] = CURRENT_USER,
		[updated_date] = CURRENT_TIMESTAMP
	WHERE work_order_id = @wo_id
	;

	-- get most recently created record based on user
	DECLARE @new_forecast_id BIGINT
	SELECT @new_forecast_id = (SELECT MAX([forecast_id]) FROM [dbo].[forecast] WHERE [created_by] = CURRENT_USER)
	;

	INSERT INTO [dbo].[forecast_line_item]
			   ([forecast_id]
			   ,[date_id]
			   ,[amount]
			   ,[is_deleted]
			   ,[is_actualized]
			   ,[created_by]
			   ,[created_date]
			   ,[updated_by]
			   ,[updated_date])
	SELECT
		@new_forecast_id as [forecast_id],
		[date_id] as date_id,
		[amount] as [amount],
		0 as [is_deleted],
		0 as [is_actualized],
		CURRENT_USER as [created_by],
		CURRENT_TIMESTAMP as [created_date],
		CURRENT_USER as [updated_by],
		CURRENT_TIMESTAMP as [updated_date]
	FROM
		(SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@jan) = 0, '0', @jan) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'January'
		UNION
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@feb) = 0, '0', @feb) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'February'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@mar) = 0, '0', @mar) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'March'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@apr) = 0, '0', @apr) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'April'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@may) = 0, '0', @may) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'May'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@jun) = 0, '0', @jun) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'June'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@jul) = 0, '0', @jul) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'July'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@aug) = 0, '0', @aug) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'August'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@sep) = 0, '0', @sep) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'September'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@oct) = 0, '0', @oct) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'October'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@nov) = 0, '0', @nov) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'November'
		UNION 
		SELECT 
			MIN(first_of_month_date_key) as date_id,
			IIF(LEN(@dec) = 0, '0', @dec) as [amount]
		FROM [dbo].[date_dimension] as dd
		WHERE dd.[calendar_year] = (SELECT LEFT(MIN(worker_start_date_id), 4) FROM [dbo].[work_order] as wo WHERE wo.[id] = @wo_id)
		AND dd.month_name = 'December'
		) as t
		;

		COMMIT; -- If everything is successful, commit the transaction
    END TRY
	    BEGIN CATCH
        ROLLBACK; -- If any error occurred, rollback the transaction

        -- Optionally, handle the error in some way, for example, by rethrowing it:
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH
END
;
GO
