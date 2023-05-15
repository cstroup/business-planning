-- Grant read and write access to a database for a specific user
USE [TEST]
GO

EXEC sp_addrolemember 'db_datareader', 'cstroup'
GO
EXEC sp_addrolemember 'db_datawriter', 'cstroup'
GO


EXEC sp_addsrvrolemember 'cstroup', 'processadmin'


TITLE: Microsoft SQL Server Management Studio
------------------------------

The SELECT permission was denied on the object 'query_store_runtime_stats', database 'mssqlsystemresource', schema 'sys'. (Microsoft SQL Server, Error: 229)

For help, click: https://docs.microsoft.com/sql/relational-databases/errors-events/mssqlserver-229-database-engine-error

------------------------------
BUTTONS:

OK
------------------------------


USE [mssqlsystemresource];
GO
GRANT SELECT ON OBJECT::[sys].[query_store_runtime_stats] TO cstroup;
GO