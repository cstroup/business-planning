DROP PROCEDURE IF EXISTS [etl].[sp_inital_migration_v1];
GO
CREATE PROCEDURE [etl].[sp_inital_migration_v1]
AS
BEGIN
    SET NOCOUNT ON;

-- STAGING TABLES
INSERT INTO [staging].[account_mapping]
	([Account Number]
	,[Account Name]
	,[P&L Rollup Level 1]
	,[P&L Rollup Level 2])
     VALUES
('AC.61020001','Salaries-Tech I ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020002','Salaries-Tech II ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020003','Salaries-Tech III ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020004','Salaries-Tech IV ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020005','Salaries-Tech V ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020006','Salaries-Tech VI ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020011','Salaries-Supervisors ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020012','Salaries-Managers ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020007','Salaries-Support Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020008','Salaries-Support Non Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020009','Salaries-Intern ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020000','Salaries-Frontline ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020010','Salaries-Leads ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020050','Corporate Attrition-Planned ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020055','Headcount Vacancy ','Total Salaries & Wages','Personnel Expenses'),
('AC.61020060','Salaries-Other Salary and Wage ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120011','On Call-Supervisors ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120012','On Call-Manager ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120001','On Call-Tech I ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120002','On Call-Tech II ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120003','On Call-Tech III ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120004','On Call-Tech IV ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120005','On Call-Tech V ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120006','On Call-Tech VI ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120007','On Call-Support Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120008','On Call-Support Non Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120009','On Call-Intern ','Total Salaries & Wages','Personnel Expenses'),
('AC.61120000','On Call-Frontline ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130011','Shift Differential-Supervisors ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130012','Shift Differential-Managers ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130001','Shift Differential-Tech I ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130002','Shift Differential-Tech II ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130003','Shift Differential-Tech III ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130004','Shift Differential-Tech IV ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130005','Shift Differential-Tech V ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130006','Shift Differential-Tech VI ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130007','Shift Differential-Support Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130008','Shift Differential-Support Non Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130009','Shift Differential-Intern ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130000','Shift Differential-Frontline ','Total Salaries & Wages','Personnel Expenses'),
('AC.61130010','Shift Differential-Leads ','Total Salaries & Wages','Personnel Expenses'),
('AC.61040000','Vacation Accrued ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160001','Commissions-Tech I ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160002','Commissions-Tech II ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160003','Commissions-Tech III ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160004','Commissions-Tech IV ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160011','Commissions-Supervisors ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160012','Commissions-Managers ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160007','Commissions-Support Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160008','Commissions-Support Non Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160009','Commissions-Intern ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160000','Commissions-Frontline ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160010','Commissions-Leads ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160050','Deferred Commissions ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080011','Incentive Compensation-Supervisors ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080012','Incentive Compensation-Managers ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080000','Incentive Compensation-Frontline ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080050','Incentive Compensation-Charter Rewards ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080055','Incentive Compensation-Other ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080056','Incentive Compensation-Excess Performance ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080057','Incentive Compensation-Annual Kicker ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080058','Incentive Compensation-Annual Performance ','Total Salaries & Wages','Personnel Expenses'),
('AC.61080060','Incentive Compensation-Employee Sales Referral ','Total Salaries & Wages','Personnel Expenses'),
('AC.61180011','Self-Install Incentive Comp-Supervisors ','Total Salaries & Wages','Personnel Expenses'),
('AC.61180012','Self-Install Incentive Comp-Managers ','Total Salaries & Wages','Personnel Expenses'),
('AC.61180000','Self-Install Incentive Comp-Frontline ','Total Salaries & Wages','Personnel Expenses'),
('AC.61160065','Commissions-Corporate Attrition ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140011','Overtime-Supervisors ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140012','Overtime-Managers ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140001','Overtime-Tech I ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140002','Overtime-Tech II ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140003','Overtime-Tech III ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140004','Overtime-Tech IV ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140005','Overtime-Tech V ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140006','Overtime-Tech VI ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140007','Overtime-Support Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140008','Overtime-Support Non Exempt ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140009','Overtime-Intern ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140000','Overtime-Frontline ','Total Salaries & Wages','Personnel Expenses'),
('AC.61140010','Overtime-Leads ','Total Salaries & Wages','Personnel Expenses'),
('AC.61210000','Health and Welfare Benefits Expense ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61210050','International Medical ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260000','401k ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260050','401k RAP ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260055','401k Transition Contribution ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260060','401k Match True-up ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260065','401k Deferred ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260070','401k Match-Forfeiture Expense ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260075','401k RAP-Forfeiture Expense ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260080','401k International ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61260085','401k Other Fees ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61050000','Deferred Comp FMV Adjs ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61090000','Benefits-Charter Merit ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61090001','Benefits-Charter Distinction ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61100000','Employee Sales Incentive Compensation ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61280000','Education Reimbursement ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61300000','Benefits-Auto Allowance ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61360000','Benefits-Other ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61360050','Benefits-Cable Box ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61200000','Union Benefits ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61060000','Bonus-Accrued ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61060050','Bonus-Long Term Incentive Plan  - LTIP','Total Benefits & Taxex','Personnel Expenses'),
('AC.61060055','Bonus-Discretionary ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61060060','Bonus-Employee Signing ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61060065','Bonus-Other ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61060070','Bonus-Relocation ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61410000','FICA-Employer ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61410050','Deferred Payroll Tax ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61410055','Tax on Bonus ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61410060','RSU-Social Security ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61410065','Stock Options-Social Security ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61420055','Stock Options-Medicare ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61420050','RSU-Medicare ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61420000','Medicare-Employer Portion ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61400000','Payroll Taxes Misc ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61470000','Local Payroll Tax Expense ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61430055','Stock Options-FUTA ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61430050','RSU-FUTA ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61430000','Federal Unemployment ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61440055','Stock Options-SUTA ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61440050','RSU-SUTA ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61440000','State Unemployment ','Total Benefits & Taxex','Personnel Expenses'),
('AC.61520001','Contract Labor-Resi Single Play Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520002','Contract Labor-Resi Double Play Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520003','Contract Labor-Resi Triple Play Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520004','Contract Labor-Resi Quad Play Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520006','Contract Labor-Installation Hourly Rate Work ','Contract Labor Total','Contractors & Temporary'),
('AC.61520008','Contract Labor-Resi Upgrade Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520013','Contract Labor-Resi Restart ','Contract Labor Total','Contractors & Temporary'),
('AC.61520014','Contract Labor-Resi Wall Fish Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520017','Contract Labor-SI Bulk Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520101','Contract Labor-SMB Single Play Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520102','Contract Labor-SMB Double Play Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520103','Contract Labor-SMB Triple Play Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520108','Contract Labor-SMB Upgrade Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520112','Contract Labor-SMB WiFi Hotspot Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520113','Contract Labor-SMB Restart ','Contract Labor Total','Contractors & Temporary'),
('AC.61520114','Contract Labor-SMB Wall Fish Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520010','Contract Labor-Resi Service Calls ','Contract Labor Total','Contractors & Temporary'),
('AC.61520110','Contract Labor-SMB Service Calls ','Contract Labor Total','Contractors & Temporary'),
('AC.61520011','Contract Labor-Resi Site Survey ','Contract Labor Total','Contractors & Temporary'),
('AC.61520111','Contract Labor-SMB Site Survey ','Contract Labor Total','Contractors & Temporary'),
('AC.61520015','Contract Labor-Resi Special Request Order 1 ','Contract Labor Total','Contractors & Temporary'),
('AC.61520016','Contract Labor-Resi Special Request Order 2 ','Contract Labor Total','Contractors & Temporary'),
('AC.61520007','Contract Labor-Drop Bury Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520009','Contract Labor-Locates ','Contract Labor Total','Contractors & Temporary'),
('AC.61520005','Contract Labor-Other ','Contract Labor Total','Contractors & Temporary'),
('AC.61520024','Contract Labor - Non Standard Drop Installation ','Contract Labor Total','Contractors & Temporary'),
('AC.61520018','Contract Labor-Per Diem ','Contract Labor Total','Contractors & Temporary'),
('AC.61520019','Contract Labor-Erate Managed ','Contract Labor Total','Contractors & Temporary'),
('AC.61520020','Contract Labor-Resi Disconnects ','Contract Labor Total','Contractors & Temporary'),
('AC.61520021','Contract Labor-Chargebacks ','Contract Labor Total','Contractors & Temporary'),
('AC.61520022','Contract Labor-Damage Recovery ','Contract Labor Total','Contractors & Temporary'),
('AC.61520120','Contract Labor-SMB Disconnects ','Contract Labor Total','Contractors & Temporary'),
('AC.61520023','Contract Labor-Damage Claim Chargeback ','Contract Labor Total','Contractors & Temporary'),
('AC.61520000','Contract Labor ','Contract Labor Total','Contractors & Temporary'),
('AC.61530000','Call Center-3rd Party Costs ','Temp Help','Contractors & Temporary'),
('AC.61510000','Temporary Help ','Temp Help','Contractors & Temporary'),
('AC.67120001','3rd Party Com-Retail Bounties-Big Box ','Bounties','3rd Party Commissions'),
('AC.67120002','3rd Party Com-Retail Bounties-Retailers ','Bounties','3rd Party Commissions'),
('AC.67120003','3rd Party Com-Retail Bounties-Authorized Partners ','Bounties','3rd Party Commissions'),
('AC.67120004','3rd Party Com-Retail Bounties-MWP ','Bounties','3rd Party Commissions'),
('AC.67120000','3rd Party Com-Retail Bounties-Point Incentives ','Bounties','3rd Party Commissions'),
('AC.67120030','3rd Party Other Bounties-Other ','Bounties','3rd Party Commissions'),
('AC.67120020','3rd Party Com-Online Bounties-Affiliates ','Bounties','3rd Party Commissions'),
('AC.67120021','3rd Party Com-Online Bounties-Digital ','Bounties','3rd Party Commissions'),
('AC.67120022','3rd Party Com-Online Bounties-Search Call Center ','Bounties','3rd Party Commissions'),
('AC.67120010','3rd Party Com-OTM Bounties ','Bounties','3rd Party Commissions'),
('AC.61800000','Education & Training-Professional Development ','Education & Training','Education & Training'),
('AC.61800001','Education & Training-Tuition Reimbursement ','Education & Training','Education & Training'),
('AC.61800002','Education & Training-Profess Development Diverse ','Education & Training','Education & Training'),
('AC.61800003','Education & Training-Other ','Education & Training','Education & Training'),
('AC.62010000','Recruitment-Other ','Recruitment','Recruitment'),
('AC.62010001','Recruitment-Recruiter Fees ','Recruitment','Recruitment'),
('AC.62010002','Recruitment-Drug Testing ','Recruitment','Recruitment'),
('AC.62010003','Recruitment-Advertising ','Recruitment','Recruitment'),
('AC.62010004','Recruitment-Diverse ','Recruitment','Recruitment'),
('AC.62000000','Relocation Exp ','Relocation','Relocation'),
('AC.61780000','Travel & Entertainment-Entertainment ','Travel & Entertainment Other','Travel & Entertrainment'),
('AC.61700000','Travel & Entertainment-Other ','Travel & Entertainment Other','Travel & Entertrainment'),
('AC.61710000','Travel & Entertainment-Airfare Expense ','Airfare Expense','Travel & Entertrainment'),
('AC.61710001','Travel & Entertainment-Airfare Luggage ','Airfare Expense','Travel & Entertrainment'),
('AC.61720000','Travel & Entertainment-Auto Mileage ','Auto Expense','Travel & Entertrainment'),
('AC.61720001','Travel & Entertainment-Auto/Car & Taxi Service ','Auto Expense','Travel & Entertrainment'),
('AC.61720002','Travel & Entertainment-Auto/Car Rental ','Auto Expense','Travel & Entertrainment'),
('AC.61720003','Travel & Entertainment-Auto Parking/Toll Fees ','Auto Expense','Travel & Entertrainment'),
('AC.61740003','Travel & Entertainment-Employee Meal Per Diem ','Travel & Entertainment Meals','Travel & Entertrainment'),
('AC.61740000','Travel & Entertainment-Employee Meal Travel ','Travel & Entertainment Meals','Travel & Entertrainment'),
('AC.61740001','Travel & Entertainment-Employee Meal Non Travel ','Travel & Entertainment Meals','Travel & Entertrainment'),
('AC.61740002','Travel & Entertainment-Guest Meals ','Travel & Entertainment Meals','Travel & Entertrainment'),
('AC.61730000','Travel & Entertainment-Lodging ','Travel & Entertainment Lodging','Travel & Entertrainment'),
('AC.61750000','Travel & Entertainment-Meetings ','Travel & Entertainment Meetings','Travel & Entertrainment'),
('AC.62050000','Office Machine Rent ','Office Machine Rent ','Office Expenses'),
('AC.62040000','Office Furniture & Equipment Rental ','Office Furniture & Equipment Rental ','Office Expenses'),
('AC.62020000','Office Maintenance-General ','Office Maintenance','Office Expenses'),
('AC.62020001','Office Maintenance-Janitorial ','Office Maintenance','Office Expenses'),
('AC.62020002','Office Maintenance-Outdoor ','Office Maintenance','Office Expenses'),
('AC.62020003','Office Maintenance-Safety & Security ','Office Maintenance','Office Expenses'),
('AC.62020004','Office Maintenance-M&R One Time Maintenance ','Office Maintenance','Office Expenses'),
('AC.62020005','Office Maintenance-Heating/AC /HVAC Repairs','Office Maintenance','Office Expenses'),
('AC.62020006','Office Maintenance-Electrical & Plumbing ','Office Maintenance','Office Expenses'),
('AC.62020007','Office Maintenance-Aesthetics ','Office Maintenance','Office Expenses'),
('AC.62020008','Office Maintenance-Power Maintenance ','Office Maintenance','Office Expenses'),
('AC.62020009','Office Maintenance-Permits/ Surveys/ Moving ','Office Maintenance','Office Expenses'),
('AC.62020010','Office Maintenance-Cafeteria Subsidize & Fitness ','Office Maintenance','Office Expenses'),
('AC.62020011','Office Maintenance-Archived Records Storage ','Office Maintenance','Office Expenses'),
('AC.62020012','Office Maintenance-Environmental Testing ','Office Maintenance','Office Expenses'),
('AC.62020013','Office Maintenance-Store Exit Costs ','Office Maintenance','Office Expenses'),
('AC.62110001','Postage Expense ','Postage Expense ','Office Expenses'),
('AC.62060000','Office Supplies ','Office Supplies ','Office Expenses'),
('AC.62100000','Office Printing ','Office Printing ','Office Expenses'),
('AC.62110002','Freight - CPE Mail in Program ','Freight - CPE Mail in Program ','Freight Expenses'),
('AC.62110003','Freight - Equipment Transfers ','Freight - Equipment Transfers ','Freight Expenses'),
('AC.62110004','Dedicated Freight Expense ','Dedicated Freight Expense ','Freight Expenses'),
('AC.62110005','Brokered Freight - Inbound ','Brokered Freight - Inbound ','Freight Expenses'),
('AC.62110006','Brokered Freight - Intra Network ','Brokered Freight - Intra Network ','Freight Expenses'),
('AC.62110000','Freight Expense ','Freight Expense ','Freight Expenses'),
('AC.62270000','Professional Services-Audit Fees ','Professional Services-Audit Fees ','Professional Services'),
('AC.62270001','Professional Services-Tax ','Professional Services-Tax ','Professional Services'),
('AC.62270010','Professional Services-Legal Fees RDOF ','Professional Services-Legal Fees RDOF ','Professional Services'),
('AC.62270003','Professional Services-Legal Settlement ','Professional Services-Legal Settlement ','Professional Services'),
('AC.62270002','Professional Services-Legal Fees ','Professional Services-Legal Fees ','Professional Services'),
('AC.62270011','Professional Services-Consulting RDOF ','Professional Services-Consulting RDOF ','Professional Services'),
('AC.62270004','Professional Services-Board of Directors ','Professional Services-Board of Directors ','Professional Services'),
('AC.62270005','Professional Services-Consulting ','Professional Services-Consulting ','Professional Services'),
('AC.62270006','Professional Services-Diverse ','Professional Services-Diverse ','Professional Services'),
('AC.62270007','Professional Services-MDU WiFi Monitoring ','Professional Services-MDU WiFi Monitoring ','Professional Services'),
('AC.62270008','Professional Services-MIS Support ','Professional Services-MIS Support ','Professional Services'),
('AC.62270009','Professional Services-Other ','Professional Services-Other ','Professional Services'),
('AC.66130002','Computer Maintenance Expense-Equipment Lease ','Computer Maintenance Expense-Equipment Lease ','Computer Maintenance'),
('AC.66130000','Computer Maintenance Expense ','Computer Maintenance Expense ','Computer Maintenance'),
('AC.66130001','Computer Maintenance Exp-Enterprise Customers ','Computer Maintenance Exp-Enterprise Customers ','Computer Maintenance'),
('AC.66430000','Enterprise Computer Maintenance ','Enterprise Computer Maintenance ','Enterprise Computer Maintenance'),
('AC.66430001','Enterprise System Maintenance ','Enterprise Computer Maintenance ','Enterprise Computer Maintenance'),
('AC.66760000','Software Expense ','Software Expense','Computer & Software Expense'),
('AC.66760001','Website Maintenance ','Software Expense','Computer & Software Expense'),
('AC.66760002','Software Exp-Enterprise Customers ','Software Expense','Computer & Software Expense'),
('AC.66290000','3rd Party Hosting Expense ','Hosting Expense','Computer & Software Expense'),
('AC.66290001','3rd Party Hosting Expense-Mobile Self-Service ','Hosting Expense','Computer & Software Expense'),
('AC.62170000','Dues-NCTA Fees ','Dues-NCTA Fees ','Dues & Subscriptions'),
('AC.62170001','Dues-Cable Labs ','Dues-Cable Labs ','Dues & Subscriptions'),
('AC.62170002','Dues-State ','Dues-State ','Dues & Subscriptions'),
('AC.62170003','Dues & Subscriptions-Professional ','Dues & Subscriptions-Professional ','Dues & Subscriptions'),
('AC.62170004','Dues & Subscriptions-Diverse ','Dues & Subscriptions-Diverse ','Dues & Subscriptions'),
('AC.62170005','Dues & Subscriptions-Other ','Dues & Subscriptions-Other ','Dues & Subscriptions'),
('AC.67150000','Original Programming-Marketing ','Original Programming-Marketing ','Marketing'),
('AC.67020001','Sales & Marketing-Digital Mktg-Social Media ','Sales & Marketing-Digital Mktg-Social Media ','Marketing'),
('AC.67020002','Sales & Marketing-Digital Mktg-Sup & Site Updates ','Sales & Marketing-Digital Mktg-Sup & Site Updates ','Marketing'),
('AC.67020003','Sales & Marketing-Digital Mktg-Analytics ','Sales & Marketing-Digital Mktg-Analytics ','Marketing'),
('AC.67020004','Sales & Marketing-Digital Mktg-Web Production ','Sales & Marketing-Digital Mktg-Web Production ','Marketing'),
('AC.67020006','Sales & Marketing-Digital Mktg-Operations ','Sales & Marketing-Digital Mktg-Operations ','Marketing'),
('AC.67020007','Sales & Marketing-Digital Mktg-Online Search ','Sales & Marketing-Digital Mktg-Online Search ','Marketing'),
('AC.67020008','Sales & Marketing-Digital Mktg-Digital Media ','Sales & Marketing-Digital Mktg-Digital Media ','Marketing'),
('AC.67020009','Sales & Marketing-Digital Mktg-Creative ','Sales & Marketing-Digital Mktg-Creative ','Marketing'),
('AC.67010001','Sales & Marketing-Split Signal Maint ','Sales & Marketing-Split Signal Maint ','Marketing'),
('AC.67010002','Sales & Marketing-Support & Site Updates ','Sales & Marketing-Support & Site Updates ','Marketing'),
('AC.67010003','Sales & Marketing-Brand/Prod/Competitive ','Sales & Marketing-Brand/Prod/Competitive ','Marketing'),
('AC.67010004','Sales & Marketing-Spokesperson Tips TV ','Sales & Marketing-Spokesperson Tips TV ','Marketing'),
('AC.67010005','Sales & Marketing-Creative-Digital ','Sales & Marketing-Creative-Digital ','Marketing'),
('AC.67010006','Sales & Marketing-Agency Retainer Fees ','Sales & Marketing-Agency Retainer Fees ','Marketing'),
('AC.67010007','Sales & Marketing-Event Marketing ','Sales & Marketing-Event Marketing ','Marketing'),
('AC.67010008','Sales & Marketing-Movers ','Sales & Marketing-Movers ','Marketing'),
('AC.67010009','Sales & Marketing-Print Ads ','Sales & Marketing-Print Ads ','Marketing'),
('AC.67010010','Sales & Marketing-TV Ads ','Sales & Marketing-TV Ads ','Marketing'),
('AC.67010011','Sales & Marketing-Media Mgt Fees ','Sales & Marketing-Media Mgt Fees ','Marketing'),
('AC.67010012','Sales & Marketing-Digital Video ','Sales & Marketing-Digital Video ','Marketing'),
('AC.67010013','Sales & Marketing-Radio & Digital Ads ','Sales & Marketing-Radio & Digital Ads ','Marketing'),
('AC.67010014','Sales & Marketing-Directories ','Sales & Marketing-Directories ','Marketing'),
('AC.67010015','Sales & Marketing-Local Competitive ','Sales & Marketing-Local Competitive ','Marketing'),
('AC.67010016','Sales & Marketing-Bill Marketing ','Sales & Marketing-Bill Marketing ','Marketing'),
('AC.67010017','Sales & Marketing-Email Marketing ','Sales & Marketing-Email Marketing ','Marketing'),
('AC.67010018','Sales & Marketing-Retention ','Sales & Marketing-Retention ','Marketing'),
('AC.67010019','Sales & Marketing-Direct Mail ','Sales & Marketing-Direct Mail ','Marketing'),
('AC.67010020','Sales & Marketing-Direct Mail-Retention/Upgrade ','Sales & Marketing-Direct Mail-Retention/Upgrade ','Marketing'),
('AC.67010021','Sales & Marketing-Direct Mail-Trigger Mktg ','Sales & Marketing-Direct Mail-Trigger Mktg ','Marketing'),
('AC.67010022','Sales & Marketing-Field Sales Channels Support ','Sales & Marketing-Field Sales Channels Support ','Marketing'),
('AC.67010023','Sales & Marketing-Direct Response ','Sales & Marketing-Direct Response ','Marketing'),
('AC.67010024','Sales & Marketing-Online Creative ','Sales & Marketing-Online Creative ','Marketing'),
('AC.67010025','Sales & Marketing-Direct Response-Fld Sls Chnl Sup ','Sales & Marketing-Direct Response-Fld Sls Chnl Sup ','Marketing'),
('AC.67010026','Sales & Marketing-Dir Response-Agency Retainer Fee ','Sales & Marketing-Dir Response-Agency Retainer Fee ','Marketing'),
('AC.67010027','Sales & Marketing-Advertising Other ','Sales & Marketing-Advertising Other ','Marketing'),
('AC.67010028','Sales & Marketing-Sponsorships Contractual ','Sales & Marketing-Sponsorships Contractual ','Marketing'),
('AC.67070001','Sales & Marketing-Incentives ','Sales & Marketing-Incentives ','Marketing'),
('AC.67070002','Sales & Marketing-Incentives-Tickets-Events/Sports ','Sales & Marketing-Incentives-Tickets-Events/Sports ','Marketing'),
('AC.67030001','Sales & Marketing-Mrktg Ops-Customer Communication ','Sales & Marketing-Mrktg Ops-Customer Communication ','Marketing'),
('AC.67030002','Sales & Marketing-Mrktg Ops-Stat Models/Analysis ','Sales & Marketing-Mrktg Ops-Stat Models/Analysis ','Marketing'),
('AC.67030003','Sales & Marketing-Mrktg Ops-Research-Pre Planned ','Sales & Marketing-Mrktg Ops-Research-Pre Planned ','Marketing'),
('AC.67030004','Sales & Marketing-Marketing Ops-Competitive Intell ','Sales & Marketing-Marketing Ops-Competitive Intell ','Marketing'),
('AC.67030005','Sales & Marketing-Marketing Ops-Infrastructure ','Sales & Marketing-Marketing Ops-Infrastructure ','Marketing'),
('AC.67030006','Sales & Marketing-Marketing Ops-Demographics ','Sales & Marketing-Marketing Ops-Demographics ','Marketing'),
('AC.67030007','Sales & Marketing-Marketing Ops-Data Lists ','Sales & Marketing-Marketing Ops-Data Lists ','Marketing'),
('AC.67030008','Sales & Marketing-Marketing Ops-Welcome Materials ','Sales & Marketing-Marketing Ops-Welcome Materials ','Marketing'),
('AC.67040001','Sales & Marketing-Multicult-Direct Response ','Sales & Marketing-Multicult-Direct Response ','Marketing'),
('AC.67040002','Sales & Marketing-Multicult-Brand/Prod/Competitiv ','Sales & Marketing-Multicult-Brand/Prod/Competitiv ','Marketing'),
('AC.67040003','Sales & Marketing-Multicult-Online Creative ','Sales & Marketing-Multicult-Online Creative ','Marketing'),
('AC.67040004','Sales & Marketing-Multicult-Field Sls Channels Sup ','Sales & Marketing-Multicult-Field Sls Channels Sup ','Marketing'),
('AC.67040005','Sales & Marketing-Multicult-Brand Agncy Retain Fee ','Sales & Marketing-Multicult-Brand Agncy Retain Fee ','Marketing'),
('AC.67040006','Sales & Marketing-Multicultural-Prog Barter ','Sales & Marketing-Multicultural-Prog Barter ','Marketing'),
('AC.67040007','Sales & Marketing-Multicultural-Print Ads ','Sales & Marketing-Multicultural-Print Ads ','Marketing'),
('AC.67040008','Sales & Marketing-Multicultural-TV Ads ','Sales & Marketing-Multicultural-TV Ads ','Marketing'),
('AC.67040009','Sales & Marketing-Multicult-Media Mgt Fees ','Sales & Marketing-Multicult-Media Mgt Fees ','Marketing'),
('AC.67040010','Sales & Marketing-Multicultural-Digital Video ','Sales & Marketing-Multicultural-Digital Video ','Marketing'),
('AC.67040011','Sales & Marketing-Multicult-Radio & Digital Ads ','Sales & Marketing-Multicult-Radio & Digital Ads ','Marketing'),
('AC.67040012','Sales & Marketing-Multicult-Dir Mail-Acquisition ','Sales & Marketing-Multicult-Dir Mail-Acquisition ','Marketing'),
('AC.67040013','Sales & Marketing-Multicult-Dir Mail-Retent/Upgrad ','Sales & Marketing-Multicult-Dir Mail-Retent/Upgrad ','Marketing'),
('AC.67040014','Sales & Marketing-Multicult-Direct Marketing ','Sales & Marketing-Multicult-Direct Marketing ','Marketing'),
('AC.67040015','Sales & Marketing-Multicult-African Amer Dir Resp ','Sales & Marketing-Multicult-African Amer Dir Resp ','Marketing'),
('AC.67040016','Sales & Marketing-Multicult-DR-Agency Retainer Fee ','Sales & Marketing-Multicult-DR-Agency Retainer Fee ','Marketing'),
('AC.67040017','Sales & Marketing-Multicult-Spokesperson Tips TV ','Sales & Marketing-Multicult-Spokesperson Tips TV ','Marketing'),
('AC.67090000','Sales & Marketing-Marketing Co-Op Other ','Sales & Marketing-Marketing Co-Op Other ','Marketing'),
('AC.67090001','Sales & Marketing-Gift with purchase-Promo ','Sales & Marketing-Gift with purchase-Promo ','Marketing'),
('AC.67090002','Sales & Marketing-Advertising Expense ','Sales & Marketing-Advertising Expense ','Marketing'),
('AC.67090003','Sales & Marketing-Adv Exp-Events & Trade Shows ','Sales & Marketing-Adv Exp-Events & Trade Shows ','Marketing'),
('AC.67090004','Sales & Marketing-Adv Exp-Chamber Dues & Assoc Fee ','Sales & Marketing-Adv Exp-Chamber Dues & Assoc Fee ','Marketing'),
('AC.67090005','Sales & Marketing-Advertising Expense-Diverse ','Sales & Marketing-Advertising Expense-Diverse ','Marketing'),
('AC.67090006','Sales & Marketing-Retailer Occupancy Compensation ','Sales & Marketing-Retailer Occupancy Compensation ','Marketing'),
('AC.67090007','Sales & Marketing-Research-Project ','Sales & Marketing-Research-Project ','Marketing'),
('AC.67090008','Sales & Marketing-Creative-Other ','Sales & Marketing-Creative-Other ','Marketing'),
('AC.67090009','Sales & Marketing-Creative-Marketing Science ','Sales & Marketing-Creative-Marketing Science ','Marketing'),
('AC.67090010','Sales & Marketing-Media Exp-Product Launches ','Sales & Marketing-Media Exp-Product Launches ','Marketing'),
('AC.67090011','Sales & Marketing-Media Exp-Sales Activation ','Sales & Marketing-Media Exp-Sales Activation ','Marketing'),
('AC.67090012','Sales & Marketing-Media Exp-Other ','Sales & Marketing-Media Exp-Other ','Marketing'),
('AC.67090013','Sales & Marketing-Digital Online National Programs ','Sales & Marketing-Digital Online National Programs ','Marketing'),
('AC.67090014','Sales & Marketing-Digital OL Campaign Development ','Sales & Marketing-Digital OL Campaign Development ','Marketing'),
('AC.67090015','Sales & Marketing-Product Creative Support ','Sales & Marketing-Product Creative Support ','Marketing'),
('AC.67090016','Sales & Marketing-Sales Activation-Charitable ','Sales & Marketing-Sales Activation-Charitable ','Marketing'),
('AC.67090017','Sales & Marketing-Advertising Credits ','Sales & Marketing-Advertising Credits ','Marketing'),
('AC.67050001','Sales & Marketing-POS Mtls ','Sales & Marketing-POS Mtls ','Marketing'),
('AC.67050002','Sales & Marketing-POS Mtls-Mystery Shopper ','Sales & Marketing-POS Mtls-Mystery Shopper ','Marketing'),
('AC.67050003','Sales & Marketing-POS Mtls-Demo Devices ','Sales & Marketing-POS Mtls-Demo Devices ','Marketing'),
('AC.67060001','Sales & Marketing-Local Trade Expense ','Sales & Marketing-Local Trade Expense ','Marketing'),
('AC.67060002','Sales & Marketing-Trade Expense Racing ','Sales & Marketing-Trade Expense Racing ','Marketing'),
('AC.62140000','Billing Exp-General ','Billing Exp-General ','Billing'),
('AC.62140001','Billing Exp-Subscriber Processing ','Billing Exp-Subscriber Processing ','Billing'),
('AC.62140002','Billing Exp-Statement Processing 3rd Party ','Billing Exp-Statement Processing 3rd Party ','Billing'),
('AC.62140003','Billing Exp-Statement Processing Postage ','Billing Exp-Statement Processing Postage ','Billing'),
('AC.62140004','Billing Exp-Statement Processing ','Billing Exp-Statement Processing ','Billing'),
('AC.62140005','Billing Exp-Statement Process-Paper & Envelope ','Billing Exp-Statement Process-Paper & Envelope ','Billing'),
('AC.62140006','Billing Exp-Enhanced Services ','Billing Exp-Enhanced Services ','Billing'),
('AC.62140007','Billing Exp-Fin Srvc-Payment Gateway Crdt Trans ','Billing Exp-Fin Srvc-Payment Gateway Crdt Trans ','Billing'),
('AC.62140008','Billing Exp-License&Maint-3rd Party Comm Sftwr ','Billing Exp-License&Maint-3rd Party Comm Sftwr ','Billing'),
('AC.62140009','Billing Exp-License Fees ','Billing Exp-License Fees ','Billing'),
('AC.62140010','Billing Exp-M&O Fees ','Billing Exp-M&O Fees ','Billing'),
('AC.62140011','Billing Exp-Non-CSG/ICOMS & GL Adjustments ','Billing Exp-Non-CSG/ICOMS & GL Adjustments ','Billing'),
('AC.62140012','Billing Exp-Non-Subscriber Services ','Billing Exp-Non-Subscriber Services ','Billing'),
('AC.62140013','Billing Exp-Optional Services ','Billing Exp-Optional Services ','Billing'),
('AC.62140014','Billing Exp-Other Billing Services ','Billing Exp-Other Billing Services ','Billing'),
('AC.62140015','Billing Exp-Other Exp-Financial Services ','Billing Exp-Other Exp-Financial Services ','Billing'),
('AC.62140016','Billing Exp-Other Exp-Sales Tax Payable ','Billing Exp-Other Exp-Sales Tax Payable ','Billing'),
('AC.62140017','Billing Exp-Platform Fees ','Billing Exp-Platform Fees ','Billing'),
('AC.62140018','Billing Exp-Prof Srvc-Consult Hours & Projects ','Billing Exp-Prof Srvc-Consult Hours & Projects ','Billing'),
('AC.62140019','Billing Exp-Vantage-ESP Message Link Processing ','Billing Exp-Vantage-ESP Message Link Processing ','Billing'),
('AC.62150006','Collection Expense-Pre Write-Off ','Collection Expense-Pre Write-Off ','Collection'),
('AC.62150003','Collection Expense-3rd Party Fee Recovery ','Collection Expense-3rd Party Fee Recovery ','Collection'),
('AC.62150004','Collection Expense-Equipment Recovery ','Collection Expense-Equipment Recovery ','Collection'),
('AC.62150000','Collection Expense-Contractors ','Collection Expense-Contractors ','Collection'),
('AC.62150007','Collection Expense-Other ','Collection Expense-Other ','Collection'),
('AC.62150002','Collection Expense-Live Outbound Call ','Collection Expense-Live Outbound Call ','Collection'),
('AC.62150005','Collection Expense-Onboarding ','Collection Expense-Onboarding ','Collection'),
('AC.62150001','Collection Expense-Past Due Notices ','Collection Expense-Past Due Notices ','Collection'),
('AC.64030002','CPE Maintenance Expense-Other ','CPE Maintenance Expense-Other ','CPE Maintenance'),
('AC.64030000','CPE Maintenance Expense ','CPE Maintenance Expense ','CPE Maintenance'),
('AC.64030001','CPE Maintenance Expense-Test Station ','CPE Maintenance Expense-Test Station ','CPE Maintenance'),
('AC.61550000','Capital Adjustment ','Capital Adjustment ','Network Plant Maintenance'),
('AC.64010000','Plant Line Gear Repair ','Plant Line Gear Repair ','Network Plant Maintenance'),
('AC.64019997','Freight Tax and Other Adj ','Freight Tax and Other Adj ','Network Plant Maintenance'),
('AC.64010001','Plant Maintenance-Underground ','Plant Maintenance-Underground ','Network Plant Maintenance'),
('AC.64010002','Plant Power Supply Repair ','Plant Power Supply Repair ','Network Plant Maintenance'),
('AC.64010003','Plant Test Equipment Calibration and Repair ','Plant Test Equipment Calibration and Repair ','Network Plant Maintenance'),
('AC.64010004','Plant Fiber Optic Equipment Repair ','Plant Fiber Optic Equipment Repair ','Network Plant Maintenance'),
('AC.64010005','Materials Issued Inv System ','Materials Issued Inv System ','Network Plant Maintenance'),
('AC.64010006','Materials Issued Other ','Materials Issued Other ','Network Plant Maintenance'),
('AC.64010007','Plant Maintenance-Ladder Inspection ','Plant Maintenance-Ladder Inspection ','Network Plant Maintenance'),
('AC.64010008','Home Security-Battery Replacements ','Home Security-Battery Replacements ','Network Plant Maintenance'),
('AC.64010009','Plant System Maintenance-Permits ','Plant System Maintenance-Permits ','Network Plant Maintenance'),
('AC.64010010','Plant Maintenance-Pre-Construction ','Plant Maintenance-Pre-Construction ','Network Plant Maintenance'),
('AC.64010011','Plant Maintenance-SMB Pre-Construction ','Plant Maintenance-SMB Pre-Construction ','Network Plant Maintenance'),
('AC.64010012','Plant MDU Maintenance-Material ','Plant MDU Maintenance-Material ','Network Plant Maintenance'),
('AC.64010013','Plant Repair and Maintenance Production Tax Exempt ','Plant Repair and Maintenance Production Tax Exempt ','Network Plant Maintenance'),
('AC.64010014','Plant MDU Maintenance-Labor ','Plant MDU Maintenance-Labor ','Network Plant Maintenance'),
('AC.64019998','Repairs-Other ','Repairs-Other ','Network Plant Maintenance'),
('AC.64040000','Enterprise Network Maintenance-Video ','Enterprise Network Maintenance-Video ','Network Plant Maintenance'),
('AC.64040001','Enterprise Network Maintenance-Core and Backbone ','Enterprise Network Maintenance-Core and Backbone ','Network Plant Maintenance'),
('AC.64040002','Enterprise Network Maintenance-Telephony ','Enterprise Network Maintenance-Telephony ','Network Plant Maintenance'),
('AC.64040003','Enterprise Network Maintenance-Appl Platform Op ','Enterprise Network Maintenance-Appl Platform Op ','Network Plant Maintenance'),
('AC.64040004','Enterprise Network Maintenance-Spectrum Guide ','Enterprise Network Maintenance-Spectrum Guide ','Network Plant Maintenance'),
('AC.64020000','Headend Maintenance-HVAC Emergency ','Headend Maintenance-HVAC Emergency ','Network Plant Maintenance'),
('AC.64020019','Headend Maintenance-Equipment Re-Installation ','Headend Maintenance-Equipment Re-Installation ','Network Plant Maintenance'),
('AC.64020020','Headend Maintenance-Fire Non-NRC Repairs ','Headend Maintenance-Fire Non-NRC Repairs ','Network Plant Maintenance'),
('AC.64020021','Headend Maintenance-Generator Non-NRC Repairs ','Headend Maintenance-Generator Non-NRC Repairs ','Network Plant Maintenance'),
('AC.64020022','Headend Maintenance-DC/UPS Non-NRC Repairs ','Headend Maintenance-DC/UPS Non-NRC Repairs ','Network Plant Maintenance'),
('AC.64020023','Headend Maintenance-HVAC Non-NRC Repairs ','Headend Maintenance-HVAC Non-NRC Repairs ','Network Plant Maintenance'),
('AC.64020001','Headend Maintenance-HVAC Preventative ','Headend Maintenance-HVAC Preventative ','Network Plant Maintenance'),
('AC.64020002','Headend Maintenance-Generator Emergency ','Headend Maintenance-Generator Emergency ','Network Plant Maintenance'),
('AC.64020003','Headend Maintenance-Generator Preventative ','Headend Maintenance-Generator Preventative ','Network Plant Maintenance'),
('AC.64020004','Headend Maintenance-DC/UPS Preventative ','Headend Maintenance-DC/UPS Preventative ','Network Plant Maintenance'),
('AC.64020005','Headend Maintenance-DC/UPS Emergency ','Headend Maintenance-DC/UPS Emergency ','Network Plant Maintenance'),
('AC.64020006','Headend Maintenance-Fire Preventive ','Headend Maintenance-Fire Preventive ','Network Plant Maintenance'),
('AC.64020007','Headend Maintenance-Fire Emergency ','Headend Maintenance-Fire Emergency ','Network Plant Maintenance'),
('AC.64020008','Headend Maintenance-Equipment Repair ','Headend Maintenance-Equipment Repair ','Network Plant Maintenance'),
('AC.64020009','Headend System Maintenance-Box/Headend ','Headend System Maintenance-Box/Headend ','Network Plant Maintenance'),
('AC.64020010','Headend Maintenance-Tower ','Headend Maintenance-Tower ','Network Plant Maintenance'),
('AC.64020011','Headend Maintenance-Generator Fuel ','Headend Maintenance-Generator Fuel ','Network Plant Maintenance'),
('AC.64020012','Headend Maintenance-Security System ','Headend Maintenance-Security System ','Network Plant Maintenance'),
('AC.64020013','Headend System Maintenance-Outside ','Headend System Maintenance-Outside ','Network Plant Maintenance'),
('AC.64020014','Headend Maintenance-Other HE repair ','Headend Maintenance-Other HE repair ','Network Plant Maintenance'),
('AC.64020015','Headend Maintenance-Fire Corrective ','Headend Maintenance-Fire Corrective ','Network Plant Maintenance'),
('AC.64020016','Headend Maintenance-Generator Corrective ','Headend Maintenance-Generator Corrective ','Network Plant Maintenance'),
('AC.64020017','Headend Maintenance-DC/UPS Corrective ','Headend Maintenance-DC/UPS Corrective ','Network Plant Maintenance'),
('AC.64020018','Headend Maintenance-HVAC Corrective ','Headend Maintenance-HVAC Corrective ','Network Plant Maintenance'),
('AC.64010015','System Maintenance-Other Network Repair ','System Maintenance-Other Network Repair ','Network Plant Maintenance'),
('AC.64010016','Plant Maintenance-Pole Transfer ','Plant Maintenance-Pole Transfer ','Network Plant Maintenance'),
('AC.64010017','Plant Maintenance-Emergency Call Out ','Plant Maintenance-Emergency Call Out ','Network Plant Maintenance'),
('AC.64010018','Plant Maintenance-Police Detail ','Plant Maintenance-Police Detail ','Network Plant Maintenance'),
('AC.64010019','Plant Maintenance-Inspection & Audit ','Plant Maintenance-Inspection & Audit ','Network Plant Maintenance'),
('AC.64010020','Plant Maintenance-Cancelled Project ','Plant Maintenance-Cancelled Project ','Network Plant Maintenance'),
('AC.64010021','Plant Maintenance-Backup Power ','Plant Maintenance-Backup Power ','Network Plant Maintenance'),
('AC.64010022','Plant Maintenance-Pole Database ','Plant Maintenance-Pole Database ','Network Plant Maintenance'),
('AC.64010023','Third Party Make Ready Reimburseable Expense ','Third Party Make Ready Reimburseable Expense ','Network Plant Maintenance'),
('AC.64010024','Third Party Make Ready Reimbursements ','Third Party Make Ready Reimbursements ','Network Plant Maintenance'),
('AC.64019999','Project Accrual ','Project Accrual ','Network Plant Maintenance'),
('AC.64050000','Pole Rental ','Pole Rental ','Pole Rent'),
('AC.64050001','Pole Rental-Audit ','Pole Rental-Audit ','Pole Rent'),
('AC.64050003','Pole Rental-Non-Recurring ','Pole Rental-Non-Recurring ','Pole Rent'),
('AC.64050002','Pole Rental-Railroad Crossing ','Pole Rental-Railroad Crossing ','Pole Rent'),
('AC.64060000','Power for Amps ','Power for Amps ','Pole Rent'),
('AC.64070000','Headend Electricity ','Headend Electricity ','Network Utilities'),
('AC.64080003','Gasoline Expense-Aviation ','Gasoline Expense-Aviation ','Vehicle & Gas Repair'),
('AC.64080000','Gasoline Expense-Vehicle ','Gasoline Expense-Vehicle ','Vehicle & Gas Repair'),
('AC.64080001','Gasoline Expense-Rebates ','Gasoline Expense-Rebates ','Vehicle & Gas Repair'),
('AC.64080002','Gasoline Expense-Accrual ','Gasoline Expense-Accrual ','Vehicle & Gas Repair'),
('AC.64090007','Aviation-Maintenance ','Aviation-Maintenance ','Vehicle & Gas Repair'),
('AC.64090008','Aviation-Engine Repair ','Aviation-Engine Repair ','Vehicle & Gas Repair'),
('AC.64090000','Vehicle Expense-Maintenance ','Vehicle Expense-Maintenance ','Vehicle & Gas Repair'),
('AC.64090001','Vehicle Expense-GPS Fees ','Vehicle Expense-GPS Fees ','Vehicle & Gas Repair'),
('AC.64090002','Vehicle Expense-Registration ','Vehicle Expense-Registration ','Vehicle & Gas Repair'),
('AC.64090003','Vehicle Expense-Tolls ','Vehicle Expense-Tolls ','Vehicle & Gas Repair'),
('AC.64090004','Vehicle Expense-Parking Citations ','Vehicle Expense-Parking Citations ','Vehicle & Gas Repair'),
('AC.64090005','Vehicle Expense-Parking ','Vehicle Expense-Parking ','Vehicle & Gas Repair'),
('AC.64090006','Vehicle Expense-Other ','Vehicle Expense-Other ','Vehicle & Gas Repair'),
('AC.64130000','Office Rent-General ','Office Rent-General ','Rent'),
('AC.64130007','Office Rent-Tenant Improvement Cost Amortization ','Office Rent-Tenant Improvement Cost Amortization ','Rent'),
('AC.64130009','Office Rent-S/L Lease Expense ','Office Rent-S/L Lease Expense ','Rent'),
('AC.64130010','Office Rent-LA Cash Rent Offset Adjustment ','Office Rent-LA Cash Rent Offset Adjustment ','Rent'),
('AC.64130001','Office Rent-Common Area Maintenance & Operating ','Office Rent-Common Area Maintenance & Operating ','Rent'),
('AC.64130002','Office Rent-Taxes ','Office Rent-Taxes ','Rent'),
('AC.64130003','Office Rent-Insurance ','Office Rent-Insurance ','Rent'),
('AC.64130004','Office Rent-Parking ','Office Rent-Parking ','Rent'),
('AC.64130005','Office Rent-Management Fee ','Office Rent-Management Fee ','Rent'),
('AC.64130006','Office Rent-Utilities ','Office Rent-Utilities ','Rent'),
('AC.64130008','Office Rent-Other ','Office Rent-Other ','Rent'),
('AC.64180001','Rent-Colocation Costs ','Rent-Colocation Costs ','Rent'),
('AC.64180002','Circuit Monthly Reoccurring Costs ','Circuit Monthly Reoccurring Costs ','Rent'),
('AC.64150000','Unreturned Converters ','Unreturned Converters ','Rent'),
('AC.64160000','Inventory Adjustments ','Inventory Adjustments ','Rent'),
('AC.64170000','Physical Inventory Adjustments ','Physical Inventory Adjustments ','Rent'),
('AC.64140000','Warehouse Rent-General ','Warehouse Rent-General ','Rent'),
('AC.64140008','Warehouse Rent-Tenant Allowance ','Warehouse Rent-Tenant Allowance ','Rent'),
('AC.64140009','Warehouse Rent-S/L Lease Expense ','Warehouse Rent-S/L Lease Expense ','Rent'),
('AC.64140010','Warehouse Rent-LA Cash Rent Offset Adjustment ','Warehouse Rent-LA Cash Rent Offset Adjustment ','Rent'),
('AC.64140001','Warehouse Rent-Common Area Maintenance&Operating ','Warehouse Rent-Common Area Maintenance&Operating ','Rent'),
('AC.64140002','Warehouse Rent-Taxes ','Warehouse Rent-Taxes ','Rent'),
('AC.64140003','Warehouse Rent-Insurance ','Warehouse Rent-Insurance ','Rent'),
('AC.64140004','Warehouse Rent-Parking ','Warehouse Rent-Parking ','Rent'),
('AC.64140005','Warehouse Rent-Management Fee ','Warehouse Rent-Management Fee ','Rent'),
('AC.64140006','Warehouse Rent-Utilities ','Warehouse Rent-Utilities ','Rent'),
('AC.64140007','Warehouse Rent-Other ','Warehouse Rent-Other ','Rent'),
('AC.64190000','3rd Party Warehousing Costs-Rent ','3rd Party Warehousing Costs-Rent ','Rent'),
('AC.64190001','3rd Party Warehousing Costs-Contract Labor ','3rd Party Warehousing Costs-Contract Labor ','Rent'),
('AC.64190002','3rd Party Warehousing Costs-Travel ','3rd Party Warehousing Costs-Travel ','Rent'),
('AC.63700000','Aviation-Hanger Rent ','Aviation-Hanger Rent ','Rent'),
('AC.63700001','Aviation-Hanger Rent S/L Lease Expense ','Aviation-Hanger Rent S/L Lease Expense ','Rent'),
('AC.63700002','Aviation-Hanger Rent LA Cash Rent Offset Adj ','Aviation-Hanger Rent LA Cash Rent Offset Adj ','Rent'),
('AC.63750001','Aviation-LA Cash Rent Offset Adjustment ','Aviation-LA Cash Rent Offset Adjustment ','Rent'),
('AC.63750002','Aviation-Lease Exp ','Aviation-Lease Exp ','Rent'),
('AC.63750000','Aviation-S/L Lease Expense ','Aviation-S/L Lease Expense ','Rent'),
('AC.62070000','Utilities-Electric ','Utilities-Electric ','Utilities'),
('AC.62070001','Utilities-Trash ','Utilities-Trash ','Utilities'),
('AC.62070002','Utilities-Water ','Utilities-Water ','Utilities'),
('AC.62070003','Utilities-Gas ','Utilities-Gas ','Utilities'),
('AC.62070004','Utilities-Other ','Utilities-Other ','Utilities'),
('AC.62350000','Telephone Landline-Usage ','Telephone Landline-Usage ','Telephone'),
('AC.62350001','Telephone Landline-Conference Calling ','Telephone Landline-Conference Calling ','Telephone'),
('AC.62350002','Telephone Landline-Voice Circuits ','Telephone Landline-Voice Circuits ','Telephone'),
('AC.62350003','Telephone Landline-Monthly Reoccurring Charges ','Telephone Landline-Monthly Reoccurring Charges ','Telephone'),
('AC.62350004','Telephone Landline-Tax ','Telephone Landline-Tax ','Telephone'),
('AC.62350005','Telephone Landline-Automated System ','Telephone Landline-Automated System ','Telephone'),
('AC.62350006','Telephone Landline-Maintenance ','Telephone Landline-Maintenance ','Telephone'),
('AC.62350007','Telephone Landline-Hardware ','Telephone Landline-Hardware ','Telephone'),
('AC.62352000','Telephone-Other ','Telephone-Other ','Telephone'),
('AC.62351000','Wireless-Voice Access ','Wireless-Voice Access ','Telephone'),
('AC.62351001','Wireless-Voice Usage ','Wireless-Voice Usage ','Telephone'),
('AC.62351002','Wireless-Access Fees ','Wireless-Access Fees ','Telephone'),
('AC.62351003','Wireless-Data Usage ','Wireless-Data Usage ','Telephone'),
('AC.62351004','Wireless-Text Usage ','Wireless-Text Usage ','Telephone'),
('AC.62351005','Wireless-Reimbursement ','Wireless-Reimbursement ','Telephone'),
('AC.62351006','Wireless-T&E Cellular Reimbursement ','Wireless-T&E Cellular Reimbursement ','Telephone'),
('AC.62351007','Wireless-Pagers ','Wireless-Pagers ','Telephone'),
('AC.62351008','Wireless-Misc Charges ','Wireless-Misc Charges ','Telephone'),
('AC.62351009','Wireless-Rebates ','Wireless-Rebates ','Telephone'),
('AC.62340000','Self Installation-Freight ','Self Installation-Freight ','Self Installation'),
('AC.62340001','Self Installation-Printing ','Self Installation-Printing ','Self Installation'),
('AC.62520001','Surety Insurance ','Surety Insurance ','Property Tax & Insurance'),
('AC.62520000','Property & Casualty Insurance ','Property & Casualty Insurance ','Property Tax & Insurance'),
('AC.62530000','Self Insurance-Customer Property ','Self Insurance-Customer Property ','Property Tax & Insurance'),
('AC.62530001','Self Insurance-Fleet ','Self Insurance-Fleet ','Property Tax & Insurance'),
('AC.62500000','Property Tax Expense ','Property Tax Expense ','Property Tax & Insurance'),
('AC.62500001','Property Tax-Commercial Rent Tax ','Property Tax-Commercial Rent Tax ','Property Tax & Insurance'),
('AC.62500002','Property Tax-Other Taxes and Licenses ','Property Tax-Other Taxes and Licenses ','Property Tax & Insurance'),
('AC.62500003','Local Real Estate Tax Expense ','Local Real Estate Tax Expense ','Property Tax & Insurance'),
('AC.62160100','Bad Debt-Change in Allowance Telephony ','Bad Debt-Change in Allowance Telephony ','Bad Debt'),
('AC.62160000','Bad Debt-Change in Allowance ','Bad Debt-Change in Allowance ','Bad Debt'),
('AC.62160007','Bad Debt-Tax Credit Adjustments ','Bad Debt-Tax Credit Adjustments ','Bad Debt'),
('AC.62160008','Bad Debt-Bankruptcy Write-offs ','Bad Debt-Bankruptcy Write-offs ','Bad Debt'),
('AC.62160106','Bad Debt-Disconnect Service Write Offs Telephony ','Bad Debt-Disconnect Service Write Offs Telephony ','Bad Debt'),
('AC.62160006','Bad Debt-Disconnect Service Write Offs ','Bad Debt-Disconnect Service Write Offs ','Bad Debt'),
('AC.62160009','Bad Debt-Account Disconnect Equipment Write Offs ','Bad Debt-Account Disconnect Equipment Write Offs ','Bad Debt'),
('AC.62160010','Bad Debt-Apple TV Account Disconnect Write Offs ','Bad Debt-Apple TV Account Disconnect Write Offs ','Bad Debt'),
('AC.62160005','Bad Debt-Write Offs ','Bad Debt-Write Offs ','Bad Debt'),
('AC.62160102','Bad Debt-Recoveries Telephony ','Bad Debt-Recoveries Telephony ','Bad Debt'),
('AC.62160003','Bad Debt-Amnesty Adjustments ','Bad Debt-Amnesty Adjustments ','Bad Debt'),
('AC.62160004','Bad Debt-Bankruptcy Recoveries ','Bad Debt-Bankruptcy Recoveries ','Bad Debt'),
('AC.62160002','Bad Debt-Recoveries ','Bad Debt-Recoveries ','Bad Debt'),
('AC.62160111','Bad Debt-NSF Checks A/R Imbalance Telephony ','Bad Debt-NSF Checks A/R Imbalance Telephony ','Bad Debt'),
('AC.62160112','Bad Debt-Refunds A/R Imbalance Telephony ','Bad Debt-Refunds A/R Imbalance Telephony ','Bad Debt'),
('AC.62160113','Bad Debt-Other ADJs Telephony ','Bad Debt-Other ADJs Telephony ','Bad Debt'),
('AC.62160019','Bad Debt-Fraud Equip Adjustments ','Bad Debt-Fraud Equip Adjustments ','Bad Debt'),
('AC.62160001','Bad Debt-Fraud Service Adjustments ','Bad Debt-Fraud Service Adjustments ','Bad Debt'),
('AC.62160015','Bad Debt-Payment Corrections ','Bad Debt-Payment Corrections ','Bad Debt'),
('AC.62160016','Bad Debt-Payment Batch Imbalances ','Bad Debt-Payment Batch Imbalances ','Bad Debt'),
('AC.62160014','Bad Debt-Unreturned Equipment Imbalances ','Bad Debt-Unreturned Equipment Imbalances ','Bad Debt'),
('AC.62160017','Bad Debt-A/R and Bank Reconciliation Adjustments ','Bad Debt-A/R and Bank Reconciliation Adjustments ','Bad Debt'),
('AC.62160013','Bad Debt-Other ADJs ','Bad Debt-Other ADJs ','Bad Debt'),
('AC.62160018','Bad Debt-CABS ','Bad Debt-CABS ','Bad Debt'),
('AC.62160012','Bad Debt-Refunds A/R Imbalance ','Bad Debt-Refunds A/R Imbalance ','Bad Debt'),
('AC.62160011','Bad Debt-NSF Checks A/R Imbalance ','Bad Debt-NSF Checks A/R Imbalance ','Bad Debt'),
('AC.65020000','Bank Charges-Credit Card ','Bank Charges-Credit Card ','Bank & Card Fees'),
('AC.65020001','Bank Charges-Debit Card ','Bank Charges-Debit Card ','Bank & Card Fees'),
('AC.65020002','Bank Charges-Depository ','Bank Charges-Depository ','Bank & Card Fees'),
('AC.65020003','Bank Charges-Lockbox ','Bank Charges-Lockbox ','Bank & Card Fees'),
('AC.65020004','Bank Charges-Other ','Bank Charges-Other ','Bank & Card Fees'),
('AC.65020005','Bank Charges-Prepaid Card Revenue Share ','Bank Charges-Prepaid Card Revenue Share ','Bank & Card Fees'),
('AC.69100001','Intercompany Allocations-In ','Intercompany Allocations-In ','Intercompany Allocations'),
('AC.69100002','Intercompany Allocations-Out ','Intercompany Allocations-Out ','Intercompany Allocations'),
('AC.62420011','Advanced Advertising Fees-Repped ','Advanced Advertising Fees-Repped ','Spectrum Reach External COS Fees'),
('AC.62420013','Advanced Advertising-Synacor ','Advanced Advertising-Synacor ','Spectrum Reach External COS Fees'),
('AC.62420005','Advanced Advertising Fees ','Advanced Advertising Fees ','Spectrum Reach External COS Fees'),
('AC.62420006','Advanced Advertising Fees-Dot.Net Media','Advanced Advertising Fees-Dot.Net Media','Spectrum Reach External COS Fees'),
('AC.62420007','Advanced Advertising Fees-Data Expense ','Advanced Advertising Fees-Data Expense ','Spectrum Reach External COS Fees'),
('AC.62420008','Viacom Spot Inventory Cost ','Viacom Spot Inventory Cost ','Spectrum Reach External COS Fees'),
('AC.62420014','Repped Fees - Other ','Repped Fees - Other ','Spectrum Reach External COS Fees'),
('AC.62420004','National Other/Local Fees ','National Other/Local Fees ','Spectrum Reach External COS Fees'),
('AC.62420002','Ampersand Fees ','Ampersand Fees ','Spectrum Reach External COS Fees'),
('AC.62420003','Ampersand Fee Rebate ','Ampersand Fee Rebate ','Spectrum Reach External COS Fees'),
('AC.62420000','Ad Sales Repped Party Expense ','Ad Sales Repped Party Expense ','Spectrum Reach External COS Fees'),
('AC.62420001','Ad Sales Repped Party Expense-Guarantee ','Ad Sales Repped Party Expense-Guarantee ','Spectrum Reach External COS Fees'),
('AC.62420009','Programming Linear Addressable ','Programming Linear Addressable ','Spectrum Reach External COS Fees'),
('AC.62420010','Linear Addressable ','Linear Addressable ','Spectrum Reach External COS Fees'),
('AC.62420012','Linear Fees ','Linear Fees ','Spectrum Reach External COS Fees'),
('AC.62180002','Contributions-Charitable ','Contributions','Other Operating Expenses'),
('AC.62180003','Contributions-Charitable Diverse ','Contributions','Other Operating Expenses'),
('AC.62180000','Contributions-Political ','Contributions','Other Operating Expenses'),
('AC.62210000','Employee Relations ','Employee Relations','Other Operating Expenses'),
('AC.62210001','Employee Relations-Charter Gold Awards ','Employee Relations','Other Operating Expenses'),
('AC.64100000','Uniform Expense ','Employee Relations','Other Operating Expenses'),
('AC.68400000','Mobile ROE Fees ','Employee Relations','Other Operating Expenses'),
('AC.63360000','Internet Connectivity-IP Circuit MRC ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360001','Internet Connectivity-IP Taxes & Surcharges ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360007','Internet Connectivity-Indirect Colo Lease fees ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360008','Internet Connectivity-Indirect Colo Lease Rent Exp ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360009','Internet Connectivity-Indirect Colo LA Cash ADJ ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360002','Internet Connectivity-IP Fiber Lease Fees ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360003','Internet Connectivity-Non Direct Transit Usage ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360004','Internet Connectivity-IP Local Access/Misc Chrgs ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360005','Internet Connectivity-IP Fiber Lease Rental Exp ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.63360006','Internet Connectivity-IP Fiber Lease LA Cash ADJ ','Internet Connectivity - Indirect','Other Operating Expenses'),
('AC.68150000','Ohio Commercial Activity Tax Expense ','State Taxes','Other Operating Expenses'),
('AC.68150001','State Franchise BS Taxes-Current Year ','State Taxes','Other Operating Expenses'),
('AC.68150002','State Other Tax Expenses ','State Taxes','Other Operating Expenses'),
('AC.68150003','ASC 450 FAS 5 Reserve','State Taxes','Other Operating Expenses'),
('AC.68150004','State NY PSC and Other Tax Expenses ','State Taxes','Other Operating Expenses'),
('AC.68100004','Other Operating Expense-NPI ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68100005','Personal Protective Equipment ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68350002','Indirect Production Costs-Support ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68240000','Corp Registration Fees & License ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68240001','Business License Expense ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68010000','Fines & Penalties ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68010001','Fines & Penalties-Property Tax ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68070000','Armor Car Fees ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68070001','Payment Box Fees ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68100000','Other Operating Expense ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68100001','Other Operating Expense-Diverse ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68100002','Sales Tax Discount ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68100003','Other Operating Expense-Aid to Construction Ref ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68110001','Reconnect Materials ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68180000','Convention Expense ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68180001','Convention Expense-Diverse ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68190000','System Audit Fees ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68200000','Public Relations ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68320000','Indirect Talent Expense ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68350000','Indirect Production Hair & Makeup ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68350001','Indirect Production Costs ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68510000','Studio Set & Props ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68520000','Program Materials & Supplies ','All Other Operating Expenses','Other Operating Expenses'),
('AC.68620000','Equipment Repair ','All Other Operating Expenses','Other Operating Expenses'),
('AC.61500029','Capitalized Internal Labor-High Split Manual ','Capitalized Labor','Capitalized Labor'),
('AC.61500200','High Split Material Overhead Capitalization ','Capitalized Labor','Capitalized Labor'),
('AC.61500203','Cap Labor-High Split Install Overhead ','Capitalized Labor','Capitalized Labor'),
('AC.61500204','Capitalized Internal Labor-High Split T&E ','Capitalized Labor','Capitalized Labor'),
('AC.61500210','Capitalized Labor-High Split CPE Install ','Capitalized Labor','Capitalized Labor'),
('AC.61500222','Cap Labor-High Split Common Time Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61540209','High Split Home Shipment Capitalization ','Capitalized Labor','Capitalized Labor'),
('AC.61500001','Capitalized Internal Labor-Construction Auto ','Capitalized Labor','Capitalized Labor'),
('AC.61500002','Capitalized Internal Labor-Construction Manual ','Capitalized Labor','Capitalized Labor'),
('AC.61540013','Contractor Cap-Resi Drop Bury Locates ','Capitalized Labor','Capitalized Labor'),
('AC.61540003','Contractor Capitalization-Resi Drop Bury ','Capitalized Labor','Capitalized Labor'),
('AC.61500007','Capitalized Internal Labor-Site Survey ','Capitalized Labor','Capitalized Labor'),
('AC.61540105','Contractor Capitalization-SMB Site Survey ','Capitalized Labor','Capitalized Labor'),
('AC.61500006','Capitalized Internal Labor-Manual Installation ','Capitalized Labor','Capitalized Labor'),
('AC.61540006','Contractor Capitalization-Resi Trouble Call ','Capitalized Labor','Capitalized Labor'),
('AC.61540106','Contractor Capitalization-SMB Trouble Call ','Capitalized Labor','Capitalized Labor'),
('AC.61540001','Contractor Capitalization-Resi Chargeback ','Capitalized Labor','Capitalized Labor'),
('AC.61500009','Residential Contractor Labor - Install Data ','Capitalized Labor','Capitalized Labor'),
('AC.61500107','SMB Contractor Labor - Install Data ','Capitalized Labor','Capitalized Labor'),
('AC.61500008','Residential Internal Labor - Install Data ','Capitalized Labor','Capitalized Labor'),
('AC.61500106','SMB Internal Labor - Install Data ','Capitalized Labor','Capitalized Labor'),
('AC.61500011','Residential Contractor Labor - Install Video ','Capitalized Labor','Capitalized Labor'),
('AC.61500109','SMB Contractor Labor - Install Video ','Capitalized Labor','Capitalized Labor'),
('AC.61500010','Residential Internal Labor - Install Video ','Capitalized Labor','Capitalized Labor'),
('AC.61500108','SMB Internal Labor - Install Video ','Capitalized Labor','Capitalized Labor'),
('AC.61500003','Capitalized Internal Labor-CPE Install Overhead ','Capitalized Labor','Capitalized Labor'),
('AC.61500004','Capitalized Internal Labor-Resi CPE Installation ','Capitalized Labor','Capitalized Labor'),
('AC.61500104','Capitalized Internal Labor-SMB CPE Installation ','Capitalized Labor','Capitalized Labor'),
('AC.61540002','Contractor Capitalization-Resi CPE Install ','Capitalized Labor','Capitalized Labor'),
('AC.61540102','Contractor Capitalization-SMB CPE Install ','Capitalized Labor','Capitalized Labor'),
('AC.61520027','Residential Contractor Labor - Non Standard Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61520127','SMB Contractor Labor - Non Standard Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500027','Residential Internal Labor -Non Standard Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500127','SMB Internal Labor - Non Standard Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500021','Residential Contractor Labor - New Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500119','SMB Contractor Labor - New Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500020','Residential Internal Labor - New Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500118','SMB Internal Labor - New Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500013','Residential Contractor Labor - Outlets ','Capitalized Labor','Capitalized Labor'),
('AC.61500111','SMB Contractor Labor - Outlets ','Capitalized Labor','Capitalized Labor'),
('AC.61500012','Residential Internal Labor - Outlets ','Capitalized Labor','Capitalized Labor'),
('AC.61500110','SMB Internal Labor - Outlets ','Capitalized Labor','Capitalized Labor'),
('AC.61500025','Residential Contractor Labor - Outlets Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500123','SMB Contractor Labor - Outlets Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500024','Residential Internal Labor - Outlets Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500122','SMB Internal Labor - Outlets Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500015','Residential Contractor Labor - Common Time-Install ','Capitalized Labor','Capitalized Labor'),
('AC.61500113','SMB Contractor Labor - Common Time-Install ','Capitalized Labor','Capitalized Labor'),
('AC.61500014','Residential Internal Labor - Common Time-Install ','Capitalized Labor','Capitalized Labor'),
('AC.61500112','SMB Internal Labor - Common Time-Install ','Capitalized Labor','Capitalized Labor'),
('AC.61500023','Residential Contractor Labor - Common Time-Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500121','SMB Contractor Labor - Common Time-Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500022','Residential Internal Labor - Common Time-Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500120','SMB Internal Labor - Common Time-Rescue ','Capitalized Labor','Capitalized Labor'),
('AC.61500017','Residential Contractor Labor - Replace Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500115','SMB Contractor Labor - Replace Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500016','Residential Internal Labor - Replace Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61500114','SMB Internal Labor - Replace Drop ','Capitalized Labor','Capitalized Labor'),
('AC.61520028','Residential Contractor Labor - DR on Rescues ','Capitalized Labor','Capitalized Labor'),
('AC.61520126','SMB Contractor Labor - DR on Rescues ','Capitalized Labor','Capitalized Labor'),
('AC.61500028','Residential Internal Labor - DR on Rescues ','Capitalized Labor','Capitalized Labor'),
('AC.61500126','SMB Internal Labor - DR on Rescues ','Capitalized Labor','Capitalized Labor'),
('AC.61520026','Residential Contractor Labor - DR on SROs ','Capitalized Labor','Capitalized Labor'),
('AC.61520124','SMB Contractor Labor - DR on SROs ','Capitalized Labor','Capitalized Labor'),
('AC.61500026','Residential Internal Labor - DR on SROs ','Capitalized Labor','Capitalized Labor'),
('AC.61500124','SMB Internal Labor - DR on SROs ','Capitalized Labor','Capitalized Labor'),
('AC.61500117','SMB Contractor Labor - DR on TCs ','Capitalized Labor','Capitalized Labor'),
('AC.61500019','Residential Contractor Labor - DR on TCs ','Capitalized Labor','Capitalized Labor'),
('AC.61500018','Residential Internal Labor - DR on TCs ','Capitalized Labor','Capitalized Labor'),
('AC.61500116','SMB Internal Labor - DR on TCs ','Capitalized Labor','Capitalized Labor'),
('AC.61500005','Capitalized Internal Labor-Resi NonCPE Install ','Capitalized Labor','Capitalized Labor'),
('AC.61500105','Capitalized Internal Labor-SMB Non-CPE Install ','Capitalized Labor','Capitalized Labor'),
('AC.61540004','Contractor Capitalization-Resi Non-CPE Install ','Capitalized Labor','Capitalized Labor'),
('AC.61540104','Contractor Capitalization-SMB Non-CPE Install ','Capitalized Labor','Capitalized Labor'),
('AC.61540007','Freight Capitalization ','Capitalized Labor','Capitalized Labor'),
('AC.61500000','Capitalized Internal Labor ','Capitalized Labor','Capitalized Labor'),
('AC.61540008','Self Install Kit Print and Freight Capitalization ','Capitalized Labor','Capitalized Labor'),
('AC.61540009','Self Install Contract Labor Capitalization ','Capitalized Labor','Capitalized Labor'),
('AC.61540000','Contractor Capitalization-Resi All Digital ','Capitalized Labor','Capitalized Labor'),
('AC.61540100','Contractor Capitalization-SMB All Digital ','Capitalized Labor','Capitalized Labor'),
('AC.56500000','Interactive Guide Fees','Interactive Guide Fees','Direct Expenses'),
('AC.52470001','Video Data Feeds','Video Data Feeds','Direct Expenses'),
('AC.52470002','Video Other','Video Other','Direct Expenses'),
('AC.52470000','VOD Encoding','VOD Encoding','Direct Expenses'),
('AC.52480002','Self-Support Fees','Self-Support Fees','Direct Expenses')
;


