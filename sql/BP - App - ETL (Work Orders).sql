USE [TEST];

-- Worker Type
INSERT INTO [dbo].[work_type]
           ([work_type]
           ,[raw])
SELECT DISTINCT
	[Worker Type],
	[Worker Type]
FROM [staging].[work_order_detail] as stg
LEFT JOIN [dbo].[work_type] AS prd
	ON stg.[Worker Type] = prd.[raw]
WHERE prd.[work_type_id] IS NULL -- is new
ORDER BY 1
;