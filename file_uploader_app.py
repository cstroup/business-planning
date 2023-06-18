# -*- coding: utf-8 -*-
"""
Created on Wed Apr 12 08:33:07 2023

@author: P3098826

python -m PyInstaller -–onefile -–windowed --icon="bp_app.ico" --name="Business Planning" --hidden-import pandas untitled0.py
"""

import pyodbc
import csv
import tkinter as tk
import tkinter.font as font
import datetime as dt
import pandas as pd
import numpy as np
import datetime
import time
# import customtkinter ## need to figure this out
from tkinter import ttk
from tkinter import Frame
from tkinter import Menu
from tkinter import filedialog



class FileUploader:
    def __init__(self, root):
        # Create the main window
        self.root = root
        self.root.title('Business Planning File Uploader')
        self.root.geometry("1000x600")
        self.frame = tk.Frame(self.root)
        self.frame.pack()
        
        self.timesheets_file_path = None
        self.contractor_details_file_path = None
        self.keach_hr_file_path = None
        
        # Set the default font style for all widgets in the application
        default_font = font.nametofont("TkDefaultFont")
        default_font.configure(family="Helvetica", size=9) # Helvetica | Calibri
        
        # Create a new font that adds bold style to the default font
        bold_font = default_font.copy()
        bold_font.configure(weight="bold")
        
        # Set the default font for all widgets
        self.root.option_add("*Font", default_font)

        # Create a style object for the notebook widget
        self.style = ttk.Style()
        self.style.theme_use('clam')  # clam | xpnative | vista | winnative | alt
        
        # Set the background color of the selected tab
        self.style.map("TNotebook.Tab", background=[("selected", "#DCDAD5"), ("!selected", "#f0f0f0")],
                       foreground=[("selected", "#000000"),("!selected", "#9C9C9C")],
                       expand=[("selected", [0, 0, 0, 3]), ("!selected", [0, 0, 0, 0])])
        
        # Button Styles
        self.style.configure('TButton', background = '#4A6984', foreground = 'white', width=20, 
                             borderwidth=3, focusthickness=3, focuscolor='none')
        self.style.map('TButton', background=[('active','#94adc3'), ('disabled', '#f0f0f0')])
        
        self.style.configure("Delete.TButton", background = '#7a0101', foreground = 'white', width=20, 
                             borderwidth=3, focusthickness=3, focuscolor='none')
        self.style.map('Delete.TButton', background=[('active','#b54343'), ('disabled', '#f0f0f0')])
        
        self.style.configure("Important.TButton", background = '#026c45', foreground = 'white', width=20, 
                             borderwidth=3, focusthickness=3, focuscolor='none')
        self.style.map('Important.TButton', background=[('active','#6fd6b0'), ('disabled', '#f0f0f0')])



    def create_admin_portal(self):
        # Create the widgets for the server name, database name, username, and password
        tk.Label(self.frame, text="Server Name:", anchor='w').pack(fill=tk.X, padx=5, pady=5)
        server_options = ["business-planning-proxy.spectrumtoolbox.com", "VM0PWDCRPTD0001"]
        self.server_var = tk.StringVar()
        self.server_var.set(server_options[0])
        self.server_option = ttk.Combobox(self.frame, textvariable=self.server_var, values=server_options, width=30, height=20)
        self.server_option.pack(fill=tk.X, padx=5, pady=5)

        tk.Label(self.frame, text="Database Name:", anchor='w').pack(fill=tk.X, padx=5, pady=5)
        db_options = ["Compiler", "EID", "PLANNING_APP", "TEST"]
        self.db_var = tk.StringVar(value=db_options[1])
        self.db_option = ttk.Combobox(self.frame, textvariable=self.db_var, values=db_options, width=30, height=20)
        self.db_option.pack(fill=tk.X, padx=5, pady=5)

        tk.Label(self.frame, text="Username:", anchor='w').pack(fill=tk.X, padx=5, pady=5)
        self.username_entry = tk.Entry(self.frame, width=30)
        self.username_entry.pack(fill=tk.X, padx=5, pady=5)

        tk.Label(self.frame, text="Password:", anchor='w').pack(fill=tk.X, padx=5, pady=5)
        self.password_entry = tk.Entry(self.frame, show="*", width=30)
        self.password_entry.pack(fill=tk.X, padx=5, pady=5)

        # Add a separator
        ttk.Separator(self.frame, orient='horizontal').pack(fill=tk.X, padx=20, pady=20)

        # Create the "Upload" button
        self.upload_button = ttk.Button(self.frame, text="Upload Files", 
                                        command=self.upload_files,
                                        style="Important.TButton")
        self.upload_button.pack(fill=tk.X, padx=5, pady=5)
        self.upload_label = tk.Label(self.roframeot, text="", anchor='w')
        self.upload_label.pack(fill=tk.X, padx=5, pady=5)


        # TIMESHEETS FILE
        tk.Label(self.frame, text="Allocation Timesheets File").pack(fill=tk.X, padx=5, pady=5)

        # Create the "Select File" button and file path label
        self.select_timesheets_button = ttk.Button(self.frame, text="Browse CSV", 
                                                command=self.select_timesheets_file,
                                                style="TButton")
        self.select_timesheets_button.pack(fill=tk.X, padx=5, pady=5)
        self.timesheets_label = tk.Label(self.frame, text=" ", anchor='w', width=70)
        self.timesheets_label.pack(fill=tk.X, padx=5, pady=5)


        # CONTRACTOR DETAILS
        tk.Label(self.frame, text="Contractor Details File").pack(fill=tk.X, padx=5, pady=5)

        # Create the "Select File" button and file path label
        self.select_contractors_button = ttk.Button(self.frame, text="Browse Excel", 
                                                command=self.select_contractor_details,
                                                style="TButton")
        self.select_contractors_button.pack(fill=tk.X, padx=5, pady=5)
        self.contractors_label = tk.Label(self.frame, text=" ", anchor='w', width=70)
        self.contractors_label.pack(fill=tk.X, padx=5, pady=5)


        # KEACH'S HR REPORT
        tk.Label(self.frame, text="Keach HR File").pack(fill=tk.X, padx=5, pady=5)

        # Create the "Select File" button and file path label
        self.select_hr_button = ttk.Button(self.frame, text="Browse Excel", 
                                                command=self.select_keach_hr,
                                                style="TButton")
        self.select_hr_button.pack(fill=tk.X, padx=5, pady=5)
        self.keach_hr_label = tk.Label(self.frame, text=" ", anchor='w', width=70)
        self.keach_hr_label.pack(fill=tk.X, padx=5, pady=5)

        
        
    def connect_to_db(self):
        # Get the database connection parameters from the user input
        server = self.server_var.get()
        database = self.db_var.get()
        username = self.username_entry.get()
        password = self.password_entry.get()
        
        try:
            # Connect to the SQL Server database
            conn = pyodbc.connect(f'Driver={{SQL Server}};'
                                  f'Server={server};'
                                  f'Database={database};'
                                  f'UID={username};'
                                  f'PWD={password};')
            return conn
        except pyodbc.Error as e:
            msg = f"Error connecting to database: {e}"
            tk.messagebox.showerror("Error", f"Invalid username or password! {msg}")


    
    def insert_etl_execution(self, job_name, file_name, stored_proc_name=None):
        try:
            conn = self.connect_to_db()
            cursor = conn.cursor()

            insert_query = f"""
            INSERT INTO [audit].[etl_executions]
                    ([job_name]
                    ,[file_name]
                    ,[requested_date]
                    ,[completed_date]
                    ,[requested_by]
                    ,[created_date]
                    ,[is_error]
                    ,[error_message])
                VALUES
            ('{job_name}' -- job_name
            ,'{file_name}' -- file_name 
            ,CURRENT_TIMESTAMP -- requested_date
            ,NULL -- completed_date
            ,CURRENT_USER -- requested_by
            ,CURRENT_TIMESTAMP -- created_date
            ,0 -- is_error
            ,NULL -- error_message
            )
            """
            print(insert_query)
            cursor.execute(insert_query)
            conn.commit()

            # run stored proc if needed
            if len(stored_proc_name) > 0:            
                wo_query = f"EXEC {stored_proc_name}"
                cursor.execute(wo_query)
                conn.commit()
            
            # update etl execution
            update_query = f"""
            UPDATE [audit].[etl_executions]
                SET [completed_date] = CURRENT_TIMESTAMP
            WHERE [etl_executions_id] = (SELECT MAX([etl_executions_id]) FROM [audit].[etl_executions] WHERE [requested_by] = CURRENT_USER)
            AND job_name = '{job_name}'
            """
            print(update_query)
            cursor.execute(update_query)
            conn.commit()
        
        except Exception as e:
            msg = str(e)
            print(f"Failed: {msg}")
            
            update_query = f"""
            UPDATE [audit].[etl_executions]
                SET [completed_date] = CURRENT_TIMESTAMP
                    ,[is_error] = 1
                    ,[error_message] = '{msg}'
            WHERE [etl_executions_id] = (SELECT MAX([etl_executions_id]) FROM [audit].[etl_executions] WHERE [requested_by] = CURRENT_USER)
            AND job_name = '{job_name}'
            """
            cursor.execute(update_query)
            conn.commit()



    def insert_dataframe_to_sql_server(self, df, schema, table, batch_size, truncate_table='N'):
        """
        Inserts a Pandas DataFrame into a SQL Server database table using a custom batch size.
        SQL Server is limited to only 1,000 rows at a time.
        
        Additionally, there is a check of column headers to ensure data ingestion is proper or else
        it will error out.
    
        Args:
            df (pd.DataFrame): DataFrame to be inserted.
            table (str): Table name.
            first_row (int): The first row to be inserted from the CSV file. Default is 2 to skip the header row.
            field_terminator (str): The field delimiter used in the CSV file. Default is ','.
            field_quote (str): The text qualifier for strings '"'.
            truncate_table (str): Either pass Y/N if you want to truncate the table first
        """
        # Convert all columns to strings
        df = df.astype(str)
        
        # issue with single quotes
        # Replace any instance of a single quote with a blank
        for col in df.columns:
            df[col] = df[col].str.replace("'", "")
        
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        db_col_headers_query = f"""
        SELECT 
            TABLE_CATALOG, 
            TABLE_SCHEMA, 
            TABLE_NAME, 
            COLUMN_NAME, 
            ORDINAL_POSITION,
            DATA_TYPE, 
            IS_NULLABLE 
        FROM 
            INFORMATION_SCHEMA.COLUMNS 
        WHERE 
            TABLE_CATALOG = '{self.database_name}'
            AND TABLE_SCHEMA = '{schema}' 
            AND TABLE_NAME = '{table}'
        ORDER BY ORDINAL_POSITION	
        """
        print(db_col_headers_query)
        cursor.execute(db_col_headers_query)
        data = cursor.fetchall()
        
        db_col_headers = []
        
        for i in data:
            db_col_headers.append(i[3])
            
        df_col_headers = df.columns.tolist()
        
        print(f"{self.database_name}.{schema}.{table} column headers: {str(db_col_headers)}")
        print(f"File Headers: {str(df_col_headers)}")
        
        if db_col_headers != df_col_headers:
            msg_1 = f"{self.database_name}.{schema}.{table} column headers:\n{str(db_col_headers)}"
            msg_2 = f"File Headers:\n{str(df_col_headers)}"
            raise ValueError(f"Column headers in the DataFrame do not match with the database. Operation aborted.\n\n{msg_1}\n\n{msg_2}")

        
        if truncate_table == 'Y':
            # Build & Execute SQL TRUNCATE statement
            truncate_query = f"TRUNCATE TABLE {schema}.{table};"
            print(truncate_query)
            cursor.execute(truncate_query)
            conn.commit()
            print('\nSUCCESS: "' + str(truncate_query) + '"\n')
            
            self.upload_label = tk.Label(self.admin_frame, text=f"{truncate_query}", anchor='w', width=100)
            self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.admin_frame.update()
        else:
            pass
        
        insert_into = 'INSERT INTO [{}].[{}]'.format(schema, table)
        
        df_len = len(df)
        counter = df_len
        rows_inserted = 0
        
        for i in range(0, df_len, batch_size):
            df_chunk = df[i:i+batch_size] # breakout og dataframe into chunks of batch_size (i.e 1,000)
            df_chunk.reset_index(inplace=True) # reset index to start at 0 for chunk
            df_chunk_len = len(df_chunk) # find length of chunk to loop through
            
            records = ''
            
            for index, row in df_chunk.iterrows():
                row_as_list = list(row)[1:]
                if index + 1 < df_chunk_len:
                    row_as_str = str(row_as_list).replace('[', '(').replace(']', '),\n').replace("'nan'", 'NULL')
                    records += row_as_str
    
                elif index + 1 == df_chunk_len: # last row
                    row_as_str = str(row_as_list).replace('[', '(').replace(']', ')\n;').replace("'nan'", 'NULL')
                    records += row_as_str
            
            # sql = insert_into + '\n' + columns + '\nVALUES\n' + records # print(sql)
            sql = insert_into + '\nVALUES\n' + records # print(sql)
            
            # Execute sql INSERT statement
            try:
                cursor.execute(sql)
                conn.commit()
                print('Successfully uploaded: ' + str(df_chunk_len) + ' record(s)')
            except Exception as e:
                msg = str(e)
                print(f"Failed: {msg}")
                tk.messagebox.showerror("Error", f"There was an error! {msg}") 
                
            rows_inserted += df_chunk_len
            counter -= df_chunk_len
            info_label = f"For table {schema.upper()}.{table.upper()}: {rows_inserted} of {df_len}"
            self.upload_label = tk.Label(self.admin_frame, text=f"{info_label}", anchor='w', width=100)
            self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.admin_frame.update()
            print('Records left: ' + str(counter) + ' Rows Inserted: ' + str(rows_inserted) + '\n')


   
    # def insert_dataframe_to_sql_server(self, df, schema, table, batch_size, truncate_table='N'):
    def flat_file_to_dataframe(self, directory, delim=',', display_df='N'):
        """
        Converts any flat file (csv, txt, etc..) into a dataframe based on the 10 most recent files
        in the user's download directory.
    
        Args:
            directory: the full path of the file
            delim: the delimiter of the flat file
            display_df: want to display the dataframe? (Y/N)
        Returns:
            A Pandas data frame containing the contents of the flat file.
        """
        df = pd.read_csv(directory, delimiter=delim, header='infer')
        
        # show dataframe or not
        if display_df == 'Y':
            print(df)
        else:
            pass
        
        return(df)
        # df = df[:2500] # if wanting only a sample
        

        
    def excel_file_to_dataframe(self, directory, skiprows=0, skipfooter=0, display_df='N'):
        """
        Converts any Excel file into a dataframe based on the 10 most recent files
        in the user's download directory.
    
        Args:
            skiprows (int): Number of rows to skip from the top of the Excel file (default is 0)
            skipfooter (int): Number of rows to skip from the bottom of the Excel file (default is 0)
            display_df: want to display the dataframe? (Y/N)
        Returns:
            A Pandas data frame containing the contents of the Excel file.
        """
        
        try:
            df = pd.read_excel(directory, skiprows=skiprows, skipfooter=skipfooter)
            # show dataframe or not
            if display_df == 'Y':
                print(df)
            else:
                pass
            return df
        except Exception as e:
            print("An error occurred while importing the Excel file:", e)
            
            
            
    def select_timesheets_file(self):
        
        self.timesheets_file_path = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        print(f"Timesheets File Path: {self.timesheets_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.timesheets_file_path:
            pass
        else:
            try:
                self.timesheets_label.config(text=self.timesheets_file_path)
            
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!") 
            
            

    def select_contractor_details(self):
        self.contractor_details_file_path = filedialog.askopenfilename(filetypes=[("Excel files", "*.xlsx;*.xls")])
        print(f"Contractor Details File Path: {self.contractor_details_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.contractor_details_file_path:
            pass
        else:
            try:
                self.contractors_label.config(text=self.contractor_details_file_path)
            
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!") 


            
    def select_keach_hr(self):
        self.keach_hr_file_path = filedialog.askopenfilename(filetypes=[("Excel files", "*.xlsx;*.xls")])
        print(f"Keach's HR File Path: {self.keach_hr_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.keach_hr_file_path:
            pass
        else:
            try:
                self.keach_hr_label.config(text=self.keach_hr_file_path)
            
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!") 
                


    def select_wo_detail(self):
        self.wo_detail_file_path = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        print(f"Work Order Details File Path: {self.wo_detail_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.wo_detail_file_path:
            pass
        else:
            try:
                self.wo_detail_label.config(text=self.wo_detail_file_path)
            
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!") 
                 


    def upload_files(self):
                
        try:
                
            if self.timesheets_file_path:
                self.insert_dataframe_to_sql_server(self.flat_file_to_dataframe(self.timesheets_file_path, 
                                                                                delim='|', display_df='N'),
                                                   'staging', 'allocations_timesheets',
                                                   batch_size=1000, truncate_table='Y')
                
            if self.contractor_details_file_path:
                self.insert_dataframe_to_sql_server(self.excel_file_to_dataframe(self.contractor_details_file_path, 
                                                                                skiprows=1, skipfooter=3, display_df='N'),
                                                   'staging', 'contractor_details',
                                                   batch_size=1000, truncate_table='Y')
                
            if self.keach_hr_file_path:
                self.insert_dataframe_to_sql_server(self.excel_file_to_dataframe(self.keach_hr_file_path, 
                                                                                skiprows=0, skipfooter=0, display_df='N'),
                                                   'staging', 'contractor_active_report',
                                                   batch_size=1000, truncate_table='Y')


            self.upload_label = tk.Label(self.root, text="Completed!", anchor='w', width=100)
            self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.root.update()
            
        except Exception as e:
            msg = str(e)
            print(f"Failed: {msg}")
            tk.messagebox.showerror("Error", f"There was an error! {msg}")



if __name__ == '__main__':
    root = tk.Tk()
    root.configure(bg="#FFFFFF")
    # root.attributes('-topmost',True)
    # root.state('zoomed')
    app = FileUploader(root)
    root.mainloop()