INSERT INTO [staging].[opex_department_mapping]
	([Department Code]
	,[Project Name]
	,[Bcode/Investment Position ID]
	,[Bcode/Investment Position Name]
	,[P&T Segmentation]
	,[Platform]
	,[Business Leader])
     VALUES
('779','P&T Business Planning ','P&T Business Planning ','P&T Business Planning ','All Other ProdTech','All Other ProdTech Dept','Maroney,Tucker'),
('782','Video Delivery','Video Delivery','Video Delivery','Video Platforms','Video','Tolva,Robyn'),
('823','Programming Acquisition','Programming Acquisition','Programming Acquisition','All Other ProdTech','All Other ProdTech Dept','Montenagmo,Tom'),
('842','Buyflow Services','Buyflow Services','Buyflow Services','Ordering','Data Platforms','Baldino,Michael'),
('874','Data Technologies Group','Data Technologies Group','Data Technologies Group','Data & Intelligence','Data Platforms','Baldino,Michael'),
('876','Video Technical Enablement','Video Technical Enablement','Video Technical Enablement','Video Platforms','Video','Tolva,Robyn'),
('877','Agent Tools','Agent Tools','Agent Tools','Agent OS','Agency & Lab','Brown,Peter'),
('884','Video Strategy & Operations','Video Strategy & Operations','Video Strategy & Operations','Video Platforms','Video','Tolva,Robyn'),
('892','Video Software','Video Software','Video Software','Video Platforms','Video','Tolva,Robyn'),
('894','Digital Platforms Support','Digital Platforms Support','Digital Platforms Support','Dept Tools and Systems','Data Platforms','Baldino,Michael'),
('503','P&T HR','P&T HR','P&T HR','All Other ProdTech','All Other ProdTech Dept','Flynn,Patrick'),
('504','P&T HR','P&T HR','P&T HR','All Other ProdTech','All Other ProdTech Dept','Flynn,Patrick'),
('505','P&T HR','P&T HR','P&T HR','All Other ProdTech','All Other ProdTech Dept','Flynn,Patrick'),
('705','Mobile SSPP Backend','Mobile SSPP Backend','Mobile SSPP Backend','Customer Self Service','Data Platforms','Baldino,Michael'),
('707','P&T HR','P&T HR','P&T HR','All Other ProdTech','All Other ProdTech Dept','Flynn,Patrick'),
('709','SSPP App & Web','SSPP App & Web','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('711','Agency Enterprise','Agency Enterprise','Agency Enterprise','Systems and Licensing','Agency & Lab','Brown,Peter'),
('712','Agency News & Sports','Agency News & Sports','Agency News & Sports','Systems and Licensing','Agency & Lab','Brown,Peter'),
('713','Agency Agent OS','Agency Agent OS','Agency Agent OS','Systems and Licensing','Agency & Lab','Brown,Peter'),
('714','Tech Tools','Tech Tools','Tech Tools','Systems and Licensing','Data Platforms','Baldino,Michael'),
('784','SSPP App & Web - Legacy App','SSPP App & Web - Legacy App','SSPP App & Web - Legacy App','All Other ProdTech','SSPP','Guiberson,Ken'),
('785','Data Science Experimentation','Data Science Experimentation','Data Science Experimentation','Data & Intelligence','Data Platforms','Baldino,Michael'),
('880','Cross Functional Platforms & Operations','Cross Functional Platforms & Operations','Cross Functional Platforms & Operations','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('881','SSPP Backend Platform','SSPP Backend Platform','SSPP Backend Platform','Customer Self Service','Data Platforms','Baldino,Michael'),
('893','Core Data Platforms','Core Data Platforms','Core Data Platforms','Data & Intelligence','Data Platforms','Baldino,Michael'),
('965','P&T Direct Expense','P&T Direct Expense','P&T Direct Expense','Direct Expense','Product Support Direct Costs','Assign by Accounts'),
('980','P&T Business Development','P&T Business Development','P&T Business Development','All Other ProdTech','All Other ProdTech Dept','Hill,Christopher'),
('995','Video Product Management','Video Product Management','Video Product Management','Video Platforms','Video','Tolva,Robyn'),
('996','Digital Platforms Agency','Digital Platforms Agency','Digital Platforms Agency','Dept Tools and Systems','Agency & Lab','Brown,Peter'),
('998','Video Experience','Video Experience','Video Experience','Video Platforms','Video','Tolva,Robyn'),
('999','Digital Platforms Insights','Digital Platforms Insights','Digital Platforms Insights','Data & Intelligence','Data Platforms','Baldino,Michael')
GO
;

INSERT INTO [staging].[company_code]
           ([Company Number]
           ,[Company Code]
           ,[Legal Entity Name]
           ,[Company Type])
VALUES
('110','Charter Com Inc.','Charter Communications, Inc.','Corporate'),
('120','CCH Holding Company LLC','CCH Holding Company, LLC','Holding Company'),
('121','TWC Sports Newco LLC','TWC Sports Newco LLC','Holding Company'),
('122','NaviSite Newco LLC','NaviSite Newco LLC','Holding Company'),
('123','Insight Com Company LLC','Insight Communicaitons Company LLC','Holding Company'),
('124','Insight Blocker LLC','Insight Blocker LLC','Holding Company'),
('125','Coaxial Com-Centrl OH LLC','Coaxial Communicaitons of Central Ohio','Holding Company'),
('130','SpectrumCom Indemnity Inc','Spectrum Communications Indemnity, Inc.','Holding Company'),
('131','SpectrumComIndmntyIncELIM','Spectrum Communications Indemnity, Inc. ELIM','Holding Company'),
('132','Spectrum Captive Hold LLC','Spectrum Captive Holdings, LLC','Holding Company'),
('140','CCH II LLC','CCH II, LLC','Holding Company'),
('150','Charter Com Holdings LLC','CHARTER COMMUNICATIONS HOLDINGS, LLC','Holding Company'),
('160','Spectrum Mngt Hold Co LLC','Spectrum Management Holding Company, LLC','Holding Company'),
('170','CHR Com Holding Co LLC','CHR Com Holding Co LLC','Corporate'),
('171','Spectrum Stamford LLC','Spectrum Stamford LLC','Holding Company'),
('172','400 Atlantic Title LLC','400 Atlantic Title LLC','Holding Company'),
('173','HP Gateway','HP Gateway','Holding Company'),
('174','HP Gateway II','HP Gateway II','Holding Company'),
('180','CCHC LLC','CCHC, LLC','Holding Company'),
('185','CCH I Holdings LLC','CCH I Holdings, LLC','Holding Company'),
('190','CCO Holdings LLC','CCO Holdings, LLC','Holding Company'),
('200','CHARTER Com OPERATING LLC','CHARTER COMMUNICATIONS OPERATING, LLC','Holding Company'),
('201','CCO NR HOLDINGS LLC','CCO NR HOLDINGS, LLC','Holding Company'),
('202','Adlink Cable Advrtsg LLC','Adlink Cable Advertising, LLC','Adverstising'),
('203','America''s Job Exchg LLC','America''s Job Exchange, LLC ','Navisite'),
('204','Bresnan Broadband CO LLC','BRESNAN BROADBAND OF COLORADO, LLC','CLEC'),
('205','Bresnan Broadband MT LLC','BRESNAN BROADBAND OF MONTANA, LLC','CLEC'),
('206','Bresnan Broadband UT LLC','BRESNAN BROADBAND OF UTAH, LLC','CLEC'),
('207','Bresnan Broadband WY LLC','BRESNAN BROADBAND OF WYOMING, LLC','CLEC'),
('208','BHN Informatn Serv AL LLC','Bright House Networks Information Services (Alabama), LLC','CLEC'),
('209','BHN Informatn Serv CA LLC','Bright House Networks Information Services (California), LLC','CLEC'),
('210','BHN Informatn Serv FL LLC','Bright House Networks Information Services (Florida), LLC','CLEC'),
('211','BHN Informatn Serv IN LLC','Bright House Networks Information Services (Indiana), LLC','CLEC'),
('212','BHN Informatn Serv MI LLC','Bright House Networks Information Services (Michigan), LLC','CLEC'),
('213','C&C Wireless Ops LLC','C&C Wireless Operations, LLC','Joint Venture'),
('214','CC Systems LLC','CC SYSTEMS, LLC','Holding Company'),
('215','Charter Distribution LLC','CHARTER DISTRIBUTION, LLC','Inventory'),
('216','CHARTER FIBERLINK-AL LLC','CHARTER FIBERLINK - ALABAMA, LLC','CLEC'),
('217','CHARTER FIBERLINK-GA LLC','CHARTER FIBERLINK - GEORGIA, LLC','CLEC'),
('218','CHARTER FIBERLINK-IL LLC','CHARTER FIBERLINK - ILLINOIS, LLC','CLEC'),
('219','CHARTER FIBERLINK-MI LLC','CHARTER FIBERLINK - MICHIGAN, LLC','CLEC'),
('220','CHARTER FIBERLINK-MO LLC','CHARTER FIBERLINK - MISSOURI, LLC','CLEC'),
('221','CHARTER FIBERLINK-NE LLC','CHARTER FIBERLINK - NEBRASKA, LLC','CLEC'),
('222','CHARTER FIBERLINK-TN LLC','CHARTER FIBERLINK - TENNESSEE, LLC','CLEC'),
('223','CHR FIBERLINK CA-CCO LLC','CHARTER FIBERLINK CA-CCO, LLC','CLEC'),
('224','CHR FIBERLINK CC VIII LLC','CHARTER FIBERLINK CC VIII, LLC','CLEC'),
('225','CHR FIBERLINK CCO LLC','CHARTER FIBERLINK CCO, LLC (fka: CHARTER FIBERLINK, LLC)','CLEC'),
('226','CHR FIBERLINK CT-CCO LLC','CHARTER FIBERLINK CT-CCO, LLC','CLEC'),
('227','CHR FIBERLINK LA-CCO LLC','CHARTER FIBERLINK LA-CCO, LLC','CLEC'),
('228','CHR FIBERLINK MA-CCO LLC','CHARTER FIBERLINK MA-CCO, LLC','CLEC'),
('229','CHR FIBERLINK MS-CCVI LLC','CHARTER FIBERLINK MS-CCVI, LLC','CLEC'),
('230','CHR FIBERLINK NC-CCO LLC','CHARTER FIBERLINK NC-CCO, LLC','CLEC'),
('231','CHR FIBERLINK NH-CCO LLC','CHARTER FIBERLINK NH-CCO, LLC','CLEC'),
('232','CHR FIBERLNK NV-CCVII LLC','CHARTER FIBERLINK NV-CCVII, LLC','CLEC'),
('233','CHR FIBERLINK NY-CCO LLC','CHARTER FIBERLINK NY-CCO, LLC','CLEC'),
('234','CHR FIBERLNK OR-CCVII LLC','CHARTER FIBERLINK OR-CCVII, LLC','CLEC'),
('235','CHR FIBERLINK SC-CCO LLC','CHARTER FIBERLINK SC-CCO, LLC','CLEC'),
('236','CHR FIBERLINK TX-CCO LLC','CHARTER FIBERLINK TX-CCO, LLC','CLEC'),
('237','CHR FIBERLINK VA-CCO LLC','CHARTER FIBERLINK VA-CCO, LLC','CLEC'),
('238','CHR FIBERLINK VT-CCO LLC','CHARTER FIBERLINK VT-CCO, LLC','CLEC'),
('239','CHR FIBERLNK WA-CCVII LLC','CHARTER FIBERLINK WA-CCVII, LLC','CLEC'),
('240','CHR Procrmt Leasing LLC','Charter Procurement Leasing, LLC','CLEC'),
('241','CV of Viera LLP','CV of Viera LLP','Cable Company - JV'),
('242','DukeNet Com LLC','DukeNet Communications, LLC','Commerical'),
('246','NaviSite Europe Limited','NaviSite Europe Limited','Navisite'),
('247','Navi India Private Limitd','NaviSite India Private Limited','Navisite'),
('248','NaviSite LLC','NaviSite LLC','Navisite'),
('249','Spectrum Sunshine St LLC','Spectrum Sunshine State, LLC','Cable Company'),
('250','Spectrum Gulf Coast LLC','Spectrum Gulf Coast, LLC','Cable Company'),
('251','Spectrum Mid-America LLC','Spectrum Mid-America, LLC','Cable Company'),
('252','Spectrum Mobile Equip LLC','Spectrum Mobile Equipment, LLC','Mobile'),
('253','Spectrum Mobile LLC','Spectrum Mobile, LLC','Mobile'),
('254','Spectrum NY Metro LLC','Spectrum NY Metro, LLC','Cable Company'),
('255','Spectrum Northeast LLC','Spectrum Northeast, LLC','Cable Company'),
('256','Spectrum Oceanic LLC','Spectrum Oceanic, LLC','Cable Company'),
('257','Spectrum Originals LLC','Spectrum Originals, LLC','Original Programming'),
('258','Spectrum Pacific West LLC','Spectrum Pacific West, LLC','Cable Company'),
('259','Spectrum Security LLC','Spectrum Security, LLC','Cable Security'),
('260','Spectrum Southeast LLC','Spectrum Southeast, LLC','Cable Company'),
('261','TWC Business LLC','Time Warner Cable Business LLC','Commerical'),
('262','TWC Enterprises LLC','Time Warner Cable Enterprises LLC','Holding Company'),
('263','TWC Informatn Serv AL LLC','Time Warner Cable Information Services (Alabama), LLC','CLEC'),
('264','TWC Informatn Serv AZ LLC','Time Warner Cable Information Services (Arizona), LLC','CLEC'),
('265','TWC Informatn Serv CA LLC','Time Warner Cable Information Services (California), LLC','CLEC'),
('266','TWC Informatn Serv CO LLC','Time Warner Cable Information Services (Colorado), LLC','CLEC'),
('267','TWC Informatn Serv HI LLC','Time Warner Cable Information Services (Hawaii), LLC','CLEC'),
('268','TWC Informatn Serv ID LLC','Time Warner Cable Information Services (Idaho), LLC','CLEC'),
('269','TWC Informatn Serv IN LLC','Time Warner Cable Information Services (Indiana), LLC','CLEC'),
('270','TWC Informatn Serv KS LLC','Time Warner Cable Information Services (Kansas), LLC','CLEC'),
('271','TWC Informatn Serv KY LLC','Time Warner Cable Information Services (Kentucky), LLC','CLEC'),
('272','TWC Informatn Serv ME LLC','Time Warner Cable Information Services (Maine), LLC','CLEC'),
('273','TWC Informatn Serv MA LLC','Time Warner Cable Information Services (Massachusetts), LLC','CLEC'),
('274','TWC Informatn Serv MI LLC','Time Warner Cable Information Services (Michigan), LLC','CLEC'),
('275','TWC Informatn Serv MO LLC','Time Warner Cable Information Services (Missouri), LLC','CLEC'),
('276','TWC Informatn Serv NE LLC','Time Warner Cable Information Services (Nebraska), LLC','CLEC'),
('277','TWC Informatn Serv NH LLC','Time Warner Cable Information Services (New Hampshire), LLC','CLEC'),
('278','TWC Informatn Serv NJ LLC','Time Warner Cable Information Services (New Jersey), LLC','CLEC'),
('279','TWC Informatn Serv NM LLC','Time Warner Cable Information Services (New Mexico), LLC','CLEC'),
('280','TWC Informatn Serv NY LLC','Time Warner Cable Information Services (New York), LLC','CLEC'),
('281','TWC Informatn Serv NC LLC','Time Warner Cable Information Services (North Carolina), LLC','CLEC'),
('282','TWC Informatn Serv OH LLC','Time Warner Cable Information Services (Ohio), LLC','CLEC'),
('283','TWC Informatn Serv PA LLC','Time Warner Cable Information Services (Pennsylvania), LLC','CLEC'),
('284','TWC Informatn Serv SC LLC','Time Warner Cable Information Services (South Carolina), LLC','CLEC'),
('285','TWC Informatn Serv TN LLC','Time Warner Cable Information Services (Tennessee), LLC','CLEC'),
('286','TWC Informatn Serv TX LLC','Time Warner Cable Information Services (Texas), LLC','CLEC'),
('287','TWC Informatn Serv VA LLC','Time Warner Cable Information Services (Virginia), LLC','CLEC'),
('288','TWC Informatn Serv WA LLC','Time Warner Cable Information Services (Washington), LLC','CLEC'),
('289','TWC Informatn Serv WV LLC','Time Warner Cable Information Services (West Virginia), LLC','CLEC'),
('290','TWC Informatn Serv WI LLC','Time Warner Cable Information Services (Wisconsin), LLC','CLEC'),
('291','TWC Internet Hold','Time Warner Cable Internet Holdings LLC','CLEC'),
('292','Spectrum Reach','Spectrum Reach, LLC','Adverstising'),
('293','TWC Administration LLC','TWC Administration LLC','Holding Company'),
('294','TWC Bus Serv Canada ULC','TWC Business Services Canada ULC','Navisite'),
('295','Spectrum TV Essentials','Spectrum TV Essentials, LLC','Holding Company'),
('296','Spectrum Advancd Serv LLC','Spectrum Advanced Services, LLC','VOIP'),
('298','Spectrum NLP LLC','Spectrum NLP, LLC ','News & Sports'),
('299','Spectrum RSN LLC','Spectrum RSN, LLC','News & Sports'),
('300','TWC SEE Holdco LLC','TWC SEE Holdco LLC ','Holding Company'),
('301','TWC Wireless LLC','TWC Wireless LLC','Holding Company'),
('302','TWC/CHR LACable Advtg LLC','TWC/Charter Los Angeles Cable Advertising, LLC','Adverstising'),
('303','TWCIS Holdco LLC','TWCIS Holdco LLC','Holding Company'),
('304','Charter Com LLC','Charter Communicaitons, LLC','Shared Services'),
('305','CCO Elimination','CCO Elimination','Holding Company'),
('306','Spectrum Orig Dvlpmt LLC','Spectrum Originals Development, LLC','Original Programming'),
('307','Time Warner Cable LLC','Time Warner Cable, LLC','Holding Company'),
('308','CHR Advanced Serv LLC-MN','Charter Advanced Serv MN','VOIP'),
('309','CHR Advanced Serv LLC-MO','Charter Advanced Serv MO','VOIP'),
('310','Cujo JV','Cujo JV','Joint Venture')
;


INSERT INTO [staging].[company_entity]
	([Company Code]
	,[Company Name]
	,[Entity Code]
	,[Entity Name]
	,[Combination])
     VALUES
('304','Cable Operations','6500','Product Operations','3046500'),
('304','Cable Operations','5000','Network Ops Support','3045000'),
('170','Corporate Operations','7100','Engineering & Technology','1707100'),
('170','Corporate Operations','7104','Coudersport Data Center','1707104'),
('170','Corporate Operations','7102','National Center East-GreenRidge Dr','1707102'),
('170','Corporate Operations','7101','Annex Data Center-Crescent Exec Dr','1707101'),
('170','Corporate Operations','7103','St Louis Data Center-Charter Commons','1707103')
;


INSERT INTO [staging].[pcode_to_bcode]
	([Project Name ID]
	,[Project Name]
	,[Bcode/Investment Position ID]
	,[Bcode/Investment Position Name]
	,[P&T Segmentation]
	,[Platform]
	,[Business Leader])
     VALUES
('P628468','App Integrated Experiences','B22000512580','App Integrated Experiences','Video Platforms','Video','Tolva,Robyn'),
('P802367','Engagement','B22000512580','App Integrated Experiences','Video Platforms','Video','Tolva,Robyn'),
('P802368','IP STB   Flex 2 0','B22000512580','App Integrated Experiences','Video Platforms','Video','Tolva,Robyn'),
('P802369','Pause Live','B22000512580','App Integrated Experiences','Video Platforms','Video','Tolva,Robyn'),
('P628519','IP Video Delivery','B22000512582','IP Video Delivery','Video Platforms','Video','Tolva,Robyn'),
('P802370','IP Video Delivery   VOD','B22000512582','IP Video Delivery','Video Platforms','Video','Tolva,Robyn'),
('P628560','Traditional Video','B22000512583','Traditional Video','Video Platforms','Video','Tolva,Robyn'),
('P802371','High Split Support','B22000512583','Traditional Video','Video Platforms','Video','Tolva,Robyn'),
('P628542','AHW App   Web Dev','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628543','Billing','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628544','Business Enablement','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628545','Change Service','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628546','Connect Protect','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628547','Data App   Web Dev','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628548','App   Web Design','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628549','Digital Self Service Mobile','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628550','Enroll Activate','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628551','Platform Dev','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628552','SCS App   Web Dev','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628553','Support Messaging','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628554','Tech Enablement','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628555','Troubleshoot','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628556','Voice App   Web Dev','B22000512586','SSPP App & Web','Customer Self Service','SSPP','Guiberson,Ken'),
('P628557','SSPP Backend Platform','B22000512587','SSPP Backend ','Customer Self Service','SSPP','Guiberson,Ken'),
('P628477','Analytics Testing','B22000512588','Data Platforms','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628478','Core Data Ingest','B22000512588','Data Platforms','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628479','Data Science   Experimentation','B22000512588','Data Platforms','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628480','Quantum Analytics','B22000512588','Data Platforms','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628481','Data Plat Transition Budget','B22000512588','Data Platforms','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628484','DP Buyflow Support','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628485','Cap Portal   Identity Enh','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628486','Single Customer Incidents','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628487','Self Install   Tech Mobile Enh','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628488','Self Service Tools Dev','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628489','SSPP Insights Support','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628490','Dig Plat Transition Budget','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628491','Video Support','B22000512589','Digital Platforms Insights','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628475','Identity Authentication Projects','B22000512594','Customer ID','Security Platforms','Cross Platforms','Chiang,Tom'),
('P628476','Identity Countermeasures','B22000512594','Customer ID','Security Platforms','Cross Platforms','Chiang,Tom'),
('P628483','Digital Notifications','B22000512595','Digital Notifications','Customer Self Service','Cross Platforms','Chiang,Tom'),
('P628511','In App Buyflow Platform','B22000512596','In App Buyflow ','Ordering','Cross Platforms','Chiang,Tom'),
('P627948','Spectrum Data Cloud','B22000512708','Spectrum Data Cloud','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P628482','Industrial Design Studio','B22000010646','Design Lab','Labs and Environments','Agency & Lab','Brown,Peter'),
('P705022','Industrial Design Studio','B22000010646','Design Lab','Labs and Environments','Agency & Lab','Brown,Peter'),
('P804482','Video Resiliency','B23000053628','Video Resiliency','Video Platforms','Video','Tolva,Robyn'),
('P804478','Architectural Consolidation','B23000053628','Video Resiliency','Video Platforms','Video','Tolva,Robyn'),
('P804479','Resiliency and Quality','B23000053628','Video Resiliency','Video Platforms','Video','Tolva,Robyn'),
('P804480','Scale  Cloud Optimization and Lantern','B23000053628','Video Resiliency','Video Platforms','Video','Tolva,Robyn'),
('P802356','Enterprise Video','B23000053629','Enterprise Video','Video Platforms','Video','Tolva,Robyn'),
('P802357','Video Advertising','B23000053630','Video Advertising','Video Platforms','Video','Tolva,Robyn'),
('P802358','Tech Mobile Modernization','B23000053631','Tech Mobile Modernization','Corp Systems','Data Platforms','Baldino,Michael'),
('P802359','Buyflow Services','B23000053632','Buyflow Services','Ordering','Data Platforms','Baldino,Michael'),
('P802360','Dig Plat Agency Internal Tools','B23000053633','Tech Standards','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('P802361','Technology Standards   DTE','B23000053633','Tech Standards','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('P802362','Technology Standards   PDE','B23000053633','Tech Standards','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('P802363','Technology Standards   PE','B23000053633','Tech Standards','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('P802364','Technology Standards   S C','B23000053633','Tech Standards','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('P802365','Dig Plat Agency Kite Development','B23000053634','Experience Standards','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('P802366','Experience Standards','B23000053634','Experience Standards','Dept Tools and Systems','Cross Platforms','Chiang,Tom'),
('P831400','High Split Support - CPE Swap','XEMERPRODTECH23','High Split Support','Video Platforms','Video','Tolva,Robyn'),
('P827125','High Split Support - CPE Swap','XEMERPRODTECH23','High Split Support','Video Platforms','Video','Tolva,Robyn'),
('P628697','Ordering Integration Services','B22000512601','2022 Carryover','Ordering','Data Platforms','Baldino,Michael'),
('P628561','Video Licensing','B22000010778','2022 Carryover','Labs and Environments','Video','Tolva,Robyn'),
('P628492','Enabling and Shared Services','B22000512581','2022 Carryover','Video Platforms','Video','Tolva,Robyn'),
('P628464','Advertising','B22000512585','2022 Carryover','Video Platforms','Video','Tolva,Robyn'),
('P628465','Dig Plat Agency Internal Tools','B22000512591','2022 Carryover','Data and Intelligence','Agency & Lab','Brown,Peter'),
('P628470','Dig Plat Agency Kite Development','B22000512592','2022 Carryover','Data and Intelligence','Agency & Lab','Brown,Peter'),
('P628469','Design Enablement','B22000512592','2022 Carryover','Data and Intelligence','Agency & Lab','Brown,Peter'),
('P628474','Aloha Tool Integration','B22000512593','2022 Carryover','Data and Intelligence','Cross Platforms','Chiang,Tom'),
('P628532','SCS Video','B22000512597','2022 Carryover','Ordering','Video','Tolva,Robyn'),
('P628466','Portals Resiliency   Feature Capacity','B22000512598','2022 Carryover','Ordering','Agency & Lab','Brown,Peter'),
('P628467','Spectrum Navigator','B22000512598','2022 Carryover','Ordering','Agency & Lab','Brown,Peter'),
('P700867','Spectrum Navigator','B22000512598','2022 Carryover','Ordering','Agency & Lab','Brown,Peter'),
('P700873','Portals Resiliency   Feature Capacity','B22000512598','2022 Carryover','Ordering','Agency & Lab','Brown,Peter'),
('P628531','Online Ordering','B22000512600','2022 Carryover','Ordering','Data Platforms','Baldino,Michael'),
('P627946','Visible Network','B22000512706','2022 Carryover','Ordering','Data Platforms','Baldino,Michael'),
('P627947','Unified Activation   Provisioning','B22000512707','2022 Carryover','Ordering','Data Platforms','Baldino,Michael'),
('P627950','Legacy Activation   Provisioning','B22000512709','2022 Carryover','Data and Intelligence','Data Platforms','Baldino,Michael'),
('P494894','Video Channel Lineup Dev','2020-2021 Carryover Projects','2020-2021 Carryover Projects','All Other and Carryover - BAU','Cross Platforms','Chiang,Tom'),
('P690452','Tech Mobile Modernization','2020-2021 Carryover Projects','2020-2021 Carryover Projects','All Other and Carryover - BAU','Cross Platforms','Chiang,Tom'),
('P363162','Buyflow Platform Stabilization','2020-2021 Carryover Projects','2020-2021 Carryover Projects','All Other and Carryover - BAU','Cross Platforms','Chiang,Tom'),
('P496775','EST Windtalker','2020-2021 Carryover Projects','2020-2021 Carryover Projects','All Other and Carryover - BAU','Cross Platforms','Chiang,Tom')
;


-- PRODUCTION TABLES


-- ACCOUNT CODE
INSERT INTO [dbo].[account]
           ([account_code]
		   ,[account_name]
		   ,[pl_rollup_level_1]
           ,[pl_rollup_level_2]
           ,[raw]
)
SELECT 
	TRY_CAST(SUBSTRING([Account Number], CHARINDEX('.', [Account Number]) + 1, LEN([Account Number])) AS INT),
	[Account Name],
	[P&L Rollup Level 1],
	[P&L Rollup Level 2],
	SUBSTRING([Account Number], CHARINDEX('.', [Account Number]) + 1, LEN([Account Number])) as [raw]
FROM [staging].[account_mapping]
ORDER BY 2
;



INSERT INTO [dbo].[account]
           ([account_code]
		   ,[account_name]
		   ,[pl_rollup_level_1]
           ,[pl_rollup_level_2]
           ,[raw]
)
SELECT DISTINCT
	TRY_CAST([Account Code] as numeric),
	[Account Name],
	'Unknown',
	'Unknown',
	[Account Code]
FROM compiler.coa.account as a
LEFT JOIN [dbo].[account] AS prd
	ON a.[Account Code] = prd.[raw]
WHERE prd.account_id IS NULL
ORDER BY 2
;
-- SELECT * FROM [dbo].[account]


-- Assignment reference is a GL only attribute, and sometimes contains Puchase Order Number when [Purchase Order Number] is null.
-- I create [Purchase Order Number] when it is not populated by filling it with [Assignment Reference] where like '4200%',
-- or where either description like '4200%', as the column from SAP is often incomplete.
INSERT INTO [dbo].[assignment_reference]
	([assignment_reference]
	,[assignment_reference_description]
	,[raw])
SELECT DISTINCT 
	 LTRIM(RTRIM(REPLACE([Assignment Reference], '"', '')))
	,LTRIM(RTRIM(REPLACE([Assignment Reference], '"', '')))
	,[Assignment Reference]
FROM [Compiler].[mart].[SAP GL Unformatted]
WHERE LTRIM(RTRIM(REPLACE([Assignment Reference], '"', ''))) IS NOT NULL
ORDER BY 1
;

--SELECT DISTINCT [Assignment Reference] FROM [staging].[sap_general_ledger] ORDER BY 1

update [dbo].[assignment_reference] 
	set assignment_reference = 
		case
			when [assignment_reference] like '%4200[0-9][0-9][0-9][0-9][0-9][0-9]%'
				then right(Left([assignment_reference],(charindex('4200',[assignment_reference])+9)),+10)
		else null
		end
;

--select * from [dbo].[assignment_reference]  order by 2,3

-- BUSINESS UNIT
-- TRUNCATE TABLE [dbo].[business_unit];
INSERT INTO [dbo].[business_unit]
           ([business_unit]
           ,[raw])
SELECT * FROM
(SELECT 
	[business_unit], 
	[business_unit] AS raw
FROM [EID].[BUSPLAN].[prd_fg_business_unit]
UNION
SELECT 
	[Business Unit],
	[Business Unit] AS raw
FROM [staging].[work_order_detail]
) AS T
WHERE [business_unit] != 'Unknown'
ORDER BY 1
;


-- COMPANY CODE
INSERT INTO [dbo].[company_code]
           ([company_code]
           ,[company_description]
           ,[company_type]
           ,[legal_entity_name]
           ,[raw])
SELECT DISTINCT
	  TRY_CAST([Company Number] as numeric),
      [Company Code], -- actually the description
      [Company Type],
      [Legal Entity Name],
      [Company Number]
FROM [TEST].[staging].[company_code]
ORDER BY 1
;


-- CONTRACTOR INFORMATION
INSERT INTO [dbo].[contractor]
           ([worker_id]
           ,[pid]
           ,[first_name]
           ,[last_name]
           ,[full_name]
           ,[worker_site]
           ,[raw])
SELECT
	[worker_id]
   ,[pid]
   ,[first_name]
   ,[last_name]
   ,[full_name]
   ,[worker_site]
   ,[raw]
FROM 
(SELECT
	[Worker ID] as worker_id,
	[PID] as pid,
	RIGHT([Worker],CHARINDEX(',',REVERSE([Worker]))-1) as first_name,
	LEFT([Worker], CHARINDEX(',', [Worker] + ',') - 1) as last_name,
	[Worker] as full_name,
	CONCAT('Worker Site: ', [Worker Site State/Province], ' - Country: ', [Country]) as worker_site,
	[Worker ID] as raw,
	ROW_NUMBER() OVER (PARTITION BY [Worker ID] ORDER BY [PID]) AS dedupe
FROM [staging].[work_order_detail]
) as T
WHERE dedupe = 1
ORDER BY 2
;


-- COST CENTER CODE
-- TRUNCATE TABLE [dbo].[cost_center_code];
INSERT INTO [dbo].[cost_center_code]
           ([cost_center_code]
           ,[cost_center]
           ,[company_code_id]
           ,[entity_code]
           ,[department_code]
           ,[raw])
SELECT DISTINCT
	TRY_CAST([Cost Center (Derv)] as numeric),
	[CC Name (Derv)],
	cc.company_code_id,
	TRY_CAST(SUBSTRING([Cost Center (Derv)], 4, 4) as numeric),
	TRY_CAST(RIGHT([Cost Center (Derv)], 3) as numeric),
	[Cost Center (Derv)]
FROM [staging].[sap_general_ledger] as gl
JOIN [dbo].[company_code] as cc
	ON LEFT(gl.[Cost Center (Derv)], 3) = cc.[raw]
ORDER BY 1
;

INSERT INTO [dbo].[cost_center_code]
           ([cost_center_code]
           ,[cost_center]
           ,[company_code_id]
           ,[entity_code]
           ,[department_code]
           ,[raw])
SELECT DISTINCT
	TRY_CAST([Cost Center Code] as numeric),
	NULL,
	cc.company_code_id,
	TRY_CAST(SUBSTRING([Cost Center Code], 4, 4)as numeric),
	TRY_CAST(RIGHT([Cost Center Code], 3) as numeric),
	[Cost Center Code]
FROM [Compiler].[mart].[RollingF] as r
JOIN [dbo].[company_code] as cc
	ON LEFT(r.[Cost Center Code], 3) = cc.[raw]
LEFT JOIN [dbo].[cost_center_code] as ccc
	ON r.[Cost Center Code] = ccc.raw
WHERE ccc.cost_center_code_id IS NULL
AND r.[Cost Center Code] IS NOT NULL
AND r.[Cost Center Code] NOT IN ('','0')
;

 
-- COST OBJECT CODE
INSERT INTO [dbo].[cost_object_code]
           ([cost_object_code]
           ,[cost_object_name]
           ,[is_opex]
           ,[raw])
SELECT DISTINCT
	[WBS Element],
	[WBS Name],
	CASE
		WHEN [WBS Element] LIKE 'FG%'
		THEN 1
		ELSE 0
	END as [is_opex],
	[WBS Element]
FROM [TEST].[staging].[sap_general_ledger]
WHERE [WBS Element] IS NOT NULL
ORDER BY 1
;

INSERT INTO [dbo].[cost_object_code]
           ([cost_object_code]
           ,[cost_object_name]
           ,[is_opex]
           ,[raw])
SELECT DISTINCT
	LTRIM([Cost Object Code]),
	NULL,
	CASE
		WHEN [Cost Object Code] LIKE 'FG%'
		THEN 1
		ELSE 0
	END as [is_opex],
	[Cost Object Code]
FROM [Compiler].[mart].[RollingF] as r
LEFT JOIN [dbo].[cost_object_code] as coc
	ON r.[Cost Object Code] = coc.[raw]
WHERE [Cost Object Code] IS NOT NULL
AND coc.[cost_object_code] IS NULL
AND [Cost Object Code] NOT IN
	('', 'Agent OS Platform',
	'Industrial Design Studio',
	'IP Video Delivery', 'Online Ordering',
	'Portals Resiliency & Feature Capacity'
	)
ORDER BY 1
;

INSERT INTO [dbo].[cost_object_code]
           ([cost_object_code]
           ,[cost_object_name]
           ,[is_opex]
           ,[raw])
SELECT DISTINCT
	LTRIM([Cost Object Code]),
	NULL,
	CASE
		WHEN [Cost Object Code] LIKE 'FG%'
		THEN 1
		ELSE 0
	END as [is_opex],
	[Cost Object Code]
FROM [staging].[work_order_detail] as wod
LEFT JOIN [dbo].[cost_object_code] as coc
	ON wod.[Cost Object Code] = coc.[raw]
WHERE wod.[Cost Object Code] IS NOT NULL
AND coc.[cost_object_code] IS NULL
ORDER BY 1
;


update [dbo].[cost_object_code]
	set cost_object_code = 
		case
			when left([raw],1) = 'P' and len([raw]) = 21
				then cost_object_code
			when left([raw],8) = 'FG00001.' and len([raw]) = 18
				then cost_object_code
		else null
		end
;
--select * FROM [dbo].[cost_object_code]



--TRUNCATE TABLE [dbo].[date_dimension];
INSERT INTO [dbo].[date_dimension]
           ([date_id]
           ,[full_date]
           ,[day_of_week_sunday]
           ,[day_of_week_monday]
           ,[day_name_of_week]
           ,[day_of_month]
           ,[day_of_year]
           ,[weekday_weekend]
           ,[week_of_month]
           ,[week_of_year_sunday]
           ,[week_of_year_monday]
           ,[month_name]
           ,[month_of_year]
           ,[is_last_day_of_month]
           ,[is_holiday]
           ,[holiday_name]
           ,[calendar_quarter]
           ,[calendar_year]
           ,[calendar_year_month]
           ,[calendar_year_qtr]
           ,[is_company_holiday]
           ,[is_estimated_pto]
           ,[onshore_work_hours]
           ,[offshore_work_hours]
           ,[forecasting_month]
		   ,[fiscal_period]
		   ,[short_month_short_year] -- this is the typical forecast header for month
		   )
SELECT REPLACE(CAST(dd.[full_date] AS VARCHAR), '-', '') AS ID
      ,dd.[full_date]
      ,dd.[day_of_week_sunday]
      ,dd.[day_of_week_monday]
      ,dd.[day_name_of_week]
      ,dd.[day_of_month]
      ,dd.[day_of_year]
      ,dd.[weekday_weekend]
      ,dd.[week_of_month]
      ,dd.[week_of_year_sunday]
      ,dd.[week_of_year_monday]
      ,dd.[month_name]
      ,dd.[month_of_year]
      ,dd.[is_last_day_of_month]
      ,dd.[is_holiday]
      ,dd.[holiday_name]
      ,dd.[calendar_quarter]
      ,dd.[calendar_year]
      ,dd.[calendar_year_month]
      ,dd.[calendar_year_qtr]
      ,dd.[is_company_holiday]
      ,dd.[is_estimated_pto]
      ,dd.[onshore_work_hours]
      ,dd.[offshore_work_hours]
	  ,CONCAT(FORMAT(ff.[full_date], 'MMM'), '-', RIGHT(ff.[calendar_year], 2)) as [forecasting_month]
	  ,dd.[month_of_year] as [fiscal_period]
	  ,CONCAT(FORMAT(dd.[full_date], 'MMM'), '-', RIGHT(dd.[calendar_year], 2)) as [short_month_short_year]
FROM [EID].[BUSPLAN].[date_dimension] as dd
LEFT JOIN [EID].[BUSPLAN].[date_dimension] as ff
  ON dd.[forecasting_month] = ff.[full_date]
ORDER BY full_date
;


-- DEPARTMENT
-- TRUNCATE TABLE [dbo].[deptartment];
INSERT INTO [dbo].[deptartment]
           ([department_code]
           ,[department]
           ,[department_long]
           ,[raw])
SELECT * FROM
(SELECT DISTINCT
	[Department Code of Hiring Manager] as code,
	[Department of Hiring Manager] as department,
	CONCAT([Department of Hiring Manager], ' (', [Department Code of Hiring Manager], ')') as department_long,
	[Department of Hiring Manager] as raw
FROM [staging].[work_order_detail]
UNION
SELECT DISTINCT
	[Dept (Derv)],
	[Dept Name (Derv)],
	CONCAT([Dept Name (Derv)], ' (', [Dept (Derv)], ')') as department_long,
	[Dept Name (Derv)] as raw
FROM [staging].[sap_general_ledger] AS gl
) as T
WHERE T.department != 'Unknown'
ORDER BY 1,2,3
;


update [dbo].[deptartment] 
set department = 
			case when department_code = 503
				then 'Network Operations - Recruitment' 
			 when department_code = 701
				then 'Mobile Wireless Product Strategy'
			 when department_code = 702
				then 'Mobile Wireless Product Strategy'
			 when department_code = 705
				then 'Mobile SSPP Backend'
			 when department_code = 709
				then 'Self Service Products & Platforms'
			 when department_code = 714
				then 'Digital Platforms Tech Tools'
			 when department_code = 779
				then 'P&T Business Planning'
			 when department_code = 785
				then 'Data Science & Experimentation'
			 when department_code = 874
				then 'Data Technologies Group'
			 when department_code = 876
				then 'Video Technical Enablement'
			 when department_code = 880
				then 'X-Functional Platforms & Operations'
			 when department_code = 881
				then 'Self Service Products&Platforms Backend'
			 when department_code = 884
				then 'Video Strategy and Operations'
			 when department_code = 894
				then 'Digital Platforms Support'
			 when department_code = 979
				then 'Mobile Product Management'
			when department_code = 980
				then 'P&T Business Development' 
			 when department_code = 990
				then 'Product Connectivity'
			 when department_code = 995
				then 'Video Product Management'
			 when department_code = 996
				then 'Digital Platforms Agency'
			 when department_code = 999
				then 'Digital Platforms Insights'
		else [department]
		end,
	department_long = 
			case when department_code = 503
				then 'Network Operations - Recruitment (503)' 
			 when department_code = 701
				then 'Mobile Wireless Product Strategy (701)'
			 when department_code = 702
				then 'Mobile Product Operational Strategy (702)'
			 when department_code = 705
				then 'Mobile Self Srvc Products&Plat Backend (705)'
			 when department_code = 709
				then 'Self Service Products & Platforms (709)'
			 when department_code = 714
				then 'Digital Platforms Tech Tools (714)'
			 when department_code = 779
				then 'P&T Business Planning (779)'
			 when department_code = 785
				then 'Data Science & Experimentation (785)'
			 when department_code = 874
				then 'Data Technologies Group (874)'
			 when department_code = 876
				then 'Video Technical Enablement (876)'
			 when department_code = 880
				then 'X-Functional Platforms & Operations (880)'
			 when department_code = 881
				then 'Self Service Products&Platforms Backend (881)'
			 when department_code = 884
				then 'Video Strategy and Operations (884)'
			 when department_code = 894
				then 'Digital Platforms Support (894)'
			 when department_code = 979
				then 'Mobile Product Management (979)'
			 when department_code = 980
				then 'P&T Business Development (980)' 
			 when department_code = 990
				then 'Product Connectivity (990)'
			 when department_code = 995
				then 'Video Product Management (995)'
			 when department_code = 996
				then 'Digital Platforms Agency (996)'
			 when department_code = 999
				then 'Digital Platforms Insights (999)'
		else [department_long]
		end
;

/*
INSERT INTO [dbo].[deptartment]
           ([department_code]
           ,[department]
           ,[department_long]
           ,[raw])
SELECT DISTINCT
	NULL,
	[Department of Hiring Manager],
	[Department of Hiring Manager],
	[Department of Hiring Manager]
FROM [EID].[SHARE].[BusPlanContractorDetails] as bp
LEFT JOIN [dbo].[deptartment] as d
	ON bp.[Department of Hiring Manager] = d.raw
WHERE d.department_id IS NULL -- new value
ORDER BY 1,2,3
;
*/

--SELECT * FROM [dbo].[deptartment_business_unit]

INSERT INTO [dbo].[deptartment_business_unit]
          ([department_id]
           ,[business_unit_id])
SELECT *
FROM
(SELECT
       department_id,
       CASE
              WHEN department_code IN (110,704,705,706,709,711,712,713,714,782,784,785,829,842,871,874,876,877,880,881,884,892,893,894,965,995,996,998,999)
              THEN (SELECT MIN(business_unit_id) FROM [dbo].[business_unit] WHERE [raw] = 'DIGITAL PLATFORMS') --1008 -- DIGITAL PLATFORMS
              ELSE NULL
       END as bu
FROM [dbo].[deptartment]
UNION
SELECT
       department_id,
       CASE
              WHEN department_code IN (110,700,701,702,707,708,710,779,924,965,975,979,980,990)
              THEN (SELECT MIN(business_unit_id) FROM [dbo].[business_unit] WHERE [raw] = 'CONNECTIVITY')  -- 1004 -- CONNECTIVITY
              ELSE NULL
       END as bu
FROM [dbo].[deptartment]
UNION
SELECT
       department_id,
       CASE
              WHEN department_code IN (503,504,505,707,779,823,980)
              THEN (SELECT MIN(business_unit_id) FROM [dbo].[business_unit] WHERE [raw] = 'P&T SUPPORT')  -- 1017 -- P&T SUPPORT
              ELSE NULL
       END as bu
FROM [dbo].[deptartment]
) as t
WHERE bu IS NOT NULL
;



--employee
-- SELECT * FROM [dbo].[employee]
INSERT INTO [dbo].[employee]
           ([employee]
           ,[raw])
SELECT DISTINCT
	[Department Leader] as employee,
	[Department Leader] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Department Leader] IS NOT NULL
AND [Department Leader] NOT IN ('')
UNION
SELECT DISTINCT
	[Team Leader] as employee,
	[Team Leader] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Team Leader] IS NOT NULL
AND [Team Leader] NOT IN ('')
UNION
SELECT DISTINCT
	[Business Owner] as employee,
	[Business Owner] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Business Owner] IS NOT NULL
AND [Business Owner] NOT IN ('')
UNION
SELECT DISTINCT
	[Worker: New Primary Contact],
	[Worker: New Primary Contact]
FROM [Compiler].[mart].[RollingF]
WHERE [Worker: New Primary Contact] IS NOT NULL
AND [Worker: New Primary Contact] NOT IN ('', '0')
UNION
SELECT DISTINCT
	[Job Posting Approver],
	[Job Posting Approver]
FROM [staging].[work_order_detail]
WHERE [Job Posting Approver] IS NOT NULL
AND [Job Posting Approver] NOT IN ('', '0')
UNION
SELECT DISTINCT
	[Job Posting Creator],
	[Job Posting Creator]
FROM [staging].[work_order_detail]
WHERE [Job Posting Creator] IS NOT NULL
AND [Job Posting Creator] NOT IN ('', '0')
UNION
SELECT DISTINCT
	[SVP],
	[SVP]
FROM [staging].[work_order_detail]
WHERE [SVP] IS NOT NULL
AND [SVP] NOT IN ('', '0')
UNION
SELECT DISTINCT
	[Worker: New Primary Contact],
	[Worker: New Primary Contact]
FROM [staging].[work_order_detail]
WHERE [Worker: New Primary Contact] IS NOT NULL
AND [Worker: New Primary Contact] NOT IN ('', '0')
ORDER BY 1
;

update [dbo].[employee] set
employee = case
			when [employee] LIKE '%[_]%' and employee like '%(P%' 
				then trim(left([employee],nullif(charindex(' (P',[employee]),0)-1))
			when [employee] LIKE '%[_]P%' 
				then concat(trim(left([employee],nullif(charindex('_',[employee]),0)-1)),trim(right([employee],nullif(charindex('_',reverse([employee])),0)-9)))
			when [employee] NOT LIKE '%,%' and [employee] not like 'Hardware%' and [employee] not like 'Software%' and [employee] not like 'P&T SUPPORT' and [employee] not like 'TBD' and [employee] like '% %' 
				then concat(trim(right([employee],nullif(charindex(' ',reverse([employee])),0)-1)),', ',trim(left([employee],nullif(charindex(' ',[employee]),0)-1)))
			when [employee] like '%Baldino%'
				then 'Baldino, Michael'
			when [employee] like '%Guiberson%'
				then 'Guiberson, Kenneth L'
			when [employee] like '%Maroney%'
				then 'Maroney, Tucker J'
			else [employee]
			end
;

-- SELECT * FROM [dbo].[employee] order by 2

-- ENTITY
INSERT INTO [dbo].[entity]
           ([company_code_id]
           ,[entity_code]
           ,[entity_name]
           ,[raw])
SELECT DISTINCT
	cc.[company_code_id],
	ce.[Entity Code] as [entity_code],
	ce.[Entity Name] as [entity_name],
	ce.[Entity Code] as [raw]
FROM [staging].[company_entity] as ce
LEFT JOIN [dbo].[company_code] as cc
	ON ce.[Company Code] = cc.[raw]
ORDER BY 2



-- EXPENSE CLASSIFICATION
INSERT INTO [dbo].[expense_classification]
           ([expense_classification]
           ,[raw])
SELECT DISTINCT
	[Expense Classification],
	[Expense Classification]
FROM [Compiler].[mart].[RollingF]
WHERE [Expense Classification] IS NOT NULL
AND [Expense Classification] NOT IN ('')
ORDER BY 1
;


-- EXPENSE TYPE
INSERT INTO [dbo].[expense_type]
           ([expense_type],
		   [raw])
VALUES
	('Direct', 'Direct'), -- OPEX
	('Indirect', 'Indirect'),
	('Indirect - CAPEX', 'Indirect - CAPEX'),
	('Indirect - OPEX', 'Indirect - OPEX'),
	('Indirect - Contractors (CAPEX)', 'Indirect - Contractors (CAPEX)'),
	('Indirect - Contractors (OPEX)', 'Indirect - Contractors (OPEX)')
;


-- function
INSERT INTO [dbo].[function]
           ([function]
           ,[raw])
     VALUES
			('Development','Development'),
			('PM/BA','PM/BA'),
			('Lab Ops','Lab Ops'),
			('Software','Software'),
			('Testing','Testing'),
			('Direct Expense','Direct Expense'),
			('Consulting','Consulting'),
			('Hardware','Hardware'),
			('Other','Other'),
			('Design','Design')
;


-- Journal Entry Type denotes the SAP method by which the entry was created. 
-- For example, an automated accrual will have a different Type than a human entering the entry by hand via a certain SAP system.
-- Usually this only serves to fact find who to reach out to about details for why the entry was booked.
INSERT INTO [dbo].[journal_entry_type]
	([journal_entry_type]
	,[journal_entry_type_description]
	,[raw])
SELECT DISTINCT 
	 [Journal Entry Type]
	,[Journal Entry Type]
	,[Journal Entry Type]
FROM [Compiler].[mart].[SAP GL Unformatted]
ORDER BY 1
;


-- location and locale
INSERT INTO [dbo].[location]
           ([location]
           ,[local]
           ,[raw])
SELECT DISTINCT
	LEFT([Country], CHARINDEX('|', [Country] + '|') - 1) as [location],
	CASE
		WHEN RIGHT([Country],CHARINDEX('|',REVERSE([Country]))-1) = 'USA'
		THEN 'Onshore'
		WHEN RIGHT([Country],CHARINDEX('|',REVERSE([Country]))-1) IN ('CAN', 'MEX')
		THEN 'Nearshore'
		ELSE 'Offshore'
	END as locale,
	[Country] as raw
FROM [staging].[work_order_detail]
WHERE [Country] is not null
ORDER BY 1
;


-- MAIN DOCUMENT TITLE 
INSERT INTO [dbo].[main_document_title]
           ([main_document_title]
           ,[raw])
SELECT DISTINCT
	[Main Document Title],
	CAST([Main Document Title] as VARCHAR(254))
FROM [staging].[work_order_detail]
--WHERE LEN([Main Document Title]) > 250
UNION
SELECT DISTINCT
	[Main Document Title],
	CAST([Main Document Title] as VARCHAR(254))
FROM [Compiler].[mart].[RollingF]
WHERE [Main Document Title] IS NOT NULL
AND [Main Document Title] NOT IN ('')
--AND LEN([Main Document Title]) > 250
ORDER BY 1
;


-- PLATFORM
INSERT INTO [dbo].[platform]
           ([platform]
           ,[raw])
SELECT DISTINCT 
	[platform], 
	[platform] 
FROM [Compiler].[mart].[RollingF] 
WHERE len(Platform) > 1
UNION
SELECT 
	[Platform],
	[Platform]
FROM [staging].[pcode_to_bcode] as stg
UNION
SELECT
	[Platform],
	[Platform]
FROM [staging].[opex_department_mapping]
ORDER BY 1
;


--I searched SAP for a Profit Center code and couldn't find it as a field to be in the GL.
--Its possible we can get this data from business when we ask for those definitions
Insert into [dbo].[profit_center]
	([profit_center],
	 [raw])
SELECT DISTINCT
	[PC Name],
	[PC Name]
FROM [Compiler].[mart].[SAP GL Unformatted]
WHERE [PC Name] IS NOT NULL
ORDER BY 1
;


--This is left([Cost Object Code],7), and is largely what business reports on.
INSERT INTO [dbo].[project]
	([project]
	,[project_name]
	,[raw])
SELECT DISTINCT
	 [Project]
	,[Project Name]
	,[Project]
FROM [Compiler].[mart].[SAP GL Unformatted]
WHERE [Project] is not null
ORDER BY 1
;


UPDATE [dbo].[project]
SET project.[budget_code_id] = t.[budget_code_id]
FROM 
(SELECT
	p.[project_id],
	bc.[budget_code_id]
FROM [dbo].[project] as p
JOIN [staging].[pcode_to_bcode] as pb
	ON p.[raw] = pb.[Project Name ID]
JOIN [dbo].[budget_code] as bc
	ON pb.[Bcode/Investment Position ID] = bc.[raw]
) as t, [project]
WHERE t.project_id = project.[project_id]
;




--No idea what these types indicate
INSERT INTO [dbo].[project_type]
	([project_type]
	,[project_type_description]
	,[raw])
SELECT DISTINCT 
	 [Project Type]
	,[Proj Typ Name]
	,[Project Type]
FROM [Compiler].[mart].[SAP GL Unformatted]
WHERE [Project Type] is not null
ORDER BY 1
;


-- SEGMENTATION
INSERT INTO [dbo].[segmentation]
           ([segmentation]
           ,[raw])
SELECT DISTINCT 
	[Segmentation],
	[Segmentation]
FROM [Compiler].[mart].[RollingF]
WHERE [Segmentation] IS NOT NULL
AND [Segmentation] NOT IN ('')
UNION
SELECT 
	[P&T Segmentation],
	[P&T Segmentation]
FROM [staging].[pcode_to_bcode] as stg
UNION
SELECT
	[P&T Segmentation],
	[P&T Segmentation]
FROM [staging].[opex_department_mapping]
ORDER BY 1
;


-- BUDGET CODE
-- comes after segmentation and platform due to FK dependency
INSERT INTO [dbo].[budget_code]
           ([segmentation_id]
		   ,[platform_id]
		   ,[budget_code]
		   ,[budget_name]
           ,[raw])
SELECT DISTINCT
	seg.[segmentation_id],
	p.[platform_id],
	[Bcode/Investment Position ID],
	[Bcode/Investment Position Name],
	[Bcode/Investment Position ID]
FROM [staging].[pcode_to_bcode] as stg
LEFT JOIN [dbo].[segmentation] as seg
	ON stg.[P&T Segmentation] = seg.[raw]
LEFT JOIN [dbo].[platform] as p
	ON stg.[Platform] = p.[raw]
ORDER BY 3
;


INSERT INTO [dbo].[budget_code]
           ([segmentation_id]
		   ,[platform_id]
		   ,[budget_code]
		   ,[budget_name]
           ,[raw])
SELECT DISTINCT
	IIF(bc.[segmentation_id] IS NOT NULL, bc.[segmentation_id], NULL),
	IIF(bc.[platform_id] IS NOT NULL, bc.[platform_id], NULL),
	IIF(bc.[budget_code] IS NOT NULL, bc.[budget_code], t.[Budget Code]),
	t.budget_name,
	t.[Budget Code]
FROM
	(SELECT DISTINCT
		[Budget Code],
		[Budget Code] as budget_name,
		prd.[budget_code]
	FROM [Compiler].[mart].[RollingF] as f
	LEFT JOIN [dbo].[budget_code] as prd
		ON f.[Budget Code] = prd.[raw]
	WHERE f.[Budget Code] IS NOT NULL
	AND f.[Budget Code] NOT IN ('', '0')
	AND prd.budget_code_id IS NULL
	) as t
LEFT JOIN [dbo].[budget_code] as bc
	ON t.[Budget Code] = bc.[budget_name]
WHERE bc.[raw] IS NULL
OR t.[Budget Code] != bc.[raw]
ORDER BY 3
;



-- SUPPLIER
INSERT INTO [dbo].[supplier]
           ([supplier_code]
		   ,[supplier]
		   ,[supplier_long]
           ,[raw])
SELECT DISTINCT
	[Supplier Code],
	[Supplier],
	CONCAT([Supplier Code], ' - ', [Supplier]),
	[Supplier]
FROM [staging].[work_order_detail]
;

INSERT INTO [dbo].[supplier]
           ([supplier_code]
		   ,[supplier]
		   ,[supplier_long]
           ,[raw])
SELECT
	NULL as [supplier_code],
	T.[Supplier],
	T.[Supplier] as [supplier_long],
	T.[raw]
FROM
(SELECT DISTINCT
	[Supplier],
	[Supplier] as raw
FROM [Compiler].[mart].[RollingF]
WHERE [Supplier] IS NOT NULL
AND [Supplier] != ''
UNION
SELECT [Supplier Name], [Supplier Name]
FROM [staging].[sap_general_ledger]
WHERE [Supplier Name] IS NOT NULL
) as T
LEFT JOIN [dbo].[supplier] as prd
	ON T.[raw] = prd.[raw]
WHERE prd.[supplier_id] IS NULL -- does not exist
ORDER BY 1
;


--SELECT DISTINCT [Supplier], [Supplier Name]
--FROM [TEST].[staging].[sap_general_ledger]


-- SUPPORT/SCALABLE
INSERT INTO [dbo].[support_scalable]
           ([support_scalable]
           ,[raw])
VALUES ('Support', 'Support'),
       ('Scalable', 'Scalable')
;


-- USER
--TRUNCATE TABLE [dbo].[user];
INSERT INTO [dbo].[user]
           ([name]
           ,[username]
           ,[pid]
           ,[is_admin])
SELECT
	emp_name,
	username,
	userPID,
	CASE
		WHEN username IN ('dev1', 'cstroup', 'kgiangrosso')
		THEN 1
		ELSE 0
	END as is_admin
FROM [Compiler].[mart].[perm_user]
ORDER BY 1
;

UPDATE [dbo].[user]
SET username = 'admin',
	pid = 'admin'
WHERE [name] = 'admin'
;


-- USER ACCESS
INSERT INTO [dbo].[user_access]
           ([user_id]
           ,[department_bu_id])
-- admins get access to everything
SELECT
	u.[user_id],
	dbu.[department_bu_id] as [deptartment_bu_id]
FROM [dbo].[user] as u 
LEFT JOIN [Compiler].[mart].[perm_user] as pu
	ON u.[username] = pu.[username]
JOIN [dbo].[deptartment_business_unit] as dbu
	ON 1=1
WHERE u.[is_admin] = 1

UNION

SELECT
	u.[user_id],
	dbu.[department_bu_id] as [deptartment_bu_id]
FROM [dbo].[user] as u 
LEFT JOIN [Compiler].[mart].[perm_user] as pu
	ON u.[username] = pu.[username]
JOIN 
	(
	SELECT
		dbu.[department_bu_id]
	FROM [dbo].[deptartment_business_unit] as dbu
	JOIN [dbo].[business_unit] as bu
		ON dbu.[business_unit_id] = bu.[business_unit_id]
	WHERE bu.[business_unit] = 'CONNECTIVITY'
	) as dbu ON 1=1
WHERE pu.[ConnectivityProducts] = 1

UNION

SELECT
	u.[user_id],
	dbu.[department_bu_id] as [deptartment_bu_id]
FROM [dbo].[user] as u 
LEFT JOIN [Compiler].[mart].[perm_user] as pu
	ON u.[username] = pu.[username]
JOIN 
	(
	SELECT
		dbu.[department_bu_id]
	FROM [dbo].[deptartment_business_unit] as dbu
	JOIN [dbo].[business_unit] as bu
		ON dbu.[business_unit_id] = bu.[business_unit_id]
	WHERE bu.[business_unit] = 'DIGITAL PLATFORMS'
	) as dbu ON 1=1
WHERE pu.[DigitalPlatforms] = 1

UNION

SELECT
	u.[user_id],
	dbu.[department_bu_id] as [deptartment_bu_id]
FROM [dbo].[user] as u 
LEFT JOIN [Compiler].[mart].[perm_user] as pu
	ON u.[username] = pu.[username]
JOIN 
	(
	SELECT
		dbu.[department_bu_id]
	FROM [dbo].[deptartment_business_unit] as dbu
	JOIN [dbo].[business_unit] as bu
		ON dbu.[business_unit_id] = bu.[business_unit_id]
	WHERE bu.[business_unit] = 'P&T SUPPORT'
	) as dbu ON 1=1
WHERE pu.[PTOther] = 1
;



-- WORK ORDER CATEGORY
INSERT INTO [dbo].[work_order_category]
           ([work_order_category]
           ,[raw])
SELECT DISTINCT
	[WO Category],
	[WO Category]
FROM [Compiler].[mart].[RollingF]
WHERE [WO Category] IS NOT NULL
AND [WO Category] NOT IN ('', '0')
ORDER BY 1
;


-- WORK ORDER STATUS
INSERT INTO [dbo].[work_order_status]
           ([work_order_status]
           ,[raw])
SELECT DISTINCT
	[Work Order Status],
	[Work Order Status]
FROM [staging].[work_order_detail]
ORDER BY 1
;



--	WORK TYPE
INSERT INTO [dbo].[work_type]
           ([work_type]
           ,[raw])
SELECT DISTINCT
	[Worker Type],
	[Worker Type]
FROM [staging].[work_order_detail]
UNION
SELECT DISTINCT
	[Work Type],
	[Work Type]
FROM [Compiler].[mart].[RollingF]
WHERE [Work Type] IS NOT NULL
AND [Work Type] NOT IN ('15263')
ORDER BY 1
;


-- WORKER STATUS
INSERT INTO [dbo].[worker_status]
           ([worker_status]
           ,[raw])
SELECT DISTINCT
	[Worker Status],
	[Worker Status]
FROM [Compiler].[mart].[RollingF]
WHERE [Worker Status] IS NOT NULL
ORDER BY 1
;

END
;
GO