#!/usr/bin/env python3
"""
Extract checklists from the SR22T-Checklists.pdf file and generate a JSON file.
"""

import json
import re
import subprocess
import os
import uuid

# Define the output file
OUTPUT_FILE = "SR22TG6-Checklists.json"
PDF_FILE = "SR22T-Checklists.pdf"

# Define the alerts to extract from the PDF
ALERTS = [
    "ALT 1", "ALT 2", "ALT AIR OPEN", "ANTI ICE HEAT", "ANTI ICE PRESS", 
    "ANTI ICE SPEED", "AOA FAIL", "AP MISCOMPARE", "AP/PFD DIF ADC", 
    "AP/PFD DIF AHRS", "AVIONICS OFF", "BATT 1", "FLAP OVERSPEED", 
    "FUEL IMBALANCE", "FUEL LOW TOTAL", "ICE DETECT FAIL", "OIL PRESS", 
    "OIL TEMP", "PITOT HEAT FAIL", "PITOT HEAT REQD", "START ENGAGED"
]

def extract_text_from_pdf():
    """Extract text from the PDF file using pdftotext."""
    try:
        result = subprocess.run(
            ["pdftotext", "-layout", PDF_FILE, "-"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error extracting text from PDF: {e}")
        return ""

def extract_checklist(text, alert):
    """Extract the checklist for a specific alert."""
    # Pattern to find the alert section
    pattern = rf"{alert}\s+(?:Caution|Warning)\s+\(Failure\)\s*\n+\s*{alert}\s*\n+\s*(.*?)(?:\n\s*\n|\n[A-Z])"
    
    # Try to find the checklist section
    match = re.search(pattern, text, re.DOTALL | re.MULTILINE)
    
    if not match:
        print(f"Could not find checklist for {alert}")
        return None
    
    # Extract the title and steps
    checklist_text = match.group(1).strip()
    
    # Parse the steps
    steps = []
    indent_level = 0
    
    # Split the text into lines
    lines = checklist_text.split("\n")
    
    for i, line in enumerate(lines):
        line = line.strip()
        if not line:
            continue
        
        # Check if this is a conditional step
        is_conditional = "if" in line.lower() or ":" in line
        
        # Determine indentation level
        if is_conditional:
            indent_level += 1
        elif i > 0 and lines[i-1].strip().endswith(":"):
            indent_level = max(1, indent_level)
        
        # Split the instruction and action
        parts = re.split(r'\s{2,}|\t', line, 1)
        
        if len(parts) == 2:
            instruction, action = parts
        else:
            instruction = line
            action = ""
        
        # Clean up the instruction and action
        instruction = instruction.strip()
        action = action.strip()
        
        # Add the step
        steps.append({
            "id": str(uuid.uuid4()),
            "instruction": instruction,
            "action": action,
            "isConditional": is_conditional,
            "indentLevel": indent_level
        })
        
        # Reset indent level after conditional
        if is_conditional:
            indent_level -= 1
    
    # Create the checklist item
    checklist_item = {
        "id": str(uuid.uuid4()),
        "alertMessage": alert,
        "title": f"{alert} Checklist",
        "steps": steps
    }
    
    return checklist_item

def main():
    """Main function to extract checklists and generate JSON."""
    # Extract text from the PDF
    text = extract_text_from_pdf()
    
    if not text:
        print("Failed to extract text from PDF")
        return
    
    # Extract checklists for each alert
    checklists = []
    
    for alert in ALERTS:
        checklist = extract_checklist(text, alert)
        if checklist:
            checklists.append(checklist)
    
    # Write the checklists to a JSON file
    with open(OUTPUT_FILE, "w") as f:
        json.dump(checklists, f, indent=2)
    
    print(f"Extracted {len(checklists)} checklists to {OUTPUT_FILE}")

if __name__ == "__main__":
    main() 