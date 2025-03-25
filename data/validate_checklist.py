#!/usr/bin/env python3
"""
Validate the checklist JSON file against the source text file.
This script runs a series of validation tests to ensure the JSON output
matches the expected content from the source text file.
"""

import json
import re
import os
import argparse
from typing import List, Dict, Set, Tuple, Optional

class ValidationTest:
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.passed = False
        self.error_messages: List[str] = []
        self.verbose_messages: List[str] = []
        self.debug_messages: List[str] = []
    
    def add_error(self, message: str):
        self.error_messages.append(message)
    
    def add_verbose(self, message: str):
        self.verbose_messages.append(message)
        
    def add_debug(self, message: str):
        self.debug_messages.append(message)
    
    def success(self):
        self.passed = True
    
    def failed(self) -> bool:
        return not self.passed

class ValidationResult:
    def __init__(self):
        self.tests: List[ValidationTest] = []
        
    def add_test(self, test: ValidationTest):
        self.tests.append(test)
    
    def summary(self) -> Tuple[int, int]:
        passed = sum(1 for test in self.tests if test.passed)
        total = len(self.tests)
        return passed, total
    
    def print_results(self, verbose: bool = False, debug: bool = False):
        passed, total = self.summary()
        
        print("\nValidation Results:")
        print(f"Tests passed: {passed}/{total}")
        
        if verbose or debug or passed < total:
            print("\nDetailed Results:")
            for test in self.tests:
                status = "✓" if test.passed else "✗"
                print(f"\n{status} {test.name}")
                print(f"  Description: {test.description}")
                if verbose and test.verbose_messages:
                    print("  Details:")
                    for msg in test.verbose_messages:
                        print(f"    - {msg}")
                if debug and test.debug_messages:
                    print("  Debug Info:")
                    for msg in test.debug_messages:
                        print(f"    - {msg}")
                if test.failed():
                    print("  Errors:")
                    for error in test.error_messages:
                        print(f"    - {error}")

def extract_checklist_titles(txt_path: str) -> Set[str]:
    """Extract all checklist titles (lines starting with ###) from the text file."""
    titles = set()
    checklist_pattern = re.compile(r'^###(.+)$')
    
    with open(txt_path, 'r', encoding='utf-8') as f:
        for line in f:
            match = checklist_pattern.match(line.strip())
            if match:
                titles.add(match.group(1).strip())
    
    return titles

