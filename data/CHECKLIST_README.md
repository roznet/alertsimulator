# SR22TG6 Checklist Extraction

This directory contains tools and data for extracting checklists from the SR22TG6 manual PDF and converting them to a structured JSON format for use in the Alert Simulator app.

## Files

- `SR22T-Checklists.pdf`: The original PDF file containing all checklists for the SR22TG6 aircraft
- `extract_checklists.py`: Python script to extract checklists from the PDF and generate a JSON file
- `SR22TG6-Checklists.json`: Pre-generated JSON file with checklists for common alerts

## Using the Python Script

The `extract_checklists.py` script extracts checklists from the PDF file and generates a JSON file that can be used by the app. To use the script:

1. Make sure you have Python 3.6+ installed
2. Install the required dependencies:
   ```
   pip install pdftotext
   ```
3. Run the script:
   ```
   python extract_checklists.py
   ```

The script will generate a file called `SR22TG6-Checklists.json` in the current directory.

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

## Adding More Checklists

To add more checklists to the JSON file:

1. Edit the `ALERTS` list in `extract_checklists.py` to include the alert messages you want to extract
2. Run the script again to generate an updated JSON file
3. Copy the generated JSON file to the app's resources directory

## Manual Editing

If the automatic extraction doesn't work well for some checklists, you can manually edit the JSON file. Make sure to follow the same structure as the existing entries.

## Integration with the App

The app loads the JSON file from its resources directory and displays the appropriate checklist when an alert is shown. If the JSON file is not found or if a checklist for a specific alert is not available, the app will fall back to hardcoded checklists for the most common alerts. 