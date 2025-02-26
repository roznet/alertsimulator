#!/usr/bin/env python3

import argparse
import pandas as pd
import json
from datetime import datetime

def excel_to_json(excel_file, sheet_name, json_file, version=None):
    # Load the Excel file
    df = pd.read_excel(excel_file, sheet_name=sheet_name)
    df = df.fillna('')  # Replace NaN values with empty strings
    
    # Convert the DataFrame to a list of dictionaries for alerts
    alerts = df.to_dict(orient='records')
    
    # If no version provided, use timestamp-based version
    if version is None:
        version = datetime.now().strftime("%Y.%m.%d.%H%M")
    
    # Create the AlertsData structure
    alerts_data = {
        "version": version,
        "alerts": alerts
    }
    
    # Write the JSON data to a file
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(alerts_data, f, ensure_ascii=False, indent=4)
    
    print(f"Data successfully converted to {json_file} with version {version}")

def main():
    parser = argparse.ArgumentParser(description='Convert Excel file to JSON with versioning for Alert Simulator')
    parser.add_argument('--excel', '-e', default='AlertsToSimulate.xlsx',
                      help='Input Excel file (default: AlertsToSimulate.xlsx)')
    parser.add_argument('--sheet', '-s', type=int, default=0,
                      help='Sheet number in Excel file (default: 0)')
    parser.add_argument('--output', '-o', default='AlertsToSimulate.json',
                      help='Output JSON file (default: AlertsToSimulate.json)')
    parser.add_argument('--version', '-v',
                      help='Version number (default: timestamp-based version YYYY.MM.DD.HHMM)')
    
    args = parser.parse_args()
    
    excel_to_json(args.excel, args.sheet, args.output, args.version)

if __name__ == "__main__":
    main()
