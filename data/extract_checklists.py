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
from typing import Dict, List, Optional, Union, Tuple
from dataclasses import dataclass, asdict

# Define the input and output files
INPUT_FILE = "S22TG6-Checklists.txt"
OUTPUT_FILE = "S22TG6-Checklists.json"

@dataclass
class ChecklistStep:
    instruction: str
    action: str
    is_conditional: bool
    indent_level: int
    step_number: Optional[str]
    sub_steps: List['ChecklistStep']

@dataclass
class Checklist:
    title: str
    section: str
    subsection: Optional[str]
    alert: Optional[str]
    alert_type: Optional[str]
    alert_message: Optional[str]
    steps: List[ChecklistStep]

class ChecklistParser:
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.checklists: List[Checklist] = []
        self.current_checklist: Optional[Checklist] = None
        self.current_step: Optional[ChecklistStep] = None
        self.current_section: Optional[str] = None
        self.current_subsection: Optional[str] = None
        self.current_alert: Optional[str] = None
        self.current_alert_type: Optional[str] = None
        self.pending_pfd_alert: Optional[str] = None
        self.line_count = 0
        
        # Define regex patterns
        self.patterns = {
            'section': re.compile(r"#([A-Z].+)$"),
            'subsection': re.compile(r"^##([A-Z].+)$"),
            'checklist': re.compile(r"^###(.+)$"),
            'item': re.compile(r"^(\s*)(?:(\d+)\.|\((\d+)\)|([a-z])\.)\s+(.+?)(?:\.\.\.\s*(.+))?$"),
            'cas_message': re.compile(r"^([A-Z][A-Z0-9 ]+)(?: (Warning|Advisory|Caution))?$"),
            'pfd_alert': re.compile(r'^PFD Alerts Window: [“"]([^“”"]*)[”"]$'),
            'unnumbered': re.compile(r"^(\s*)(?!\d+\.|\(\d+\)|[a-z]\.)([^#].+?)(?:\.\.\.\s*(.+))?$")
        }

    def create_checklist_step(self, instruction: str, action: str, indent_level: int, 
                            step_number: Optional[str] = None) -> ChecklistStep:
        """Create a new ChecklistStep with the given parameters."""
        is_conditional = instruction.lower().startswith(('if', 'when', 'verify'))
        return ChecklistStep(
            instruction=instruction,
            action=action,
            is_conditional=is_conditional,
            indent_level=indent_level,
            step_number=step_number,
            sub_steps=[]
        )

    def find_parent_step(self, indent_level: int) -> Optional[ChecklistStep]:
        """Find the appropriate parent step for the current indent level."""
        if not self.current_checklist:
            return None
            
        step_stack = []
        
        # Build stack of potential parent steps
        for step in reversed(self.current_checklist.steps):
            if step.indent_level < indent_level:
                step_stack.append(step)
            
            # Check substeps recursively
            current = step
            while current.sub_steps:
                last_substep = current.sub_steps[-1]
                if last_substep.indent_level < indent_level:
                    step_stack.append(last_substep)
                current = last_substep
        
        # Find the closest parent with lower indent level
        for potential_parent in step_stack:
            if potential_parent.indent_level < indent_level:
                return potential_parent
        
        return None

    def add_step_to_checklist(self, step: ChecklistStep, indent_level: int):
        """Add a step to the current checklist at the appropriate level."""
        if not self.current_checklist:
            return
            
        if indent_level == 0:
            self.current_checklist.steps.append(step)
            self.current_step = step
        else:
            parent = self.find_parent_step(indent_level)
            if parent:
                parent.sub_steps.append(step)
            else:
                self.current_checklist.steps.append(step)
            self.current_step = step

    def process_section_header(self, line: str, line_number: int):
        """Process a section header line."""
        match = self.patterns['section'].match(line)
        if match:
            self.current_section = match.group(1)
            if self.verbose:
                print(f"Found section: {self.current_section} at line {line_number}")

    def process_subsection_header(self, line: str, line_number: int):
        """Process a subsection header line."""
        match = self.patterns['subsection'].match(line)
        if match:
            self.current_subsection = match.group(1)
            if self.verbose:
                print(f"Found subsection: {self.current_subsection} at line {line_number}")

    def process_checklist_header(self, line: str, line_number: int):
        """Process a checklist header line."""
        match = self.patterns['checklist'].match(line)
        if match:
            if self.current_checklist:
                self.checklists.append(self.current_checklist)
            
            self.current_checklist = Checklist(
                title=match.group(1).strip(),
                section=self.current_section or "",
                subsection=self.current_subsection,
                steps=[],
                alert=None,
                alert_type=None,
                alert_message=None
            )
            self.current_step = None
            self.current_alert = None
            self.current_alert_type = None
            self.pending_pfd_alert = None
            
            if self.verbose:
                print(f"Found checklist: {self.current_checklist.title} at line {line_number}")

    def process_pfd_alert(self, line: str, line_number: int):
        """Process a PFD alert line."""
        match = self.patterns['pfd_alert'].match(line)
        if match and self.current_checklist:
            self.pending_pfd_alert = match.group(1).strip()
            self.current_checklist.alert_message = self.pending_pfd_alert
            if self.verbose:
                print(f"Found PFD Alert: {self.pending_pfd_alert} at line {line_number}")

    def process_cas_message(self, line: str, line_number: int):
        """Process a CAS message line."""
        match = self.patterns['cas_message'].match(line)
        if match and self.current_checklist:
            self.current_alert = match.group(1).strip()
            self.current_alert_type = match.group(2).strip() if match.group(2) else None
            self.current_checklist.alert = self.current_alert
            self.current_checklist.alert_type = self.current_alert_type
            
            if self.verbose:
                print(f"Found CAS message: {self.current_alert} at line {line_number}")

    def process_numbered_step(self, line: str, line_number: int) -> bool:
        """Process a numbered checklist step. Returns True if a step was processed."""
        match = self.patterns['item'].match(line)
        if match and self.current_checklist:
            indent, num1, num2, num3, content, action = match.groups()
            
            # Calculate indent level (2 spaces = 1 level)
            indent_level = len(indent) // 2
            
            # Split content into instruction and action
            instruction = content.strip()
            action = action.strip() if action else ""
            
            # Remove dots from action text
            if action:
                action = re.sub(r'\.+', '', action).strip()
            
            # Determine step number format
            step_number = None
            if num1:  # "1", "2", etc.
                step_number = num1
                indent_level = 0
            elif num2:  # "(1)", "(2)", etc.
                step_number = f"({num2})"
                indent_level = 2
            elif num3:  # "a", "b", etc.
                step_number = num3
                indent_level = 1

            step = self.create_checklist_step(instruction, action, indent_level, step_number)
            self.add_step_to_checklist(step, indent_level)
            
            if self.verbose:
                print(f"Found step: {step_number} - {instruction} at line {line_number}")
            return True
        return False

    def process_unnumbered_step(self, line: str, line_number: int):
        """Process an unnumbered checklist step."""
        # Skip if this is a section, subsection, or checklist title
        if (self.patterns['section'].match(line) or 
            self.patterns['subsection'].match(line) or 
            self.patterns['checklist'].match(line)):
            return
            
        # Skip if this is a CAS message or PFD Alert
        if (self.patterns['cas_message'].match(line) or 
            self.patterns['pfd_alert'].match(line)):
            return
            
        match = self.patterns['unnumbered'].match(line)
        if match and self.current_checklist:
            indent, content, action = match.groups()
            
            # Calculate indent level (2 spaces = 1 level)
            indent_level = len(indent) // 2
            
            # Split content into instruction and action
            instruction = content.strip()
            action = action.strip() if action else ""
            
            # Remove dots from action text
            if action:
                action = re.sub(r'\.+', '', action).strip()
            
            step = self.create_checklist_step(instruction, action, indent_level)
            self.add_step_to_checklist(step, indent_level)
            
            if self.verbose:
                print(f"Found unnumbered step: {instruction} at line {line_number}")

    def parse_checklist(self, file_path: str, output_path: str) -> None:
        """Parse the checklist file and generate a JSON output."""
        if self.verbose:
            print(f"Opening input file: {file_path}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for i, line in enumerate(lines, 1):
            self.line_count += 1
            line = line.rstrip()
            
            # Skip empty lines
            if not line:
                continue
            
            # Process each type of line in order of precedence
            # First check for headers and alerts
            self.process_section_header(line, i)
            self.process_subsection_header(line, i)
            self.process_checklist_header(line, i)
            self.process_cas_message(line, i)
            self.process_pfd_alert(line, i)
            
            # Then process steps - only process unnumbered if numbered didn't match
            if not self.process_numbered_step(line, i):
                self.process_unnumbered_step(line, i)
        
        # Add the last checklist
        if self.current_checklist:
            self.checklists.append(self.current_checklist)
        
        if self.verbose:
            print(f"\nProcessing complete:")
            print(f"Total lines processed: {self.line_count}")
            print(f"Total checklists found: {len(self.checklists)}")
            print(f"Writing output to: {output_path}")
        
        # Convert dataclasses to dictionaries for JSON serialization
        def dataclass_to_dict(obj):
            if isinstance(obj, (Checklist, ChecklistStep)):
                return {k: dataclass_to_dict(v) for k, v in asdict(obj).items()}
            elif isinstance(obj, list):
                return [dataclass_to_dict(item) for item in obj]
            return obj
        
        # Filter out empty checklists and those without alert messages
        self.checklists = [c for c in self.checklists if c.steps]
        
        with open(output_path, 'w', encoding='utf-8') as json_file:
            json.dump(dataclass_to_dict(self.checklists), json_file, indent=4)

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
        parser = ChecklistParser(verbose=args.verbose)
        parser.parse_checklist(input_path, output_path)
        print(f"Successfully generated {output_file}")
    except Exception as e:
        print(f"Error processing file: {str(e)}")

if __name__ == "__main__":
    main()
