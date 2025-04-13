#!/usr/bin/env python3
"""
Process SF50 summary text file into CSV format.
Extracts section, category, alert type, and message information from the summary file.
"""

import argparse
import csv
import os
import re
import logging
from dataclasses import dataclass
from typing import List, Optional, Tuple, Dict

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s'
)
logger = logging.getLogger(__name__)

@dataclass
class AlertEntry:
    """Represents a single alert entry with its properties."""
    section: str
    category: str
    alert_type: str
    message: str
    priority: str
    submessage: Optional[str] = None

class SF50Processor:
    """Processes SF50 summary text files into structured alert entries."""
    
    def __init__(self, debug: bool = False):
        self.current_section = None
        self.entries: List[AlertEntry] = []
        self.cas_descriptions: Dict[str, str] = {}
        self.debug = debug
    
    def load_cas_descriptions(self, file_path: str) -> None:
        """Load CAS descriptions from emergency/abnormal file.
        
        Expected pattern for each CAS message:
        1. "MESSAGE TYPE" (e.g., "AOA HEAT FAIL Caution")
        2. "MESSAGE" (e.g., "AOA HEAT FAIL")
        3. "description" (e.g., "AOA heat failure")
        
        Special handling for AFCS Alerts section:
        - Lines with "annunciator on PFD" are treated as submessages for the previous line
        - Section starts at "AFCS Alerts" and ends at "Abnormal CAS Procedures" or "Emergency CAS Procedures"
        """
        if self.debug:
            logger.info(f"\nProcessing file: {file_path}")
        
        with open(file_path, 'r') as f:
            lines = [line.strip() for line in f if line.strip() and line.strip() != "Procedure Complete"]  # Remove empty lines and "Procedure Complete"
            i = 0
            in_afcs_section = False
            previous_line = None
            
            while i < len(lines):
                line = lines[i]
                
                # Check for AFCS Alerts section start/end
                if line == "AFCS Alerts":
                    in_afcs_section = True
                    if self.debug:
                        logger.info("\nEntering AFCS Alerts section")
                    i += 1
                    continue
                elif line in ["Abnormal CAS Procedures", "Emergency CAS Procedures"]:
                    in_afcs_section = False
                    if self.debug:
                        logger.info("Exiting AFCS Alerts section\n")
                    i += 1
                    continue
                
                if in_afcs_section:
                    # Check for annunciator message
                    if "annunciator on pfd" in line.lower():
                        if previous_line :
                            if self.debug:
                                logger.info(f"Found AFCS description:")
                                logger.info(f"  Message: {previous_line}")
                                logger.info(f"  Description: {line}")
                            self.cas_descriptions[previous_line] = line
                        i += 1
                        continue
                    previous_line = line
                else:
                    # Normal CAS message processing
                    if i < len(lines) - 2:  # Need at least 3 lines for a complete entry
                        # Check if this is a CAS message line with type (uppercase + Caution/Advisory)
                        if re.match(r'^[A-Z\s]+(Caution|Advisory)$', line):
                            message_with_type = lines[i]
                            # Extract just the message part (remove the type)
                            message = re.sub(r'\s+(Caution|Advisory)$', '', message_with_type)
                            
                            # Check if next line is just the message
                            if lines[i + 1] == message:
                                # The line after that should be the description
                                description = lines[i + 2]
                                if description and description.endswith('.'):
                                    if self.debug:
                                        logger.info(f"Found CAS description:")
                                        logger.info(f"  Message: {message}")
                                        logger.info(f"  Description: {description}")
                                    self.cas_descriptions[message] = description
                                i += 2  # Skip the next two lines
                i += 1
    
    def process_line(self, line: str) -> None:
        """Process a single line of the input file."""
        line = line.strip()
        if not line:  # Skip empty lines
            return
            
        # Check for section header (handles both "Section X:" and "Section:" formats)
        if line.startswith("Section"):
            # Extract everything after the colon
            self.current_section = line.split(":", 1)[1].strip()
            return
            
        # Skip if no section has been set
        if not self.current_section:
            return
            
        # Process alert line
        if self._is_uppercase_start(line):
            self._process_cas_alert(line)
        else:
            self._process_situation_alert(line)
    
    def _is_uppercase_start(self, line: str) -> bool:
        """Check if line starts with uppercase words."""
        first_word = line.split()[0]
        return first_word.isupper()
    
    def _get_category(self, alert_type: str, is_situation: bool = False) -> str:
        """Determine the category based on alert type and section."""
        if is_situation:
            return "emergency" if "emergency" in self.current_section.lower() else "abnormal"
        else:
            return "emergency" if alert_type == "Caution" else "abnormal"
    
    def _get_priority(self) -> str:
        """Determine the priority based on section type."""
        if "emergency" in self.current_section.lower():
            return "high"
        return "medium"
    
    def _process_cas_alert(self, line: str) -> None:
        """Process a CAS type alert line."""
        # Find the first occurrence of Caution/Advisory/Warning
        type_match = re.search(r'(Caution|Advisory|Warning)', line)
        if type_match:
            # Split the line at the alert type
            type_start = type_match.start()
            message = line[:type_start].strip()
            alert_type = "cas"  # Always use lowercase 'cas'
            
            # Get any text after the alert type
            remaining_text = line[type_match.end():].strip()
            
            # Handle "- On Ground" suffix
            if remaining_text.startswith("- "):
                submessage = remaining_text[2:]  # Remove the "- " prefix
            else:
                submessage = remaining_text if remaining_text else None
            
            # Add description from emergency/abnormal file if available
            if message in self.cas_descriptions:
                if submessage:
                    submessage = f"{submessage} - {self.cas_descriptions[message]}"
                else:
                    submessage = self.cas_descriptions[message]
        else:
            # If no alert type found, treat as CAS
            message = line.strip()
            alert_type = "cas"
            submessage = None
            
        self.entries.append(AlertEntry(
            section=self.current_section,
            category=self._get_category(alert_type),
            alert_type=alert_type,
            message=message,
            priority=self._get_priority(),
            submessage=submessage
        ))
    
    def _process_situation_alert(self, line: str) -> None:
        """Process a situation type alert line."""
        message = line.strip()
        submessage = None
        
        # Check if this situation has an associated AFCS alert description
        if message in self.cas_descriptions:
            submessage = self.cas_descriptions[message]
            if self.debug:
                logger.info(f"Found AFCS description for situation:")
                logger.info(f"  Situation: {message}")
                logger.info(f"  Description: {submessage}")
            
        self.entries.append(AlertEntry(
            section=self.current_section,
            category=self._get_category("", is_situation=True),
            alert_type="situation",
            message=message,
            priority=self._get_priority(),
            submessage=submessage
        ))
    
    def write_csv(self, output_file: str) -> None:
        """Write processed entries to CSV file."""
        with open(output_file, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['section', 'category', 'alert_type', 'message', 'priority', 'submessage'])
            for entry in self.entries:
                writer.writerow([
                    entry.section,
                    entry.category,
                    entry.alert_type,
                    entry.message,
                    entry.priority,
                    entry.submessage or ''
                ])

