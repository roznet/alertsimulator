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
from typing import List, Dict, Set, Tuple

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
    
    # Print results
    results.print_results(args.verbose, args.debug)
    
    # Exit with status code based on validation results
    passed, total = results.summary()
    exit(0 if passed == total else 1)

if __name__ == "__main__":
    main() 