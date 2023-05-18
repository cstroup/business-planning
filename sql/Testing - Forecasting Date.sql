/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *
FROM [TEST].[dbo].[date_dimension]
WHERE date_id >= 20230101



SELECT * FROM [TEST].[dbo].[date_dimension] WHERE calendar_year_month = '2023-05' ORDER BY 1




SELECT *
FROM  [dbo].[date_dimension]
	