def process_file(input_file: str, emergency_file: str, abnormal_file: str, output_file: Optional[str] = None, debug: bool = False) -> None:
    """Process input file and write results to output file."""
    if output_file is None:
        output_file = os.path.splitext(input_file)[0] + '.csv'
    
    processor = SF50Processor(debug=debug)
    
    # Load descriptions from emergency and abnormal files
    processor.load_cas_descriptions(emergency_file)
    processor.load_cas_descriptions(abnormal_file)
    
    with open(input_file, 'r') as f:
        for line in f:
            processor.process_line(line)
    
    processor.write_csv(output_file)
    print(f"Processed {len(processor.entries)} alerts. Output written to {output_file}")

def main():
    """Main entry point with argument parsing."""
    parser = argparse.ArgumentParser(
        description='Process SF50 summary text into CSV format.'
    )
    parser.add_argument(
        'input_file',
        help='Input SF50 summary text file'
    )
    parser.add_argument(
        'emergency_file',
        help='Emergency procedures file'
    )
    parser.add_argument(
        'abnormal_file',
        help='Abnormal procedures file'
    )
    parser.add_argument(
        '-o', '--output',
        help='Output CSV file (default: input file with .csv extension)'
    )
    parser.add_argument(
        '-d', '--debug',
        action='store_true',
        help='Enable debug logging'
    )
    
    args = parser.parse_args()
    process_file(args.input_file, args.emergency_file, args.abnormal_file, args.output, args.debug)

if __name__ == '__main__':
    main() 