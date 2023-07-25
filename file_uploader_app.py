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
import os
# import customtkinter ## need to figure this out
from tkinter import ttk
from tkinter import Frame
from tkinter import Menu
from tkinter import filedialog



class FileUploader:
    def __init__(self):
        # Create the main window
        self.root = tk.Tk()
        
        self.root.title('Business Planning File Uploader')
        self.root.geometry("1000x600")
        
        self.timesheets_file_path = None
        self.contractor_details_file_path = None
        self.keach_hr_file_path = None
        self.gl_file_path = None
        self.wo_detail_file_path = None
        
        
        # Set the default font style for all widgets in the application
        default_font = font.nametofont("TkDefaultFont")
        default_font.configure(family="Helvetica", size=9) # Helvetica | Calibri
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
        
        
        
        # Create the widgets for the server name, database name, username, and password
        tk.Label(self.root, text="Server Name:", anchor='w').grid(row=0, column=0, columnspan=2, padx=5, pady=5, sticky='w')
        server_options = ["business-planning-proxy.spectrumtoolbox.com", "VM0PWDCRPTD0001"]
        self.server_var = tk.StringVar()
        self.server_var.set(server_options[0])
        self.server_option = ttk.Combobox(self.root, textvariable=self.server_var, values=server_options, width=30, height=20)
        #self.server_option.configure(state="disabled")
        self.server_option.grid(row=0, column=1, padx=5, pady=10, sticky='w')
        
        tk.Label(self.root, text="Database Name:", anchor='w').grid(row=1, column=0, padx=5, pady=10, sticky='w')
        db_options = ["Compiler", "EID", "PLANNING_APP", "TEST"]
        self.db_var = tk.StringVar(value=db_options[1])
        self.db_option = ttk.Combobox(self.root, textvariable=self.db_var, values=db_options, width=30, height=20)
        self.db_option.grid(row=1, column=1, padx=5, pady=10, sticky='w')
        
        tk.Label(self.root, text="Username:", anchor='w').grid(row=2, column=0, padx=5, pady=10, sticky='w')
        self.username_entry = tk.Entry(self.root, width=30)
        self.username_entry.grid(row=2, column=1, padx=5, pady=10, sticky='w')
        
        tk.Label(self.root, text="Password:", anchor='w').grid(row=3, column=0, padx=5, pady=10, sticky='w')
        self.password_entry = tk.Entry(self.root, show="*", width=30)
        self.password_entry.grid(row=3, column=1, padx=5, pady=10, sticky='w')
        
        # Add a separator
        ttk.Separator(self.root, orient='horizontal').grid(row=4, column=0, columnspan=10, sticky='we', padx=20, pady=20)
        
        
        # Create the "Upload" button
        self.upload_button = ttk.Button(self.root, text="Upload Files", 
                                        command=self.upload_files,
                                        style="Important.TButton")
        self.upload_button.grid(row=5, column=0, padx=5, pady=20, sticky='w')
        self.upload_label = tk.Label(self.root, text="", anchor='w')
        self.upload_label.grid(row=5, column=1, columnspan=4, padx=5, pady=20, sticky='w')
        
        
        
        # TIMESHEETS FILE
        tk.Label(self.root, text="Allocation Timesheets File").grid(row=6, column=0, padx=5, pady=5, sticky='w')
        
        
        # Create the "Select File" button and file path label
        self.select_timesheets_button = ttk.Button(self.root, text="Browse CSV", 
                                                  command=self.select_timesheets_file,
                                                  style="TButton")
        self.select_timesheets_button.grid(row=6, column=1, padx=5, pady=5, sticky='w')
    
        self.timesheets_label = tk.Label(self.root, text=" ", anchor='w', width=70)
        self.timesheets_label.grid(row=6, column=2, columnspan=4, padx=5, pady=5, sticky='w')
        
        
        # CONTRACTOR DETAILS
        tk.Label(self.root, text="Contractor Details File").grid(row=8, column=0, padx=5, pady=5, sticky='w')
        
        
        # Create the "Select File" button and file path label
        self.select_contractors_button = ttk.Button(self.root, text="Browse Excel", 
                                                  command=self.select_contractor_details,
                                                  style="TButton")
        self.select_contractors_button.grid(row=8, column=1, padx=5, pady=5, sticky='w')
    
        self.contractors_label = tk.Label(self.root, text=" ", anchor='w', width=70)
        self.contractors_label.grid(row=8, column=2, columnspan=4, padx=5, pady=5, sticky='w')
        
        
        # KEACH'S HR REPORT
        tk.Label(self.root, text="Keach HR File").grid(row=10, column=0, padx=5, pady=5, sticky='w')
        
        
        # Create the "Select File" button and file path label
        self.select_hr_button = ttk.Button(self.root, text="Browse Excel", 
                                                  command=self.select_keach_hr,
                                                  style="TButton")
        self.select_hr_button.grid(row=10, column=1, padx=5, pady=5, sticky='w')
    
        self.keach_hr_label = tk.Label(self.root, text=" ", anchor='w', width=70)
        self.keach_hr_label.grid(row=10, column=2, columnspan=4, padx=5, pady=5, sticky='w')
        
        
        # WORK ORDER DETAIL FOR APP
        tk.Label(self.root, text="Work Order Detail").grid(row=11, column=0, padx=5, pady=5, sticky='w')
        
        
        # Create the "Select File" button and file path label
        self.select_wo_detail_button = ttk.Button(self.root, text="Browse CSV", 
                                                  command=self.select_wo_detail,
                                                  style="TButton")
        self.select_wo_detail_button.grid(row=11, column=1, padx=5, pady=5, sticky='w')
    
        self.wo_detail_label = tk.Label(self.root, text=" ", anchor='w', width=70)
        self.wo_detail_label.grid(row=11, column=2, columnspan=4, padx=5, pady=5, sticky='w')
        
        
        # GL DATA FOR APP
        tk.Label(self.root, text="General Ledger (GL)").grid(row=12, column=0, padx=5, pady=5, sticky='w')
        
        # Create the "Select File" button and file path label
        self.select_gl_button = ttk.Button(self.root, text="Browse Excel", 
                                                  command=self.select_gl,
                                                  style="TButton")
        self.select_gl_button.grid(row=12, column=1, padx=5, pady=5, sticky='w')
    
        self.gl_label = tk.Label(self.root, text=" ", anchor='w', width=70)
        self.gl_label.grid(row=12, column=2, columnspan=4, padx=5, pady=5, sticky='w')
        
        
        
        # Start the application
        self.root.mainloop()
        
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
            
            
    def insert_dataframe_to_sql_server(self, df, schema, table, batch_size, truncate_table='N'):
        """
        Inserts a Pandas DataFrame into a SQL Server database table using a custom batch size.
        SQL Server is limited to only 1,000 rows at a time
    
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
        
        
        # Test the database connection with the entered username and password
        conn = self.connect_to_db()
        # Create a cursor
        cursor = conn.cursor()
        
        if truncate_table == 'Y':
            # Build & Execute SQL TRUNCATE statement
            truncate_query = f"TRUNCATE TABLE {schema}.{table};"
            cursor.execute(truncate_query)
            conn.commit()
            print('\nSUCCESS: "' + str(truncate_query) + '"\n')
            
            self.upload_label = tk.Label(self.root, text=f"{truncate_query}", anchor='w', width=100)
            self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.root.update()
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
                # print(sql)
                cursor.execute(sql)
                conn.commit()
                print('Successfully uploaded: ' + str(df_chunk_len) + ' record(s)')
            except Exception as e:
                print('Failed: '+ str(e))
                
            rows_inserted += df_chunk_len
            counter -= df_chunk_len
            info_label = f"For table {self.db_var.get()}.{schema}.{table}: {rows_inserted} of {df_len}"
            self.upload_label = tk.Label(self.root, text=f"{info_label}", anchor='w', width=100)
            self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.root.update()
            print('Records left: ' + str(counter) + ' Rows Inserted: ' + str(rows_inserted) + '\n')
            
        conn.close()

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
                
                
    def select_gl(self):
    
        self.gl_file_path = filedialog.askopenfilename(filetypes=[("Excel files", "*.xlsx;*.xls")])
        print(f"General Ledger (GL) File Path: {self.gl_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.gl_file_path:
            pass
        else:
            try:
                self.gl_label.config(text=self.gl_file_path)
            
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!") 
            

    def upload_files(self):
                
        try:
            
            if self.gl_file_path and os.path.isfile(self.gl_file_path):
                self.insert_dataframe_to_sql_server(self.excel_file_to_dataframe(self.gl_file_path, 
                                                                                skiprows=0, skipfooter=0, display_df='N'),
                                                   'staging', 'sap_general_ledger',
                                                   batch_size=1000, truncate_table='N')
                
            if self.timesheets_file_path and os.path.isfile(self.timesheets_file_path):
                self.insert_dataframe_to_sql_server(self.flat_file_to_dataframe(self.timesheets_file_path, 
                                                                                delim='|', display_df='N'),
                                                   'SHARE', 'BusPlanAllocationsTimesheets',
                                                   batch_size=1000, truncate_table='Y')
                
            if self.contractor_details_file_path and os.path.isfile(self.contractor_details_file_path):
                self.insert_dataframe_to_sql_server(self.excel_file_to_dataframe(self.contractor_details_file_path, 
                                                                                skiprows=1, skipfooter=3, display_df='N'),
                                                   'SHARE', 'BusPlanContractorDetails',
                                                   batch_size=1000, truncate_table='Y')
                
            if self.keach_hr_file_path and os.path.isfile(self.keach_hr_file_path):
                self.insert_dataframe_to_sql_server(self.excel_file_to_dataframe(self.keach_hr_file_path, 
                                                                                skiprows=0, skipfooter=0, display_df='N'),
                                                   'SHARE', 'BusPlanContractorActiveRpt',
                                                   batch_size=1000, truncate_table='Y')
                
            if self.wo_detail_file_path and os.path.isfile(self.wo_detail_file_path):
                self.insert_dataframe_to_sql_server(self.flat_file_to_dataframe(self.wo_detail_file_path, 
                                                                                delim='|', display_df='N'),
                                                   'staging', 'work_order_detail',
                                                   batch_size=1000, truncate_table='N')
                
            
                
            self.upload_label = tk.Label(self.root, text="Completed!", anchor='w', width=100)
            self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.root.update()
            
        except Exception as e:
            msg = str(e)
            print(f"Failed: {msg}")
            tk.messagebox.showerror("Error", f"There was an error! {msg}") 



if __name__ == '__main__':
    app = FileUploader()

# if __name__ == '__main__':
#     root = tk.Tk()
#     root.configure(bg="#FFFFFF")
#     # root.attributes('-topmost',True)
#     root.state('zoomed')
#     app = FileUploader(root)
#     root.mainloop()