#!/usr/bin/env python3
"""
Extract checklists from the SR22T-Checklists.txt file and generate a JSON file.

Line patterns:
 #SECTION like #NORMAL, #ABNORMAL and #EMERGENCY are section headers single # followed by all caps
 ##title are sub section headers 
 ###tile are checklists
 1. description ....... ACTION are checklist item
 a. description .... ACTION are sub checklist item
 (1)  descriptoin .... ACTOIN are sub sub checklist item
 Line in all caps followed by Caution or Advisory are CAS messages, the following line in all cap is the cas message repeated
 line of the form: PFD Alerts Window: "text description" provide the text description for the current CAS messaeg relevant for that checklist
 line of text that don't have normal text during a checklist are comments for the checklist

 items spans multiple line, until the next pattern they should be merged.
"""

import json
import re
import os
import uuid
import argparse
from typing import Dict, List, Optional, Union
from dataclasses import dataclass, asdict

# Define the input and output files
INPUT_FILE = "SR22T-Checklists.txt"
OUTPUT_FILE = "SR22TG6-Checklists.json"

@dataclass
class ChecklistStep:
    id: str
    instruction: str
    action: str
    is_conditional: bool
    indent_level: int
    step_number: Optional[str]
    sub_steps: List['ChecklistStep']

@dataclass
class Checklist:
    id: str
    title: str
    section: str
    subsection: Optional[str]
    cas: Optional[str]
    cas_type: Optional[str]
    cas_description: Optional[str]
    alert_message: Optional[str]
    steps: List[ChecklistStep]

