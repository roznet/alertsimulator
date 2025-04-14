#!/usr/bin/env python3

import json
import sys
import os

def convert_quiz_to_markdown(json_file):
    # Read the JSON file
    with open(json_file, 'r') as f:
        quiz_data = json.load(f)
    
    # Get the base filename without extension for the title
    base_name = os.path.splitext(os.path.basename(json_file))[0]
    
    # Start building the markdown content
    markdown = f"# {base_name} Quiz\n\n"
    
    # Process each section
    for section, questions in quiz_data['sections'].items():
        markdown += f"# {section}\n\n"
        
        # Process each question in the section
        for question in questions:
            markdown += f"Q: {question['question']}\n"
            markdown += f"A: {question['answer']}\n\n"
    
    return markdown

def main():
    if len(sys.argv) != 2:
        print("Usage: python quiz_to_markdown.py <quiz_file.json>")
        sys.exit(1)
    
    json_file = sys.argv[1]
    if not json_file.endswith('.json'):
        print("Error: Input file must be a JSON file")
        sys.exit(1)
    
    try:
        markdown = convert_quiz_to_markdown(json_file)
        output_file = json_file.replace('.json', '.md')
        
        with open(output_file, 'w') as f:
            f.write(markdown)
        
        print(f"Successfully converted {json_file} to {output_file}")
    
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 