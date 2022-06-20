# -*- coding: utf-8 -*-
"""
Created on Sat Jun 18 18:24:05 2022

@author: Carlos Mejia
"""

import csv
import pandas as pd
import sqlalchemy as db
from sqlalchemy import create_engine, types, inspect
from flask import Flask, jsonify, request
import pyodbc

    # initialize our Flask application
app= Flask(__name__)
@app.route("/InsertData", methods=["POST"])

#  main thread of execution to start the server

    
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
    
    #acatar la orden de true para actualizar que viene del request
    print('body..............................................')
    print(str(request.data))
    
    if request.data:
        print('inside body')
        #read CSV
        url = 'https://drive.google.com/file/d/14JcOSJAWqKOUNyadVZDPm7FplA7XYhrU/view?usp=sharing'
        path = 'https://drive.google.com/uc?export=download&id=' + url.split('/')[-2]
        df = pd.read_csv(path)
        #print(df.shape)
            
        #connection database
        #conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=DESKTOP-L80GCAR;DATABASE=DBEngineer;UID=DataEngineer;PWD=Qwerty123*')
        conn = pyodbc.connect('DRIVER={SQL Server};SERVER=DESKTOP-L80GCAR;DATABASE=DBEngineer;UID=DataEngineer;PWD=Qwerty123*')
        cursor = conn.cursor()
            
        
        for i in df.index:  
            insert_into = "INSERT INTO TripsTemp(Region,OriginCoord,DestinationCoord,DateTimeTrip,DataSource)"
            insert = insert_into + "VALUES('"+ df["region"][i]+ "'"",'" + df["origin_coord"][i] + "','" + df["destination_coord"][i]+"','"+ df["datetime"][i]+"','"+ df["datasource"][i]+"')"       
            cursor.execute(insert)
            #commit the transaction
            conn.commit()
            
        return jsonify(str("Successfully stored")) 

    else:
        return jsonify(str("Error stored")) 

if __name__ == '__main__':
    app.run(debug=True)

    
    
    # =============================================================================
    # funciona el select
    #     cursor.execute("SELECT * FROM TripsTemp")
    #     tables = cursor.fetchall()
    #     
    #     
    #     for row in cursor.columns(table='TripsTemp'):
    #         print (row.column_name)
    #         for field in row:
    #             print (field)
    # =============================================================================
    # =============================================================================
    #     engine = create_engine('mssql+pyodbc://DataEngineer:Qwerty123*@DESKTOP-L80GCAR/DataEngineer')
    #     engine = db.create_engine('mssql://DESKTOP-L80GCAR\\SQLEXPRESS/DataEngineer?trusted_connection=yes')
    #     inspector = inspect(engine)
    #     inspector.get_columns('TripsTemp')
    #     
    #     
    #     metadata = db.metadata()
    #     TripsTemp = db.Table('TripsTemp', metadata, autoload=True, autoload_with=engine) 
    #     
    #     connection =  engine.connect()
    #     query = db.select([TripsTemp])
    #     result = connection.execute(query)
    #     resultSet = result.fetchall()
    #     resultSet[:3]
    # =============================================================================
        

