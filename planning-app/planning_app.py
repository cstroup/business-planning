# -*- coding: utf-8 -*-
"""
Created on Sat Mar 25 15:19:12 2023

@author: P3098826

pip install ttkthemes

python -m PyInstaller -–onefile -–windowed --icon="bp-app.ico" --name="JANUS Forecasting Tool v#.#" --hidden-import pandas planning_app.py
"""

import pyodbc
import csv
import tkinter as tk
import tkinter.font as font
import datetime as dt
import pandas as pd
import math
import os
import datetime
import sys
from tkinter import ttk
from tkinter import Frame
from tkinter.filedialog import asksaveasfile
from tkinter import filedialog
import tkinter.font as tkFont

# import paramiko
# from paramiko import Transport, SFTPClient, RSAKey

# from ttkthemes import ThemedStyle

# import seaborn as sns
# import matplotlib.pyplot as plt
# from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

class App:
    
    
    def __init__(self, master):
        self.master = master
        self.database_name = "TEST" # Compiler | TEST | PLANNING_APP
        self.master.title(f"JANUS Forecasting Tool - {self.database_name}")
        self.master.geometry("1600x800")
        self.server_name = "business-planning-proxy.spectrumtoolbox.com"
        self.username = None
        self.password = None
        self.sort_column = None  # added attribute for sorting
        self.dropdown_values = None
        self.dropdown_value_keys = None
        # GL Filters
        self.filter_start_date = None
        self.filter_end_date = None
        self.filter_acct_number = None
        self.filter_po_number = None
        self.filter_dept_code = None
        self.filter_bu = None
        # Auto Tagger Filters
        self.tab2_filter_forecast_id = None
        self.tab2_filter_cc_code = None
        self.tab2_filter_account_code = None
        self.tab2_filter_po_number = None
        self.tab2_filter_co_code = None
        # Full Forecast Filters
        self.filter_year_forecast = None
        self.filter_dept_code_frcst = None
        self.filter_acct_number_frcst = None
        self.filter_mdt_frcst = None # main doc title
        self.filter_supplier_frcst = None
        self.filter_desc_frcst = None
        self.filter_po_frcst = None
        # Tab Frames
        self.tab_tagging = None
        self.tab_auto_tagger = None
        self.tab_full_forecast = None
        self.tab_add_work_orders = None
        self.tab_admin = None
        self.tab_1_table1_frame = None
        self.tab_1_table2_frame = None
        self.tab_2_table1_frame = None
        self.tab_3_table1_frame = None
        self.tab_3_table2_frame = None
        self.tab_4_table1_frame = None
        self.tab_4_bottom_table2_frame = None
        self.tab_4_bottom_left_top_half_frame = None
        self.tab_4_bottom_left_bottom_half_frame = None
        self.upload_frame = None
        # File Paths
        self.gl_file_path = None
        self.active_wo_file_path = None
        self.resources_forecast_bulk_label = None
        self.bulk_forecast_file_path = None
        self.resources_forecast_lineitems_bulk_label = None
        self.bulk_forecast_lineitems_file_path = None
        # Default Values 
        self.label_width = 17
        self.entry_width = 25
        self.dropdown_width = 10
        
        # views are used to show the data
        self.gl_view_name = '[dbo].[vw_general_ledger_full]' # [dbo].[vw_general_ledger_full] | [mart].[msa_GL_rawformat]
        self.forecast_view_name = '[dbo].[vw_forecast_full]' # [dbo].[vw_forecast_full] | [mart].[RollingF]
        self.forecast_line_items_view_name = '[dbo].[vw_forecast_line_items]'
        self.auto_tagger_view_name = '[dbo].[vw_auto_tagger_full]' # [dbo].[vw_auto_tagger_full] | [mart].[FCSTID_PO]
        
        # tables are used when updating/inserting/deleting data 
        self.gl_table = '[dbo].[general_ledger]' # [dbo].[general_ledger] | [mart].[msa_GL_rawformat]
        self.forecast_table = '[dbo].[forecast]' # [dbo].[forecast] | [mart].[RollingF]
        self.forecast_line_items_table = '[dbo].[forecast_line_item]'
        self.auto_tagger_table = '[dbo].[auto_tag]' # [dbo].[auto_tag] | [mart].[FCSTID_PO]
        self.user_table = '[dbo].[user]' # [dbo].[user] | [mart].[perm_user]

        # Set the default font style for all widgets in the application
        default_font = font.nametofont("TkDefaultFont")
        default_font.configure(family="Helvetica", size=9) # Helvetica | Calibri
        
        # Create a new font that adds bold style to the default font
        bold_font = default_font.copy()
        bold_font.configure(weight="bold")
        
        # Set the default font for all widgets
        self.master.option_add("*Font", default_font)

        # Create a style object for the notebook widget
        self.style = ttk.Style()
        self.style.theme_use('clam')  # clam | xpnative | vista | winnative | alt
        
        # Set the background color of the selected tab
        self.style.map("TNotebook.Tab", background=[("selected", "#DCDAD5"), ("!selected", "#f0f0f0")],
                       foreground=[("selected", "#000000"),("!selected", "#9C9C9C")],
                       expand=[("selected", [0, 0, 0, 3]), ("!selected", [0, 0, 0, 0])])
        
        # Button Styles
        self.style.configure('TButton', background = '#4A6984', foreground = 'white', width=25, 
                             borderwidth=3, focusthickness=3, focuscolor='none')
        self.style.map('TButton', background=[('active','#94adc3'), ('disabled', '#f0f0f0')])
        
        self.style.configure("Delete.TButton", background = '#7a0101', foreground = 'white', width=25, 
                             borderwidth=3, focusthickness=3, focuscolor='none')
        self.style.map('Delete.TButton', background=[('active','#b54343'), ('disabled', '#f0f0f0')])
        
        self.style.configure("Important.TButton", background = '#026c45', foreground = 'white', width=25, 
                             borderwidth=3, focusthickness=3, focuscolor='none')
        self.style.map('Important.TButton', background=[('active','#6fd6b0'), ('disabled', '#f0f0f0')])
        
        # Treeview Styles
        # self.style.configure("Treeview", padding=(20, 0), font=('Helvetica', 9))
        
        # Set the font size and padding for each tab
        self.style.configure('TNotebook.Tab', font=('TkDefaultFont', 11, 'bold'), padding=(10, 4))
        
        # create a custom style for the treeview
        self.style.configure('Treeview', rowheight=16, bordercolor='#d3d3d3')
        self.style.configure('Treeview.Heading', font=('Helvetica', 9, 'bold'))
        # self.style.configure('Treeview.Heading', font=('Helvetica', 10, 'bold'), bordercolor='#d3d3d3')
        # self.style.configure("Treeview.Vertical.TSeparator", background="#d9d9d9")
        
        # add the vertical gridlines to the treeview
        self.style.layout("Treeview", [("Treeview.treearea", {"sticky": "nswe"})])
        self.style.layout("Treeview.Item", [("Treeview.cell", {"sticky": "w"})])
        self.style.layout("Treeview.Item", [("Treeview.cell", {"sticky": "w", "border": "1"})])
        
        # Create a notebook widget
        self.notebook = ttk.Notebook(self.master)
        self.notebook.pack(fill='both', expand=True)
        

        # Create each tab/view as a separate frame
        self.tab1 = Frame(self.notebook, bg='#DCDAD5') # 4A6984 | FFFFFF
        self.notebook.add(self.tab1, text=" Login ")
        self.create_login_form()

        
        
    def connect_to_db(self):
        self.username = self.username_entry.get()
        self.password = self.password_entry.get()
        
        try:
            # Connect to the SQL Server database
            conn = pyodbc.connect(f'Driver={{SQL Server}};'
                                  f'Server={self.server_name};'
                                  f'Database={self.database_name};'
                                  f'UID={self.username};'
                                  f'PWD={self.password};')
            # print(conn)
            return conn
        except pyodbc.Error as e:
            msg = f"Error connecting to database: {e}"
            print('Failed: '+ str(msg))
            tk.messagebox.showerror("Error", f"Invalid username or password! {msg}")
        
        
        
    # Define the sorting function
    def treeview_sort_column(self, tree, col, reverse):
        l = [(tree.set(k, col), k) for k in tree.get_children('')]
        l.sort(reverse=reverse)
    
        for index, (val, k) in enumerate(l):
            tree.move(k, '', index)
    
        tree.heading(col, command=lambda: self.treeview_sort_column(tree, col, not reverse))
     
        
            
    def measure_width(self, value):
        # Get the default font
        font = tkFont.nametofont("TkDefaultFont")
        return font.measure(str(value))
    
    
    
    def format_cells(self, dtype_dict, col):
        if col in dtype_dict['int'] + dtype_dict['float'] + dtype_dict['date']:
            anchor = 'e'
            format_func = lambda x: '' if (pd.isna(x) or x is None) else x
        else:
            anchor = 'w'
            format_func = lambda x: '' if (pd.isna(x) or x is None) else x
        return anchor, format_func
    
    
    
    def format_float_column(self, column):
        formatted_column = column.apply(lambda x: f"({-1*x:,.2f})".replace(",", ".") if x < 0 else f"{x:,.2f}".replace(",", ".") if pd.notna(x) else '')
        return formatted_column



    def create_treeview_columns(self, treeview, dtype_dict, column_headers, rows):
        if not rows:
            return
        for col in column_headers:
            col_bytes_len = max([self.measure_width(row[col]) for row in rows]) + 30
            treeview.heading(col, text=col, command=lambda _col=col: \
                                 self.treeview_sort_column(treeview, _col, False))
            anchor, format_func = self.format_cells(dtype_dict, col)
            col_width = 100 if col_bytes_len < 100 else (300 if col_bytes_len > 300 else col_bytes_len)
            treeview.column(col, width=col_width, anchor=anchor, stretch=False)
    
    
    
    def return_query_into_dict(self, sql_query):      
        # Initialize dictionary with default entry
        final_dict = {'': 0}
    
        # Execute the query
        cursor = self.connect_to_db().cursor()
        cursor.execute(sql_query)
    
        # Fetch all rows from the last executed statement
        rows = cursor.fetchall()
    
        # Add entries from rows to dictionary
        for row in rows:
            final_dict[str(row[1])] = row[0]  # convert key to string
    
        return final_dict


    
    # def insert_dataframe_to_sql_server(self, df, schema, table, batch_size, truncate_table='N'):
    def flat_file_to_dataframe(self, directory, delim=',', display_df='N', encode='utf-8'):
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
        df = pd.read_csv(directory, delimiter=delim, header='infer',encoding=encode)
        
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



    def refresh_all_forecast_tables(self): 
        # self.refresh_all_forecast_tables()
        # run this function to refresh all forecast tables
        # TAB #1 BOTTOM TABLE
        self.create_forecast_table_tab_1()

        # TAB #3 TOP TABLE
        self.create_full_forecast_table_tab3()
        # TAB #3 BOTTOM TABLE
        self.create_forecast_line_item_table_tab3()

        # TAB #4 BOTTOM RIGHT TABLE
        self.create_filtered_forecast_table_tab_4()




    # using return_query_into_dict turn data points into a dropdown values
    # Keys are the textual string and Values are the ids from the tables
    # i.e. {'Business Unit': {'': 0, 'BI': 1000,}, 'Location': {'': 0, 'American Samoa': 1000, 'Argentina': 1001}
    def create_drop_down_values(self):
        self.dropdown_values = {}
        
        bu = "SELECT [business_unit_id], [business_unit] FROM [dbo].[vw_dropdown_business_unit] ORDER BY 2"
        self.dropdown_values['Business Unit'] = self.return_query_into_dict(bu)
        
        dept = "SELECT [department_id], [department] FROM [dbo].[vw_dropdown_department] ORDER BY 2"
        self.dropdown_values['Department'] = self.return_query_into_dict(dept)
        
        # employee = "SELECT [employee_id], [employee] FROM [dbo].[vw_dropdown_employee] ORDER BY 1"
        # self.dropdown_values['Employee'] = self.return_query_into_dict(employee)
        
        location = "SELECT [location_id], [location] FROM [dbo].[vw_dropdown_location] ORDER BY 2"
        self.dropdown_values['Location'] = self.return_query_into_dict(location)
        self.dropdown_values['Site'] = self.return_query_into_dict(location) # added cuz different headers
        
        work_type = "SELECT [work_type_id], [work_type] FROM [dbo].[vw_dropdown_work_type] ORDER BY 2"
        self.dropdown_values['Work Type'] = self.return_query_into_dict(work_type)
        
        ws = "SELECT [worker_status_id], [worker_status] FROM [dbo].[vw_dropdown_worker_status] ORDER BY 2"
        self.dropdown_values['Worker Status'] = self.return_query_into_dict(ws)
        
        woc = "SELECT [work_order_category_id], [work_order_category] FROM [dbo].[vw_dropdown_work_order_category] ORDER BY 2"
        self.dropdown_values['Work Order Category'] = self.return_query_into_dict(woc)
        
        ex = "SELECT [expense_classification_id], [expense_classification] FROM [dbo].[vw_dropdown_expense_classification] ORDER BY 2"
        self.dropdown_values['Expense Classification'] = self.return_query_into_dict(ex)
        
        seg = "SELECT [segmentation_id], [segmentation] FROM [dbo].[vw_dropdown_segmentation] ORDER BY 2"
        self.dropdown_values['Segmentation'] = self.return_query_into_dict(seg)
        
        plat = "SELECT [platform_id], [platform] FROM [dbo].[vw_dropdown_platform] ORDER BY 2"
        self.dropdown_values['Platform'] = self.return_query_into_dict(plat)
        
        fun = "SELECT [function_id], [function] FROM [dbo].[vw_dropdown_function] ORDER BY 2"
        self.dropdown_values['Function'] = self.return_query_into_dict(fun)
        
        ss = "SELECT [support_scalable_id], [support_scalable] FROM [dbo].[vw_dropdown_support_scalable] ORDER BY 2"
        self.dropdown_values['Support/Scalable'] = self.return_query_into_dict(ss)
        
        # coc = "SELECT [cost_object_code_id], [cost_object_code] FROM [dbo].[vw_dropdown_cost_object] ORDER BY 2"
        # self.dropdown_values['Cost Object Code'] = self.return_query_into_dict(coc)
        # maybe WBS Code?
        
        cc = "SELECT [company_code_id], [company_code] FROM [dbo].[vw_dropdown_company_code] ORDER BY 2"
        self.dropdown_values['Company Code'] = self.return_query_into_dict(cc)
        
        ccc = "SELECT [cost_center_code_id], [cost_center_code] FROM [dbo].[vw_dropdown_cost_center_code] ORDER BY 2"
        self.dropdown_values['Cost Center Code'] = self.return_query_into_dict(ccc)
        
        pro = "SELECT [project_id], [project] FROM [dbo].[vw_dropdown_project] ORDER BY 2"
        self.dropdown_values['Project'] = self.return_query_into_dict(pro)
        
        et = "SELECT [expense_type_id], [expense_type] FROM [dbo].[vw_dropdown_expense_type] ORDER BY 2"
        self.dropdown_values['Expense Type'] = self.return_query_into_dict(et)
        
        act = "SELECT [account_id], [account_code] FROM [dbo].[vw_dropdown_account] ORDER BY 2"
        self.dropdown_values['Account Code'] = self.return_query_into_dict(act)
        
        # record what options are available for the user
        conn = self.connect_to_db()
        cursor = conn.cursor()
        cursor.execute(f"""
        INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
        VALUES ('dropdown_values_available', '{str(self.dropdown_values).replace("'", "''")}')
        """)
        conn.commit()
        
        ## DON'T REALLY CARE ABOUT INSERTING DATES FOR AUDITING SINCE THEY ARE DUPLICATIVE
        
        date = "SELECT [date_id], [full_date] FROM [dbo].[vw_dropdown_date] ORDER BY 1"
        self.dropdown_values['Worker Start Date'] = self.return_query_into_dict(date)
        self.dropdown_values['Worker End Date'] = self.return_query_into_dict(date)
        self.dropdown_values['Override End Date'] = self.return_query_into_dict(date)
        self.dropdown_values['Journal Entry Date'] = self.return_query_into_dict(date)
        self.dropdown_values['Posting Date'] = self.return_query_into_dict(date)
        
        sdate = """
        SELECT [date_id], [full_date] 
        FROM [dbo].[vw_dropdown_date] 
        WHERE [full_date] >= DATEADD(day, -90, CURRENT_TIMESTAMP)
        AND [full_date] < DATEADD(day, -1, CURRENT_TIMESTAMP)
        ORDER BY 1
        """
        self.dropdown_values['GL Start Date'] = self.return_query_into_dict(sdate)
        
        edate = """
        SELECT [date_id], [full_date] 
        FROM [dbo].[vw_dropdown_date] 
        WHERE [full_date] >= DATEADD(day, -90, CURRENT_TIMESTAMP)
        AND [full_date] < CURRENT_TIMESTAMP
        ORDER BY 1
        """
        self.dropdown_values['GL End Date'] = self.return_query_into_dict(edate)
        
        years = "SELECT [calendar_year_id], [calendar_year] FROM [dbo].[vw_dropdown_years] ORDER BY 1"
        self.dropdown_values['Years'] = self.return_query_into_dict(years)
        
        months = "SELECT [month_id], [month_name] FROM [dbo].[vw_dropdown_months] ORDER BY 1"
        self.dropdown_values['Months'] = self.return_query_into_dict(months)
        
        # create a list of keys
        self.dropdown_value_keys = list(self.dropdown_values.keys())
        
        

    def create_login_form(self):
        # Create a login frame
        self.login_frame = Frame(self.tab1, bg='#f0f0f0', padx=50, pady=50) # bg='#FFFFFF'
        self.login_frame.pack(side='top', fill=None, expand=True)
        self.login_frame['width'] = 400
        self.login_frame['borderwidth'] = 2
        self.login_frame['relief'] = 'solid'
        
        # Add labels and entry boxes for the username and password fields
        username_label = ttk.Label(self.login_frame, text="Username", foreground='#000000', background=self.login_frame["background"])
        username_label.grid(row=0, column=0, pady=(40, 5), sticky="e")
        self.username_entry = ttk.Entry(self.login_frame)
        self.username_entry.grid(row=0, column=1, pady=(40, 5), padx=5)
        self.username_entry.bind('<Return>', self.authorize_login) # allow login on enter key press
    
        password_label = ttk.Label(self.login_frame, text="Password", foreground='#000000', background=self.login_frame["background"])
        password_label.grid(row=1, column=0, pady=(5, 40), sticky="e")
        self.password_entry = ttk.Entry(self.login_frame, show="*")
        self.password_entry.grid(row=1, column=1, pady=(5, 40), padx=5)
        self.password_entry.bind('<Return>', self.authorize_login) # allow login on enter key press
    
        # Create a button to submit the login form
        login_button = ttk.Button(self.login_frame, text="Login", command=self.authorize_login, width=15)
        login_button.grid(row=2, column=0, columnspan=2, pady=30)
        login_button.config(padding=(10,))
    
        # Add a label to display login
        self.login_label = ttk.Label(self.login_frame, text="", background="#f0f0f0", width=50, anchor='center')
        self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
        
        
        
    def authorize_login(self, event=None):
        # Get the username and password from the entry boxes
        self.username = self.username_entry.get()
        self.password = self.password_entry.get()
        
        # print(self.style.configure("Treeview"))
    
        print(f"USERNAME: {self.username} | {str(self.style)}")
        
        if self.tab_tagging is not None:
            self.tab_tagging.destroy()
        if self.tab_auto_tagger is not None:
            self.tab_auto_tagger.destroy()
        if self.tab_full_forecast is not None:
            self.tab_full_forecast.destroy()
        if self.tab_add_work_orders is not None:
            self.tab_add_work_orders.destroy()
        if self.tab_admin is not None:
            self.tab_admin.destroy()
    
        try:
            # min width for the labels describing what's going on
            min_width = 50
            
            self.login_label = ttk.Label(self.login_frame, text="Logging into Database...", background="#f0f0f0", width=min_width, anchor='center')
            self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
            self.login_frame.update()
            
            # Test the database connection with the entered username and password
            conn = self.connect_to_db()
            cursor = conn.cursor()
            query_user = f"""
            SELECT
             	is_admin
            FROM {self.user_table} 
            WHERE username = '{self.username}'
            """
            ## SELECT username, pid, is_admin
            print(query_user)
            
            cursor.execute(query_user)
            self.rows = cursor.fetchall()
            try:
                is_admin = self.rows[0][0] # change to whatever index
            except:
                return 0
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('login', 'username:{self.username}, is_admin: {is_admin}, style: {str(self.style)}')
            """)
            conn.commit()
            
            # Create the dictionary of all the drop-down values
            self.create_drop_down_values() 


            # # Tab #1 - Create GL and Forecast Tables
            # self.tab_tagging = ttk.Frame(self.notebook)
            # self.notebook.add(self.tab_tagging, text=" Tag GL/Forecast Data ")
            # self.login_label = ttk.Label(self.login_frame, text="Building tab 1 for GL tagging...", background="#f0f0f0", width=min_width, anchor='center')
            # self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
            # self.login_frame.update()
            # self.create_tagger_tab_tables()
            
            # # Tab #2
            # self.tab_auto_tagger = ttk.Frame(self.notebook)
            # self.notebook.add(self.tab_auto_tagger, text=" Auto Tagger ")
            # self.login_label = ttk.Label(self.login_frame, text="Building tab 2 for auto tagger...", background="#f0f0f0", width=min_width, anchor='center')
            # self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
            # self.login_frame.update()
            # self.create_auto_tagger_table()
            
            # # Tab #3
            # self.tab_full_forecast = ttk.Frame(self.notebook)
            # self.notebook.add(self.tab_full_forecast, text=" Edit Forecast Line Items ")
            # self.login_label = ttk.Label(self.login_frame, text="Building tab 3 for forecast line items...", background="#f0f0f0", width=min_width, anchor='center')
            # self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
            # self.login_frame.update()
            # self.create_full_forecast_table()
            
            # # Tab #4
            # self.tab_add_work_orders = ttk.Frame(self.notebook)
            # self.notebook.add(self.tab_add_work_orders, text=" Add Work Orders to Forecast ")
            # self.login_label = ttk.Label(self.login_frame, text="Building tab 4 for work orders...", background="#f0f0f0", width=min_width, anchor='center')
            # self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
            # self.login_frame.update()
            # self.create_new_work_order_tab()

            # Tab #5
            self.tab_resources = ttk.Frame(self.notebook)
            self.notebook.add(self.tab_resources, text=" Resources ")
            self.login_label = ttk.Label(self.login_frame, text="Building tab 5 for resources...", background="#f0f0f0", width=min_width, anchor='center')
            self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
            self.login_frame.update()
            self.create_resources_tab()
            
            # Tab Admin 
            if is_admin == 1:
                self.tab_admin = ttk.Frame(self.notebook)
                self.notebook.add(self.tab_admin, text=" Admin ")
                self.login_label = ttk.Label(self.login_frame, text="Building admin tab...", background="#f0f0f0", width=min_width, anchor='center')
                self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
                self.login_frame.update()
                self.create_admin_portal()

            # Hide the login tab and show the other tabs
            self.notebook.hide(self.tab1)
            
            
        # If the connection fails, display an error message
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            self.login_label = ttk.Label(self.login_frame, text=f"{msg}", background="#f0f0f0", width=min_width, anchor='center')
            self.login_label.grid(row=3, column=0, columnspan=2, pady=2, sticky='nsew')
            self.login_frame.update()
            tk.messagebox.showerror("Error", f"There was an error! {msg}")  
    
    
    
    #################
    ##### TAB 1 #####
    #################
    def create_tagger_tab_tables(self):
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        # TOP FRAME ON PAGE
        self.tab1_top_frame = Frame(self.tab_tagging, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab1_top_frame.pack(side='top', pady=5, fill='x', expand=False)
        
        # CREATE BUTTONS FRAME
        self.tab1_top_frame_buttons = Frame(self.tab1_top_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab1_top_frame_buttons.pack(side='top', pady=5, fill='x', expand=False)
        
        # Update Button
        update_gl_button = ttk.Button(self.tab1_top_frame_buttons, text="Update GL Record", command=self.open_update_window, state="disabled")
        update_gl_button.pack(side='left', padx=(15, 5), pady=5, anchor='w')
        self.update_gl_button = update_gl_button  # Store the button as an instance variable to access it later
        
        # Delete Button
        delete_gl_record_button = ttk.Button(self.tab1_top_frame_buttons, text="Delete GL Record", 
                                          command=self.delete_gl_record, state="disabled",
                                          style="Delete.TButton")
        delete_gl_record_button.pack(side='left', padx=50, pady=5, anchor='w')
        self.delete_gl_record_button = delete_gl_record_button

        # Start Date
        self.start_date_label = tk.Label(self.tab1_top_frame_buttons, text="JE Start Date:", bg='#DCDAD5')
        self.start_date_label.pack(side="left", padx=(10, 5), pady=5,)
        # get values from dict
        start_date_values = list(self.dropdown_values['GL Start Date'].keys())
        start_date = (dt.date.today() - dt.timedelta(days=30)).strftime('%m/%d/%Y')
        self.selected_gl_start_date = tk.StringVar(value=str(start_date))
        self.start_dropdown_gl = ttk.Combobox(self.tab1_top_frame_buttons, textvariable=self.selected_gl_start_date,
                                                  values=start_date_values, width=10)
        self.start_dropdown_gl.pack(side='left', padx=5, pady=10, anchor='w')
        self.filter_start_date = self.start_dropdown_gl.get()
         
        # End Date
        self.end_date_label = tk.Label(self.tab1_top_frame_buttons, text="JE End Date:", bg='#DCDAD5')
        self.end_date_label.pack(side="left", padx=(10, 5), pady=5,)
        # get values from dict
        end_date_values = list(self.dropdown_values['GL End Date'].keys())
        end_date = (dt.date.today()).strftime('%m/%d/%Y')
        self.selected_gl_end_date = tk.StringVar(value=str(end_date))
        self.end_dropdown_gl = ttk.Combobox(self.tab1_top_frame_buttons, textvariable=self.selected_gl_end_date,
                                                  values=end_date_values, width=10)
        self.end_dropdown_gl.pack(side='left', padx=5, pady=10, anchor='w')
        self.filter_end_date = self.end_dropdown_gl.get()

        # Refresh button
        refresh_button = ttk.Button(self.tab1_top_frame_buttons, text="Refresh GL Data", command=self.refresh_gl_forecast_tables_tab1)
        refresh_button.pack(side='left', padx=(15,5), pady=5, anchor='w')
        self.refresh_button = refresh_button
                
        # Export Button
        export_button = ttk.Button(self.tab1_top_frame_buttons, text="Export GL Data (csv)", command=self.export_csv_gl)
        export_button.pack(side='right', padx=5, pady=5, anchor='e')
        self.export_button = export_button
        
        # Last Updated Label
        query_gl_updated = """
        SELECT max_date FROM vw_general_ledger_last_upload
        """
        # print(query_gl_updated)
        cursor.execute(query_gl_updated)
        gl_update_results = cursor.fetchall()[0][0]
        self.gl_udpated_label = tk.Label(self.tab1_top_frame_buttons, text=f"Last Upload: {gl_update_results}", bg='#DCDAD5')
        self.gl_udpated_label.pack(side='right', padx=5, pady=5, anchor='e')
        
        
        # Create the filter frame
        self.tab1_top_frame_filters = Frame(self.tab1_top_frame, bg='#DCDAD5')
        self.tab1_top_frame_filters.pack(side='top', pady=5, fill='x', expand=False)
    
    
        # Add the filter inputs to the filter frame
        # Account Number
        self.tab1_account_number_label = tk.Label(self.tab1_top_frame_filters, text="Account Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab1_account_number_label.grid(row=0, column=0, padx=5, pady=5, sticky='w')
        # self.tab1_account_number_label.pack(side="left", padx=(10, 5), pady=5,)
        self.tab1_account_number_input = tk.Entry(self.tab1_top_frame_filters, width=20)
        self.tab1_account_number_input.grid(row=0, column=1, padx=5, pady=5, sticky='w')
        # self.tab1_account_number_input.pack(side="left", padx=(5, 15), pady=5,)
        self.filter_acct_number_gl = self.tab1_account_number_input.get()
        self.tab1_account_number_input.bind('<Return>', self.apply_gl_forecast_filters)
        
        # Purchase Order #
        self.tab1_purchase_order_label = tk.Label(self.tab1_top_frame_filters, text="Purchase Order #:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab1_purchase_order_label.grid(row=0, column=2, padx=5, pady=5, sticky='w') # pack(side="left", padx=(10, 5), pady=5,)
        self.tab1_purchase_order_input = tk.Entry(self.tab1_top_frame_filters, width=20)
        self.tab1_purchase_order_input.grid(row=0, column=3, padx=5, pady=5, sticky='w')# pack(side="left", padx=(5, 15), pady=5,)
        self.filter_po_number_gl = self.tab1_purchase_order_input.get()
        self.tab1_purchase_order_input.bind('<Return>', self.apply_gl_forecast_filters)
        
        # Department Code
        self.tab1_department_code_label = tk.Label(self.tab1_top_frame_filters, text="Department Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab1_department_code_label.grid(row=0, column=4, padx=5, pady=5, sticky='w') # pack(side="left", padx=(10, 5), pady=5,)
        self.tab1_department_code_input = tk.Entry(self.tab1_top_frame_filters, width=20)
        self.tab1_department_code_input.grid(row=0, column=5, padx=5, pady=5, sticky='w') # pack(side="left", padx=(5, 15), pady=5,)
        self.filter_dept_code_gl = self.tab1_department_code_input.get()
        self.tab1_department_code_input.bind('<Return>', self.apply_gl_forecast_filters)
        
        # Business Unit 
        # bu_keys = list(self.dropdown_values['Business Unit'].keys())
        # self.tab1_bu_label = tk.Label(self.tab1_top_frame_filters, text="Business Unit:", bg='#DCDAD5')
        # self.tab1_bu_label.pack(side="left", padx=(10, 5), pady=5,)
        # self.bu_var = tk.StringVar()
        # self.bu_var.set(bu_keys[0])
        # self.tab1_bu_dropdown = ttk.Combobox(self.tab1_top_frame_filters, textvariable=bu_keys, values=bu_keys, width=30, height=20)
        # self.tab1_bu_dropdown.pack(side="left", padx=(5, 15), pady=5,)
        # self.filter_bu_gl = self.bu_var.get()

        # Business Unit
        self.tab1_business_unit_label = tk.Label(self.tab1_top_frame_filters, text="Business Unit:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab1_business_unit_label.grid(row=0, column=6, padx=5, pady=5, sticky='w') # pack(side="left", padx=(10, 5), pady=5,)
        self.tab1_business_unit_input = tk.Entry(self.tab1_top_frame_filters, width=20)
        self.tab1_business_unit_input.grid(row=0, column=7, padx=5, pady=5, sticky='w') # pack(side="left", padx=(5, 15), pady=5,)
        self.filter_business_unit_gl = self.tab1_business_unit_input.get()
        self.tab1_business_unit_input.bind('<Return>', self.apply_gl_forecast_filters)


        # # Create 2nd level filter frame
        # self.tab1_top_frame_filters_2 = Frame(self.tab1_top_frame, bg='#DCDAD5')
        # self.tab1_top_frame_filters_2.pack(side='top', pady=5, fill='x', expand=False)

        
        # Header Text
        self.tab1_header_text_label = tk.Label(self.tab1_top_frame_filters, text="Header Text:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab1_header_text_label.grid(row=1, column=0, padx=5, pady=5, sticky='w') # pack(side="left", padx=(10, 5), pady=5,)
        self.tab1_header_text_input = tk.Entry(self.tab1_top_frame_filters, width=20)
        self.tab1_header_text_input.grid(row=1, column=1, padx=5, pady=5, sticky='w') # pack(side="left", padx=(5, 15), pady=5,)
        self.filter_header_text_gl = self.tab1_header_text_input.get()
        self.tab1_header_text_input.bind('<Return>', self.apply_gl_forecast_filters)
        
        # Item Text
        self.tab1_item_text_label = tk.Label(self.tab1_top_frame_filters, text="Item Text:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab1_item_text_label.grid(row=1, column=2, padx=5, pady=5, sticky='w') # pack(side="left", padx=(10, 5), pady=5,)
        self.tab1_item_text_input = tk.Entry(self.tab1_top_frame_filters, width=20)
        self.tab1_item_text_input.grid(row=1, column=3, padx=5, pady=5, sticky='w') # pack(side="left", padx=(5, 15), pady=5,)
        self.filter_item_text_gl = self.tab1_item_text_input.get()
        self.tab1_item_text_input.bind('<Return>', self.apply_gl_forecast_filters)
        
        # Cost Object Code
        self.tab1_cost_object_label = tk.Label(self.tab1_top_frame_filters, text="Cost Object Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab1_cost_object_label.grid(row=1, column=4, padx=5, pady=5, sticky='w') # pack(side="left", padx=(10, 5), pady=5,)
        self.tab1_cost_object_input = tk.Entry(self.tab1_top_frame_filters, width=20)
        self.tab1_cost_object_input.grid(row=1, column=5, padx=5, pady=5, sticky='w') # pack(side="left", padx=(5, 15), pady=5,)
        self.filter_cost_object_filter = self.tab1_cost_object_input.get()
        self.tab1_cost_object_input.bind('<Return>', self.apply_gl_forecast_filters)


        # CREATE BUTTONS FRAME
        self.tab1_apply_filters_frame = Frame(self.tab1_top_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab1_apply_filters_frame.pack(side='top', pady=5, fill='x', expand=False)


        # Apply Filters Button
        gl_apply_filter_button = ttk.Button(self.tab1_apply_filters_frame, text="Apply Filters", command=self.apply_gl_forecast_filters)
        gl_apply_filter_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.gl_apply_filter_button = gl_apply_filter_button

        gl_remove_filters_button = ttk.Button(self.tab1_apply_filters_frame, text="Clear Filters", command=self.gl_forecast_remove_all_filters)
        gl_remove_filters_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.gl_remove_filters_button = gl_remove_filters_button 

        
        ## BOTTOM HALF
        
        
        # create a frame at the bottom to hold buttons
        self.tab1_bottom_frame = Frame(self.tab_tagging, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab1_bottom_frame.pack(side='bottom', fill='both', expand=False, pady=5)
        
        # create filters frame within bottom
        self.tab1_bottom_frame_buttons = Frame(self.tab1_bottom_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab1_bottom_frame_buttons.pack(side='top', fill='both', expand=False, pady=5)
        
        
        # Add "Undo Filter" button
        undo_filter_button = ttk.Button(self.tab1_bottom_frame_buttons, text="Show All Items", 
                                        command=self.undo_forecast_filter) # , bg='#507DBC', fg='#FFFFFF', width=15)
        undo_filter_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.undo_filter_button = undo_filter_button
        
        # Insert Button
        insert_record_button = ttk.Button(self.tab1_bottom_frame_buttons, text="Quick Add from GL", 
                                          command=self.open_insert_forecast_from_gl_window, state="disabled")
        insert_record_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.insert_record_button = insert_record_button
        
        # Link Button
        link_button = ttk.Button(self.tab1_bottom_frame_buttons, text="Add to Auto Tagger", 
                                          command=self.add_gl_to_auto_tagger, state="disabled",
                                          style="Important.TButton")
        link_button.pack(side='left', padx=75, pady=5, anchor='w')
        self.link_button = link_button
    
        
        # CREATE TOP TABLE (GL TABLE)
        self.create_gl_table_tab_1()
      
        # CREATE BOTTOM TABLE (FORECAST TABLE)
        self.create_forecast_table_tab_1()
        
        
        
    # create top table for gl in tab 1 
    def create_gl_table_tab_1(self):
        if self.tab_1_table1_frame is not None:
            self.tab_1_table1_frame.destroy()
        
        # TABLE 1 (TOP TABLE) - FOR GL DATA
        # Create a frame for the first table and its scrollbars
        self.tab_1_table1_frame = Frame(self.tab_tagging) # bg='#FFFFFF'
        self.tab_1_table1_frame.pack(side='top', pady=(10,20), fill='both', expand=True)
        
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        # execute a SQL query to select data from a table
        query_gl = f"""
        SELECT
             [GL ID]
             ,[Forecast ID]
             ,[Auto Tagger ID]
             ,[Journal Entry Date]
             ,[Posting Date]
             ,[JE Type]
             ,[Assignment Ref]
             ,[Account Code]
             ,[Department]
             ,[Profit Center]
             ,[Cost Center Code]
             ,[Cost Object Code]
             ,[Project Type]
             ,[Project]
             ,[Project Name]
             ,[Supplier]
             ,[Expense Type]
             ,[Amount]
             ,[PO Number]
             ,[PO Composite]
             ,[Header Text]
             ,[Item Text]
             ,[Comment]
             ,[Journal Entry]
             ,[Journal Entry Item]
             ,[Journaly Entry Composite]
        FROM [dbo].[vw_general_ledger_full]
        WHERE [Journal Entry Date] BETWEEN '{self.filter_start_date}' AND '{self.filter_end_date}'
        ORDER BY [Journal Entry Date] DESC, [GL ID]
        """
        # AND CAST([Account Code] AS VARCHAR(250)) LIKE '{self.filter_acct_number}%'
        # AND CAST([PO Number] AS VARCHAR(250)) LIKE '{self.filter_po_number}%'
        # AND CAST([Department] AS VARCHAR(250)) LIKE '%{self.filter_dept_code}%'
    	# 	AND department_id IN (
    	# 		SELECT dbu.[department_id]
    	# 		FROM [dbo].[deptartment_business_unit] as dbu
    	# 		JOIN [dbo].[business_unit] as bu
    	# 			ON dbu.[business_unit_id] = bu.[business_unit_id]
    	# 		WHERE CAST([business_unit] AS VARCHAR(250)) LIKE '%{self.filter_bu}%'
    	# 		)
        
        print(query_gl)
        cursor.execute(query_gl)
        
        # fetch the column headers from the cursor description
        self.column_headers_gl = [column[0] for column in cursor.description]
        print(f"GL Columns: {self.column_headers_gl}")
        
        # create a list of dictionaries, each representing a row in the table
        self.rows_gl = [dict(zip(self.column_headers_gl, row)) for row in cursor.fetchall()]
        
        # apply data types to columns        
        self.dtype_dict_gl = {
            'int': ['GL ID', 'Forecast ID', 'Auto Tagger ID', 'Account Code', # 'Assignment Ref',
                    'Cost Center Code', 'PO Number', 'Journal Entry', 'Journal Entry Item'],
            'float': ['Amount'],
            'date': ['Journal Entry Date', 'Posting Date']
        }
        
        for col in self.column_headers_gl:
            if col in self.dtype_dict_gl['int']:
                for row in self.rows_gl:
                    row[col] = int(row[col]) if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_gl['float']:
                for row in self.rows_gl:
                    row[col] = f"{float(row[col]):.2f}" if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_gl['date']:
                for row in self.rows_gl:
                    row[col] = pd.to_datetime(row[col]).strftime('%m/%d/%Y') if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            else:
                for row in self.rows_gl:
                    row[col] = row[col] if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
        
        # create the treeview table
        self.tree_gl = ttk.Treeview(self.tab_1_table1_frame, columns=self.column_headers_gl,
                                          show='headings', selectmode="browse")
        self.tree_gl.column("#0", width=0, stretch='no')
        self.tree_gl.heading("#0", text='')
        
        # create treeview columns using the provided function
        self.create_treeview_columns(self.tree_gl, self.dtype_dict_gl, self.column_headers_gl, self.rows_gl)
    
        # create treeview rows
        for row in self.rows_gl:
            values = []
            for col in self.column_headers_gl:
                _, format_func = self.format_cells(self.dtype_dict_gl, col)
                values.append(format_func(row.get(col, "")))
            self.tree_gl.insert("", "end", values=values)
            
        ### SCROLLBARS    
        # Add vertical scrollbar to the first table in tab_1_table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_1_table1_frame)
        self.treeScroll.configure(command=self.tree_gl.yview)
        self.tree_gl.configure(yscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_1_table1_frame, side='right', fill='y')
        # Add horizontal scrollbar to the first table in tab_1_table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_1_table1_frame, orient='horizontal')
        self.treeScroll.configure(command=self.tree_gl.xview)
        self.tree_gl.configure(xscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_1_table1_frame, side='bottom', fill='x')
        self.tree_gl.pack(in_=self.tab_1_table1_frame, pady=(1, 0), fill='both', expand=True)
        # Add a binding for the horizontal scrollwheel event
        self.tree_gl.bind("<Shift-MouseWheel>", lambda event: self.tree_gl.xview_scroll(int(-1*(event.delta/5)), "units"))
        
        # this allows a gl row to filter the forecast table
        self.tree_gl.bind('<<TreeviewSelect>>', self.on_gl_row_select)
        
        
    
    # create bottom table for the forecast
    def create_forecast_table_tab_1(self):
        if self.tab_1_table2_frame is not None:
            self.tab_1_table2_frame.destroy()
            
        ### TABLE 2 (BOTTOM TABLE)
        # Create a frame for the second table and its scrollbars
        self.tab_1_table2_frame = Frame(self.tab1_bottom_frame) # bg='#FFFFFF'
        self.tab_1_table2_frame.pack(side='bottom', pady=10, fill='both', expand=False)
        
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        # execute a SQL query to select data from a table
        query_two = f"""
        SELECT
             [Forecast ID]
            ,[Company Code]
            ,[Business Unit]
            ,[Department]
            ,[Cost Center Code]
            ,[Department Leader]
            ,[Team Leader]
            ,[Business Owner]
            ,[Primary Contact]
            ,[Supplier]
            ,[Contractor]
            ,[Worker ID]
            ,[PID]
            ,[Worker Start Date]
            ,[Worker End Date]
            ,[Override End Date]
            ,[Main Document Title]
            ,[Cost Object Code]
            ,[Site]
            ,[Account Code]
            ,[Work Type]
            ,[Worker Status]
            ,[Work Order Category]
            ,[Expense Classification]
            ,[Budget Code]
            ,[Segmentation]
            ,[Platform]
            ,[Function]
            ,[Work Order ID]
            ,[Description]
            ,[Allocation]
            ,[Current Bill Rate (Hr)]
            ,[Current Bill Rate (Day)]
            ,[Comment]
        FROM [dbo].[vw_forecast_full]
        ORDER BY [Forecast ID] DESC
        """
        # WHERE CAST([Business Unit] AS VARCHAR(250)) LIKE '%{self.filter_bu}%'
        # AND CAST([Department] AS VARCHAR(250)) LIKE '%{self.filter_dept_code}%'
        
        print(query_two)
        cursor.execute(query_two)
        
        # fetch the column headers from the cursor description
        self.column_headers_forecast = [column[0] for column in cursor.description]
        print(f"Forecast Columns: {self.column_headers_forecast}")
        
        # create a list of dictionaries, each representing a row in the table
        self.rows_forecast = [dict(zip(self.column_headers_forecast, row)) for row in cursor.fetchall()]
        
        # apply data types to columns
        self.dtype_dict_forecast = {
            'int': ['Forecast ID', 'Company Code', 'Cost Center Code', 'Account Code'],
            'float': ['Allocation', 'Current', 'Current Bill Rate (Hr)', 'Current Bill Rate (Day)'],
            'date': ['Worker Start Date', 'Worker End Date', 'Override End Date']
        }
        
        for col in self.column_headers_forecast:
            if col in self.dtype_dict_forecast['int']:
                for row in self.rows_forecast:
                    row[col] = int(row[col]) if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_forecast['float']:
                for row in self.rows_forecast:
                    row[col] = f"({-1*float(row[col]):,.2f})".replace(",", ".") if row[col] and pd.notna(row[col]) and row[col] < 0 else f"{float(row[col]):,.2f}".replace(",", ".") if row[col] and pd.notna(row[col]) else ''
                    # row[col] = self.format_float_column(row[col])
                    # row[col] = f"{float(row[col]):.2f}" if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_forecast['date']:
                for row in self.rows_forecast:
                    row[col] = pd.to_datetime(row[col]).strftime('%m/%d/%Y') if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            else:
                for row in self.rows_forecast:
                    row[col] = row[col] if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
        
        
        # create the treeview table
        self.tree_forecast = ttk.Treeview(self.tab_1_table2_frame, columns=self.column_headers_forecast,
                                          show='headings', selectmode="browse")
        self.tree_forecast.column("#0", width=0, stretch='no')
        self.tree_forecast.heading("#0", text='')
        
        # create treeview columns using the provided function
        self.create_treeview_columns(self.tree_forecast, self.dtype_dict_forecast, 
                                     self.column_headers_forecast, self.rows_forecast)

        # create treeview rows
        for row in self.rows_forecast:
            values = []
            for col in self.column_headers_forecast:
                _, format_func = self.format_cells(self.dtype_dict_forecast, col)
                values.append(format_func(row.get(col, "")))
            self.tree_forecast.insert("", "end", values=values)
                        
        
        # Add vertical scrollbar to the second table in tab_1_table2_frame
        self.treeScroll2 = ttk.Scrollbar(self.tab_1_table2_frame)
        self.treeScroll2.configure(command=self.tree_forecast.yview)
        self.tree_forecast.configure(yscrollcommand=self.treeScroll2.set)
        self.treeScroll2.pack(in_=self.tab_1_table2_frame, side='right', fill='y')
        # Add horizontal scrollbar to the second table in tab_1_table2_frame
        self.treeScroll2 = ttk.Scrollbar(self.tab_1_table2_frame, orient='horizontal')
        self.treeScroll2.configure(command=self.tree_forecast.xview)
        self.tree_forecast.configure(xscrollcommand=self.treeScroll2.set)
        self.treeScroll2.pack(in_=self.tab_1_table2_frame, side='bottom', fill='x')
        self.tree_forecast.bind("<Shift-MouseWheel>", lambda event: self.tree_forecast.xview_scroll(int(-1*(event.delta/5)), "units"))
        # Repack the second table after setting the scrollbars
        self.tree_forecast.pack(in_=self.tab_1_table2_frame, pady=(1, 0), fill='both', expand=True)
        
        # this allows the forecast specific items to show
        self.tree_forecast.bind('<<TreeviewSelect>>', self.on_gl_and_forecast_row_select)
    
        
        
    # REFRESH GL and FORECAST DATA
    def refresh_gl_forecast_tables_tab1(self):
        try:
            self.filter_start_date = self.start_dropdown_gl.get()
            self.filter_end_date = self.end_dropdown_gl.get()
            # self.filter_acct_number = self.account_number_input.get()
            # self.filter_po_number = self.purchase_order_input.get()
            # self.filter_dept_code = self.department_code_input.get()
            # self.filter_bu = self.bu_var.get()
            
            # CREATE TOP TABLE (GL TABLE)
            self.create_gl_table_tab_1()
              
            # CREATE BOTTOM TABLE (FORECAST TABLE)
            self.create_forecast_table_tab_1()
            
            # unselect row and disable update/delete buttons
            self.selected_row = None
            self.delete_gl_record_button.config(state='disabled')
            self.update_gl_button.config(state='disabled')
            
            tk.messagebox.showinfo("Success", "Data refreshed successfully!")
        except Exception as e:
            print('Failed: '+ str(e))
            tk.messagebox.showerror("Error", "Data not successfully refreshed!")
            
            
            
    def open_update_window(self):
        item = self.tree_gl.focus()
        selected_row = self.tree_gl.item(item)['values']
        gl_id = selected_row[0]  # Replace with the index of the gl id
        jl_id = selected_row[25]  # Replace with the index of je and je item
        
        # screen_width = self.master.winfo_screenwidth() | screen_height = self.master.winfo_screenheight()
        self.update_window = tk.Toplevel(self.master)
        height = self.master.winfo_screenheight() - 100
        self.update_window.geometry(f"600x{height}+10+10")
        self.update_window.title(f"Update {jl_id} Record")
        
        # Create a canvas and add a scrollbar to it
        canvas = tk.Canvas(self.update_window)
        scrollbar = ttk.Scrollbar(self.update_window, orient="vertical", command=canvas.yview)
        scrollbar.pack(side="right", fill="y")
        canvas.pack(side="left", fill="both", expand=True)
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.bind('<Configure>', lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        
        inner_frame = tk.Frame(canvas)
        canvas.create_window((0, 0), window=inner_frame, anchor="nw")
        
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        query = f"""
        SELECT TOP 1
             [GL ID]
    		,[Forecast ID]
    		,[Auto Tagger ID]
    		,[Journal Entry Date]
    		,[Posting Date]
    		,[JE Type]
    		,[Assignment Ref]
    		,[Account Code]
    		,[Department]
    		,[Profit Center]
    		,[Cost Center Code]
    		,[Cost Object Code]
    		,[Project Type]
    		,[Project]
    		,[Project Name]
    		,[Supplier]
    		,[Expense Type]
    		,[Amount]
    		,[PO Number]
    		,[PO Composite]
    		,[Header Text]
    		,[Item Text]
    		,[Comment]
    		,[Journal Entry]
    		,[Journal Entry Item]
    		,[Journaly Entry Composite]
        FROM {self.gl_view_name} 
        WHERE [GL ID] = '{gl_id}'
        """
        print(query)
        cursor.execute(query)
        row = cursor.fetchone()
        # print(row)
        
        # fetch the column headers from the cursor description
        self.column_headers = [column[0] for column in cursor.description]
    
        # Create prepopulated text boxes
        entry_fields = []
        
        # self.dropdown_values
        # self.downdown_value_keys
                
        for i, (column_name, value) in enumerate(zip(self.column_headers, row)):
            label = ttk.Label(inner_frame, text=column_name, background='#F0F0F0')
            label.grid(row=i, column=0, padx=5, pady=5, sticky="w")
            
            if column_name == "Comment":
                entry = tk.Text(inner_frame, wrap='word', height=5, width=50)
                entry.insert('1.0', value or "")  # Insert value or empty string as placeholder text
            else:
                entry = ttk.Entry(inner_frame, width=50)
                entry.insert(0, value or "")  # Insert value or empty string as placeholder text
            
            entry.grid(row=i, column=1, padx=5, pady=5, sticky="w")
            # Only make certain inputs available
            if column_name == "Comment" or column_name == "Forecast ID": #  or column_name == "Date"
                inner_frame.grid_rowconfigure(i)
            else:
                entry.configure(state="disabled") # disable the rest
                
            entry_fields.append(entry)
        
        # Create a button to save the updates
        save_button = ttk.Button(inner_frame, text="Save", command=lambda: self.save_gl_updates(gl_id, entry_fields))
        save_button.grid(row=len(entry_fields), column=1, padx=5, pady=5, sticky="e")
        
        # Update the canvas scrollregion
        inner_frame.update_idletasks()
        canvas.configure(scrollregion=canvas.bbox("all"))
        
        
        
    def save_gl_updates(self, pk_id, entry_fields):
        conn = self.connect_to_db()
        cursor = conn.cursor()
        # Construct the update query to save GL Data
        gl_value = entry_fields[0].get() # gl id value
        frcst_value = entry_fields[1].get() or ''  # forcast value
        comment_value = entry_fields[22].get("1.0", 'end') # entry_fields[22].get() or '' # comment value 
        update_gl_query = f"""
        EXEC [dbo].[sp_update_record_general_ledger] '{gl_value}', '{frcst_value}', '{comment_value}'
        """
        print(update_gl_query)
        try:
            # Execute the update query
            cursor.execute(update_gl_query)
            conn.commit()
            
            # Close the update window
            self.update_window.destroy()
            
            # Refresh Data
            self.create_gl_table_tab_1()
            
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"The GL record has NOT been updated. {msg}")
            
            
    
    def delete_gl_record(self):
        item_gl = self.tree_gl.focus()
        selected_row_gl = self.tree_gl.item(item_gl)['values']
        gl_id = selected_row_gl[0]  # Replace 0 with the index of the pk
        print(f"DELETE GL RECORD: {gl_id}")
        
        if not gl_id:
            self.selected_row = None
            self.delete_gl_record_button.config(state='disabled')
        else:
            pass # move on
    
        # Ask for confirmation
        response = tk.messagebox.askyesno("Delete Record", "Are you sure you want to delete this record?")
        
        if response:
            try:
                conn = self.connect_to_db()
                cursor = conn.cursor()
                query = f"""
                UPDATE {self.gl_table} 
                SET [is_deleted] = 1 
                WHERE [general_ledger_id] = '{gl_id}'
                """ 
                print(query)
                cursor.execute(query)
                print(f"Executed DELETE Query for {gl_id}!")
                conn.commit()
        
                # Update the Treeview to remove the deleted row
                self.tree_gl.delete(self.tree_gl.selection())
        
                # Reset the selected_row
                self.selected_row = None
                self.delete_gl_record_button.config(state='disabled')
        
                # Show a message box with a confirmation message
                tk.messagebox.showinfo("Record Deleted", "The GL record {gl_id} has been deleted successfully.")
            except Exception as e:
                msg = str(e)
                print('Failed: '+ str(msg))
                tk.messagebox.showinfo("Failed", f"The GL record {gl_id} was NOT deleted. {msg}")
        
        
        
    # Get the data from the treeview and write it to a CSV file
    def export_csv_gl(self):
        current_date = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
        # Open a file dialog to let the user choose where to save the CSV file
        file_types = [('CSV files', '*.csv'), ('Text files', '*.txt'), ('All files', '*.*')]
        file_path = asksaveasfile(initialfile = f"gl_data_{current_date}.csv", 
                                  defaultextension=".csv", filetypes=file_types)
        if file_path:
            with open(file_path.name, 'w', newline='') as file:
                file_path = file_path.name # get the file path string
                # Open the file in write mode and create a CSV writer object
                writer = csv.writer(file)
                # Write the headers of the CSV file (column names)
                writer.writerow(self.column_headers_gl)
                # Write each row of the Treeview to the CSV file
                for row in self.tree_gl.get_children():
                    values = self.tree_gl.item(row)['values']
                    writer.writerow(values)
                    
            # Test the database connection with the entered username and password
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('export_csv_gl', '{file_path}')
            """)
            conn.commit()

    

    def apply_gl_forecast_filters(self, event=None):
        # Retrieve the values from the input fields
        acct_code = self.tab1_account_number_input.get().lower()
        po_num = self.tab1_purchase_order_input.get().lower()
        dept_code = self.tab1_department_code_input.get().lower()
        bu = self.tab1_business_unit_input.get().lower()
        header_text = self.tab1_header_text_input.get().lower()
        item_text = self.tab1_item_text_input.get().lower()
        cost_obj = self.tab1_cost_object_input.get().lower()
    
        # Filter the rows of GL table
        filtered_rows_gl = [
            row for row in self.rows_gl
            if (not acct_code or acct_code in str(row['Account Code']).lower()) and \
               (not po_num or po_num in str(row['PO Number']).lower()) and \
               (not dept_code or dept_code in str(row['Department']).lower()) and \
               # (not bu or bu in str(row['Business Unit']).lower()) and \
               (not header_text or dept_code in str(row['Header Text']).lower()) and \
               (not item_text or item_text in str(row['Item Text']).lower()) and \
               (not cost_obj or cost_obj in str(row['Cost Object Code']).lower())
        ]
    
        # Clear the existing rows in the full forecast table treeview
        for item in self.tree_gl.get_children():
            self.tree_gl.delete(item)
    
        # Add the filtered rows to the full forecast table treeview
        for row in filtered_rows_gl:
            values = [row.get(col, "") for col in self.column_headers_gl]
            self.tree_gl.insert("", "end", values=values)

        
        # Filter the rows of Forecast table
        filtered_rows_frcst = [
            row for row in self.rows_forecast
            if (not acct_code or acct_code in str(row['Account Code']).lower()) and \
               # (not po_num or po_num in str(row['PO Number']).lower()) and \
               (not dept_code or dept_code in str(row['Department']).lower()) and \
               (not bu or bu in str(row['Business Unit']).lower()) and \
               # (not header_text or dept_code in str(row['Header Text']).lower()) and \
               # (not item_text or item_text in str(row['Item Text']).lower()) and \
               (not cost_obj or cost_obj in str(row['Cost Object Code']).lower())
        ]
    
        # Clear the existing rows in the full forecast table treeview
        for item in self.tree_forecast.get_children():
            self.tree_forecast.delete(item)
    
        # Add the filtered rows to the full forecast table treeview
        for row in filtered_rows_frcst:
            values = [row.get(col, "") for col in self.column_headers_forecast]
            self.tree_forecast.insert("", "end", values=values)



    def gl_forecast_remove_all_filters(self):
        # Set all inputs to empty strings
        self.tab1_account_number_input.delete(0, 'end')
        self.tab1_purchase_order_input.delete(0, 'end')
        self.tab1_department_code_input.delete(0, 'end')
        self.tab1_business_unit_input.delete(0, 'end')
        self.tab1_header_text_input.delete(0, 'end')
        self.tab1_item_text_input.delete(0, 'end')
        self.tab1_cost_object_input.delete(0, 'end')
        
        # Re-call the apply filters
        self.apply_gl_forecast_filters()



    # this allows a row to be selected and filtered in the second table\
    # gl.Department Code = rf.Department of Hiring Manager Code, Account Code = Account Code
    def on_gl_row_select(self, event):
        # remove forecast selected row
        if self.tree_forecast.selection():
            self.tree_forecast.selection_remove(self.tree_forecast.selection()[0])
        
        item = self.tree_gl.focus()
        print(f"GL Item: {item}")
        print(f"GL Selected Row: {self.tree_gl.item(item)}")
        selected_row = self.tree_gl.item(item)['values']
        act_id = selected_row[7]  # Replace with index for Account Code (G/L Account)
        je_jei_id = selected_row[25]
        dept_id = selected_row[8]
        print(f"SELECTED GL ACCOUNT ID: {act_id} | {je_jei_id} | {dept_id}")
        
        self.update_gl_button.config(state="normal") # enable update button
        # self.delete_gl_record_button.config(state="normal") # enable delete button
        self.insert_record_button.config(state="normal") # enable open_insert_forecast_from_gl_window button
        
        # Filter the rows of the second treeview
        filtered_rows = [
            row for row in self.rows_forecast
            if row[self.column_headers_forecast[19]] == act_id
            and row[self.column_headers_forecast[3]] == dept_id
        ]
        
        # Clear the existing rows in treeview2
        for item in self.tree_forecast.get_children():
            self.tree_forecast.delete(item)
        
        # Add the filtered rows to treeview2
        for row in filtered_rows:
            values = [row.get(col, "") for col in self.column_headers_forecast]
            self.tree_forecast.insert("", "end", values=values)
        
        
        
    def undo_forecast_filter(self):
        # remove forecast selected row
        if self.tree_forecast.selection():
            self.tree_forecast.selection_remove(self.tree_forecast.selection()[0])
            
        # Clear the tree
        for i in self.tree_forecast.get_children():
            self.tree_forecast.delete(i)
    
        # Repopulate the tree with the original data
        for row in self.rows_forecast:
            values = []
            for col in self.column_headers_forecast:
                _, format_func = self.format_cells(self.dtype_dict_forecast, col)
                values.append(format_func(row.get(col, "")))
            self.tree_forecast.insert("", "end", values=values)
        
        
        
    # need to make these have drop-downs
    # gather some information from the gl and pre-populate the forecast item
    def open_insert_forecast_from_gl_window(self):     
        try:
            # print(self.dropdown_values, '\n')
            # print(self.dropdown_value_keys, '\n')
            
            item = self.tree_gl.focus()
            selected_row = self.tree_gl.item(item)['values']
            gl_id = selected_row[0]  # Replace with the index of the gl id
            # jl_id = selected_row[25]  # Replace with the index of je and je item
            
            # screen_width = self.master.winfo_screenwidth() | screen_height = self.master.winfo_screenheight()
            self.insert_forecast_window = tk.Toplevel(self.master)
            height = self.master.winfo_screenheight() - 100
            self.insert_forecast_window.geometry(f"600x{height}+10+10")
            self.insert_forecast_window.title(f"Create New Forecast Record from GL: {gl_id}")
            
            # Create a canvas and add a scrollbar to it
            canvas = tk.Canvas(self.insert_forecast_window)
            scrollbar = ttk.Scrollbar(self.insert_forecast_window, orient="vertical", command=canvas.yview)
            scrollbar.pack(side="right", fill="y")
            canvas.pack(side="left", fill="both", expand=True)
            canvas.configure(yscrollcommand=scrollbar.set)
            canvas.bind('<Configure>', lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
            
            inner_frame = tk.Frame(canvas)
            canvas.create_window((0, 0), window=inner_frame, anchor="nw")
            
            # Bind the scrollwheel event to the canvas
            canvas.bind_all('<MouseWheel>', lambda event: canvas.yview_scroll(int(-1*(event.delta/120)), "units"))
            
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            query = f"""
            EXEC [dbo].[sp_select_gl_from_forecast] {gl_id};
            """
            print(query)
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('open_insert_forecast_from_gl_window', '{query}')
            """)
            conn.commit()
            cursor.execute(query)
            row = cursor.fetchone()
            # print(row)
            
            # fetch the column headers from the cursor description
            self.forecast_insert_column_headers = [column[0] for column in cursor.description]
            
            editable_fields = ['Comment', 'Business Unit', 'Department Leader', 'Team Leader',
                               'Business Owner', 'Primary Contact', 'Contractor', 'Worker ID',
                               'PID', 'Worker Start Date', 'Worker End Date', 'Override End Date',
                               'Main Document Title', 'Location', 'Work Type','Worker Status', 
                               'Work Order Category', 'Expense Classification', 'Budget Code',
                               'Segmentation', 'Platform', 'Function', 'Support/Scalable', 'Work Order ID',
                               'Allocation', 'Current Bill Rate (Hr)', 'Current Bill Rate (Day)']
        
            # Create prepopulated text boxes
            entry_fields = []
                    
            for i, (column_name, value) in enumerate(zip(self.forecast_insert_column_headers, row)):
                label = ttk.Label(inner_frame, text=column_name, background='#F0F0F0')
                label.grid(row=i, column=0, padx=5, pady=5, sticky="w")
                
                # big text field for comments
                if column_name == "Comment":
                    entry = tk.Text(inner_frame, wrap='word', height=5, width=50)
                    entry.insert('1.0', value or "")  # Insert value or empty string as placeholder text
                
                # values from dropdown_value_keys dictionary
                # only show dropdowns for editible fields, otherwise show a disabled input text field
                elif column_name in self.dropdown_value_keys and column_name in editable_fields:
                    keys = [str(key) for key in self.dropdown_values[column_name].keys()]
                    if str(value) in keys:
                        default_value = str(value)
                    else:
                        default_value = keys[0] if keys else ''
                    entry = ttk.Combobox(inner_frame, values=keys, width=40, height=20)  # don't use var as the textvariable
                    entry.set(default_value)  # set the Combobox value directly
                    
                # default to input fields
                else:
                    entry = ttk.Entry(inner_frame, width=50)
                    entry.insert(0, value or "")  # Insert value or empty string as placeholder text
                
                entry.grid(row=i, column=1, padx=5, pady=5, sticky="w")
                # Only make certain inputs available
                if column_name in editable_fields: # in the editable fields list
                    inner_frame.grid_rowconfigure(i)
                else:
                    entry.configure(state="disabled") # disable the rest
                    
                entry_fields.append(entry)
            
            # Create a button to save the updates
            save_button = ttk.Button(inner_frame, text="Save", command=lambda: self.save_insert_forecast_data(gl_id, entry_fields))
            save_button.grid(row=len(entry_fields), column=1, padx=5, pady=5, sticky="e")
            
            # Update the canvas scrollregion
            inner_frame.update_idletasks()
            canvas.configure(scrollregion=canvas.bbox("all"))
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
    
    
    
    def save_insert_forecast_data(self, gl_id, entry_fields):       
        comment_value = entry_fields[14].get("1.0", tk.END).strip().replace("'", "''") or '' # comment value 
        bu_value = self.dropdown_values['Business Unit'][entry_fields[15].get()] # entry_fields[15].get() or '' # business unit value
        department_leader_value = entry_fields[16].get().replace("'", "''") or ''
        team_leader_value = entry_fields[17].get().replace("'", "''") or ''
        business_owner_value = entry_fields[18].get().replace("'", "''") or ''
        primary_contact_value = entry_fields[19].get().replace("'", "''") or ''
        contractor_value = entry_fields[20].get().replace("'", "''") or ''
        worker_id_value = entry_fields[21].get().replace("'", "''") or ''
        pid_value = entry_fields[22].get().replace("'", "''") or ''
        worker_start_date = entry_fields[23].get().replace("'", "''") or ''
        worker_end_date = entry_fields[24].get().replace("'", "''") or ''
        override_end_date = entry_fields[25].get().replace("'", "''") or ''
        main_doc_title_value = entry_fields[26].get().replace("'", "''") or ''
        site_value =  self.dropdown_values['Location'][entry_fields[27].get()]
        work_type_value = self.dropdown_values['Work Type'][entry_fields[28].get()]
        worker_status_value = self.dropdown_values['Worker Status'][entry_fields[29].get()]
        work_order_category_value = self.dropdown_values['Work Order Category'][entry_fields[30].get()]
        expense_class_value = self.dropdown_values['Expense Classification'][entry_fields[31].get()]
        budget_code_value = entry_fields[32].get().replace("'", "''") or ''
        segmentation_value = self.dropdown_values['Segmentation'][entry_fields[33].get()]
        platform_value = self.dropdown_values['Platform'][entry_fields[34].get()]
        function_value = self.dropdown_values['Function'][entry_fields[35].get()]
        support_scalable = self.dropdown_values['Support/Scalable'][entry_fields[36].get()]
        work_order_id_value = entry_fields[37].get().replace("'", "''") or ''
        allocation_value = entry_fields[38].get().replace("'", "''") or ''
        current_br_hr_value = entry_fields[39].get().replace("'", "''") or ''
        current_br_day_value = entry_fields[40].get().replace("'", "''") or ''
    
        try:
            # Create connection
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            # need to add 
            query = f"""
            EXEC [dbo].[sp_insert_forecast_from_gl] 
                 {gl_id}, -- gl_id
                '{comment_value}', -- comment
                '{bu_value}', -- bu
                '{department_leader_value}', -- department leader
                '{team_leader_value}', -- team leader
                '{business_owner_value}', -- business owner
                '{primary_contact_value}', -- primary contact
                '{contractor_value}', -- contractor
                '{worker_id_value}', -- worker id
                '{pid_value}', -- pid
                '{worker_start_date}', -- start date
                '{worker_end_date}', -- end date 
                '{override_end_date}', -- override date
                '{main_doc_title_value}', -- main doc
                '{site_value}', -- location/site
                '{work_type_value}', -- work type
                '{worker_status_value}', -- worker status
                '{work_order_category_value}', -- work order category
                '{expense_class_value}', -- expense class
                '{budget_code_value}', -- budget code
                '{segmentation_value}', -- segmentation
                '{platform_value}', -- platform
                '{function_value}', -- function
                '{support_scalable}', -- support/scalable
                '{work_order_id_value}', -- work order id 
                '{allocation_value}', -- allocation
                '{current_br_hr_value}', -- bill rate hr
                '{current_br_day_value}' -- bill rate day
            """
            print(query)
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('save_insert_forecast_data', '{str(query).replace("'", "''")}')
            """)
            conn.commit()
        
            # Insert the record into the database
            cursor.execute(query)
            conn.commit()
            
            # Close the update window
            self.insert_forecast_window.destroy()

            self.create_gl_table_tab_1() # Refresh GL Data
            self.refresh_all_forecast_tables() # Refresh all forecast tables
            self.create_tagger_table_tab_2() # Refresh auto tagger data
            
            tk.messagebox.showinfo("Success", "Record added successfully!")
            
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
            
            
            
    # this allows the auto tagger button to appear
    def on_gl_and_forecast_row_select(self, event):
        if self.tree_forecast.focus() is None:
            pass
        else:
            item_forcast = self.tree_forecast.focus()
            forecast_row = self.tree_forecast.item(item_forcast)['values']
            forecast_id = forecast_row[0]  # Replace with index of Primary Key
            # account_id = forecast_row[25]  # Replace with index of Primary Key
            print(f"SELECTED FORECAST ID: {forecast_id}") #  | ACCT CODE: {account_id}")
            self.link_button.config(state="normal") # enable "LINK" button
    
    
    
    def add_gl_to_auto_tagger(self):
        item_gl = self.tree_gl.focus()
        item_forcast = self.tree_forecast.focus()
        
        gl_row = self.tree_gl.item(item_gl)['values']
        forecast_row = self.tree_forecast.item(item_forcast)['values']
        
        gl_id = str(gl_row[0])  # Replace with index of primary key
        gl_po = str(gl_row[18])  # Replace with index of po #
        gl_po_comp = str(gl_row[19]) # this is the original po composite  
        gl_co_code = str(gl_row[11]) # Replace with index for cost ojbect code
        gl_po_coc_comp = f"{gl_po}-{gl_co_code}" # this is the cost object and po composite  
        forecast_id = int(forecast_row[0])  # Replace with index of Primary Key
        print(f"GL PO Comp: {gl_po_comp} | GL PO/Cost Comp: {gl_po_coc_comp} | FORECAST ID: {forecast_id}")
        
        conn = self.connect_to_db()
        cursor = conn.cursor()
        query = f"""
        EXEC [dbo].[sp_insert_record_auto_tag] {gl_id}, {forecast_id}
        """ 
        print(query)
        try:
            cursor.execute(query)
            print("Executed INSERT for autotagger!")
            conn.commit()

        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"The record has NOT been added to the autotagger. {msg}")
            
        try:
            # CREATE TOP TABLE (GL TABLE)
            self.create_gl_table_tab_1()
            
            # CREATE AUTO TAG TABLE
            self.create_tagger_table_tab_2()
            
            # unselect row and disable update/delete buttons
            self.selected_row = None
            self.update_gl_button.config(state='disabled')
            self.delete_gl_record_button.config(state='disabled')
            self.link_button.config(state='disabled')
            self.insert_record_button.config(state='disabled')
            tk.messagebox.showinfo("Success", "The record has been added to the autotagger and the GL has been updated!")
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Failed to return updated GL and Forecast Data. {msg}")
        
        
        
    #################
    ##### TAB 2 #####
    #################
    def create_auto_tagger_table(self):
        # TOP FRAME ON PAGE
        self.tab2_top_frame = Frame(self.tab_auto_tagger, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab2_top_frame.pack(side='top', pady=5, fill='x', expand=False)
        
        # CREATE BUTTONS FRAME
        self.tab2_button_frame = Frame(self.tab2_top_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab2_button_frame.pack(side='top', pady=5, fill='x', expand=False)
        
        # Refresh button
        refresh_button_at = ttk.Button(self.tab2_button_frame, text="Refresh Auto Tagger", 
                                       command=self.refresh_autotagger_tab2) # , bg='#507DBC', fg='#FFFFFF', width=15)
        refresh_button_at.pack(side='left', padx=5, pady=5, anchor='w')
        self.refresh_button_at = refresh_button_at
        
        # Edit button
        edit_button_at = ttk.Button(self.tab2_button_frame, text="Edit Record", 
                                       command=self.refresh_autotagger_tab2, state="disabled")
        edit_button_at.pack(side='left', padx=5, pady=5, anchor='w')
        self.edit_button_at = edit_button_at
        
        # Delete Button
        delete_auto_tagger_record_button = ttk.Button(self.tab2_button_frame, text="Delete Tagger Record", 
                                          command=self.delete_auto_tagger_record, state="disabled",
                                          style="Delete.TButton")
        delete_auto_tagger_record_button.pack(side='left', padx=75, pady=5, anchor='w')
        self.delete_auto_tagger_record_button = delete_auto_tagger_record_button
        
        
        # Create the filter frame
        self.tab2_filters_frame = Frame(self.tab2_top_frame, bg='#DCDAD5')
        self.tab2_filters_frame.pack(side='top', pady=5, fill='x', expand=False)

        # Forecast ID
        self.tab2_forecast_id_label = tk.Label(self.tab2_filters_frame, text="Forecast ID:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab2_forecast_id_label.grid(row=0, column=0, padx=5, pady=5, sticky='w')
        self.tab2_forecast_id_input = tk.Entry(self.tab2_filters_frame, width=20)
        self.tab2_forecast_id_input.grid(row=0, column=1, padx=5, pady=5, sticky='w')
        self.tab2_filter_forecast_id = self.tab2_forecast_id_input.get()
        self.tab2_forecast_id_input.bind('<Return>', self.apply_auto_tagger_filters)

        # Cost Center Code
        self.tab2_cc_code_label = tk.Label(self.tab2_filters_frame, text="Cost Center Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab2_cc_code_label.grid(row=0, column=2, padx=5, pady=5, sticky='w')
        self.tab2_cc_code_input = tk.Entry(self.tab2_filters_frame, width=20)
        self.tab2_cc_code_input.grid(row=0, column=3, padx=5, pady=5, sticky='w')
        self.tab2_filter_cc_code = self.tab2_cc_code_input.get()
        self.tab2_cc_code_input.bind('<Return>', self.apply_auto_tagger_filters)
        
        # Account Code
        self.tab2_account_code_label = tk.Label(self.tab2_filters_frame, text="Account Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab2_account_code_label.grid(row=0, column=4, padx=5, pady=5, sticky='w')
        self.tab2_account_code_input = tk.Entry(self.tab2_filters_frame, width=20)
        self.tab2_account_code_input.grid(row=0, column=5, padx=5, pady=5, sticky='w')
        self.tab2_filter_account_code = self.tab2_account_code_input.get()
        self.tab2_account_code_input.bind('<Return>', self.apply_auto_tagger_filters)

        # Purchase Order #
        self.tab2_purchase_order_label = tk.Label(self.tab2_filters_frame, text="Purchase Order #:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab2_purchase_order_label.grid(row=1, column=0, padx=5, pady=5, sticky='w')
        self.tab2_purchase_order_input = tk.Entry(self.tab2_filters_frame, width=20)
        self.tab2_purchase_order_input.grid(row=1, column=1, padx=5, pady=5, sticky='w')
        self.tab2_filter_po_number = self.tab2_purchase_order_input.get()
        self.tab2_purchase_order_input.bind('<Return>', self.apply_auto_tagger_filters)

        # Cost Object Code
        self.tab2_co_code_label = tk.Label(self.tab2_filters_frame, text="Cost Object Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab2_co_code_label.grid(row=1, column=2, padx=5, pady=5, sticky='w')
        self.tab2_co_code_input = tk.Entry(self.tab2_filters_frame, width=20)
        self.tab2_co_code_input.grid(row=1, column=3, padx=5, pady=5, sticky='w')
        self.tab2_filter_co_code = self.tab2_co_code_input.get()
        self.tab2_co_code_input.bind('<Return>', self.apply_auto_tagger_filters)
        

        # Create the filter frame
        self.tab2_apply_filters_frame = Frame(self.tab2_top_frame, bg='#DCDAD5')
        self.tab2_apply_filters_frame.pack(side='top', pady=5, fill='x', expand=False)


        # Apply Filters Button
        tagger_apply_filter_button = ttk.Button(self.tab2_apply_filters_frame, text="Apply Filters", command=self.apply_auto_tagger_filters)
        tagger_apply_filter_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.tagger_apply_filter_button = tagger_apply_filter_button

        # Clear Filters Button
        tagger_clear_filter_button = ttk.Button(self.tab2_apply_filters_frame, text="Clear Filters", command=self.tagger_remove_all_filters)
        tagger_clear_filter_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.tagger_clear_filter_button = tagger_clear_filter_button
        
        # Create the table
        self.create_tagger_table_tab_2()
        

        
    def create_tagger_table_tab_2(self):
        if self.tab_2_table1_frame is not None:
            self.tab_2_table1_frame.destroy()
            
        self.tab_2_table1_frame = Frame(self.tab_auto_tagger, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_2_table1_frame.pack(side='top', pady=5, fill='both', expand=True)
            
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
            
        # execute a SQL query to select data from a table
        query_autotagger = f"""
        SELECT
             [Auto Tag ID]
            ,[Forecast ID]
            ,[Cost Center Code]
            ,[Account Code]
            ,[Purchase Order Number]
            ,[Cost Object Code]
            ,[PO Composite]
            ,[PO/Cost Object Composite]
        FROM {self.auto_tagger_view_name} 
        ORDER BY 1 DESC
        """
        print(query_autotagger)
        cursor.execute(query_autotagger)
        
        # fetch the column headers from the cursor description
        self.column_headers_auto_tagger = [column[0] for column in cursor.description]
        print(f"Auto Tagger Columns: {self.column_headers_auto_tagger}\n")
        
        # create a list of dictionaries, each representing a row in the table
        self.rows_auto_tagger = [dict(zip(self.column_headers_auto_tagger, row)) for row in cursor.fetchall()]
        
        # print(self.rows_auto_tagger[:10])
        
        # apply data types to columns
        self.dtype_dict_auto_tagger = {
            'int': ['Auto Tag ID', 'Forecast ID', 'Cost Center Code', 'Account Code', 'Purchase Order Number'],
            'float': [],
            'date': []
        }
        
        for col in self.column_headers_auto_tagger:
            if col in self.dtype_dict_auto_tagger['int']:
                for row in self.rows_auto_tagger:
                    row[col] = int(row[col]) if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_auto_tagger['float']:
                for row in self.rows_auto_tagger:
                    row[col] = f"{float(row[col]):.2f}" if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_auto_tagger['date']:
                for row in self.rows_auto_tagger:
                    row[col] = pd.to_datetime(row[col]).strftime('%m/%d/%Y') if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            else:
                for row in self.rows_auto_tagger:
                    row[col] = row[col] if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''

        # create the treeview table
        self.tree_auto_tagger = ttk.Treeview(self.tab_2_table1_frame, columns=self.column_headers_auto_tagger,
                                          show='headings', selectmode="browse")
        self.tree_auto_tagger.column("#0", width=0, stretch='no')
        self.tree_auto_tagger.heading("#0", text='')
  
        
        # create treeview columns using the provided function
        self.create_treeview_columns(self.tree_auto_tagger, self.dtype_dict_auto_tagger, 
                                     self.column_headers_auto_tagger, self.rows_auto_tagger)
        

        # create treeview rows
        for row in self.rows_auto_tagger:
            values = []
            for col in self.column_headers_auto_tagger:
                _, format_func = self.format_cells(self.dtype_dict_auto_tagger, col)
                values.append(format_func(row.get(col, "")))
            self.tree_auto_tagger.insert("", "end", values=values)
        
        
        ### SCROLLBARS    
        # Add vertical scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_2_table1_frame)
        self.treeScroll.configure(command=self.tree_auto_tagger.yview)
        self.tree_auto_tagger.configure(yscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_2_table1_frame, side='right', fill='y')
        # Add horizontal scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_2_table1_frame, orient='horizontal')
        self.treeScroll.configure(command=self.tree_auto_tagger.xview)
        self.tree_auto_tagger.configure(xscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_2_table1_frame, side='bottom', fill='x')
        self.tree_auto_tagger.pack(in_=self.tab_2_table1_frame, pady=(1, 0), fill='both', expand=True)
        self.tree_auto_tagger.bind("<Shift-MouseWheel>", lambda event: self.tree_auto_tagger.xview_scroll(int(-1*(event.delta/5)), "units"))
        
        # this allows the delete button to appear after a row is selected
        self.tree_auto_tagger.bind('<<TreeviewSelect>>', self.on_auto_tagger_row_select)
        
        
        
    # REFRESH DATA
    def refresh_autotagger_tab2(self):
        try:
            # call funtion to create tagger table
            self.create_tagger_table_tab_2()
            
            self.at_row = None
            self.delete_auto_tagger_record_button.config(state='disabled')
            
            tk.messagebox.showinfo("Success", "Auto Tagger data refreshed successfully!")
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Auto Tagger NOT refreshed! {msg}")
        
        
        
    # this allows the auto tagger delete button to appear
    def on_auto_tagger_row_select(self, event):
        self.item_at = self.tree_auto_tagger.focus() ## at short for auto tagger
        at_row = self.tree_auto_tagger.item(self.item_at)['values']
        at_id = at_row[0]  # Replace with the index of the primary key column
        print(f"SELECTED AUTO TAGGER ID: {at_id}")
        self.delete_auto_tagger_record_button.config(state="normal") # enable "DELETE" button
        
        
        
    def delete_auto_tagger_record(self):
        self.item_at = self.tree_auto_tagger.focus() # at short for auto tagger
        at_row = self.tree_auto_tagger.item(self.item_at)['values']
        at_id = at_row[0]  # Replace with the index of the primary key column
        
        if not at_id:
            self.delete_auto_tagger_record_button.config(state='disabled')
        else:
            pass # move on
    
        # Ask for confirmation
        response = tk.messagebox.askyesno("Delete Record", "Are you sure you want to delete this record?\n\nThis will also remove all references in the GL!")
        
        if response:
            try:
                conn = self.connect_to_db()
                cursor = conn.cursor()
                query = f"""
                EXEC [dbo].[sp_delete_record_auto_tag] {at_id}
                """ 
                print(query)
                cursor.execute(query)
                print(f"Executed DELETE Stored Proc for {at_id}!")
                conn.commit()
        
                # Update the Treeview to remove the deleted row
                self.tree_auto_tagger.delete(self.tree_auto_tagger.selection())
        
                # Reset the selected_row
                self.delete_auto_tagger_record_button.config(state='disabled')
                
                # CREATE TOP TABLE (GL TABLE)
                self.create_gl_table_tab_1()
        
                # Show a message box with a confirmation message
                tk.messagebox.showinfo("Record Deleted", f"The Auto Tag record {at_id} has been deleted successfully.")
                
            except Exception as e:
                msg = str(e)
                print('Failed: '+ str(msg))
                tk.messagebox.showinfo("Failed", f"The Auto Tag record {at_id} was NOT deleted. {msg}")
    


    def apply_auto_tagger_filters(self, event=None):
        # Retrieve the values from the input fields
        forecast_id = self.tab2_forecast_id_input.get().lower()
        cost_center_code = self.tab2_cc_code_input.get().lower()
        account_code = self.tab2_account_code_input.get().lower()
        po_num = self.tab2_purchase_order_input.get().lower()
        cost_obj_code = self.tab2_co_code_input.get().lower()
    
        # Filter the rows of the full forecast table
        filtered_rows = [
            row for row in self.rows_auto_tagger
            if (not forecast_id or forecast_id in str(row['Forecast ID']).lower()) and \
               (not cost_center_code or cost_center_code in str(row['Cost Center Code']).lower()) and \
               (not account_code or account_code in str(row['Account Code']).lower()) and \
               (not po_num or po_num in str(row['Purchase Order Number']).lower()) and \
               (not cost_obj_code or cost_obj_code in str(row['Cost Object Code']).lower())
        ]
    
        # Clear the existing rows in the full forecast table treeview
        for item in self.tree_auto_tagger.get_children():
            self.tree_auto_tagger.delete(item)
    
        # Add the filtered rows to the full forecast table treeview
        for row in filtered_rows:
            values = [row.get(col, "") for col in self.column_headers_auto_tagger]
            self.tree_auto_tagger.insert("", "end", values=values)

    

    def tagger_remove_all_filters(self):
        # Set all inputs to empty strings
        self.tab2_forecast_id_input.delete(0, 'end')
        self.tab2_cc_code_input.delete(0, 'end')
        self.tab2_account_code_input.delete(0, 'end')
        self.tab2_purchase_order_input.delete(0, 'end')
        self.tab2_co_code_input.delete(0, 'end')
        
        # Re-call the apply filters
        self.apply_auto_tagger_filters()
            
            
    #################
    ##### TAB 3 #####
    #################
    def create_full_forecast_table(self):
        label_width = 15
        entry_width = 25
        dropdown_width = 10
        
        self.tab_3_button_frame = Frame(self.tab_full_forecast, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_3_button_frame.pack(side='top', pady=5, fill='both', expand=False)
        
        # Update button
        update_button_ff = ttk.Button(self.tab_3_button_frame, text="Update Forecast Item", 
                                      command=self.open_update_full_forecat_window, state="disabled")
        update_button_ff.pack(side='left', padx=5, pady=5, anchor='w')
        self.update_button_ff = update_button_ff
        
        # Copy and Paste button
        copy_and_paste_button_ff = ttk.Button(self.tab_3_button_frame, text="Copy and Add New", 
                                              command=self.open_insert_full_forecat_window, state="disabled")
        copy_and_paste_button_ff.pack(side='left', padx=5, pady=5, anchor='w')
        self.copy_and_paste_button_ff = copy_and_paste_button_ff
        
        # Delete Button
        delete_forecast_li_record_button = ttk.Button(self.tab_3_button_frame, text="Delete Forecast Record", 
                                          command=self.delete_full_forecast_record, state="disabled",
                                          style="Delete.TButton")
        delete_forecast_li_record_button.pack(side='left', padx=75, pady=5, anchor='w')
        self.delete_forecast_li_record_button = delete_forecast_li_record_button

        
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        query_actualized = """
        SELECT
            actualized_date
        FROM [vw_actualized_date]
        """
        print(query_actualized)
        cursor.execute(query_actualized)
        actualized_date = cursor.fetchone()[0]
        
        self.actualized_label = tk.Label(self.tab_3_button_frame, text=f"Actualized: {actualized_date}", bg='#DCDAD5', anchor='e')
        self.actualized_label.pack(side='left', padx=(5, 15), pady=5, anchor='w')
        
        # Year Drop Down        
        self.current_year = datetime.datetime.now().year
        self.years = list(self.dropdown_values['Years'].keys())
        self.selected_year = tk.StringVar(value=str(self.current_year))
        self.year_label_frcst = tk.Label(self.tab_3_button_frame, text="Viewing Year:", bg='#DCDAD5', anchor='e')
        self.year_label_frcst.pack(side='left', padx=5, pady=5, anchor='w')
        
        self.year_dropdown_frcst = ttk.Combobox(self.tab_3_button_frame, textvariable=self.selected_year,
                                                values=self.years, width=dropdown_width)
        self.year_dropdown_frcst.pack(side='left', padx=5, pady=5, anchor='w')
        self.filter_year_forecast = self.year_dropdown_frcst.get()


        # Refresh button
        refresh_button_ff = ttk.Button(self.tab_3_button_frame, text="Refresh Data", command=self.refresh_full_forecast_tab3)
        refresh_button_ff.pack(side='left', padx=10, pady=5, anchor='w')
        self.refresh_button_ff = refresh_button_ff
        
        # Export Button
        export_forecast_button = ttk.Button(self.tab_3_button_frame, text="Export Forecast (csv)", 
                                            command=self.export_csv_full_forecast)
        export_forecast_button.pack(side='right', padx=5, pady=5, anchor='e')
        self.export_forecast_button = export_forecast_button
        
        
        # Create the filter frame
        self.tab_3_filter_frame = Frame(self.tab_full_forecast, bg='#DCDAD5')
        self.tab_3_filter_frame.pack(side='top', fill='both', expand=False)
        
        
        # Department Code
        self.department_code_label_frcst = tk.Label(self.tab_3_filter_frame, text="Department Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.department_code_label_frcst.grid(row=0, column=0, padx=5, pady=5, sticky='w')
        self.department_code_input_frcst = tk.Entry(self.tab_3_filter_frame, width=entry_width)
        self.department_code_input_frcst.grid(row=0, column=1, padx=5, pady=5, sticky='w')
        self.filter_dept_code_frcst = self.department_code_input_frcst.get()
        self.department_code_input_frcst.bind('<Return>', self.apply_full_forecast_filters)
        
        # Account Number
        self.account_number_label_frcst = tk.Label(self.tab_3_filter_frame, text="Account Code:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.account_number_label_frcst.grid(row=0, column=2, padx=5, pady=5, sticky='w')
        self.account_number_input_frcst = tk.Entry(self.tab_3_filter_frame, width=entry_width)
        self.account_number_input_frcst.grid(row=0, column=3, padx=5, pady=5, sticky='w')
        self.filter_acct_number_frcst = self.account_number_input_frcst.get()
        self.account_number_input_frcst.bind('<Return>', self.apply_full_forecast_filters)
        
        # Main Document Title
        self.mdt_label_frcst = tk.Label(self.tab_3_filter_frame, text="Main Doc Title:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.mdt_label_frcst.grid(row=0, column=4, padx=5, pady=5, sticky='w')
        self.mdt_input_frcst = tk.Entry(self.tab_3_filter_frame, width=entry_width)
        self.mdt_input_frcst.grid(row=0, column=5, padx=5, pady=5, sticky='w')
        self.filter_mdt_frcst = self.mdt_input_frcst.get()
        self.mdt_input_frcst.bind('<Return>', self.apply_full_forecast_filters)
        
        # Row 2
        
        # Supplier
        self.supplier_label_frcst = tk.Label(self.tab_3_filter_frame, text="Supplier:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.supplier_label_frcst.grid(row=1, column=0, padx=5, pady=5, sticky='w')
        self.supplier_input_frcst = tk.Entry(self.tab_3_filter_frame, width=entry_width)
        self.supplier_input_frcst.grid(row=1, column=1, padx=5, pady=5, sticky='w')
        self.filter_supplier_frcst = self.supplier_input_frcst.get()
        self.supplier_input_frcst.bind('<Return>', self.apply_full_forecast_filters)
        
        # Description
        self.desc_label_frcst = tk.Label(self.tab_3_filter_frame, text="Description:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.desc_label_frcst.grid(row=1, column=2, padx=5, pady=5, sticky='w')
        self.desc_input_frcst = tk.Entry(self.tab_3_filter_frame, width=entry_width)
        self.desc_input_frcst.grid(row=1, column=3, padx=5, pady=5, sticky='w')
        self.filter_desc_frcst = self.desc_input_frcst.get()
        self.desc_input_frcst.bind('<Return>', self.apply_full_forecast_filters)
        
        # PO Number
        self.po_label_frcst = tk.Label(self.tab_3_filter_frame, text="PO Number:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.po_label_frcst.grid(row=1, column=4, padx=5, pady=5, sticky='w')
        self.po_input_frcst = tk.Entry(self.tab_3_filter_frame, width=entry_width)
        self.po_input_frcst.grid(row=1, column=5, padx=5, pady=5, sticky='w')
        self.filter_po_frcst = self.po_input_frcst.get()
        self.po_input_frcst.bind('<Return>', self.apply_full_forecast_filters)
        
        
        # Apply Filter Frame
        self.tab_3_apply_filters_frame = Frame(self.tab_full_forecast, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_3_apply_filters_frame.pack(side='top', pady=5, fill='both', expand=False)
        
        # Apply Filters Button
        frcst_apply_filter_button = ttk.Button(self.tab_3_apply_filters_frame, text="Apply Filters", 
                                               command=self.apply_full_forecast_filters)
        frcst_apply_filter_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.frcst_apply_filter_button = frcst_apply_filter_button

        # Clear Filters Button
        frcst_remove_filter_button = ttk.Button(self.tab_3_apply_filters_frame, text="Clear Filters", 
                                               command=self.full_forecast_remove_all_filters)
        frcst_remove_filter_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.frcst_remove_filter_button = frcst_apply_filter_button

        
        # Create top table
        self.create_full_forecast_table_tab3()
        
        
        self.tab_3_bottom_button_frame = Frame(self.tab_full_forecast, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_3_bottom_button_frame.pack(side='bottom', pady=5, fill='both', expand=False)
        
        
        # Create bottom table
        self.create_forecast_line_item_table_tab3()
    


    def create_full_forecast_table_tab3(self):   
        if self.tab_3_table1_frame is not None:
            self.tab_3_table1_frame.destroy()
            
        self.tab_3_table1_frame = Frame(self.tab_full_forecast, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_3_table1_frame.pack(side='top', pady=5, fill='both', expand=True)
            
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        query_po_numbers = """
        SELECT DISTINCT
        	[purchase_order_number],
        	[forecast_id]
        FROM [vw_po_number_forecast_id]
        ORDER BY [forecast_id]
        """
        print(query_po_numbers)
        cursor.execute(query_po_numbers)
        
        forecast_po_dict = {}
        for row in cursor.fetchall():
            po_number = row[0]
            forecast_id = row[1]
            # print(po_number, forecast_id)
            # print(forecast_po_dict)
            if forecast_id in forecast_po_dict.keys():
                forecast_po_dict[forecast_id].append(po_number)
            else:
                forecast_po_dict[forecast_id] = [po_number]


        query_full_forecast = """
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
            ,f.[Worker Start Date]
            ,f.[Worker End Date]
            ,f.[Override End Date]
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
            ,f.[Comment]
        FROM [dbo].[vw_forecast_full] as f
        JOIN [dbo].[vw_forecast_line_items] as fli 
            ON f.[Forecast ID] = fli.[forecast_id]
        ORDER BY 1 DESC
        """
        print(query_full_forecast)
        cursor.execute(query_full_forecast)
        
        
        # fetch the column headers from the cursor description
        self.column_headers_full_forecast = [column[0] for column in cursor.description]
        self.column_headers_full_forecast.append('PO Numbers')
        print(f"Full Forecast Columns: {self.column_headers_full_forecast}\n")
        
        # create a list of dictionaries, each representing a row in the table
        self.rows_full_forecast = [dict(zip(self.column_headers_full_forecast, row)) for row in cursor.fetchall()]
        # apply po number array to forecast item
        for row in self.rows_full_forecast:
            full_forecast_id = row['Forecast ID']
            if full_forecast_id in forecast_po_dict:
                po_id = ', '.join(forecast_po_dict[full_forecast_id])
                row["PO Numbers"] = po_id
            else:
                row["PO Numbers"] = None
        
        # print(self.rows_full_forecast[:5])
        
        # apply data types to columns
        self.dtype_dict_full_forecast = {
            'int': ['Forecast ID', 'Company Code', 'Cost Center Code', 'Account Code'],
            'float': ['Allocation', 'Current Bill Rate (Hr)', 'Current Bill Rate (Day)'],
            'date': ['Worker Start Date', 'Worker End Date', 'Override End Date']
        }
        
        for col in self.column_headers_full_forecast:
            if col in self.dtype_dict_full_forecast['int']:
                for row in self.rows_full_forecast:
                    row[col] = int(row[col]) if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_full_forecast['float']:
                for row in self.rows_full_forecast:
                    # row[col] = f"{float(row[col]):.2f}" if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
                    row[col] = f"({-1*float(row[col]):,.2f})" if row[col] and pd.notna(row[col]) and row[col] < 0 else f"{float(row[col]):,.2f}" if row[col] and pd.notna(row[col]) else f"{float(0.00):,.2f}"
            elif col in self.dtype_dict_full_forecast['date']:
                for row in self.rows_full_forecast:
                    row[col] = pd.to_datetime(row[col]).strftime('%m/%d/%Y') if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            else:
                for row in self.rows_full_forecast:
                    row[col] = row[col] if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''

        # create the treeview table
        self.tree_full_forecast = ttk.Treeview(self.tab_3_table1_frame, columns=self.column_headers_full_forecast,
                                          show='headings', selectmode="browse")
        self.tree_full_forecast.column("#0", width=0, stretch='no')
        self.tree_full_forecast.heading("#0", text='')
  
        # create treeview columns using the provided function
        self.create_treeview_columns(self.tree_full_forecast, self.dtype_dict_full_forecast, 
                                     self.column_headers_full_forecast, self.rows_full_forecast)

        # create treeview rows
        for row in self.rows_full_forecast:
            values = []
            for col in self.column_headers_full_forecast:
                _, format_func = self.format_cells(self.dtype_dict_full_forecast, col)
                values.append(format_func(row.get(col, "")))
            self.tree_full_forecast.insert("", "end", values=values)
        
        
        ### SCROLLBARS    
        # Add vertical scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_3_table1_frame)
        self.treeScroll.configure(command=self.tree_full_forecast.yview)
        self.tree_full_forecast.configure(yscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_3_table1_frame, side='right', fill='y')
        # Add horizontal scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_3_table1_frame, orient='horizontal')
        self.treeScroll.configure(command=self.tree_full_forecast.xview)
        self.tree_full_forecast.configure(xscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_3_table1_frame, side='bottom', fill='x')
        self.tree_full_forecast.pack(in_=self.tab_3_table1_frame, pady=(1, 0), fill='both', expand=True)
        self.tree_full_forecast.bind("<Shift-MouseWheel>", lambda event: self.tree_full_forecast.xview_scroll(int(-1*(event.delta/5)), "units"))
        
        # this allows the delete button to appear after a row is selected
        self.tree_full_forecast.bind('<<TreeviewSelect>>', self.on_full_forecast_row_select)
        
        

    def create_forecast_line_item_table_tab3(self):   
        if self.tab_3_table2_frame is not None:
            self.tab_3_table2_frame.destroy()
        
        self.filter_year_forecast = self.year_dropdown_frcst.get()
            
        self.tab_3_table2_frame = Frame(self.tab_full_forecast, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_3_table2_frame.pack(side='bottom', pady=5, fill='both', expand=False)
            
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        # execute a SQL query to select data from a table
        var_cur_year = int(str(self.filter_year_forecast)[-2:])
        var_prev_year = var_cur_year - 1
        
        query_forecast_line_item = f"""
        EXEC [dbo].[sp_select_full_forecast_metrics] {self.filter_year_forecast};
        """
        print(query_forecast_line_item)
        cursor.execute(query_forecast_line_item)
        
        # fetch the column headers from the cursor description
        self.column_headers_forecast_line_items = [
            column[0].replace("{current_year}", f"{var_cur_year}").replace("{prev_year}", f"{var_prev_year}")
            for column in cursor.description
        ]
        print(f"Forecast Line Items Columns: {self.column_headers_forecast_line_items}\n")
        
        # create a list of dictionaries, each representing a row in the table
        self.rows_forecast_line_items = [dict(zip(self.column_headers_forecast_line_items, row)) for row in cursor.fetchall()]
        
        # print(self.rows_forecast_line_items[:10])
        
        # apply data types to columns
        self.dtype_dict_forecast_line_items = {
            'int': ['Forecast ID'],
            'float': [f"Jan-{var_cur_year}", f"Feb-{var_cur_year}", f"Mar-{var_cur_year}",
                      f"Apr-{var_cur_year}", f"May-{var_cur_year}", f"Jun-{var_cur_year}",
                      f"Jul-{var_cur_year}", f"Aug-{var_cur_year}", f"Sep-{var_cur_year}",
                      f"Oct-{var_cur_year}", f"Nov-{var_cur_year}", f"Dec-{var_cur_year}",
                      f"FY-{var_cur_year} Forecast", f"FY-{var_cur_year} Budget", 
                      f"FY-{var_cur_year} F/B Var", f"FY-{var_cur_year} Q1F", 
                      f"FY-{var_cur_year} Q2F", f"FY-{var_cur_year} Q3F",
                      f"FY-{var_prev_year} Budget", f"FY-{var_prev_year} Q1F", 
                      f"FY-{var_prev_year} Q2F", f"FY-{var_prev_year} Q3F",
                      f"Q1-{var_cur_year} Total", f"Q2-{var_cur_year} Total", 
                      f"Q3-{var_cur_year} Total", f"Q4-{var_cur_year} Total"],
            'date': []
        }
        
        # print(self.dtype_dict_forecast_line_items)
        
        for col in self.column_headers_forecast_line_items:
            if col in self.dtype_dict_forecast_line_items['int']:
                for row in self.rows_forecast_line_items:
                    row[col] = int(row[col]) if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_forecast_line_items['float']:
                for row in self.rows_forecast_line_items:
                    row[col] = f"({-1*float(row[col]):,.2f})" if row[col] and pd.notna(row[col]) and row[col] < 0 else f"{float(row[col]):,.2f}" if row[col] and pd.notna(row[col]) else f"{float(0.00):,.2f}"
            elif col in self.dtype_dict_forecast_line_items['date']:
                for row in self.rows_forecast_line_items:
                    row[col] = pd.to_datetime(row[col]).strftime('%m/%d/%Y') if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            else:
                for row in self.rows_forecast_line_items:
                    row[col] = row[col] if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''

        # create the treeview table
        self.tree_forecast_line_items = ttk.Treeview(self.tab_3_table2_frame, columns=self.column_headers_forecast_line_items,
                                          show='headings', selectmode="browse")
        self.tree_forecast_line_items.column("#0", width=0, stretch='no')
        self.tree_forecast_line_items.heading("#0", text='')
  
        # create treeview columns using the provided function
        self.create_treeview_columns(self.tree_forecast_line_items, self.dtype_dict_forecast_line_items, 
                                     self.column_headers_forecast_line_items, self.rows_forecast_line_items)

        # create treeview rows
        for row in self.rows_forecast_line_items:
            values = []
            for col in self.column_headers_forecast_line_items:
                _, format_func = self.format_cells(self.dtype_dict_forecast_line_items, col)
                values.append(format_func(row.get(col, "")))
            self.tree_forecast_line_items.insert("", "end", values=values)
        
        
        ### SCROLLBARS    
        # Add vertical scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_3_table2_frame)
        self.treeScroll.configure(command=self.tree_forecast_line_items.yview)
        self.tree_forecast_line_items.configure(yscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_3_table2_frame, side='right', fill='y')
        # Add horizontal scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_3_table2_frame, orient='horizontal')
        self.treeScroll.configure(command=self.tree_forecast_line_items.xview)
        self.tree_forecast_line_items.configure(xscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_3_table2_frame, side='bottom', fill='x')
        self.tree_forecast_line_items.pack(in_=self.tab_3_table2_frame, pady=(1, 0), fill='both', expand=True)
        self.tree_forecast_line_items.bind("<Shift-MouseWheel>", lambda event: self.tree_forecast_line_items.xview_scroll(int(-1*(event.delta/5)), "units"))
        
        # this allows the delete button to appear after a row is selected
        # self.tree_forecast_line_items.bind('<<TreeviewSelect>>', self.on_full_forecast_row_select)


    def apply_full_forecast_filters(self, event=None):
        # Retrieve the values from the input fields
        dept_code = self.department_code_input_frcst.get().lower()
        acct_number = self.account_number_input_frcst.get().lower()
        mdt = self.mdt_input_frcst.get().lower()
        supplier = self.supplier_input_frcst.get().lower()
        desc = self.desc_input_frcst.get().lower()
        po_num = self.po_input_frcst.get().lower()
        
        # print(dept_code, acct_number, mdt, supplier, desc, po_num)
    
        # Filter the rows of the full forecast table
        filtered_rows = [
            row for row in self.rows_full_forecast
            if (not dept_code or dept_code in str(row['Department']).lower()) and \
               (not acct_number or acct_number in str(row['Account Code']).lower()) and \
               (not mdt or mdt in str(row['Main Document Title']).lower()) and \
               (not supplier or supplier in str(row['Supplier']).lower()) and \
               (not po_num or po_num in str(row['PO Numbers']).lower()) and \
               (not desc or desc in str(row['Description']).lower())
        ]
    
        # Clear the existing rows in the full forecast table treeview
        for item in self.tree_full_forecast.get_children():
            self.tree_full_forecast.delete(item)
    
        # Add the filtered rows to the full forecast table treeview
        for row in filtered_rows:
            values = [row.get(col, "") for col in self.column_headers_full_forecast]
            self.tree_full_forecast.insert("", "end", values=values)
            
        # FILTER 2ND TABLE
        
        # Extract Forecast IDs from filtered_rows
        filtered_forecast_ids = [row['Forecast ID'] for row in filtered_rows]
        
        # Filter the rows of the forecast_line_items table based on matching Forecast IDs
        filtered_line_items_rows = [
            row for row in self.rows_forecast_line_items
            if row['Forecast ID'] in filtered_forecast_ids
        ]
        
        # Clear the existing rows in the forecast_line_items table treeview
        for item in self.tree_forecast_line_items.get_children():
            self.tree_forecast_line_items.delete(item)
        
        # Add the filtered rows to the forecast_line_items table treeview
        for row in filtered_line_items_rows:
            values = [row.get(col, "") for col in self.column_headers_forecast_line_items]
            self.tree_forecast_line_items.insert("", "end", values=values)


                
    def full_forecast_remove_all_filters(self):
        # Set all inputs to empty strings
        self.department_code_input_frcst.delete(0, 'end')
        self.account_number_input_frcst.delete(0, 'end')
        self.mdt_input_frcst.delete(0, 'end')
        self.supplier_input_frcst.delete(0, 'end')
        self.desc_input_frcst.delete(0, 'end')
        self.po_input_frcst.delete(0, 'end')
        
        # Re-call the apply filters
        self.apply_full_forecast_filters()

        
    
    # REFRESH DATA
    def refresh_full_forecast_tab3(self):
        try:
            # call function to create full forecast table
            self.create_full_forecast_table_tab3()
            
            # call function to create metrics table
            self.create_forecast_line_item_table_tab3()
            
            self.delete_forecast_li_record_button.config(state='disabled')
            
            tk.messagebox.showinfo("Success", "Full Forecast data refreshed successfully!")
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Full Forecast NOT refreshed! {msg}")
   
    
    
    # this allows the auto tagger delete button to appear
    def on_full_forecast_row_select(self, event):
        if self.tree_forecast_line_items.selection():
            self.tree_forecast_line_items.selection_remove(self.tree_forecast_line_items.selection()[0])
        
        self.item_ff = self.tree_full_forecast.focus() # ff short for full forecast
        ff_row = self.tree_full_forecast.item(self.item_ff)['values']
        self.ff_id = ff_row[0]  # Replace with the index of the primary key column
        print(f"SELECTED FORECAST ID: {self.ff_id}")
        
        self.delete_forecast_li_record_button.config(state="normal") # enable "DELETE" button
        self.update_button_ff.config(state="normal") # enable "UPDATE" button
        self.copy_and_paste_button_ff.config(state="normal") # enable "Copy and Paste" button
        
        # Filter the rows of the second treeview
        filtered_rows = [
            row for row in self.rows_forecast_line_items
            if row[self.column_headers_forecast_line_items[0]] == self.ff_id # matching forecast ids
        ]
        
        # Clear the existing rows in treeview2
        for item in self.tree_forecast_line_items.get_children():
            self.tree_forecast_line_items.delete(item)
        
        # Add the filtered rows to treeview2
        for row in filtered_rows:
            values = [row.get(col, "") for col in self.column_headers_forecast_line_items]
            self.tree_forecast_line_items.insert("", "end", values=values)
            
            
            
    def open_update_full_forecat_window(self):     
        try:            
            # screen_width = self.master.winfo_screenwidth() | screen_height = self.master.winfo_screenheight()
            self.update_full_forecast_window = tk.Toplevel(self.master)
            # height = self.master.winfo_screenheight() - 100
            # self.update_full_forecast_window.geometry(f"1200x{height}+10+10")
            self.update_full_forecast_window.geometry("1200x900+10+10")
            self.update_full_forecast_window.title(f"Update Forecast ID: {self.ff_id}")
            
            # Create a canvas and add a scrollbar to it
            canvas = tk.Canvas(self.update_full_forecast_window)
            scrollbar = ttk.Scrollbar(self.update_full_forecast_window, orient="vertical", command=canvas.yview)
            scrollbar.pack(side="right", fill="y")
            canvas.pack(side="left", fill="both", expand=True)
            canvas.configure(yscrollcommand=scrollbar.set)
            canvas.bind('<Configure>', lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
            
            inner_frame = tk.Frame(canvas)
            canvas.create_window((0, 0), window=inner_frame, anchor="nw")
            
            # Bind the scrollwheel event to the canvas
            canvas.bind_all('<MouseWheel>', lambda event: canvas.yview_scroll(int(-1*(event.delta/120)), "units"))
            
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            # get the variables for current year and previous year
            # this is based on the year of filter dropdown
            var_cur_year = int(str(self.filter_year_forecast)[-2:])
            var_prev_year = var_cur_year - 1
            
            query = f"""
            EXEC [dbo].[sp_select_full_forecast_and_items_for_update] {self.ff_id}, {self.filter_year_forecast};
            """.lstrip('\t')
            print(query)
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('open_update_full_forecat_window', '{query.replace("'", "''")}')
            """)
            conn.commit()
            cursor.execute(query)
            row = cursor.fetchone()
            # print(row)
            
            # fetch the column headers from the cursor description
            self.forecast_update_column_headers = [
                column[0].replace("{current_year}", f"{var_cur_year}").replace("{prev_year}", f"{var_prev_year}")
                for column in cursor.description
            ]
            
            # print(self.forecast_update_column_headers)
            
            # all fields will be editable
            editable_fields = self.forecast_update_column_headers
            
            # Create prepopulated text boxes
            entry_fields = []
                                
            halfway_point = math.ceil(len(self.forecast_update_column_headers) / 2)
                        
            for i, (column_name, value) in enumerate(zip(self.forecast_update_column_headers, row)):
                # print(str(column_name) + ": " + str(value) + f" {type(value)}")
                # Create spacer after your inner_frame definition
                spacer = tk.Label(inner_frame, width=20)
                spacer.grid(row=0, column=2, rowspan=halfway_point, sticky="ns")
                            
                # then in your loop, increment label_column and entry_column by 1 when i >= halfway_point
                if i < halfway_point:
                    # Place the first half of the fields in columns 0 and 1
                    label_column = 0
                    entry_column = 1
                    grid_row = i
                else:
                    # Place the second half of the fields in columns 3 and 4
                    label_column = 3
                    entry_column = 4
                    grid_row = i - halfway_point
                            
                label = ttk.Label(inner_frame, text=column_name, background='#F0F0F0')
                label.grid(row=grid_row, column=label_column, padx=5, pady=5, sticky="w")
                            
                # big text field for comments
                if column_name == "Comment":
                    entry = tk.Text(inner_frame, wrap='word', height=5, width=50)
                    entry.insert('1.0', value or "")  # Insert value or empty string as placeholder text
                            
                # values from dropdown_value_keys dictionary
                # only show dropdowns for editible fields, otherwise show a disabled input text field
                elif column_name in self.dropdown_value_keys and column_name in editable_fields:
                    keys = [str(key) for key in self.dropdown_values[column_name].keys()]
                    if str(value) in keys:
                        default_value = str(value)
                    else:
                        default_value = keys[0] if keys else ''
                    entry = ttk.Combobox(inner_frame, values=keys, width=40, height=20)  # don't use var as the textvariable
                    entry.set(default_value)  # set the Combobox value directly
                                
                # default to input fields
                else:
                    entry = ttk.Entry(inner_frame, width=50)
                    entry.insert(0, value or "")  # Insert value or empty string as placeholder text
                            
                entry.grid(row=grid_row, column=entry_column, padx=5, pady=5, sticky="w")
                # Only make certain inputs available
                if column_name in editable_fields and column_name != 'Forecast ID': # in the editable fields list
                    inner_frame.grid_rowconfigure(i)
                else:
                    entry.configure(state="disabled") # disable the rest
                                
                entry_fields.append(entry)
                        
            # Create a button to save the updates
            save_button = ttk.Button(inner_frame, text="Save", command=lambda: self.save_update_full_forecast_data(entry_fields))
            save_button.grid(row=len(entry_fields), column=entry_column, padx=5, pady=5, sticky="e")
            
            # Update the canvas scrollregion
            inner_frame.update_idletasks()
            canvas.configure(scrollregion=canvas.bbox("all"))
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
            
            
    def save_update_full_forecast_data(self, entry_fields):        
        cc_value = self.dropdown_values['Company Code'][entry_fields[1].get()] # company code
        bu_value = self.dropdown_values['Business Unit'][entry_fields[2].get()] # entry_fields[15].get() or '' # business unit value
        dept_value = self.dropdown_values['Department'][entry_fields[3].get()]
        ccc_value = self.dropdown_values['Cost Center Code'][entry_fields[4].get()] # cost center code
        department_leader_value = entry_fields[4].get().replace("'", "''") or ''
        team_leader_value = entry_fields[6].get().replace("'", "''") or ''
        business_owner_value = entry_fields[7].get().replace("'", "''") or ''
        primary_contact_value = entry_fields[8].get().replace("'", "''") or ''
        supplier_value = entry_fields[9].get().replace("'", "''") or ''
        contractor_value = entry_fields[10].get().replace("'", "''") or ''
        worker_id_value = entry_fields[11].get().replace("'", "''") or ''
        pid_value = entry_fields[12].get().replace("'", "''") or ''
        worker_start_date = self.dropdown_values['Worker Start Date'][entry_fields[13].get()]
        worker_end_date = self.dropdown_values['Worker End Date'][entry_fields[14].get()]
        override_end_date = self.dropdown_values['Override End Date'][entry_fields[15].get()]
        main_doc_title_value = entry_fields[16].get().replace("'", "''") or ''
        coc_value = entry_fields[17].get().replace("'", "''") or '' # cost object code
        site_value = self.dropdown_values['Location'][entry_fields[18].get()]
        account_value = entry_fields[19].get().replace("'", "''") or ''
        work_type_value = self.dropdown_values['Work Type'][entry_fields[20].get()]
        worker_status_value = self.dropdown_values['Worker Status'][entry_fields[21].get()]
        wo_category_value = self.dropdown_values['Work Order Category'][entry_fields[22].get()]
        exp_class_value = self.dropdown_values['Expense Classification'][entry_fields[23].get()]
        budget_code_value = entry_fields[24].get().replace("'", "''") or ''
        seg_value = self.dropdown_values['Segmentation'][entry_fields[25].get()]
        plat_value = self.dropdown_values['Platform'][entry_fields[26].get()]
        fun_value = self.dropdown_values['Function'][entry_fields[27].get()]
        ss_value = self.dropdown_values['Support/Scalable'][entry_fields[28].get()]
        wo_id_value = entry_fields[29].get().replace("'", "''") or '' # work order id
        desc_value = entry_fields[30].get().replace("'", "''") or ''
        allocation_value = entry_fields[31].get().replace("'", "''") or ''
        br_hr_value = entry_fields[32].get().replace("'", "''") or ''
        br_day_value = entry_fields[33].get().replace("'", "''") or ''
        comment_value = entry_fields[34].get("1.0", tk.END).strip().replace("'", "''") or '' # comment value 
        jan_value = entry_fields[35].get().replace("'", "''") or ''
        feb_value = entry_fields[36].get().replace("'", "''") or ''
        mar_value = entry_fields[37].get().replace("'", "''") or ''
        apr_value = entry_fields[38].get().replace("'", "''") or ''
        may_value = entry_fields[39].get().replace("'", "''") or ''
        jun_value = entry_fields[40].get().replace("'", "''") or ''
        jul_value = entry_fields[41].get().replace("'", "''") or ''
        aug_value = entry_fields[42].get().replace("'", "''") or ''
        sep_value = entry_fields[43].get().replace("'", "''") or ''
        oct_value = entry_fields[44].get().replace("'", "''") or ''
        nov_value = entry_fields[45].get().replace("'", "''") or ''
        dec_value = entry_fields[46].get().replace("'", "''") or ''

        try:
            # Create connection
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            query = f"""
            EXEC [dbo].[sp_update_full_forecast_and_items]
                 {self.ff_id}, -- forecast id
                 {self.filter_year_forecast}, -- year
                '{cc_value}', -- company code
                '{bu_value}', -- business unit
                '{dept_value}', -- department
                '{ccc_value}', -- cost center code
                '{department_leader_value}', -- department leader
                '{team_leader_value}', -- team leader
                '{business_owner_value}', -- business owner
                '{primary_contact_value}', -- primary contact
                '{supplier_value}', -- supplier
                '{contractor_value}', -- contractor
                '{worker_id_value}', -- worker id
                '{pid_value}', -- pid
                '{worker_start_date}', -- start date
                '{worker_end_date}', -- end date 
                '{override_end_date}', -- override date
                '{main_doc_title_value}', -- main doc
                '{coc_value}', -- cost object code
                '{site_value}', -- location/site
                '{account_value}', -- account code
                '{work_type_value}', -- work type
                '{worker_status_value}', -- worker status
                '{wo_category_value}', -- work order category
                '{exp_class_value}', -- expense class 
                '{budget_code_value}', -- budget code
                '{seg_value}', -- segmentation
                '{plat_value}', -- platform
                '{fun_value}', -- function
                '{ss_value}', -- support/scalable
                '{wo_id_value}', -- work order id
                '{desc_value}', -- description
                '{allocation_value}', -- allocation
                '{br_hr_value}', -- bill rate hr
                '{br_day_value}', -- bill rate day
                '{comment_value}', -- comment
                '{jan_value}', -- jan
                '{feb_value}', -- feb
                '{mar_value}', -- mar
                '{apr_value}', -- apr
                '{may_value}', -- may
                '{jun_value}', -- jun
                '{jul_value}', -- jul
                '{aug_value}', -- aug
                '{sep_value}', -- sep
                '{oct_value}', -- oct
                '{nov_value}', -- nov
                '{dec_value}' -- dec
            """
            print(str(query).replace("'", "''"))
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('save_insert_forecast_data', '{str(query).replace("'", "''")}')
            """)
            conn.commit()
        
            # Insert the record into the database
            cursor.execute(query)
            conn.commit()
            
            # Close the update window
            self.update_full_forecast_window.destroy()
            
            # update forecast tables
            self.refresh_all_forecast_tables()
            
            tk.messagebox.showinfo("Success", "Record successfully updated!")
            
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
            
            
            
    def open_insert_full_forecat_window(self):     
        try:            
            # screen_width = self.master.winfo_screenwidth() | screen_height = self.master.winfo_screenheight()
            self.insert_full_forecast_window = tk.Toplevel(self.master)
            # height = self.master.winfo_screenheight() - 100
            # self.insert_full_forecast_window.geometry(f"1200x{height}+10+10")
            self.insert_full_forecast_window.geometry("1200x900+10+10")
            self.insert_full_forecast_window.title(f"Create New Forecast Record Based on Forecast ID: {self.ff_id}")
            
            # Create a canvas and add a scrollbar to it
            canvas = tk.Canvas(self.insert_full_forecast_window)
            scrollbar = ttk.Scrollbar(self.insert_full_forecast_window, orient="vertical", command=canvas.yview)
            scrollbar.pack(side="right", fill="y")
            canvas.pack(side="left", fill="both", expand=True)
            canvas.configure(yscrollcommand=scrollbar.set)
            canvas.bind('<Configure>', lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
            
            inner_frame = tk.Frame(canvas)
            canvas.create_window((0, 0), window=inner_frame, anchor="nw")
            
            # Bind the scrollwheel event to the canvas
            canvas.bind_all('<MouseWheel>', lambda event: canvas.yview_scroll(int(-1*(event.delta/120)), "units"))
            
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            # get the variables for current year and previous year
            # this is based on the year of filter dropdown
            var_cur_year = int(str(self.filter_year_forecast)[-2:])
            var_prev_year = var_cur_year - 1
            
            query = f"""
            EXEC [dbo].[sp_select_full_forecast_and_items] {self.ff_id}, {self.filter_year_forecast};
            """.lstrip('\t')
            print(query)
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('open_insert_full_forecat_window', '{query.replace("'", "''")}')
            """)
            conn.commit()
            cursor.execute(query)
            row = cursor.fetchone()
            # print(row)
            
            # fetch the column headers from the cursor description
            self.forecast_insert_column_headers = [
                column[0].replace("{current_year}", f"{var_cur_year}").replace("{prev_year}", f"{var_prev_year}")
                for column in cursor.description
            ]
            
            # all fields will be editable
            editable_fields = self.forecast_insert_column_headers
        
            # Create prepopulated text boxes
            entry_fields = []
                    
            halfway_point = math.ceil(len(self.forecast_insert_column_headers) / 2)
            
            for i, (column_name, value) in enumerate(zip(self.forecast_insert_column_headers, row)):
                # Create spacer after your inner_frame definition
                spacer = tk.Label(inner_frame, width=20)
                spacer.grid(row=0, column=2, rowspan=halfway_point, sticky="ns")
                
                # then in your loop, increment label_column and entry_column by 1 when i >= halfway_point
                if i < halfway_point:
                    # Place the first half of the fields in columns 0 and 1
                    label_column = 0
                    entry_column = 1
                    grid_row = i
                else:
                    # Place the second half of the fields in columns 3 and 4
                    label_column = 3
                    entry_column = 4
                    grid_row = i - halfway_point
                
                label = ttk.Label(inner_frame, text=column_name, background='#F0F0F0')
                label.grid(row=grid_row, column=label_column, padx=5, pady=5, sticky="w")
                
                # big text field for comments
                if column_name == "Comment":
                    entry = tk.Text(inner_frame, wrap='word', height=5, width=50)
                    entry.insert('1.0', value or "")  # Insert value or empty string as placeholder text
                
                # values from dropdown_value_keys dictionary
                # only show dropdowns for editible fields, otherwise show a disabled input text field
                elif column_name in self.dropdown_value_keys and column_name in editable_fields:
                    keys = [str(key) for key in self.dropdown_values[column_name].keys()]
                    if str(value) in keys:
                        default_value = str(value)
                    else:
                        default_value = keys[0] if keys else ''
                    entry = ttk.Combobox(inner_frame, values=keys, width=40, height=20)  # don't use var as the textvariable
                    entry.set(default_value)  # set the Combobox value directly
                    
                # default to input fields
                else:
                    entry = ttk.Entry(inner_frame, width=50)
                    entry.insert(0, value or "")  # Insert value or empty string as placeholder text
                
                entry.grid(row=grid_row, column=entry_column, padx=5, pady=5, sticky="w")
                # Only make certain inputs available
                if column_name in editable_fields: # in the editable fields list
                    inner_frame.grid_rowconfigure(i)
                else:
                    entry.configure(state="disabled") # disable the rest
                    
                entry_fields.append(entry)
            
            # Create a button to save the updates
            save_button = ttk.Button(inner_frame, text="Save", command=lambda: self.save_insert_full_forecast_data(entry_fields))
            save_button.grid(row=len(entry_fields), column=entry_column, padx=5, pady=5, sticky="e")
            
            # Update the canvas scrollregion
            inner_frame.update_idletasks()
            canvas.configure(scrollregion=canvas.bbox("all"))
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
    
    
    
    def save_insert_full_forecast_data(self, entry_fields):
        cc_value = self.dropdown_values['Company Code'][entry_fields[0].get()] # company code
        bu_value = self.dropdown_values['Business Unit'][entry_fields[1].get()] # entry_fields[15].get() or '' # business unit value
        dept_value = self.dropdown_values['Department'][entry_fields[2].get()]
        ccc_value = self.dropdown_values['Cost Center Code'][entry_fields[3].get()] # cost center code
        department_leader_value = entry_fields[4].get().replace("'", "''") or ''
        team_leader_value = entry_fields[5].get().replace("'", "''") or ''
        business_owner_value = entry_fields[6].get().replace("'", "''") or ''
        primary_contact_value = entry_fields[7].get().replace("'", "''") or ''
        supplier_value = entry_fields[8].get().replace("'", "''") or ''
        contractor_value = entry_fields[9].get().replace("'", "''") or ''
        worker_id_value = entry_fields[10].get().replace("'", "''") or ''
        pid_value = entry_fields[11].get().replace("'", "''") or ''
        worker_start_date = self.dropdown_values['Worker Start Date'][entry_fields[12].get()]
        worker_end_date = self.dropdown_values['Worker End Date'][entry_fields[13].get()]
        override_end_date = self.dropdown_values['Override End Date'][entry_fields[14].get()]
        main_doc_title_value = entry_fields[15].get().replace("'", "''") or ''
        coc_value = entry_fields[16].get().replace("'", "''") or '' # cost object code
        site_value = self.dropdown_values['Location'][entry_fields[17].get()]
        account_value = entry_fields[18].get().replace("'", "''") or ''
        work_type_value = self.dropdown_values['Work Type'][entry_fields[19].get()]
        worker_status_value = self.dropdown_values['Worker Status'][entry_fields[20].get()]
        wo_category_value = self.dropdown_values['Work Order Category'][entry_fields[21].get()]
        exp_class_value = self.dropdown_values['Expense Classification'][entry_fields[22].get()]
        budget_code_value = entry_fields[23].get().replace("'", "''") or ''
        seg_value = self.dropdown_values['Segmentation'][entry_fields[24].get()]
        plat_value = self.dropdown_values['Platform'][entry_fields[25].get()]
        fun_value = self.dropdown_values['Function'][entry_fields[26].get()]
        ss_value = self.dropdown_values['Support/Scalable'][entry_fields[27].get()]
        wo_id_value = entry_fields[28].get().replace("'", "''") or '' # work order id
        desc_value = entry_fields[29].get().replace("'", "''") or ''
        allocation_value = entry_fields[30].get().replace("'", "''") or ''
        br_hr_value = entry_fields[31].get().replace("'", "''") or ''
        br_day_value = entry_fields[32].get().replace("'", "''") or ''
        comment_value = entry_fields[33].get("1.0", tk.END).strip().replace("'", "''") or '' # comment value 
        jan_value = entry_fields[34].get().replace("'", "''") or ''
        feb_value = entry_fields[35].get().replace("'", "''") or ''
        mar_value = entry_fields[36].get().replace("'", "''") or ''
        apr_value = entry_fields[37].get().replace("'", "''") or ''
        may_value = entry_fields[38].get().replace("'", "''") or ''
        jun_value = entry_fields[39].get().replace("'", "''") or ''
        jul_value = entry_fields[40].get().replace("'", "''") or ''
        aug_value = entry_fields[41].get().replace("'", "''") or ''
        sep_value = entry_fields[42].get().replace("'", "''") or ''
        oct_value = entry_fields[43].get().replace("'", "''") or ''
        nov_value = entry_fields[44].get().replace("'", "''") or ''
        dec_value = entry_fields[45].get().replace("'", "''") or ''

        try:
            # Create connection
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            query = f"""
            EXEC [dbo].[sp_insert_new_forecast_from_copy]
                 {self.filter_year_forecast}, -- year
                '{cc_value}', -- company code
                '{bu_value}', -- business unit
                '{dept_value}', -- department
                '{ccc_value}', -- cost center code
                '{department_leader_value}', -- department leader
                '{team_leader_value}', -- team leader
                '{business_owner_value}', -- business owner
                '{primary_contact_value}', -- primary contact
                '{supplier_value}', -- supplier
                '{contractor_value}', -- contractor
                '{worker_id_value}', -- worker id
                '{pid_value}', -- pid
                '{worker_start_date}', -- start date
                '{worker_end_date}', -- end date 
                '{override_end_date}', -- override date
                '{main_doc_title_value}', -- main doc
                '{coc_value}', -- cost object code
                '{site_value}', -- location/site
                '{account_value}', -- account code
                '{work_type_value}', -- work type
                '{worker_status_value}', -- worker status
                '{wo_category_value}', -- work order category
                '{exp_class_value}', -- expense class 
                '{budget_code_value}', -- budget code
                '{seg_value}', -- segmentation
                '{plat_value}', -- platform
                '{fun_value}', -- function
                '{ss_value}', -- support/scalable
                '{wo_id_value}', -- work order id
                '{desc_value}', -- description
                '{allocation_value}', -- allocation
                '{br_hr_value}', -- bill rate hr
                '{br_day_value}', -- bill rate day
                '{comment_value}', -- comment
                '{jan_value}', -- jan
                '{feb_value}', -- feb
                '{mar_value}', -- mar
                '{apr_value}', -- apr
                '{may_value}', -- may
                '{jun_value}', -- jun
                '{jul_value}', -- jul
                '{aug_value}', -- aug
                '{sep_value}', -- sep
                '{oct_value}', -- oct
                '{nov_value}', -- nov
                '{dec_value}' -- dec
            """
            print(query.lstrip('\t'))
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('save_insert_forecast_data', '{str(query).replace("'", "''")}')
            """)
            conn.commit()
        
            # Insert the record into the database
            cursor.execute(query)
            conn.commit()
            
            # Close the update window
            self.insert_full_forecast_window.destroy()

            # update forecast tables
            self.refresh_all_forecast_tables()
            
            tk.messagebox.showinfo("Success", "Record added successfully!")
            
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
        
        
        
    def delete_full_forecast_record(self):
        self.item_ff = self.tree_full_forecast.focus() # ff short for full forecast
        ff_row = self.tree_full_forecast.item(self.item_ff)['values']
        ff_id = ff_row[0]  # Replace with the index of the primary key column
        
        if not ff_id:
            self.delete_forecast_li_record_button.config(state='disabled')
        else:
            pass # move on
    
        # Ask for confirmation
        response = tk.messagebox.askyesno("Delete Record", "Are you sure you want to delete this Forecast record?")
        
        if response:
            try:
                conn = self.connect_to_db()
                cursor = conn.cursor()
                query_forecast = f"""
                EXEC [dbo].[sp_delete_forecast_and_forecast_line_item] {ff_id}
                """
                ## ^^ this soft deletes the forecast and forecast line item
                print(query_forecast)
                cursor.execute(query_forecast)
                conn.commit()

                # update forecast tables
                self.refresh_all_forecast_tables()
        
                # Reset the selected_row
                self.delete_forecast_li_record_button.config(state='disabled')                
        
                # Show a message box with a confirmation message
                tk.messagebox.showinfo("Record Deleted", f"The Forecast record {ff_id} has been deleted successfully.")
            except Exception as e:
                msg = str(e)
                print('Failed: '+ str(msg))
                tk.messagebox.showinfo("Failed", f"The Forecast record {ff_id} was NOT deleted. {msg}")
        
        
        
    # Get the data from the treeview and write it to a CSV file
    def export_csv_full_forecast(self):
        # Retrieve the values from the input fields
        filter_dict = {}
        filter_dict['Year'] = self.filter_year_forecast
        filter_dict['Department Code'] = self.department_code_input_frcst.get().lower()
        filter_dict['Account Code'] =  self.account_number_input_frcst.get().lower()
        filter_dict['Main Doc Title'] = self.mdt_input_frcst.get().lower()
        filter_dict['Supplier'] = self.supplier_input_frcst.get().lower()
        filter_dict['Description'] = self.desc_input_frcst.get().lower()
        filter_dict['PO Number'] = self.po_input_frcst.get().lower()
        
        current_date = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
        # Open a file dialog to let the user choose where to save the CSV file
        file_types = [('CSV files', '*.csv'), ('Text files', '*.txt'), ('All files', '*.*')]
        file_path = asksaveasfile(initialfile = f"full_forecast_data_{current_date}.csv", 
                                  defaultextension=".csv", filetypes=file_types)

        # CREATE A SQL QUERY INSTEAD OF EXPORTING FROM TABLE
        # INCLUDE FILTERS

        if file_path:
            with open(file_path.name, 'w', newline='') as file:
                file_path = file_path.name # get the file path string
                # Open the file in write mode and create a CSV writer object
                writer = csv.writer(file)
                # Write the headers of the CSV file (column names)
                writer.writerow(self.column_headers_full_forecast)
                # Write each row of the Treeview to the CSV file
                for row in self.tree_full_forecast.get_children():
                    values = self.tree_full_forecast.item(row)['values']
                    writer.writerow(values)
                    
            # Test the database connection with the entered username and password
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('export_csv_full_forecast', '{file_path} | {filter_dict}')
            """)
            conn.commit()
       

                
    #################
    ##### TAB 4 #####
    #################
    def create_new_work_order_tab(self):
        self.tab_4_button_frame = Frame(self.tab_add_work_orders, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_button_frame.pack(side='top', pady=5, fill='x', expand=False)
        
        # Refresh button
        refresh_button_wo = ttk.Button(self.tab_4_button_frame, text="Refresh WO Data", command=self.refresh_work_orders_tab4)
        refresh_button_wo.pack(side='left', padx=5, pady=5, anchor='w')
        self.refresh_button_wo = refresh_button_wo
        
        edit_wo_details_button = ttk.Button(self.tab_4_button_frame, text="Edit Work Order", 
                                            command=self.edit_wo_details_tab4, state="disabled")
        edit_wo_details_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.edit_wo_details_button = edit_wo_details_button
        
        # Delete Button
        delete_new_wo = ttk.Button(self.tab_4_button_frame, text="Remove WO from Report", 
                                          command=self.delete_new_work_order_record, state="disabled",
                                          style="Delete.TButton")
        delete_new_wo.pack(side='left', padx=75, pady=5, anchor='w')
        self.delete_new_wo = delete_new_wo


        # Create the filter frame
        self.tab4_top_frame_filters = Frame(self.tab_add_work_orders, bg='#DCDAD5')
        self.tab4_top_frame_filters.pack(side='top', pady=5, fill='x', expand=False)
    
        # Add the filter inputs to the filter frame
        # Worker Status
        self.tab4_worker_status_label = tk.Label(self.tab4_top_frame_filters, text="Worker Status:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_worker_status_label.grid(row=0, column=0, padx=5, pady=5, sticky='w')
        self.tab4_worker_status_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_worker_status_input.grid(row=0, column=1, padx=5, pady=5, sticky='w')
        self.filter_worker_status_wo = self.tab4_worker_status_input.get()
        self.tab4_worker_status_input.bind('<Return>', self.apply_work_order_filters)

        # Worker Order Status
        self.tab4_wo_status_label = tk.Label(self.tab4_top_frame_filters, text="Worker Order Status:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_wo_status_label.grid(row=0, column=2, padx=5, pady=5, sticky='w')
        self.tab4_wo_status_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_wo_status_input.grid(row=0, column=3, padx=5, pady=5, sticky='w')
        self.filter_wo_status_wo = self.tab4_wo_status_input.get()
        self.tab4_wo_status_input.bind('<Return>', self.apply_work_order_filters)

        # Main Doc Title
        self.tab4_mdt_label = tk.Label(self.tab4_top_frame_filters, text="Main Doc Title:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_mdt_label.grid(row=0, column=4, padx=5, pady=5, sticky='w')
        self.tab4_mdt_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_mdt_input.grid(row=0, column=5, padx=5, pady=5, sticky='w')
        self.filter_mdt_wo = self.tab4_mdt_input.get()
        self.tab4_mdt_input.bind('<Return>', self.apply_work_order_filters)

        # Business Unit
        self.tab4_bu_label = tk.Label(self.tab4_top_frame_filters, text="Business Unit:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_bu_label.grid(row=0, column=6, padx=5, pady=5, sticky='w')
        self.tab4_bu_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_bu_input.grid(row=0, column=7, padx=5, pady=5, sticky='w')
        self.filter_bu_wo = self.tab4_bu_input.get()
        self.tab4_bu_input.bind('<Return>', self.apply_work_order_filters)

        # PID
        self.tab4_pid_label = tk.Label(self.tab4_top_frame_filters, text="PID:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_pid_label.grid(row=1, column=0, padx=5, pady=5, sticky='w')
        self.tab4_pid_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_pid_input.grid(row=1, column=1, padx=5, pady=5, sticky='w')
        self.filter_pid_wo = self.tab4_pid_input.get()
        self.tab4_pid_input.bind('<Return>', self.apply_work_order_filters)

        # Contractor 
        self.tab4_contractor_label = tk.Label(self.tab4_top_frame_filters, text="Contractor:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_contractor_label.grid(row=1, column=2, padx=5, pady=5, sticky='w')
        self.tab4_contractor_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_contractor_input.grid(row=1, column=3, padx=5, pady=5, sticky='w')
        self.filter_contractor_wo = self.tab4_contractor_input.get()
        self.tab4_contractor_input.bind('<Return>', self.apply_work_order_filters)

        # Work Order ID 
        self.tab4_wo_id_label = tk.Label(self.tab4_top_frame_filters, text="Work Order ID:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_wo_id_label.grid(row=1, column=4, padx=5, pady=5, sticky='w')
        self.tab4_wo_id_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_wo_id_input.grid(row=1, column=5, padx=5, pady=5, sticky='w')
        self.filter_wo_id_wo = self.tab4_wo_id_input.get()
        self.tab4_wo_id_input.bind('<Return>', self.apply_work_order_filters)

        # PO Number
        self.tab4_po_label = tk.Label(self.tab4_top_frame_filters, text="PO Number:", bg='#DCDAD5', width=self.label_width, anchor='e')
        self.tab4_po_label.grid(row=1, column=6, padx=5, pady=5, sticky='w')
        self.tab4_po_input = tk.Entry(self.tab4_top_frame_filters, width=25)
        self.tab4_po_input.grid(row=1, column=7, padx=5, pady=5, sticky='w')
        self.filter_po_wo = self.tab4_po_input.get()
        self.tab4_po_input.bind('<Return>', self.apply_work_order_filters)


        # CREATE BUTTONS FRAME
        self.tab4_apply_filters_frame = Frame(self.tab_add_work_orders, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab4_apply_filters_frame.pack(side='top', pady=5, fill='x', expand=False)

        # Apply Filters Button
        wo_apply_filter_button = ttk.Button(self.tab4_apply_filters_frame, text="Apply Filters", command=self.apply_work_order_filters)
        wo_apply_filter_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.wo_apply_filter_button = wo_apply_filter_button

        wo_remove_filters_button = ttk.Button(self.tab4_apply_filters_frame, text="Clear Filters", command=self.work_order_remove_all_filters)
        wo_remove_filters_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.wo_remove_filters_button = wo_remove_filters_button 
        
        
        # Create top table for work orders
        self.create_work_order_table_tab_4()
        
  
        # BOTTOM FRAME
        self.tab_4_bottom_frame = Frame(self.tab_add_work_orders, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_bottom_frame.pack(side='bottom', pady=5, fill='both', expand=True)
        
        # Frame for buttons in bottom portion
        self.tab_4_bottom_buttons_frame = Frame(self.tab_4_bottom_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_bottom_buttons_frame.pack(side='top', fill='x', expand=False)
        
        # Calculate Forcasted Costs
        forecast_costs_button = ttk.Button(self.tab_4_bottom_buttons_frame, text="Calc Forecast Costs", 
                                           command=self.calculate_forecast_values)
        forecast_costs_button.pack(side='left', padx=5, pady=5, anchor='w', expand=False)
        self.forecast_costs_button = forecast_costs_button
        
        # Add Work Order to Forecast
        tab_4_add_wo_to_forecast_button = ttk.Button(self.tab_4_bottom_buttons_frame, text="Add WO to Forecast", 
                                          command=self.add_work_order_to_forecast, state="disabled",
                                          style="Important.TButton")
        tab_4_add_wo_to_forecast_button.pack(side='left', padx=5, pady=5, anchor='w')
        self.tab_4_add_wo_to_forecast_button = tab_4_add_wo_to_forecast_button
        
        
        # Edit Forecast Item
        find_forecast_from_wo_button = ttk.Button(self.tab_4_bottom_buttons_frame, text="Edit Forecast Record", 
                                                  command=self.open_update_filtered_forecat_window, state="disabled")
        find_forecast_from_wo_button.pack(side='right', padx=5, pady=5, anchor='e', expand=False)
        self.find_forecast_from_wo_button = find_forecast_from_wo_button
        
        
        # BOTTOM LEFT QUAD
        # Create a frame within the self.bottom_frame
        # this will house the work order details and forecast costs
        self.tab_4_bottom_left_frame = Frame(self.tab_4_bottom_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_bottom_left_frame.pack(side='left', pady=5, fill='both', expand=False)
        
        # Create labels in bottom left quad
        self.create_work_order_detail_labels()
        
        
        # BOTTOM RIGHT QUAD
        # Create a frame within the self.bottom_frame
        # this will house the work order details and forecast costs
        self.tab_4_bottom_table2_frame = Frame(self.tab_4_bottom_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_bottom_table2_frame.pack(side='right', pady=5, fill='both', expand=False)
        
        
        # call the function to create the filtered forecast table
        self.create_filtered_forecast_table_tab_4()
        
        
        
    def create_work_order_table_tab_4(self):
        if self.tab_4_table1_frame is not None:
            self.tab_4_table1_frame.destroy()
            
        self.tab_4_table1_frame = Frame(self.tab_add_work_orders, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_table1_frame.pack(side='top', pady=5, fill='x', expand=False)
            
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
            
        # execute a SQL query to select data from a table
        query_new_work_orders = """
        SELECT
             [WO ID]
            ,[Worker Type]
            ,[Worker Status]
            ,[Work Order Status]
            ,[Main Document Title]
            ,[Department]
            ,[Supplier]
            ,[Business Unit]
            ,[Cost Object Code]
            ,[Worker ID]
            ,[PID]
            ,[Contractor]
            ,[Worker Start Date]
            ,[Worker End Date]
            ,[Location]
            ,[Locale]
            ,[Job Posting ID]
            ,[Work Order ID]
            ,[PO Number]
            ,[Revision]
            ,[Bill Rate]
            ,[Hours Per Week]
            ,[Hours Per Day]
            ,[Allocation]
            ,[Work Order Composite]
        FROM [dbo].[vw_work_orders_new]
        ORDER BY 1 DESC
        """
        print(query_new_work_orders)
        cursor.execute(query_new_work_orders)
        
        # fetch the column headers from the cursor description
        self.column_headers_new_work_orders = [column[0] for column in cursor.description]
        print(f"New Work Orders Columns: {self.column_headers_new_work_orders}\n")
        
        # create a list of dictionaries, each representing a row in the table
        self.rows_new_work_orders = [dict(zip(self.column_headers_new_work_orders, row)) for row in cursor.fetchall()]
        
        # print(self.rows_new_work_orders[:10])
        
        # apply data types to columns
        self.dtype_dict_new_work_orders = {
            'int': ['WO ID', 'PO Number', 'Revision'],
            'float': ['Bill Rate', 'Hours Per Week', 'Hours Per Day', 'Allocation'],
            'date': ['Worker Start Date', 'Worker End Date']
        }
        
        for col in self.column_headers_new_work_orders:
            if col in self.dtype_dict_new_work_orders['int']:
                for row in self.rows_new_work_orders:
                    row[col] = int(row[col]) if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_new_work_orders['float']:
                for row in self.rows_new_work_orders:
                    row[col] = f"{float(row[col]):.2f}" if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_new_work_orders['date']:
                for row in self.rows_new_work_orders:
                    row[col] = pd.to_datetime(row[col]).strftime('%m/%d/%Y') if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            else:
                for row in self.rows_new_work_orders:
                    row[col] = row[col] if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
        
        # create the treeview table
        self.tree_new_work_orders = ttk.Treeview(self.tab_4_table1_frame, columns=self.column_headers_new_work_orders,
                                          show='headings', selectmode="browse")
        self.tree_new_work_orders.column("#0", width=0, stretch='no')
        self.tree_new_work_orders.heading("#0", text='')
  
        
        # create treeview columns using the provided function
        self.create_treeview_columns(self.tree_new_work_orders, self.dtype_dict_new_work_orders, 
                                     self.column_headers_new_work_orders, self.rows_new_work_orders)

        # create treeview rows
        for row in self.rows_new_work_orders:
            values = []
            for col in self.column_headers_new_work_orders:
                _, format_func = self.format_cells(self.dtype_dict_new_work_orders, col)
                values.append(format_func(row.get(col, "")))
            self.tree_new_work_orders.insert("", "end", values=values)
        
        
        ### SCROLLBARS    
        # Add vertical scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_4_table1_frame)
        self.treeScroll.configure(command=self.tree_new_work_orders.yview)
        self.tree_new_work_orders.configure(yscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_4_table1_frame, side='right', fill='y')
        # Add horizontal scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_4_table1_frame, orient='horizontal')
        self.treeScroll.configure(command=self.tree_new_work_orders.xview)
        self.tree_new_work_orders.configure(xscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_4_table1_frame, side='bottom', fill='x')
        self.tree_new_work_orders.pack(in_=self.tab_4_table1_frame, pady=(1, 0), fill='both', expand=True)
        self.tree_new_work_orders.bind("<Shift-MouseWheel>", lambda event: self.tree_new_work_orders.xview_scroll(int(-1*(event.delta/5)), "units"))
        
        # this allows the delete button to appear after a row is selected
        self.tree_new_work_orders.bind('<<TreeviewSelect>>', self.on_new_work_orders_row_select)
      
        
    
    def create_filtered_forecast_table_tab_4(self):
        if self.tab_4_bottom_table2_frame is not None:
            self.tab_4_bottom_table2_frame.destroy()
            
        # Create a frame for the first table and its scrollbars
        self.tab_4_bottom_table2_frame = Frame(self.tab_4_bottom_frame) # bg='#FFFFFF'
        self.tab_4_bottom_table2_frame.pack(side='top', pady=(10,20), fill='both', expand=True)
        
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
        
        # execute a SQL query to select data from a table
        var_cur_year = dt.datetime.now().strftime('%y')
        
        query_filtered_forecast = """
        EXEC [dbo].[sp_select_filtered_forecast_line_item]
        """

        print(query_filtered_forecast)
        cursor.execute(query_filtered_forecast)
        
        # fetch the column headers from the cursor description
        self.column_headers_filtered_forecast = [
            column[0].replace("{current_year}", f"{var_cur_year}")
            for column in cursor.description
        ]
        print(f"Filtered Forecast Columns: {self.column_headers_filtered_forecast}\n")
        
        # create a list of dictionaries, each representing a row in the table
        self.rows_filtered_forecast = [dict(zip(self.column_headers_filtered_forecast, row)) for row in cursor.fetchall()]
        
        # print(self.rows_{}[:10])
        
        # apply data types to columns
        self.dtype_dict_filtered_forecast = {
            'int': ['Forecast ID'],
            'float': ['Allocation', 'Current Bill Rate (Hr)', 'Current Bill Rate (Day)',
                      f"Jan-{var_cur_year}", f"Feb-{var_cur_year}", f"Mar-{var_cur_year}",
                      f"Apr-{var_cur_year}", f"May-{var_cur_year}", f"Jun-{var_cur_year}",
                      f"Jul-{var_cur_year}", f"Aug-{var_cur_year}", f"Sep-{var_cur_year}",
                      f"Oct-{var_cur_year}", f"Nov-{var_cur_year}", f"Dec-{var_cur_year}"],
            'date': ['Worker Start Date', 'Worker End Date']
        }
        
        for col in self.column_headers_filtered_forecast:
            if col in self.dtype_dict_filtered_forecast['int']:
                for row in self.rows_filtered_forecast:
                    row[col] = int(row[col]) if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_filtered_forecast['float']:
                for row in self.rows_filtered_forecast:
                    row[col] = f"{float(row[col]):.2f}" if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            elif col in self.dtype_dict_filtered_forecast['date']:
                for row in self.rows_filtered_forecast:
                    row[col] = pd.to_datetime(row[col]).strftime('%m/%d/%Y') if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
            else:
                for row in self.rows_filtered_forecast:
                    row[col] = row[col] if (row[col] is not None and not pd.isna(row[col]) and row[col] != '') else ''
        
        # create the treeview table
        self.tree_filtered_forecast = ttk.Treeview(self.tab_4_bottom_table2_frame, columns=self.column_headers_filtered_forecast,
                                          show='headings', selectmode="browse")
        self.tree_filtered_forecast.column("#0", width=0, stretch='no')
        self.tree_filtered_forecast.heading("#0", text='')
  
        
        # create treeview columns using the provided function
        self.create_treeview_columns(self.tree_filtered_forecast, self.dtype_dict_filtered_forecast, 
                                     self.column_headers_filtered_forecast, self.rows_filtered_forecast)
        
        # create treeview rows
        for row in self.rows_new_work_orders:
            values = []
            for col in self.column_headers_filtered_forecast:
                _, format_func = self.format_cells(self.dtype_dict_filtered_forecast, col)
                values.append(format_func(row.get(col, "")))
            self.tree_filtered_forecast.insert("", "end", values=values)
        
        
        ### SCROLLBARS    
        # Add vertical scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_4_bottom_table2_frame)
        self.treeScroll.configure(command=self.tree_filtered_forecast.yview)
        self.tree_filtered_forecast.configure(yscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_4_bottom_table2_frame, side='right', fill='y')
        # Add horizontal scrollbar to the first table in table1_frame
        self.treeScroll = ttk.Scrollbar(self.tab_4_bottom_table2_frame, orient='horizontal')
        self.treeScroll.configure(command=self.tree_filtered_forecast.xview)
        self.tree_filtered_forecast.configure(xscrollcommand=self.treeScroll.set)
        self.treeScroll.pack(in_=self.tab_4_bottom_table2_frame, side='bottom', fill='x')
        self.tree_filtered_forecast.pack(in_=self.tab_4_bottom_table2_frame, pady=(1, 0), fill='both', expand=True)
        self.tree_filtered_forecast.bind("<Shift-MouseWheel>", lambda event: self.tree_filtered_forecast.xview_scroll(int(-1*(event.delta/5)), "units"))
        
        # this allows the delete button to appear after a row is selected
        self.tree_filtered_forecast.bind('<<TreeviewSelect>>', self.on_filtered_forecast_row_select)



    def apply_work_order_filters(self, event=None):
        # Retrieve the values from the input fields
        worker_status = self.tab4_worker_status_input.get().lower()
        work_order_status = self.tab4_wo_status_input.get().lower()
        mdt = self.tab4_mdt_input.get().lower()
        bu = self.tab4_bu_input.get().lower()
        pid = self.tab4_pid_input.get().lower()
        contractor = self.tab4_contractor_input.get().lower()
        work_order_id = self.tab4_wo_id_input.get().lower()
        po_num = self.tab4_po_input.get().lower()
    
        # Filter the rows of the full forecast table
        # column_headers_new_work_orders
        # rows_new_work_orders
        # tree_new_work_orders
        filtered_rows_wo = [
            row for row in self.rows_new_work_orders
            if (not worker_status or worker_status in str(row['Worker Status']).lower()) and \
               (not work_order_status or work_order_status in str(row['Work Order Status']).lower()) and \
               (not mdt or mdt in str(row['Main Document Title']).lower()) and \
               (not bu or bu in str(row['Business Unit']).lower()) and \
               (not pid or pid in str(row['PID']).lower()) and \
               (not contractor or contractor in str(row['Contractor']).lower()) and \
               (not work_order_id or work_order_id in str(row['Work Order ID']).lower()) and \
               (not po_num or po_num in str(row['PO Number']).lower())
        ]
    
        # Clear the existing rows in the full forecast table treeview
        for item in self.tree_new_work_orders.get_children():
            self.tree_new_work_orders.delete(item)
    
        # Add the filtered rows to the full forecast table treeview
        for row in filtered_rows_wo:
            values = [row.get(col, "") for col in self.column_headers_new_work_orders]
            self.tree_new_work_orders.insert("", "end", values=values)

    

    def work_order_remove_all_filters(self):
        # Set all inputs to empty strings
        self.tab4_worker_status_input.delete(0, 'end')
        self.tab4_wo_status_input.delete(0, 'end')
        self.tab4_mdt_input.delete(0, 'end')
        self.tab4_bu_input.delete(0, 'end')
        self.tab4_pid_input.delete(0, 'end')
        self.tab4_contractor_input.delete(0, 'end')
        self.tab4_wo_id_input.delete(0, 'end')
        self.tab4_po_input.delete(0, 'end')
        
        # Re-call the apply filters
        self.apply_work_order_filters()
        
        
        
    # bottom left quad, top half
    # summarized details of the work order: id, cost object code, locale, etc...
    def create_work_order_detail_labels(self):
        # these are the labels for work order details
        self.tab_4_bottom_left_top_half_frame = Frame(self.tab_4_bottom_left_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_bottom_left_top_half_frame.pack(side='top', pady=0, fill='x', expand=False)
        
        # Row 0 Columns 0,1 - Work Order ID
        wo_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Work Order ID: ", background='#DCDAD5', anchor='e')
        wo_header_label.grid(row=0, column=0, padx=5, pady=5)
        wo_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        wo_text_label.grid(row=0, column=1, padx=5, pady=5)
        
        # Row 0 Columns 2,3 - Cost Object Code
        coc_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Cost Object Code: ", background='#DCDAD5', anchor='e')
        coc_header_label.grid(row=0, column=2, padx=5, pady=5)
        coc_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        coc_text_label.grid(row=0, column=3, padx=5, pady=5)
        
        # Row 0 Columns 4,5 - Locale
        locale_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Locale: ", background='#DCDAD5', anchor='e')
        locale_header_label.grid(row=0, column=4, padx=5, pady=5)
        locale_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        locale_text_label.grid(row=0, column=5, padx=5, pady=5)
        
        # Row 1 Columns 0,1 - Start Date
        start_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Worker Start Date: ", background='#DCDAD5', anchor='e')
        start_header_label.grid(row=1, column=0, padx=5, pady=5)
        start_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        start_text_label.grid(row=1, column=1, padx=5, pady=5)
        
        # Row 2 Columns 2,3 - End Date
        end_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Worker End Date: ", background='#DCDAD5', anchor='e')
        end_header_label.grid(row=1, column=2, padx=5, pady=5)
        end_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        end_text_label.grid(row=1, column=3, padx=5, pady=5)
        
        # Row 0 Columns 4,5 - Allocation
        allocation_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Allocation %: ", background='#DCDAD5', anchor='e')
        allocation_header_label.grid(row=1, column=4, padx=5, pady=5)
        allocation_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        allocation_text_label.grid(row=1, column=5, padx=5, pady=5)
        
        # Row 1 Columns 0,1 - Bill Rate
        br_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Bill Rate: ", background='#DCDAD5', anchor='e')
        br_header_label.grid(row=2, column=0, padx=5, pady=5)
        br_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        br_text_label.grid(row=2, column=1, padx=5, pady=5)
        
        # Row 2 Columns 2,3 - Hours per Day
        day_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Hours Per Day: ", background='#DCDAD5', anchor='e')
        day_header_label.grid(row=2, column=2, padx=5, pady=5)
        day_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        day_text_label.grid(row=2, column=3, padx=5, pady=5)
        
        # Row 0 Columns 4,5 - Hours per Week
        week_header_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="Hours Per Week: ", background='#DCDAD5', anchor='e')
        week_header_label.grid(row=2, column=4, padx=5, pady=5)
        week_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text="", background='#DCDAD5', width=20, anchor='w')
        week_text_label.grid(row=2, column=5, padx=5, pady=5)
     
        
        
    # bottom left quad populate other table with forecast items 
    def on_new_work_orders_row_select(self, event):
        self.item_wo_id = self.tree_new_work_orders.focus() # wo short for work order
        wo_row = self.tree_new_work_orders.item(self.item_wo_id)['values']
        wo_id = wo_row[0]  # Replace with the index of the primary key column
        wo_pid = wo_row[10]
        print(f"SELECTED WORK ORDER ID: {wo_id} | PID: {wo_row[10]}")
        
        # delete calculated forecast costs frame
        if self.tab_4_bottom_left_bottom_half_frame is not None:
            self.tab_4_bottom_left_bottom_half_frame.destroy()
        
        # enable buttons
        self.delete_new_wo.config(state="normal")
        self.find_forecast_from_wo_button.config(state="disabled") # re-disable forecast record
        
        # Row 0 Columns 0,1 - Work Order ID
        wo_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{str(wo_row[17])}", background='#DCDAD5', width=20, anchor='w')
        wo_text_label.grid(row=0, column=1, padx=5, pady=5)
        
        # Row 0 Columns 2,3 - Cost Object Code
        coc_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{str(wo_row[8])}", background='#DCDAD5', width=20, anchor='w')
        coc_text_label.grid(row=0, column=3, padx=5, pady=5)
        
        # Row 0 Columns 4,5 - Locale
        locale_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{wo_row[14]} | {wo_row[15]}", background='#DCDAD5', width=20, anchor='w')
        locale_text_label.grid(row=0, column=5, padx=5, pady=5)
        
        # Row 1 Columns 0,1 - Start Date
        start_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{str(wo_row[12])}", background='#DCDAD5', width=20, anchor='w')
        start_text_label.grid(row=1, column=1, padx=5, pady=5)
        
        # Row 1 Columns 2,3 - End Date
        end_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{str(wo_row[13])}", background='#DCDAD5', width=20, anchor='w')
        end_text_label.grid(row=1, column=3, padx=5, pady=5)
        
        # Row 1 Columns 4,5 - Allocation
        allocation_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{wo_row[23]}", background='#DCDAD5', width=20, anchor='w')
        allocation_text_label.grid(row=1, column=5, padx=5, pady=5)
        
        # Row 2 Columns 0,1 - Bill Rate
        br_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{str(wo_row[20])}", background='#DCDAD5', width=20, anchor='w')
        br_text_label.grid(row=2, column=1, padx=5, pady=5)
        
        # Row 2 Columns 2,3 - Hours per Day
        day_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{str(wo_row[22])}", background='#DCDAD5', width=20, anchor='w')
        day_text_label.grid(row=2, column=3, padx=5, pady=5)
        
        # Row 2 Columns 4,5 - Hours per Week
        week_text_label = tk.Label(self.tab_4_bottom_left_top_half_frame, text=f"{wo_row[21]}", background='#DCDAD5', width=20, anchor='w')
        week_text_label.grid(row=2, column=5, padx=5, pady=5)
        
        self.tab_4_bottom_left_top_half_frame.update() # update frame with new text values
        
        
        # Filter the rows of the second treeview
        filtered_rows = [
            row for row in self.rows_filtered_forecast
            if row[self.column_headers_filtered_forecast[3]] == wo_pid
        ]
        
        # Clear the existing rows in treeview2
        for item in self.tree_filtered_forecast.get_children():
            self.tree_filtered_forecast.delete(item)
        
        # Add the filtered rows to treeview2
        for row in filtered_rows:
            values = [row.get(col, "") for col in self.column_headers_filtered_forecast]
            self.tree_filtered_forecast.insert("", "end", values=values)

        self.tab_4_add_wo_to_forecast_button.config(state="disabled")


    # REFRESH WORK ORDER DATA
    def refresh_work_orders_tab4(self):
        try:
            # destroy then rebuild table1 frame
            if self.tab_4_table1_frame is not None:
                self.tab_4_table1_frame.destroy()
            
            self.create_work_order_table_tab_4()
            
            # destroy then rebuild table2 frame (bottom right)
            if self.tab_4_bottom_table2_frame is not None:
                self.tab_4_bottom_table2_frame.destroy()
            
            # recreate the filter forecast table (bottom right)
            self.create_filtered_forecast_table_tab_4()
            
            # destroy bottom left quad frames
            if self.tab_4_bottom_left_top_half_frame is not None:
                self.tab_4_bottom_left_top_half_frame.destroy()
                
            self.create_work_order_detail_labels()
            
            if self.tab_4_bottom_left_bottom_half_frame is not None:
                self.tab_4_bottom_left_bottom_half_frame.destroy()
            
            tk.messagebox.showinfo("Success", "Work Order data refreshed successfully!")
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Work Order data NOT refreshed successfully! {msg}")
    
    

    def edit_wo_details_tab4(self):
        try:
            pass
            
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Work Order was NOT retreived successfully! {msg}")
            
            
            
    def delete_new_work_order_record(self):
        self.item_wo_id = self.tree_new_work_orders.focus() # wo short for work order
        wo_row = self.tree_new_work_orders.item(self.item_wo_id)['values']
        wo_id = wo_row[0]  # Replace with the index of the primary key column
        
        if not wo_id:
            self.delete_new_wo.config(state='disabled')
        else:
            pass # move on
    
        # Ask for confirmation
        response = tk.messagebox.askyesno("Delete Record", "Are you sure you want to delete this record?!")
        
        if response:
            try:
                conn = self.connect_to_db()
                cursor = conn.cursor()
                query = f"""
                EXEC [dbo].[sp_delete_record_new_work_order] {wo_id}
                """ 
                print(query)
                cursor.execute(query)
                conn.commit()
        
                # Update the Treeview to remove the deleted row
                self.tree_new_work_orders.delete(self.tree_new_work_orders.selection())
        
                # Reset the selected_row
                self.delete_new_wo.config(state='disabled')
        
                # Show a message box with a confirmation message
                tk.messagebox.showinfo("Record Deleted", f"The Work Order record {wo_id} will not be added to the forecast.")
                
            except Exception as e:
                msg = str(e)
                print('Failed: '+ str(msg))
                tk.messagebox.showinfo("Failed", f"Something went wrong trying to remove Work Order {wo_id}. {msg}")
            
        

    def calculate_forecast_values(self):
        if self.tab_4_bottom_left_bottom_half_frame is not None:
            self.tab_4_bottom_left_bottom_half_frame.destroy()

        # BOTTOM LEFT QAUD UNDERNEATH wo_details_frame
        self.tab_4_bottom_left_bottom_half_frame = Frame(self.tab_4_bottom_left_frame, bg='#DCDAD5') # bg='#FFFFFF'
        self.tab_4_bottom_left_bottom_half_frame.pack(side='bottom', pady=(30,10), fill='both', expand=True)
        
        self.item_wo_id = self.tree_new_work_orders.focus() # wo short for work order
        wo_row = self.tree_new_work_orders.item(self.item_wo_id)['values']
        wo_id = wo_row[0]  # Replace with the index of the primary key column
    
        # Create connection
        conn = self.connect_to_db()
        cursor = conn.cursor()
    
        query = f"""
        EXEC [dbo].[sp_select_work_order_details] '{wo_id}'
        """
        print(query)
        cursor.execute(query)
        
        self.rows_wo_forecast = cursor.fetchall()
    
        # Create the header labels
        header_labels = ["Month", "Weekends", "Holidays", "Est. PTO", "WO Work Days", "Cost"]
        for col, label in enumerate(header_labels):
            tk.Label(self.tab_4_bottom_left_bottom_half_frame, text=label, background='#DCDAD5', width=15).grid(row=0, column=col, padx=5, pady=5, sticky='w')
    
    
        # Initialize the list to store the Entry fields
        self.forecasted_cost_entries = []
    
        # Loop through the query results and create the table rows
        for row_num, row_data in enumerate(self.rows_wo_forecast):
            
            # print(row_num, row_data, "\n")
            # Add the Month Year label
            month_year_label = tk.Label(self.tab_4_bottom_left_bottom_half_frame, text=row_data[1], background='#DCDAD5', width=15)
            month_year_label.grid(row=row_num+1, column=0, padx=5, pady=5, sticky='w')
            
            # print(month_year_label, "\n")
    
            # Add the Weekends label
            weekends_label = tk.Label(self.tab_4_bottom_left_bottom_half_frame, text=row_data[2], background='#DCDAD5', anchor='e')
            weekends_label.grid(row=row_num+1, column=1, padx=(5,10), pady=5, sticky='e')
    
            # Add the Holidays label
            holiday_label = tk.Label(self.tab_4_bottom_left_bottom_half_frame, text=row_data[3], background='#DCDAD5', anchor='e')
            holiday_label.grid(row=row_num+1, column=2, padx=(5,10), pady=5, sticky='e')
    
            # Add the Estimated PTO label
            pto_label = tk.Label(self.tab_4_bottom_left_bottom_half_frame, text=int(row_data[4]), background='#DCDAD5', anchor='e')
            pto_label.grid(row=row_num+1, column=3, padx=(5,10), pady=5, sticky='e')
            
            # Add the WO Work Days label
            wo_work_days_label = tk.Label(self.tab_4_bottom_left_bottom_half_frame, text=int(row_data[6]), background='#DCDAD5', anchor='e')
            wo_work_days_label.grid(row=row_num+1, column=4, padx=(5,10), pady=5, sticky='e')
            
            # Add the Forecasted Cost input field
            forecasted_cost_entry = tk.Entry(self.tab_4_bottom_left_bottom_half_frame, width=15, justify='right')
            forecasted_cost_entry.insert(0, f"{float(row_data[7]):,.2f}")
            forecasted_cost_entry.grid(row=row_num+1, column=5, padx=(5,10), pady=5, sticky='w')
            # Store the Entry field in the list
            self.forecasted_cost_entries.append(forecasted_cost_entry)
            
            
        self.tab_4_bottom_left_frame.update()
        self.tab_4_add_wo_to_forecast_button.config(state="normal")
        
        
        
    def add_work_order_to_forecast(self):
        try:
            self.item_wo_id = self.tree_new_work_orders.focus() # wo short for work order
            wo_row = self.tree_new_work_orders.item(self.item_wo_id)['values']
            wo_id = wo_row[0]  # Replace with the index of the primary key column
            
            costs = [entry.get() for entry in self.forecasted_cost_entries]
            print(wo_id, costs)
            
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            query = f"""
            EXEC [dbo].[sp_insert_work_order_into_forecast] 
                {wo_id} -- wo id
                ,'{costs[0]}'  -- jan
                ,'{costs[1]}'  -- feb
                ,'{costs[2]}'  -- mar
                ,'{costs[3]}'  -- apr 
                ,'{costs[4]}'  -- may
                ,'{costs[5]}'  -- jun
                ,'{costs[6]}'  -- jul
                ,'{costs[7]}'  -- aug
                ,'{costs[8]}'  -- sep
                ,'{costs[9]}'  -- oct
                ,'{costs[10]}' -- nov
                ,'{costs[11]}' -- dec
            """
            print(query)
            cursor.execute(query)
            conn.commit()

            # refresh wo table
            # self.create_work_order_table_tab_4()
            self.tree_new_work_orders.delete(self.tree_new_work_orders.selection())

            # update forecast tables
            self.refresh_all_forecast_tables()
            
            self.tab_4_add_wo_to_forecast_button.config(state="disabled")
        
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('add_work_order_to_forecast', '{query.replace("'", "''")}')
            """)
            conn.commit()

            # get new forcast id and return in dialog box
            frcst_id_query = f"SELECT MAX([forecast_id]) FROM [dbo].[forecast] WHERE [created_by] = CURRENT_USER" 
            cursor.execute(frcst_id_query)
            frcst_id = cursor.fetchone()[0]

            tk.messagebox.showinfo("Success", f"Upload successful! New Forecast ID: {frcst_id}")         
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Something went wrong trying to add the Work Order {wo_id} to the Forecast. {msg}")
            
    

    def on_filtered_forecast_row_select(self, event):
        filtered_forecast_row = self.tree_filtered_forecast.item(self.tree_filtered_forecast.focus())['values']
        self.filtered_forecast_id = filtered_forecast_row[0]  # Replace with the index of the primary key column
        print(f"SELECTED FILTERED FORECAST ID: {self.filtered_forecast_id}")
        
        self.find_forecast_from_wo_button.config(state="normal") # enable button
        
        
        
    def open_update_filtered_forecat_window(self):     
        try:            
            # screen_width = self.master.winfo_screenwidth() | screen_height = self.master.winfo_screenheight()
            self.update_filtered_forecast_window = tk.Toplevel(self.master)
            # height = self.master.winfo_screenheight() - 100
            # self.update_full_forecast_window.geometry(f"1200x{height}+10+10")
            self.update_filtered_forecast_window.geometry("1200x900+10+10")
            self.update_filtered_forecast_window.title(f"Update Forecast ID: {self.filtered_forecast_id}")
            
            # Create a canvas and add a scrollbar to it
            canvas = tk.Canvas(self.update_filtered_forecast_window)
            scrollbar = ttk.Scrollbar(self.update_filtered_forecast_window, orient="vertical", command=canvas.yview)
            scrollbar.pack(side="right", fill="y")
            canvas.pack(side="left", fill="both", expand=True)
            canvas.configure(yscrollcommand=scrollbar.set)
            canvas.bind('<Configure>', lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
            
            inner_frame = tk.Frame(canvas)
            canvas.create_window((0, 0), window=inner_frame, anchor="nw")
            
            # Bind the scrollwheel event to the canvas
            canvas.bind_all('<MouseWheel>', lambda event: canvas.yview_scroll(int(-1*(event.delta/120)), "units"))
            
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            # get the variables for current year and previous year
            # this is based on the year of filter dropdown
            var_cur_year = int(str(self.filter_year_forecast)[-2:])
            var_prev_year = var_cur_year - 1
            
            query = f"""
            EXEC [dbo].[sp_select_full_forecast_and_items_for_update] {self.filtered_forecast_id}, {self.filter_year_forecast};
            """.lstrip('\t')
            print(query)
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('open_update_filtered_forecat_window', '{query.replace("'", "''")}')
            """)
            conn.commit()
            cursor.execute(query)
            row = cursor.fetchone()
            # print(row)
            
            # fetch the column headers from the cursor description
            self.forecast_update_filtered_column_headers = [
                column[0].replace("{current_year}", f"{var_cur_year}").replace("{prev_year}", f"{var_prev_year}")
                for column in cursor.description
            ]
            
            # print(self.forecast_update_column_headers)
            
            # all fields will be editable
            editable_fields = self.forecast_update_filtered_column_headers
            
            # Create prepopulated text boxes
            entry_fields = []
                                
            halfway_point = math.ceil(len(self.forecast_update_filtered_column_headers) / 2)
                        
            for i, (column_name, value) in enumerate(zip(self.forecast_update_filtered_column_headers, row)):
                # print(str(column_name) + ": " + str(value) + f" {type(value)}")
                # Create spacer after your inner_frame definition
                spacer = tk.Label(inner_frame, width=20)
                spacer.grid(row=0, column=2, rowspan=halfway_point, sticky="ns")
                            
                # then in your loop, increment label_column and entry_column by 1 when i >= halfway_point
                if i < halfway_point:
                    # Place the first half of the fields in columns 0 and 1
                    label_column = 0
                    entry_column = 1
                    grid_row = i
                else:
                    # Place the second half of the fields in columns 3 and 4
                    label_column = 3
                    entry_column = 4
                    grid_row = i - halfway_point
                            
                label = ttk.Label(inner_frame, text=column_name, background='#F0F0F0')
                label.grid(row=grid_row, column=label_column, padx=5, pady=5, sticky="w")
                            
                # big text field for comments
                if column_name == "Comment":
                    entry = tk.Text(inner_frame, wrap='word', height=5, width=50)
                    entry.insert('1.0', value or "")  # Insert value or empty string as placeholder text
                            
                # values from dropdown_value_keys dictionary
                # only show dropdowns for editible fields, otherwise show a disabled input text field
                elif column_name in self.dropdown_value_keys and column_name in editable_fields:
                    keys = [str(key) for key in self.dropdown_values[column_name].keys()]
                    if str(value) in keys:
                        default_value = str(value)
                    else:
                        default_value = keys[0] if keys else ''
                    entry = ttk.Combobox(inner_frame, values=keys, width=40, height=20)  # don't use var as the textvariable
                    entry.set(default_value)  # set the Combobox value directly
                                
                # default to input fields
                else:
                    entry = ttk.Entry(inner_frame, width=50)
                    entry.insert(0, value or "")  # Insert value or empty string as placeholder text
                            
                entry.grid(row=grid_row, column=entry_column, padx=5, pady=5, sticky="w")
                # Only make certain inputs available
                if column_name in editable_fields and column_name != 'Forecast ID': # in the editable fields list
                    inner_frame.grid_rowconfigure(i)
                else:
                    entry.configure(state="disabled") # disable the rest
                                
                entry_fields.append(entry)
                        
            # Create a button to save the updates
            save_button = ttk.Button(inner_frame, text="Save", command=lambda: self.save_update_filtered_forecast_data(entry_fields))
            save_button.grid(row=len(entry_fields), column=entry_column, padx=5, pady=5, sticky="e")
            
            # Update the canvas scrollregion
            inner_frame.update_idletasks()
            canvas.configure(scrollregion=canvas.bbox("all"))
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
            
            
            
    def save_update_filtered_forecast_data(self, entry_fields):
        cc_value = self.dropdown_values['Company Code'][entry_fields[1].get()] # company code
        bu_value = self.dropdown_values['Business Unit'][entry_fields[2].get()] # entry_fields[15].get() or '' # business unit value
        dept_value = self.dropdown_values['Department'][entry_fields[3].get()]
        ccc_value = self.dropdown_values['Cost Center Code'][entry_fields[4].get()] # cost center code
        department_leader_value = entry_fields[4].get().replace("'", "''") or ''
        team_leader_value = entry_fields[6].get().replace("'", "''") or ''
        business_owner_value = entry_fields[7].get().replace("'", "''") or ''
        primary_contact_value = entry_fields[8].get().replace("'", "''") or ''
        supplier_value = entry_fields[9].get().replace("'", "''") or ''
        contractor_value = entry_fields[10].get().replace("'", "''") or ''
        worker_id_value = entry_fields[11].get().replace("'", "''") or ''
        pid_value = entry_fields[12].get().replace("'", "''") or ''
        worker_start_date = self.dropdown_values['Worker Start Date'][entry_fields[13].get()]
        worker_end_date = self.dropdown_values['Worker End Date'][entry_fields[14].get()]
        override_end_date = self.dropdown_values['Override End Date'][entry_fields[15].get()]
        main_doc_title_value = entry_fields[16].get().replace("'", "''") or ''
        coc_value = entry_fields[17].get().replace("'", "''") or '' # cost object code
        site_value = self.dropdown_values['Location'][entry_fields[18].get()]
        account_value = entry_fields[19].get().replace("'", "''") or ''
        work_type_value = self.dropdown_values['Work Type'][entry_fields[20].get()]
        worker_status_value = self.dropdown_values['Worker Status'][entry_fields[21].get()]
        wo_category_value = self.dropdown_values['Work Order Category'][entry_fields[22].get()]
        exp_class_value = self.dropdown_values['Expense Classification'][entry_fields[23].get()]
        budget_code_value = entry_fields[24].get().replace("'", "''") or ''
        seg_value = self.dropdown_values['Segmentation'][entry_fields[25].get()]
        plat_value = self.dropdown_values['Platform'][entry_fields[26].get()]
        fun_value = self.dropdown_values['Function'][entry_fields[27].get()]
        ss_value = self.dropdown_values['Support/Scalable'][entry_fields[28].get()]
        wo_id_value = entry_fields[29].get().replace("'", "''") or '' # work order id
        desc_value = entry_fields[30].get().replace("'", "''") or ''
        allocation_value = entry_fields[31].get().replace("'", "''") or ''
        br_hr_value = entry_fields[32].get().replace("'", "''") or ''
        br_day_value = entry_fields[33].get().replace("'", "''") or ''
        comment_value = entry_fields[34].get("1.0", tk.END).strip().replace("'", "''") or '' # comment value 
        jan_value = entry_fields[35].get().replace("'", "''") or ''
        feb_value = entry_fields[36].get().replace("'", "''") or ''
        mar_value = entry_fields[37].get().replace("'", "''") or ''
        apr_value = entry_fields[38].get().replace("'", "''") or ''
        may_value = entry_fields[39].get().replace("'", "''") or ''
        jun_value = entry_fields[40].get().replace("'", "''") or ''
        jul_value = entry_fields[41].get().replace("'", "''") or ''
        aug_value = entry_fields[42].get().replace("'", "''") or ''
        sep_value = entry_fields[43].get().replace("'", "''") or ''
        oct_value = entry_fields[44].get().replace("'", "''") or ''
        nov_value = entry_fields[45].get().replace("'", "''") or ''
        dec_value = entry_fields[46].get().replace("'", "''") or ''

        try:
            # Create connection
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            query = f"""
            EXEC [dbo].[sp_update_full_forecast_and_items]
                 {self.filtered_forecast_id}, -- forecast id
                 {self.filter_year_forecast}, -- year
                '{cc_value}', -- company code
                '{bu_value}', -- business unit
                '{dept_value}', -- department
                '{ccc_value}', -- cost center code
                '{department_leader_value}', -- department leader
                '{team_leader_value}', -- team leader
                '{business_owner_value}', -- business owner
                '{primary_contact_value}', -- primary contact
                '{supplier_value}', -- supplier
                '{contractor_value}', -- contractor
                '{worker_id_value}', -- worker id
                '{pid_value}', -- pid
                '{worker_start_date}', -- start date
                '{worker_end_date}', -- end date 
                '{override_end_date}', -- override date
                '{main_doc_title_value}', -- main doc
                '{coc_value}', -- cost object code
                '{site_value}', -- location/site
                '{account_value}', -- account code
                '{work_type_value}', -- work type
                '{worker_status_value}', -- worker status
                '{wo_category_value}', -- work order category
                '{exp_class_value}', -- expense class 
                '{budget_code_value}', -- budget code
                '{seg_value}', -- segmentation
                '{plat_value}', -- platform
                '{fun_value}', -- function
                '{ss_value}', -- support/scalable
                '{wo_id_value}', -- work order id
                '{desc_value}', -- description
                '{allocation_value}', -- allocation
                '{br_hr_value}', -- bill rate hr
                '{br_day_value}', -- bill rate day
                '{comment_value}', -- comment
                '{jan_value}', -- jan
                '{feb_value}', -- feb
                '{mar_value}', -- mar
                '{apr_value}', -- apr
                '{may_value}', -- may
                '{jun_value}', -- jun
                '{jul_value}', -- jul
                '{aug_value}', -- aug
                '{sep_value}', -- sep
                '{oct_value}', -- oct
                '{nov_value}', -- nov
                '{dec_value}' -- dec
            """
            print(str(query).replace("'", "''"))
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('save_update_filtered_forecast_data', '{str(query).replace("'", "''")}')
            """)
            conn.commit()
        
            # Insert the record into the database
            cursor.execute(query)
            conn.commit()
            
            # Close the update window
            self.update_filtered_forecast_window.destroy()
            
            # update forecast tables
            self.refresh_all_forecast_tables()
            
            tk.messagebox.showinfo("Success", f"Record ID {self.filtered_forecast_id} successfully updated!")
            
        except Exception as e:
            msg = str(e)
            print('Failed: '+ str(msg))
            tk.messagebox.showinfo("Failed", f"Error! {msg}")
    
    
    #########################
    ##### RESOURCES TAB #####
    #########################
    
    # bulk upload forecast updates (add in template file)
    
    # trigger SFTP file update (non-admin stuff)

    def create_resources_tab(self):
        self.resources_frame = Frame(self.tab_resources, bg='#DCDAD5') # bg='#FFFFFF'
        self.resources_frame.pack(side='top', pady=5, fill='x')

        # Messaging
        self.resources_message_frame = tk.Frame(self.resources_frame, bg='#DCDAD5')
        self.resources_message_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)
        self.resources_message = tk.Label(self.resources_message_frame, text=" ", anchor='w', width=150, bg=self.resources_message_frame["bg"])
        self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=5, sticky='w') # pack(side='left', padx=5, pady=5, anchor='w')

        # Forecast
        download_forecast_frame = tk.Frame(self.resources_frame, bg='#DCDAD5')
        download_forecast_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)
        tk.Label(download_forecast_frame, text="Forecast Bulk Edit", bg=download_forecast_frame["bg"]).pack(side='left', padx=5, pady=5, anchor='w')
        # Download button
        self.resources_download_forecast_bulk = ttk.Button(download_forecast_frame, text="Download Template",  
                                                  command=self.download_full_forecast_file, style="TButton")
        self.resources_download_forecast_bulk.pack(side='left', padx=5, pady=5, anchor='w')
        # Upload button
        self.resources_upload_forecast_bulk = ttk.Button(download_forecast_frame, text="Select Upload File",  
                                                  command=self.select_bulk_forecast_file, style="TButton")
        self.resources_upload_forecast_bulk.pack(side='left', padx=5, pady=5, anchor='w')
        # Label
        self.resources_forecast_bulk_label = tk.Label(download_forecast_frame, text=" ", anchor='w', width=70, bg=download_forecast_frame["bg"])
        self.resources_forecast_bulk_label.pack(side='left', padx=5, pady=5, anchor='w')
        # Update button
        self.resources_update_forecast_bulk = ttk.Button(download_forecast_frame, text="Update Database",  
                                                  command=self.upload_bulk_forecast_file, style="Important.TButton")
        self.resources_update_forecast_bulk.pack(side='left', padx=5, pady=5, anchor='w')

        # Forecast
        download_forecast_lineitems_frame = tk.Frame(self.resources_frame, bg='#DCDAD5')
        download_forecast_lineitems_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)
        tk.Label(download_forecast_lineitems_frame, text="Forecast Line Items Bulk Edit", bg=download_forecast_lineitems_frame["bg"]).pack(side='left', padx=5, pady=5, anchor='w')
        # Download button
        self.resources_download_forecast_lineitems_bulk = ttk.Button(download_forecast_lineitems_frame, text="Download Template",  
                                                  command=self.download_forecast_lineitems_file, style="TButton")
        self.resources_download_forecast_lineitems_bulk.pack(side='left', padx=5, pady=5, anchor='w')
        # Upload button
        self.resources_upload_forecast_lineitems_bulk = ttk.Button(download_forecast_lineitems_frame, text="Select Upload File",  
                                                  command=self.select_bulk_forecast_lineitems_file, style="TButton")
        self.resources_upload_forecast_lineitems_bulk.pack(side='left', padx=5, pady=5, anchor='w')
        # Label
        self.resources_forecast_lineitems_bulk_label = tk.Label(download_forecast_lineitems_frame, text=" ", anchor='w', width=70, bg=download_forecast_lineitems_frame["bg"])
        self.resources_forecast_lineitems_bulk_label.pack(side='left', padx=5, pady=5, anchor='w')
        # Update button
        self.resources_update_forecast_lineitems_bulk = ttk.Button(download_forecast_lineitems_frame, text="Update Database",  
                                                  command=self.upload_bulk_forecast_lineitems_file, style="Important.TButton")
        self.resources_update_forecast_lineitems_bulk.pack(side='left', padx=5, pady=5, anchor='w')



    def insert_dataframe_to_sql_server_bulk(self, df, schema, table, batch_size, truncate_table='N'):
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

            missing_db_col = []
            for element in db_col_headers:
                if element not in df_col_headers:
                    missing_db_col.append(element)
            
            msg_3 = f"Missing Headers:\n{str(missing_db_col)}"
            raise ValueError(f"Column headers in the DataFrame do not match with the database. Operation aborted.\n\n{msg_1}\n\n{msg_2}\n\n{msg_3}")

        
        if truncate_table == 'Y':
            # Build & Execute SQL TRUNCATE statement
            try:
                truncate_query = f"TRUNCATE TABLE {schema}.{table};"
                print(truncate_query)
                cursor.execute(truncate_query)
                conn.commit()
                print('\nSUCCESS: "' + str(truncate_query) + '"\n')
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", f"There was an error with the upload! {e}")
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
            self.resources_message = tk.Label(self.resources_message_frame, text=f"{info_label}", anchor='w', width=150, bg=self.resources_message_frame["bg"])
            self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
            self.resources_message_frame.update()
            print('Records left: ' + str(counter) + ' Rows Inserted: ' + str(rows_inserted) + '\n')



    def download_full_forecast_file(self):
        current_date = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
        # Open a file dialog to let the user choose where to save the CSV file
        file_types = [('CSV files', '*.csv'), ('Text files', '*.txt'), ('All files', '*.*')]
        file_path = asksaveasfile(initialfile = f"forecast_bulk_edit_{current_date}.csv", 
                                  defaultextension=".csv", filetypes=file_types)
        if file_path:
            with open(file_path.name, 'w', newline='') as file:
                file_path = file_path.name # get the file path string
                # Run query
                conn = self.connect_to_db()
                cursor = conn.cursor()
                query = """
                SELECT 
                    ff.[Forecast ID]
                    ,ff.[Company Code]
                    ,ff.[Business Unit]
                    ,ff.[Department]
                    ,ff.[Cost Center Code]
                    ,ff.[Department Leader]
                    ,ff.[Team Leader]
                    ,ff.[Business Owner]
                    ,ff.[Primary Contact]
                    ,ff.[Supplier]
                    ,ff.[Contractor]
                    ,ff.[Worker ID]
                    ,ff.[PID]
                    ,ff.[Worker Start Date]
                    ,ff.[Worker End Date]
                    ,ff.[Override End Date]
                    ,ff.[Main Document Title]
                    ,ff.[Cost Object Code]
                    ,ff.[Site]
                    ,ff.[Account Code]
                    ,ff.[Work Type]
                    ,ff.[Worker Status]
                    ,ff.[Work Order Category]
                    ,ff.[Expense Classification]
                    ,ff.[Budget Code]
                    ,ff.[Segmentation]
                    ,ff.[Platform]
                    ,ff.[Function]
                    ,ff.[Support/Scalable]
                    ,ff.[Work Order ID]
                    ,ff.[Description]
                    ,ff.[Allocation]
                    ,ff.[Current Bill Rate (Hr)]
                    ,ff.[Current Bill Rate (Day)]
                    ,ff.[Comment]
                FROM [vw_forecast_full] as ff
                ORDER BY [Forecast ID]
                """
                print(query)
                cursor.execute(query)

                rows = cursor.fetchall()

                # New empty list called 'result'. This will be written to a file.
                result = list()

                # The row name is the first entry for each entity in the description tuple.
                column_names = list()
                for i in cursor.description:
                    column_names.append(i[0])

                result.append(column_names)
                for row in rows:
                    result.append(row)

                # Write result to file.
                with open(file_path, 'w', newline='') as csvfile:
                    csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                    for row in result:
                        csvwriter.writerow(row)
                    
            # Test the database connection with the entered username and password
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('export_csv_forecast_bulk_edit', '{file_path}')
            """)
            conn.commit()



    def select_bulk_forecast_file(self):
        self.bulk_forecast_file_path = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        print(f"Bulk Forecast File Path: {self.bulk_forecast_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.bulk_forecast_file_path:
            pass
        else:
            try:
                self.resources_forecast_bulk_label.config(text=self.bulk_forecast_file_path)
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!")


    
    def upload_bulk_forecast_file(self):
        conn = self.connect_to_db()
        cursor = conn.cursor()
                
        try:
            if self.bulk_forecast_file_path and os.path.isfile(self.bulk_forecast_file_path):
                self.insert_dataframe_to_sql_server_bulk(self.flat_file_to_dataframe(self.bulk_forecast_file_path, 
                                                                                delim=',', display_df='N', encode='windows-1254'),
                                                    'staging', 'bulk_update_forecast',
                                                    batch_size=1000, truncate_table='Y')
                try:
                    job_name = 'sp_etl_bulk_forecast'
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
                    ,'{self.bulk_forecast_file_path}' -- file_name 
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

                    bulk_forecast_query = "EXEC [dbo].[{job_name}]"
                    self.resources_message = tk.Label(self.resources_message_frame, text=f"Running Ingestion: {bulk_forecast_query}...", anchor='w', width=150, bg=self.resources_message_frame["bg"])
                    self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
                    self.resources_message_frame.update()
                    cursor.execute(bulk_forecast_query)
                    conn.commit()

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
                    tk.messagebox.showerror("Error", f"There was an error! {msg}")
                    self.resources_message = tk.Label(self.resources_message_frame, text=f"Error! {msg}", anchor='w', width=150, bg=self.resources_message_frame["bg"])
                    self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
                    self.resources_message_frame.update()
                    
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

            # update to completed
            self.resources_message = tk.Label(self.resources_message_frame, text=f"Completed!", anchor='w', width=150, bg=self.resources_message_frame["bg"])
            self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
            self.resources_message_frame.update()
            
        except Exception as e:
            msg = str(e)
            print(f"Failed: {msg}")
            tk.messagebox.showerror("Error", f"There was an error! {msg}")
            self.resources_message = tk.Label(self.resources_message_frame, text=f"Error! {msg}", anchor='w', width=150, bg=self.resources_message_frame["bg"])
            self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
            self.resources_message_frame.update()



    
    def download_forecast_lineitems_file(self):
        current_date = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
        # Open a file dialog to let the user choose where to save the CSV file
        file_types = [('CSV files', '*.csv'), ('Text files', '*.txt'), ('All files', '*.*')]
        file_path = asksaveasfile(initialfile = f"forecast_line_item_bulk_edit_{current_date}.csv", 
                                  defaultextension=".csv", filetypes=file_types)
        if file_path:
            with open(file_path.name, 'w', newline='') as file:
                file_path = file_path.name # get the file path string
                # Run query
                conn = self.connect_to_db()
                cursor = conn.cursor()
                query = """
                SELECT
                    fli.[forecast_line_item_id] as [Forecast Line Item ID]
                    ,fli.[forecast_id] as [Forecast ID]
                    ,f.[description] as [Forecast Description]
                    ,f.[comment] as [Forecast Comment]
                    ,f.[work_order_id] as [Work Order ID]
                    ,f.[allocation] as [Allocation]
                    ,dd.[full_date] as [Date]
                    ,fli.[forecast] as [Forecast Value]
                    ,fli.[budget] as [Budget Value]
                    ,fli.[q1f] as [Q1F Value]
                    ,fli.[q2f] as [Q2F Value]
                    ,fli.[q3f] as [Q3F Value]
                    ,fli.[forecast_spring] as [Spring Forecast Value]
                    ,fli.[forecast_summer] as [Summer Forecast Value]
                    ,CASE
                        WHEN fli.[is_actualized] = 1
                        THEN 'True'
                        ELSE 'False'
                    END as [Is Actualized]
                FROM [dbo].[forecast_line_item] as fli
                JOIN [dbo].[forecast] as f
                    ON fli.[forecast_id] = f.[forecast_id]
                JOIN [dbo].[date_dimension] as dd
                    ON fli.[date_id] = dd.[date_id]
                WHERE fli.[is_deleted] = 0
                AND f.[is_deleted] = 0
                ORDER BY fli.[forecast_id], dd.[full_date]
                """
                print(query)
                cursor.execute(query)

                rows = cursor.fetchall()

                # New empty list called 'result'. This will be written to a file.
                result = list()

                # The row name is the first entry for each entity in the description tuple.
                column_names = list()
                for i in cursor.description:
                    column_names.append(i[0])

                result.append(column_names)
                for row in rows:
                    result.append(row)

                # Write result to file.
                with open(file_path, 'w', newline='') as csvfile:
                    csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                    for row in result:
                        csvwriter.writerow(row)
                    
            # Test the database connection with the entered username and password
            conn = self.connect_to_db()
            cursor = conn.cursor()
            
            cursor.execute(f"""
            INSERT INTO [audit].[user_actions] ([action_type], [action_sql]) 
            VALUES ('export_csv_forecast_lineitem_bulk_edit', '{file_path}')
            """)
            conn.commit()



    def select_bulk_forecast_lineitems_file(self):
        self.bulk_forecast_lineitems_file_path = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        print(f"Bulk Forecast Line Items File Path: {self.bulk_forecast_lineitems_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.bulk_forecast_lineitems_file_path:
            pass
        else:
            try:
                self.resources_forecast_lineitems_bulk_label.config(text=self.bulk_forecast_lineitems_file_path)
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!")



    def upload_bulk_forecast_lineitems_file(self):
        conn = self.connect_to_db()
        cursor = conn.cursor()
                
        try:
            if self.bulk_forecast_lineitems_file_path and os.path.isfile(self.bulk_forecast_lineitems_file_path):
                self.insert_dataframe_to_sql_server_bulk(self.flat_file_to_dataframe(self.bulk_forecast_lineitems_file_path, 
                                                                                delim=',', display_df='N', encode='windows-1254'),
                                                    'staging', 'bulk_update_forecast_lineitems',
                                                    batch_size=1000, truncate_table='Y')
                try:
                    job_name = 'sp_etl_bulk_forecast_lineitems'
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
                    ,'{self.bulk_forecast_lineitems_file_path}' -- file_name 
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

                    bulk_query = "EXEC [dbo].[{job_name}]"
                    self.resources_message = tk.Label(self.resources_message_frame, text=f"Running Ingestion: {bulk_query}...", anchor='w', width=150, bg=self.resources_message_frame["bg"])
                    self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
                    self.resources_message_frame.update()
                    cursor.execute(bulk_query)
                    conn.commit()

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
                    tk.messagebox.showerror("Error", f"There was an error! {msg}")
                    self.resources_message = tk.Label(self.resources_message_frame, text=f"Error! {msg}", anchor='w', width=150, bg=self.resources_message_frame["bg"])
                    self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
                    self.resources_message_frame.update()
                    
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

            # update to completed
            self.resources_message = tk.Label(self.resources_message_frame, text=f"Completed!", anchor='w', width=150, bg=self.resources_message_frame["bg"])
            self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
            self.resources_message_frame.update()
            
        except Exception as e:
            msg = str(e)
            print(f"Failed: {msg}")
            tk.messagebox.showerror("Error", f"There was an error! {msg}")
            self.resources_message = tk.Label(self.resources_message_frame, text=f"Error! {msg}", anchor='w', width=150, bg=self.resources_message_frame["bg"])
            self.resources_message.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w')
            self.resources_message_frame.update()


    
    
    #####################
    ##### ADMIN TAB #####
    #####################
    def create_admin_portal(self):
        self.admin_frame = Frame(self.tab_admin, bg='#DCDAD5') # bg='#FFFFFF'
        self.admin_frame.pack(side='top', pady=5, fill='x')
        
        # Server
        server_frame = tk.Frame(self.tab_admin, bg='#DCDAD5')
        server_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)
        tk.Label(server_frame, text="Server Name:", anchor='w', bg='#DCDAD5').pack(side='left', padx=5, pady=5, anchor='w')
        server_options = ["business-planning-proxy.spectrumtoolbox.com", "VM0PWDCRPTD0001"]
        self.server_var = tk.StringVar()
        self.server_var.set(server_options[0])
        self.server_option = ttk.Combobox(server_frame, textvariable=self.server_var, values=server_options, width=40, height=20)
        self.server_option.configure(state="disabled")
        self.server_option.pack(side='left', padx=5, pady=5, anchor='w')
        
        # Database
        db_frame = tk.Frame(self.tab_admin, bg='#DCDAD5')
        db_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)
        tk.Label(db_frame, text="Database Name:", anchor='w', bg='#DCDAD5').pack(side='left', padx=5, pady=5, anchor='w')
        db_options = ["Compiler", "EID", "PLANNING_APP", "TEST"]
        if self.database_name in db_options:
            self.db_var = tk.StringVar(value=self.database_name)
        else:
            self.db_var = tk.StringVar(value=db_options[2])
        self.db_option = ttk.Combobox(db_frame, textvariable=self.db_var, values=db_options, width=30, height=20)
        self.db_option.pack(side='left', padx=5, pady=5, anchor='w')
        
        # # Add a separator
        # ttk.Separator(self.admin_frame, orient='horizontal').grid(row=4, column=0, columnspan=10, sticky='we', padx=20, pady=20)
        
        # Create the "Upload" button
        self.upload_frame = tk.Frame(self.tab_admin, bg='#DCDAD5')
        self.upload_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)

        self.upload_button = ttk.Button(self.upload_frame, text="Upload Files", command=self.upload_files, style="Important.TButton")
        self.upload_button.grid(row=0, column=0, columnspan=1, padx=5, pady=20, sticky='w') # pack(side='left', padx=5, pady=5, anchor='w')
        self.upload_label = tk.Label(self.upload_frame, text="", anchor='w', bg=self.upload_frame["bg"], width=100)
        self.upload_label.grid(row=0, column=1, columnspan=1, padx=5, pady=20, sticky='w') # pack(side='left', padx=5, pady=5, anchor='w')
        
        
        # GENERAL LEDGER MANUAL FILE
        gl_frame = tk.Frame(self.tab_admin, bg='#DCDAD5')
        gl_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)
        tk.Label(gl_frame, text="General Ledger File", bg=gl_frame["bg"]).pack(side='left', padx=5, pady=5, anchor='w')
        # Create the "Select File" button and file path label
        self.select_gl_button = ttk.Button(gl_frame, text="Browse Excel", command=self.select_gl_file, style="TButton")
        self.select_gl_button.pack(side='left', padx=5, pady=5, anchor='w')
    
        self.gl_label = tk.Label(gl_frame, text=" ", anchor='w', width=70, bg=gl_frame["bg"])
        self.gl_label.pack(side='left', padx=5, pady=5, anchor='w')
        
        
        # WORK ORDER
        wo_frame = tk.Frame(self.tab_admin, bg='#DCDAD5')
        wo_frame.pack(side='top', fill='both', padx=5, pady=5, expand=False)
        tk.Label(wo_frame, text="Active Work Orders File", bg=wo_frame["bg"]).pack(side='left', padx=5, pady=5, anchor='w')
        # Create the "Select File" button and file path label
        self.select_active_wo_button = ttk.Button(wo_frame, text="Browse CSV",  
                                                  command=self.select_active_wo_file,
                                                  style="TButton")
        self.select_active_wo_button.pack(side='left', padx=5, pady=5, anchor='w')
    
        self.active_wo_label = tk.Label(wo_frame, text=" ", anchor='w', width=70, bg=wo_frame["bg"])
        self.active_wo_label.pack(side='left', padx=5, pady=5, anchor='w')
                

                
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

            missing_db_col = []
            for element in db_col_headers:
                if element not in df_col_headers:
                    missing_db_col.append(element)
            
            msg_3 = f"Missing Headers:\n{str(missing_db_col)}"
            raise ValueError(f"Column headers in the DataFrame do not match with the database. Operation aborted.\n\n{msg_1}\n\n{msg_2}\n\n{msg_3}")

        
        if truncate_table == 'Y':
            # Build & Execute SQL TRUNCATE statement
            truncate_query = f"TRUNCATE TABLE {schema}.{table};"
            print(truncate_query)
            cursor.execute(truncate_query)
            conn.commit()
            print('\nSUCCESS: "' + str(truncate_query) + '"\n')
            
            self.upload_label = tk.Label(self.upload_frame, text=f"{truncate_query}", anchor='w', bg=self.upload_frame["bg"], width=100)
            self.upload_label.grid(row=0, column=1, columnspan=1, padx=5, pady=20, sticky='w')
            self.upload_frame.update()
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
            # self.upload_label = tk.Label(self.upload_frame, text=f"{info_label}", anchor='w', width=100)
            # self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.upload_label = tk.Label(self.upload_frame, text=f"{info_label}", anchor='w', bg=self.upload_frame["bg"], width=100)
            self.upload_label.grid(row=0, column=1, columnspan=1, padx=5, pady=20, sticky='w')
            self.upload_frame.update()
            print('Records left: ' + str(counter) + ' Rows Inserted: ' + str(rows_inserted) + '\n')
            
    

    def select_gl_file(self):
        self.gl_file_path = filedialog.askopenfilename(filetypes=[("Excel files", "*.xlsx;*.xls")])
        print(f"General Ledger File Path: {self.gl_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.gl_file_path:
            pass
        else:
            try:
                self.gl_label.config(text=self.gl_file_path)
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!") 
                
                
                
    def select_active_wo_file(self):
        self.active_wo_file_path = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        print(f"Active Work Orders File Path: {self.active_wo_file_path}")
        
        # If the user didn't select a file, do nothing
        if not self.active_wo_file_path:
            pass
        else:
            try:
                self.active_wo_label.config(text=self.active_wo_file_path)
            except Exception as e:
                print('Failed: '+ str(e))
                tk.messagebox.showerror("Error", "There was an error with the upload!") 
            


    def upload_files(self):
        conn = self.connect_to_db()
        cursor = conn.cursor()
                
        try:
        
            if self.gl_file_path and os.path.isfile(self.gl_file_path):
                self.insert_dataframe_to_sql_server(self.excel_file_to_dataframe(self.gl_file_path, 
                                                                                skiprows=0, skipfooter=0, display_df='N'),
                                                    'staging', 'sap_general_ledger',
                                                    batch_size=1000, truncate_table='Y')
                try:
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
                    ('sp_etl_general_ledger' -- job_name
                    ,'{self.gl_file_path}' -- file_name 
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
                    
                    gl_query = "EXEC [dbo].[sp_etl_general_ledger]"
                    cursor.execute(gl_query)
                    conn.commit()
                    
                    update_query = f"""
                    UPDATE [audit].[etl_executions]
                       SET [completed_date] = CURRENT_TIMESTAMP
                    WHERE [etl_executions_id] = (SELECT MAX([etl_executions_id]) FROM [audit].[etl_executions] WHERE [requested_by] = CURRENT_USER)
                    AND job_name = 'sp_etl_general_ledger'
                    """
                    print(update_query)
                    cursor.execute(update_query)
                    conn.commit()
                
                except Exception as e:
                    msg = str(e)
                    print(f"Failed: {msg}")
                    tk.messagebox.showerror("Error", f"There was an error! {msg}")
                    self.upload_label = tk.Label(self.upload_frame, text=f"Error! {msg}", anchor='w', width=100)
                    self.upload_label.grid(row=0, column=1, columnspan=1, padx=5, pady=20, sticky='w')
                    self.upload_frame.update()
                    
                    update_query = f"""
                    UPDATE [audit].[etl_executions]
                       SET [completed_date] = CURRENT_TIMESTAMP
                          ,[is_error] = 1
                          ,[error_message] = '{msg}'
                    WHERE [etl_executions_id] = (SELECT MAX([etl_executions_id]) FROM [audit].[etl_executions] WHERE [requested_by] = CURRENT_USER)
                    AND job_name = 'sp_etl_general_ledger'
                    """
                    cursor.execute(update_query)
                    conn.commit()
            
                        
            if self.active_wo_file_path and os.path.isfile(self.active_wo_file_path):
                self.insert_dataframe_to_sql_server(self.flat_file_to_dataframe(self.active_wo_file_path, 
                                                                                delim='|', display_df='N'),
                                                    'staging', 'work_order_detail',
                                                    batch_size=1000, truncate_table='Y')
                try:
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
                    ('sp_etl_work_order' -- job_name
                    ,'{self.active_wo_file_path}' -- file_name 
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
                    
                    wo_query = "EXEC [dbo].[sp_etl_work_order]"
                    cursor.execute(wo_query)
                    conn.commit()
                    
                    update_query = f"""
                    UPDATE [audit].[etl_executions]
                       SET [completed_date] = CURRENT_TIMESTAMP
                    WHERE [etl_executions_id] = (SELECT MAX([etl_executions_id]) FROM [audit].[etl_executions] WHERE [requested_by] = CURRENT_USER)
                    AND job_name = 'sp_etl_work_order'
                    """
                    print(update_query)
                    cursor.execute(update_query)
                    conn.commit()
                
                except Exception as e:
                    msg = str(e)
                    print(f"Failed: {msg}")
                    tk.messagebox.showerror("Error", f"There was an error! {msg}")
                    self.upload_label = tk.Label(self.upload_frame, text=f"Error! {msg}", anchor='w', width=100)
                    self.upload_label.grid(row=0, column=1, columnspan=1, padx=5, pady=20, sticky='w')
                    self.upload_frame.update()
                    
                    update_query = f"""
                    UPDATE [audit].[etl_executions]
                       SET [completed_date] = CURRENT_TIMESTAMP
                          ,[is_error] = 1
                          ,[error_message] = '{msg}'
                    WHERE [etl_executions_id] = (SELECT MAX([etl_executions_id]) FROM [audit].[etl_executions] WHERE [requested_by] = CURRENT_USER)
                    AND job_name = 'sp_etl_work_order'
                    """
                    cursor.execute(update_query)
                    conn.commit()
                    
                
            # update to completed
            self.upload_label = tk.Label(self.upload_frame, text="Completed!", anchor='w', bg=self.upload_frame["bg"], width=100)
            self.upload_label.grid(row=0, column=1, columnspan=1, padx=5, pady=20, sticky='w')
            # self.upload_label = tk.Label(self.upload_frame, text="Completed!", anchor='w', width=100)
            # self.upload_label.grid(row=5, column=1, columnspan=5, padx=5, pady=20, sticky='w')
            self.upload_frame.update()
            
        except Exception as e:
            msg = str(e)
            print(f"Failed: {msg}")
            tk.messagebox.showerror("Error", f"There was an error! {msg}")
            self.upload_label = tk.Label(self.upload_frame, text=f"Error! {msg}", anchor='w', width=100)
            self.upload_label.grid(row=0, column=1, columnspan=1, padx=5, pady=20, sticky='w')
            self.upload_frame.update()
            


if __name__ == '__main__':
    root = tk.Tk()
    root.configure(bg="#FFFFFF")
    root.focus_force()  # root.attributes('-topmost',True)
    root.state('zoomed')
    app = App(root)
    root.mainloop()