SELECT * FROM [dbo].[auto_tag]
ORDER BY 1 DESC


SELECT * 
FROM [dbo].[general_ledger]
WHERE [auto_tag_id] IS NOT NULL


SELECT * 
FROM [dbo].[general_ledger]
WHERE [comment] IS NOT NULL

SELECT * 
FROM [dbo].[general_ledger]
WHERE [forecast_id] IS NOT NULL



SELECT * FROM [audit].[user_actions]