def load_json_checklists(json_path: str) -> Dict:
    """Load the JSON file and return the checklist data."""
    with open(json_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def validate_checklist_titles(txt_path: str, json_path: str) -> ValidationTest:
    """
    Validate that all checklist titles in the text file exist in the JSON file
    and vice versa.
    """
    test = ValidationTest(
        name="Checklist Titles Validation",
        description="Verify all checklist titles from text file exist in JSON and vice versa"
    )
    
    try:
        # Get titles from text file
        txt_titles = extract_checklist_titles(txt_path)
        
        # Get titles from JSON file
        json_data = load_json_checklists(json_path)
        json_titles = {checklist['title'] for checklist in json_data}
        
        # Find matching titles
        matching_titles = txt_titles & json_titles
        test.add_verbose(f"Found {len(matching_titles)} matching checklist titles")
        
        # Add detailed title list in debug mode
        if matching_titles:
            test.add_debug("Matched titles:")
            for title in sorted(matching_titles):
                test.add_debug(f"  • {title}")
        
        # Check for missing titles in JSON
        missing_in_json = txt_titles - json_titles
        if missing_in_json:
            test.add_error(f"Checklists found in text file but missing in JSON: {sorted(missing_in_json)}")
        
        # Check for extra titles in JSON
        extra_in_json = json_titles - txt_titles
        if extra_in_json:
            test.add_error(f"Checklists found in JSON but missing in text file: {sorted(extra_in_json)}")
        
        if not test.error_messages:
            test.success()
            
    except Exception as e:
        test.add_error(f"Error during validation: {str(e)}")
    
    return test

def extract_cas_messages(txt_path: str) -> Set[str]:
    """Extract all CAS messages from the text file (ignoring the type)."""
    messages = set()
    cas_pattern = re.compile(r"^([A-Z][A-Z0-9 ]+)(?: (Warning|Advisory|Caution))?$")
    
    with open(txt_path, 'r', encoding='utf-8') as f:
        for line in f:
            match = cas_pattern.match(line.strip())
            if match:
                message = match.group(1).strip()
                messages.add(message)
    
    return messages

def validate_cas_messages(txt_path: str, json_path: str) -> ValidationTest:
    """
    Validate that all CAS messages in the text file exist in the JSON file
    and vice versa, ignoring the alert type.
    """
    test = ValidationTest(
        name="CAS Messages Validation",
        description="Verify all CAS messages from text file exist in JSON and vice versa"
    )
    
    try:
        # Get CAS messages from text file
        txt_messages = extract_cas_messages(txt_path)
        
        # Get CAS messages from JSON file
        json_data = load_json_checklists(json_path)
        json_messages = {
            checklist['alert']
            for checklist in json_data
            if checklist['alert'] is not None
        }
        
        # Find matching messages
        matching_messages = txt_messages & json_messages
        test.add_verbose(f"Found {len(matching_messages)} matching CAS messages")
        
        # Add detailed message list in debug mode
        if matching_messages:
            test.add_debug("Matched CAS messages:")
            for msg in sorted(matching_messages):
                test.add_debug(f"  • {msg}")
        
        # Check for missing messages in JSON
        missing_in_json = txt_messages - json_messages
        if missing_in_json:
            test.add_error(f"CAS messages found in text file but missing in JSON: {sorted(missing_in_json)}")
        
        # Check for extra messages in JSON
        extra_in_json = json_messages - txt_messages
        if extra_in_json:
            test.add_error(f"CAS messages found in JSON but missing in text file: {sorted(extra_in_json)}")
        
        if not test.error_messages:
            test.success()
            
    except Exception as e:
        test.add_error(f"Error during validation: {str(e)}")
    
    return test

def extract_checklist_steps(txt_path: str, checklist_title: str, checklist_section: str) -> List[str]:
    """Extract all steps from a specific checklist in the text file, matching both title and section."""
    steps = []
    in_section = False
    in_checklist = False
    current_section = None
    section_pattern = re.compile(r"^#([A-Z].+)$")
    checklist_pattern = re.compile(r'^###(.+)$')
    item_pattern = re.compile(r'^(\s*)(?:(\d+)\.|\((\d+)\)|([a-z])\.)\s+(.+?)(?:\.\.\.\s*(.+))?$')
    unnumbered_item_pattern = re.compile(r"^(\s*)([^#].+?)(?:\.\.\.\s*(.+))?$")
    
    with open(txt_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            # Check for section header
            section_match = section_pattern.match(line)
            if section_match:
                current_section = section_match.group(1).strip()
                in_section = (current_section == checklist_section)
                in_checklist = False  # Reset checklist flag when section changes
                continue
                
            # Only process checklist if we're in the right section
            if not in_section:
                continue
                
            # Check for checklist title
            checklist_match = checklist_pattern.match(line)
            if checklist_match:
                title = checklist_match.group(1).strip()
                if title == checklist_title:
                    in_checklist = True
                    continue
                elif in_checklist:
                    # We've reached the next checklist
                    break
                continue
            
            if in_checklist:
                # Try to match numbered items first
                item_match = item_pattern.match(line)
                if item_match:
                    content = item_match.group(5).strip()
                    steps.append(content)
                    continue
                
                # Then try unnumbered items
                unnumbered_match = unnumbered_item_pattern.match(line)
                if unnumbered_match:
                    content = unnumbered_match.group(2).strip()
                    # Skip if this looks like a section, subsection, CAS message, or PFD Alert
                    if not (content.isupper() or content.startswith('PFD Alerts Window:')):
                        steps.append(content)
    
    return steps

def normalize_instruction(instruction: str) -> str:
    """Normalize instruction text for comparison by removing dots and extra whitespace."""
    return re.sub(r'\s+', ' ', instruction.replace('.', '').strip())

def validate_checklist_steps(txt_path: str, json_path: str) -> ValidationTest:
    """
    Validate that all steps in each JSON checklist appear in the same order
    in the text file, matching checklists by both title and section.
    """
    test = ValidationTest(
        name="Checklist Steps Validation",
        description="Verify all checklist steps from JSON appear in order in the text file"
    )
    
    try:
        json_data = load_json_checklists(json_path)
        total_checklists = len(json_data)
        matching_checklists = 0
        
        for checklist in json_data:
            title = checklist['title']
            section = checklist['section']
            txt_steps = extract_checklist_steps(txt_path, title, section)
            
            if not txt_steps:
                test.add_error(f"Could not find steps for checklist '{title}' (section: {section}) in text file")
                continue
                
            # Get all instructions from JSON steps (including sub-steps)
            json_instructions = []
            def collect_instructions(steps):
                for step in steps:
                    if step['instruction']:
                        json_instructions.append(normalize_instruction(step['instruction']))
                    if step['sub_steps']:
                        collect_instructions(step['sub_steps'])
            
            collect_instructions(checklist['steps'])
            
            # Normalize text file steps
            txt_instructions = [normalize_instruction(step) for step in txt_steps]
            
            # Check if all JSON instructions appear in order in text file
            txt_idx = 0
            json_idx = 0
            missing_steps = []
            
            while json_idx < len(json_instructions):
                json_instruction = json_instructions[json_idx]
                
                # Try to find the next JSON instruction in remaining text steps
                found = False
                while txt_idx < len(txt_instructions):
                    if json_instruction == txt_instructions[txt_idx]:
                        found = True
                        txt_idx += 1
                        break
                    txt_idx += 1
                
                if not found:
                    missing_steps.append(json_instruction)
                
                json_idx += 1
            
            if missing_steps:
                test.add_error(f"Checklist '{title}' (section: {section}) has steps in JSON that don't appear in order in text file:")
                for step in missing_steps:
                    test.add_error(f"  • {step}")
            else:
                matching_checklists += 1
                test.add_debug(f"✓ Checklist '{title}' (section: {section}) steps match")
        
        test.add_verbose(f"Found {matching_checklists}/{total_checklists} checklists with matching steps")
        
        if not test.error_messages:
            test.success()
            
    except Exception as e:
        test.add_error(f"Error during validation: {str(e)}")
    
    return test

def main():
    parser = argparse.ArgumentParser(description='Validate checklist JSON against source text file.')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose output')
    parser.add_argument('-d', '--debug', action='store_true', help='Enable debug output (includes all details)')
    parser.add_argument('--txt', default='S22TG6-Checklists.txt', help='Input text file path')
    parser.add_argument('--json', default='S22TG6-Checklists.json', help='Input JSON file path')
    
    args = parser.parse_args()
    
    # Get the directory where the script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Construct full paths
    txt_path = os.path.join(script_dir, args.txt)
    json_path = os.path.join(script_dir, args.json)
    
    # Initialize validation results
    results = ValidationResult()
    
    # Run validation tests
    results.add_test(validate_checklist_titles(txt_path, json_path))
    results.add_test(validate_cas_messages(txt_path, json_path))
    results.add_test(validate_checklist_steps(txt_path, json_path))
    
    # Print results
    results.print_results(args.verbose, args.debug)
    
    # Exit with status code based on validation results
    passed, total = results.summary()
    exit(0 if passed == total else 1)

if __name__ == "__main__":
    main() 