def parse_checklist(file_path: str, output_path: str, verbose: bool = False) -> None:
    """
    Parse the checklist file and generate a JSON output.
    
    Args:
        file_path: Path to the input text file
        output_path: Path where the JSON file will be saved
        verbose: Whether to print detailed information about the parsing process
    """
    checklists: List[Checklist] = []
    current_checklist: Optional[Checklist] = None
    current_step: Optional[ChecklistStep] = None
    current_section: Optional[str] = None
    current_subsection: Optional[str] = None
    current_cas: Optional[str] = None
    current_cas_type: Optional[str] = None
    current_cas_description: Optional[str] = None
    line_count = 0
    
    # Define regex patterns
    section_pattern = re.compile(r"#([A-Z].+)$")
    subsection_pattern = re.compile(r"^##([A-Z].+)$")
    checklist_pattern = re.compile(r"^###(.+)$")
    item_pattern = re.compile(r"^(\s*)(?:(\d+)\.|\((\d+)\)|([a-z])\.)\s+(.+?)(?:\.\.\.\s*(.+))?$")
    cas_message_pattern = re.compile(r"^([A-Z][A-Z0-9 ]+)(?:\s+\(([^)]+)\))?(?:\s*-\s*(.+))?$")
    
    if verbose:
        print(f"Opening input file: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for i, line in enumerate(lines, 1):
        line_count += 1
        line = line.rstrip()
        
        # Skip empty lines
        if not line:
            continue
        
        # Check for section header (#EMERGENCY, #ABNORMAL, #NORMAL)
        section_match = section_pattern.match(line)
        if section_match:
            current_section = section_match.group(1)
            if verbose:
                print(f"Found section: {current_section} at line {i}")
            continue
        
        # Check for subsection header
        subsection_match = subsection_pattern.match(line)
        if subsection_match:
            current_subsection = subsection_match.group(1)
            if verbose:
                print(f"Found subsection: {current_subsection} at line {i}")
            continue
        
        # Check for checklist title
        checklist_match = checklist_pattern.match(line)
        if checklist_match:
            if current_checklist:
                checklists.append(current_checklist)
            
            # Create new checklist
            current_checklist = Checklist(
                id=str(uuid.uuid4()),
                title=checklist_match.group(1).strip(),
                section=current_section or "",
                subsection=current_subsection,
                steps=[],
                cas=current_cas,
                cas_type=current_cas_type,
                cas_description=current_cas_description,
                alert_message=current_cas
            )
            current_step = None
            current_cas = None
            current_cas_type = None
            current_cas_description = None
            if verbose:
                print(f"Found checklist: {current_checklist.title} at line {i}")
            continue
        
        # Check for CAS message
        cas_match = cas_message_pattern.match(line)
        if cas_match:
            current_cas = cas_match.group(1).strip()
            current_cas_type = cas_match.group(2).strip() if cas_match.group(2) else None
            current_cas_description = cas_match.group(3).strip() if cas_match.group(3) else None
            if verbose:
                print(f"Found CAS message: {current_cas} at line {i}")
            continue
        
        # Check for checklist step
        step_match = item_pattern.match(line)
        if step_match and current_checklist:
            indent, num1, num2, num3, content, action = step_match.groups()
            
            # Calculate indent level (2 spaces = 1 level)
            indent_level = len(indent) // 2
            
            # Split content into instruction and action
            instruction = content.strip()
            action = action.strip() if action else ""
            
            # Remove dots from action text
            if action:
                action = re.sub(r'\.+', '', action).strip()
            
            # Check if step is conditional
            is_conditional = instruction.lower().startswith(('if', 'when', 'verify'))
            
            # Determine step number format
            step_number = None
            if num1:  # "1", "2", etc.
                step_number = num1
            elif num2:  # "(1)", "(2)", etc.
                step_number = f"({num2})"
            elif num3:  # "a", "b", etc.
                step_number = num3
            
            new_step = ChecklistStep(
                id=str(uuid.uuid4()),
                instruction=instruction,
                action=action,
                is_conditional=is_conditional,
                indent_level=indent_level,
                step_number=step_number,
                sub_steps=[]
            )
            
            # Add step to appropriate parent based on indentation and number format
            if indent_level == 0:
                current_checklist.steps.append(new_step)
                current_step = new_step
            elif current_step and indent_level > current_step.indent_level:
                current_step.sub_steps.append(new_step)
            elif current_checklist.steps:
                # Find appropriate parent based on indentation
                parent = current_checklist.steps[-1]
                while parent.sub_steps and parent.sub_steps[-1].indent_level >= indent_level:
                    parent = parent.sub_steps[-1]
                parent.sub_steps.append(new_step)
                current_step = new_step
            
            if verbose:
                print(f"Found step: {step_number} - {instruction} at line {i}")
            continue
    
    # Add the last checklist
    if current_checklist:
        checklists.append(current_checklist)
    
    if verbose:
        print(f"\nProcessing complete:")
        print(f"Total lines processed: {line_count}")
        print(f"Total checklists found: {len(checklists)}")
        print(f"Writing output to: {output_path}")
    
    # Convert dataclasses to dictionaries for JSON serialization
    def dataclass_to_dict(obj):
        if isinstance(obj, (Checklist, ChecklistStep)):
            return {k: dataclass_to_dict(v) for k, v in asdict(obj).items()}
        elif isinstance(obj, list):
            return [dataclass_to_dict(item) for item in obj]
        return obj
    
    # Filter out empty checklists and those without alert messages
    checklists = [c for c in checklists if c.alert_message and c.steps]
    
    with open(output_path, 'w', encoding='utf-8') as json_file:
        json.dump(dataclass_to_dict(checklists), json_file, indent=4)

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Extract checklists from SR22T-Checklists.txt and generate a JSON file.')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose output', default=True)
    parser.add_argument('-i', '--input', help='Input file path (default: SR22T-Checklists.txt)')
    parser.add_argument('-o', '--output', help='Output file path (default: SR22TG6-Checklists.json)')
    
    args = parser.parse_args()
    
    # Get the directory where the script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Use command line arguments or defaults
    input_file = args.input or INPUT_FILE
    output_file = args.output or OUTPUT_FILE
    
    # Construct full paths
    input_path = os.path.join(script_dir, input_file)
    output_path = os.path.join(script_dir, output_file)
    
    # Check if input file exists
    if not os.path.exists(input_path):
        print(f"Error: Input file '{input_file}' not found in {script_dir}")
        return
    
    try:
        print(f"Processing {input_file}...")
        parse_checklist(input_path, output_path, args.verbose)
        print(f"Successfully generated {output_file}")
    except Exception as e:
        print(f"Error processing file: {str(e)}")

if __name__ == "__main__":
    main()
