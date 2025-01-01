#!/usr/bin/env python3

import csv
import sqlite3
import urllib.request
import os
import pandas as pd
import json

def excel_to_json(excel_file, sheet_name, json_file):
    # Load the Excel file
    df = pd.read_excel(excel_file, sheet_name=sheet_name)
    df = df.fillna('')  # Replace NaN values with empty strings
    
    # Convert the DataFrame to a list of dictionaries
    data = df.to_dict(orient='records')
    
    # Write the JSON data to a file
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    
    print(f"Data successfully converted to {json_file}")

# Example Usage
excel_to_json('AlertsToSimulate.xlsx', sheet_name=0, json_file='AlertsToSimulate.json')
