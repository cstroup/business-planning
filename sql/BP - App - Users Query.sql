USE [TEST]
GO

SELECT * FROM [dbo].[business_unit];

SELECT * FROM [dbo].[deptartment];

SELECT * FROM [dbo].[user];

SELECT * FROM [dbo].[user_access];

SELECT * FROM [dbo].[deptartment_business_unit]


SELECT * FROM [dbo].[date_dimension] ORDER BY 1

SELECT
	calendar_year_month,
	sum(onshore_work_hours),
	sum(offshore_work_hours)
FROM [dbo].[date_dimension] 
GROUP BY calendar_year_month
ORDER BY 1


UPDATE [dbo].[deptartment]
SET [department] = 'Digital Platforms Insights',
[department_long] = 'Digital Platforms Insights (999)'
WHERE [department_code] = 999
;



INSERT INTO [dbo].[deptartment_business_unit]
           ([department_id]
           ,[business_unit_id])
SELECT *
FROM
(SELECT
	department_id,
	CASE
		WHEN department_code IN (999, 996, 110)
		THEN (SELECT MIN(business_unit_id) FROM [dbo].[business_unit] WHERE [raw] = 'DIGITAL PLATFORMS') --1008 -- DIGITAL PLATFORMS
		ELSE NULL
	END as bu
FROM [dbo].[deptartment]
UNION
SELECT
	department_id,
	CASE
		WHEN department_code IN (110)
		THEN (SELECT MIN(business_unit_id) FROM [dbo].[business_unit] WHERE [raw] = 'CONNECTIVITY')  -- 1004 -- CONNECTIVITY
		ELSE NULL
	END as bu
FROM [dbo].[deptartment]
) as t
WHERE bu IS NOT NULL
;



SELECT
	dbu.id
FROM [dbo].[deptartment_business_unit] as dbu
JOIN [dbo].[business_unit] as bu
	ON dbu.business_unit_id = bu.business_unit_id
WHERE bu.business_unit = 'DIGITAL PLATFORMS' -- DIGITAL PLATFORMS | CONNECTIVITY
;