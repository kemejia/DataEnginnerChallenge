# -*- coding: utf-8 -*-
"""
Created on Sat Jun 18 18:24:05 2022

@author: Carlos Mejia
"""

#import csv
#import sqlalchemy as db
#from sqlalchemy import create_engine, types, inspect
import pandas as pd
from flask import Flask, jsonify, request
import pyodbc
import warnings

#ignore warnings
warnings.filterwarnings("ignore")

# initialize our Flask application
app= Flask(__name__)
@app.route("/InsertData", methods=["POST"])
    
#API security
def insertData():
    #convert the request to JSON 
    posted_data = request.get_json()
    
    #security
    headers = request.headers
    auth = headers.get("X-Api-Key")
    if auth == 'Qwerty123*':
        print("message: OK: Authorized, 200")
    else:
        return jsonify({"message": "ERROR: Unauthorized"}), 401
    
    #validate if the request coming is true
    if request.data:
        
        #read CSV
        url = 'https://drive.google.com/file/d/14JcOSJAWqKOUNyadVZDPm7FplA7XYhrU/view?usp=sharing'
        path = 'https://drive.google.com/uc?export=download&id=' + url.split('/')[-2]
        df = pd.read_csv(path)
                  
        #connection database
        #conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=DESKTOP-L80GCAR;DATABASE=DBEngineer;UID=DataEngineer;PWD=Qwerty123*')
        conn = pyodbc.connect('DRIVER={SQL Server};SERVER=DESKTOP-L80GCAR;DATABASE=DBEngineer;UID=DataEngineer;PWD=Qwerty123*')
        cursor = conn.cursor()
        
        #Delete Staging table
        delete_query = "DELETE FROM TripsStaging"
        cursor.execute(delete_query)
        conn.commit()
            
        #Load staging table TripsStaging
        for i in df.index:  
            insert_into = "INSERT INTO TripsStaging(Region,OriginCoord,DestinationCoord,DateTimeTrip,DataSource)"
            insert_query = insert_into + "VALUES('"+ df["region"][i]+ "'"",'" + df["origin_coord"][i] + "','" + df["destination_coord"][i]+"','"+ df["datetime"][i]+"','"+ df["datasource"][i]+"')"       
            cursor.execute(insert_query)
            conn.commit()
            
        #Load final table Trip
        sp_query = "EXECUTE usp_loadTrip"
        cursor.execute(sp_query)
        conn.commit()
        
        #Develop a way to obtain the weekly average number of trips for an area
        try:
            sp_average = pd.read_sql_query("EXECUTE usp_RegionWeeklyAvg", conn)
            dfw = pd.DataFrame(sp_average, columns=['Region', 'RegionWeeklyAvg'])
            #return print(dfw)
       
        except:
            print("Error: unable to convert the data")
        
        
        #Develop a way to inform the user about the status of the data ingestion without using a polling solution.       
        return jsonify({"message" : "Successfully stored",
                        "dfRegionWeeklyAvg" : dfw.to_json()}) 
    
    
    
    else:
        return jsonify({"message" : "Error stored"}) 
    
    
    conn.close()

if __name__ == '__main__':
    app.run(debug=True)

    
