# -*- coding: utf-8 -*-
"""
Created on Wed Apr 19 14:48:59 2023

@author: P3098826
"""

import pyodbc

# Set up the connection string
server = 'business-planning-proxy.spectrumtoolbox.com'
database = 'PLANNING_APP' # Compiler | TEST | PLANNING_APP
username = 'admin'
password = 'daJQ6bW4NQ4!9xAKCAaX'
conn_str = f"DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}"

# Connect to the database
cnxn = pyodbc.connect(conn_str)

# Set up the cursor
cursor = cnxn.cursor()

schema = 'dbo'

# Define the query to retrieve the table names
query = f"SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = '{schema}' ORDER BY 1"

cursor.execute(query)
rows = cursor.fetchall()

# print(rows)

for i in rows:
    table_name = i[0]
    # print(table_name)
    query_table = f"""
    SELECT count(*) FROM {database}.[{schema}].[{table_name}]
    """
    # print(query_table)
    cursor.execute(query_table)
    rows = cursor.fetchall()
    
    print(f"TABLE: {table_name} | RECORDS: {rows[0][0]}")

# # Execute the query and loop through the results
# for table in cursor.execute(query):
#     table_name = table[0]
#     count_query = f"SELECT COUNT(*) FROM dbo.[{table_name}]"
#     count_result = cursor.execute(count_query).fetchone()[0]
#     print(f"{table_name}: {count_result} records")

# # Close the cursor and the connection
# cursor.close()
# cnxn.close()