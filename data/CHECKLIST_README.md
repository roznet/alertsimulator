# SR22TG6 Checklist Extraction

This directory contains tools and data for extracting checklists from the SR22TG6 manual PDF and converting them to a structured JSON format for use in the Alert Simulator app.

## Files

- `SR22T-Checklists.pdf`: The original PDF file containing all checklists for the SR22TG6 aircraft
- `SR22T-Checklists.txt`: Text version of the PDF file for easier parsing
- `extract_checklists.py`: Python script to extract checklists from the text file and generate a JSON file
- `SR22TG6-Checklists.json`: Pre-generated JSON file with checklists for common alerts

## Using the Python Script

The `extract_checklists.py` script extracts checklists from the text file and generates a JSON file that can be used by the app. To use the script:

1. Make sure you have Python 3.6+ installed
2. Run the script:
   ```
   python extract_checklists.py
   ```

The script will generate a file called `SR22TG6-Checklists.json` in the current directory.

## How the Script Works

The script parses the `SR22T-Checklists.txt` file to identify and extract checklists using the following approach:

1. It identifies sections marked with "EMERGENCY" or "ABNORMAL" headers
2. Within these sections, it looks for checklist titles and CAS messages
3. It extracts steps, including numbered steps, conditional statements, and sub-steps
4. It organizes the steps with proper indentation and formatting
5. It outputs the checklists in a structured JSON format

## JSON Format

The JSON file contains an array of checklist items, each with the following structure:

```json
{
  "id": "unique-id",
  "alertMessage": "ALT 1",
  "title": "Low Alternator 1 Output",
  "steps": [
    {
      "id": "step-id",
      "instruction": "1. ALT 1 Circuit Breaker",
      "action": "CHECK & SET",
      "isConditional": false,
      "indentLevel": 0
    },
    // More steps...
  ]
}
```

## Available Checklists

The app includes checklists for the following alerts:

### Abnormal Procedures
- ALT 1 (Low Alternator 1 Output)
- ALT 2 (Low Alternator 2 Output)
- ALT AIR OPEN (Alternate Air Door Open)
- ANTI ICE HEAT (Anti-Ice Heat Failure)
- ANTI ICE PRESS (Anti-Ice Pressure Issue)
- ANTI ICE SPEED (Anti-Ice Speed Warning)
- AOA FAIL (Angle of Attack Failure)
- AP MISCOMPARE (Autopilot Miscompare)
- AVIONICS OFF (Avionics Master Off)
- BATT 1 (Battery 1 Issue)
- FLAP OVERSPEED (Flaps Overspeed)
- FUEL LOW TOTAL (Low Fuel Quantity)
- OIL PRESS (Low Idle Oil Pressure)
- PITOT HEAT FAIL (Pitot Heat Failure)
- PITOT HEAT REQD (Pitot Heat Required)
- START ENGAGED (Starter Engaged Warning)

### Emergency Procedures
- ENGINE FAILURE (Engine Failure In Flight)
- ENGINE FIRE (Engine Fire In Flight)
- CABIN FIRE (Cabin Fire In Flight)
- ELECTRICAL FIRE (Electrical Fire In Flight)
- EMERGENCY DESCENT (Emergency Descent)
- INADVERTENT ICING (Inadvertent Icing Encounter)

## Using the Checklist Feature in the App

When an alert is displayed in the app, you can access the corresponding checklist by:

1. Clicking the eye icon next to the alert message, or
2. Clicking the "View Checklist" button in the alert details panel

The checklist will be displayed in a modal sheet with:
- The checklist title
- The alert message
- A list of steps with proper formatting for:
  - Numbered steps
  - Conditional statements (shown in blue)
  - Indented sub-steps
  - Actions (shown in bold)

## Adding More Checklists

To add more checklists to the app:

1. Update the `extract_checklists.py` script to improve the parsing logic if needed
2. Run the script to generate an updated JSON file
3. Add new cases to the `loadChecklist()` method in `ChecklistViewImplementation.swift`

## Manual Editing

If the automatic extraction doesn't work well for some checklists, you can manually edit the JSON file or add hardcoded checklists directly in the `ChecklistViewImplementation.swift` file. Make sure to follow the same structure as the existing entries. 