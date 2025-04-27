#!/usr/bin/env python3

"""
Alert Simulator - Excel to JSON Converter

This script converts Excel files containing alert definitions into a JSON format
suitable for the Alert Simulator. It supports versioning of the alert definitions
and handles data cleaning (replacing NaN values with empty strings).

The script expects an Excel file with columns that will be converted into alert
properties. Each row in the Excel sheet represents a single alert definition.

Example Excel format:
    | alert_id | severity | message | ... |
    |----------|----------|---------|-----|
    | ALERT001 | HIGH     | Message | ... |
    | ALERT002 | MEDIUM   | Message | ... |

The output JSON format will be:
{
    "version": "YYYY.MM.DD.HHMM",
    "alerts": [
        {
            "alert_id": "ALERT001",
            "severity": "HIGH",
            "message": "Message",
            ...
        },
        ...
    ]
}

Usage:
    python update_alerts.py --excel alerts.xlsx --sheet 0 --output alerts.json
    python update_alerts.py -e alerts.xlsx -s 0 -o alerts.json -v 1.0.0
    python update_alerts.py --validate -e alerts.xlsx -j alerts.json
"""

import argparse
import pandas as pd
import json
from datetime import datetime
from collections import defaultdict
from typing import Dict, List, Tuple

def analyze_alerts(data: List[Dict]) -> Dict:
    """
    Analyze alerts data and return statistics about planes and alert types.
    
    Args:
        data (List[Dict]): List of alert dictionaries
        
    Returns:
        Dict: Statistics about planes and alert types
    """
    stats = {
        'total_alerts': len(data),
        'planes': defaultdict(lambda: defaultdict(int)),
        'alert_types': defaultdict(int)
    }
    
    for alert in data:
        plane = alert.get('aircraftName', 'Unknown')
        alert_type = alert.get('alertType', 'Unknown')
        stats['planes'][plane][alert_type] += 1
        stats['alert_types'][alert_type] += 1
    
    return stats

def print_analysis(excel_stats: Dict, json_stats: Dict):
    """
    Print the analysis results in a table format comparing Excel and JSON data.
    
    Args:
        excel_stats (Dict): Statistics from Excel file
        json_stats (Dict): Statistics from JSON file
    """
    print("\n=== Validation Results ===")
    print(f"Total alerts: Excel: {excel_stats['total_alerts']} | JSON: {json_stats['total_alerts']}")
    
    # Get all unique combinations of plane and alert type
    all_combinations = set()
    for plane in set(excel_stats['planes'].keys()) | set(json_stats['planes'].keys()):
        for alert_type in set(excel_stats['alert_types'].keys()) | set(json_stats['alert_types'].keys()):
            all_combinations.add((plane, alert_type))
    
    # Print header
    print("\nPlane | Alert Type | Excel | JSON | Status")
    print("-" * 50)
    
    # Print each combination
    for plane, alert_type in sorted(all_combinations):
        excel_count = excel_stats['planes'][plane].get(alert_type, 0)
        json_count = json_stats['planes'][plane].get(alert_type, 0)
        status = "✅" if excel_count == json_count else "❌"
        print(f"{plane} | {alert_type} | {excel_count:6d} | {json_count:6d} | {status}")

def validate_files(excel_file: str, sheet_name: int, json_file: str) -> bool:
    """
    Validate that Excel and JSON files contain the same data.
    
    Args:
        excel_file (str): Path to the Excel file
        sheet_name (int): Sheet number in Excel file
        json_file (str): Path to the JSON file
        
    Returns:
        bool: True if files are in sync, False otherwise
    """
    # Load Excel data
    df = pd.read_excel(excel_file, sheet_name=sheet_name)
    df = df.fillna('')
    excel_alerts = df.to_dict(orient='records')
    
    # Load JSON data
    with open(json_file, 'r', encoding='utf-8') as f:
        json_data = json.load(f)
    json_alerts = json_data.get('alerts', [])
    
    # Analyze both sources
    excel_stats = analyze_alerts(excel_alerts)
    json_stats = analyze_alerts(json_alerts)
    
    # Print analysis in table format
    print_analysis(excel_stats, json_stats)
    
    # Check if files are in sync
    is_sync = True
    for plane in set(excel_stats['planes'].keys()) | set(json_stats['planes'].keys()):
        for alert_type in set(excel_stats['alert_types'].keys()) | set(json_stats['alert_types'].keys()):
            excel_count = excel_stats['planes'][plane].get(alert_type, 0)
            json_count = json_stats['planes'][plane].get(alert_type, 0)
            if excel_count != json_count:
                is_sync = False
                break
        if not is_sync:
            break
    
    if is_sync:
        print("\n✅ Files are in sync!")
    else:
        print("\n❌ Files are not in sync!")
    
    return is_sync

def excel_to_json(excel_file, sheet_name, json_file, version=None):
    """
    Convert Excel file containing alert definitions to JSON format.

    Args:
        excel_file (str): Path to the input Excel file
        sheet_name (int): Index of the sheet to process (0-based)
        json_file (str): Path where the output JSON file will be saved
        version (str, optional): Version number for the alerts. If not provided,
                               a timestamp-based version will be generated
                               (format: YYYY.MM.DD.HHMM)

    Returns:
        None

    Raises:
        FileNotFoundError: If the input Excel file doesn't exist
        ValueError: If the specified sheet doesn't exist
        PermissionError: If there are issues writing to the output file
    """
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
    """
    Main entry point for the script. Parses command line arguments and
    triggers the Excel to JSON conversion or validation.
    """
    parser = argparse.ArgumentParser(
        description='Convert Excel file to JSON with versioning for Alert Simulator',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Convert using default settings
    python update_alerts.py

    # Convert specific Excel file and sheet
    python update_alerts.py -e custom_alerts.xlsx -s 1

    # Convert with custom version number
    python update_alerts.py -e alerts.xlsx -v 1.0.0

    # Convert with custom output file
    python update_alerts.py -e alerts.xlsx -o custom_output.json

    # Validate Excel and JSON files
    python update_alerts.py --validate -e alerts.xlsx -j alerts.json
        """
    )
    parser.add_argument('--excel', '-e', default='AlertsToSimulate.xlsx',
                      help='Input Excel file (default: AlertsToSimulate.xlsx)')
    parser.add_argument('--sheet', '-s', type=int, default=0,
                      help='Sheet number in Excel file (default: 0)')
    parser.add_argument('--output', '-o', default='AlertsToSimulate.json',
                      help='Output JSON file (default: AlertsToSimulate.json)')
    parser.add_argument('--version', '-v',
                      help='Version number (default: timestamp-based version YYYY.MM.DD.HHMM)')
    parser.add_argument('--validate', action='store_true',
                      help='Validate Excel and JSON files instead of converting')
    
    args = parser.parse_args()
    
    if args.validate:
        validate_files(args.excel, args.sheet, args.output)
    else:
        excel_to_json(args.excel, args.sheet, args.output, args.version)

if __name__ == "__main__":
    main()
