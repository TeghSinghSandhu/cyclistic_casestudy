#Importing necessary packages
import os
import glob
import pandas as pd
import mysql.connector
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError


#Defining and obtaining file paths and changing the cuurent working directory
path= 'C:/Case Study 2 Cyclistic/Clean Data/CSV'

q3_path = 'C:/Case Study 2 Cyclistic/Clean Data/CSV/Q3 2022/'
q4_path = 'C:/Case Study 2 Cyclistic/Clean Data/CSV/Q4 2022/'
q1_path = 'C:/Case Study 2 Cyclistic/Clean Data/CSV/Q1 2023/'
q2_path = 'C:/Case Study 2 Cyclistic/Clean Data/CSV/Q2 2023/'

os.chdir(path)

q3_files= glob.glob(os.path.join(q3_path , "*.csv"))
q4_files= glob.glob(os.path.join(q4_path , "*.csv"))
q1_files= glob.glob(os.path.join(q1_path , "*.csv"))
q2_files= glob.glob(os.path.join(q2_path , "*.csv"))


#Reading and concatenating the csv files into a pandas DataFrame 
                #Q3_2022
q3_df = []

for file in q3_files:
    data = pd.read_csv(file, index_col = None, header = 0)
    q3_df.append(data)  
    
q3_frame = pd.concat(q3_df, axis=0, ignore_index=True)

                #Q4_2022
q4_df = []

for file in q4_files:
    data = pd.read_csv(file, index_col = None, header = 0)
    q4_df.append(data)  
    
q4_frame = pd.concat(q4_df, axis=0, ignore_index=True)

                #Q1_2023
q1_df = []

for file in q1_files:
    data = pd.read_csv(file, index_col = None, header = 0)
    q1_df.append(data)  
    
q1_frame = pd.concat(q1_df, axis=0, ignore_index=True)

                #Q2_2023
q2_df = []

for file in q2_files:
    data = pd.read_csv(file, index_col = None, header = 0)
    q2_df.append(data)  
    
q2_frame = pd.concat(q2_df, axis=0, ignore_index=True)


#Dropping any Null rows and rechecking to make sure
q3_frame = q3_frame.dropna()
q4_frame = q4_frame.dropna()
q1_frame = q1_frame.dropna()
q2_frame = q2_frame.dropna()

q3_frame.isnull().sum()
q4_frame.isnull().sum()
q1_frame.isnull().sum()
q2_frame.isnull().sum()


#Splitting the DataFrames into chunks of 10,000 records per chunk 
                #Q3_2022
batch_no = 1

for chunk in pd.read_csv('q3_data.csv', chunksize = 10000):
    chunk.to_csv('q3_data' + str(batch_no) + '.csv', index = False)
    batch_no += 1

                #Q4_2022
batch_no = 1

for chunk in pd.read_csv('q4_data.csv', chunksize = 10000):
    chunk.to_csv('q4_data' + str(batch_no) + '.csv', index = False)
    batch_no += 1

                #Q1_2023
batch_no = 1

for chunk in pd.read_csv('q1_data.csv', chunksize = 10000):
    chunk.to_csv('q1_data' + str(batch_no) + '.csv', index = False)
    batch_no += 1

                #Q2_2023
batch_no = 1

for chunk in pd.read_csv('q2_data.csv', chunksize = 10000):
    chunk.to_csv('q2_data' + str(batch_no) + '.csv', index = False)
    batch_no += 1


#Importing the chunks onto a MySQL server 
                #Q3_2022
# MySQL database connection settings
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '########',
    'database': 'cyclistic_case_study',
}

# Directory where your CSV chunks are stored
csv_directory = 'C:\Case Study 2 Cyclistic\Clean Data\CSV\Q3 2022\Chunks'    

# Create a MySQL database connection using SQLAlchemy
engine = create_engine(f"mysql+mysqlconnector://{db_config['user']}:
                       {db_config['password']}@{db_config['host']}/{db_config['database']}")

try:
    # Iterate through CSV files and import into MySQL
    for filename in os.listdir(csv_directory):
        if filename.endswith('.csv'):
            file_path = os.path.join(csv_directory, filename)

            # Read the CSV file into a DataFrame
            df = pd.read_csv(file_path)

            # Insert data into the MySQL table (modify table name)
            table_name = 'q1_2023_data'      ##
            df.to_sql(name=table_name, con=engine, if_exists='append', index=False)

    print("Data import completed successfully!")

except SQLAlchemyError as e:
    print(f"An error occurred during data import: {e}")

finally:
    # Close the database connection
    engine.dispose()

    #Use the same code except change the file path for each quarter
