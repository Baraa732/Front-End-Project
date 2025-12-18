#!/usr/bin/env python3
"""
PDF Converter for AUTOHIVE Documentation
Run this script to convert the text documentation to PDF
"""

from reportlab.lib.pagesizes import letter, A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
import os

def convert_txt_to_pdf():
    # Input and output files
    txt_file = "AUTOHIVE_PACKAGES_DOCUMENTATION.txt"
    pdf_file = "AUTOHIVE_PACKAGES_DOCUMENTATION.pdf"
    
    # Check if input file exists
    if not os.path.exists(txt_file):
        print(f"Error: {txt_file} not found!")
        return
    
    # Create PDF document
    doc = SimpleDocTemplate(pdf_file, pagesize=A4)
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=16,
        spaceAfter=30,
        textColor='#2E86AB'
    )
    
    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        spaceAfter=12,
        textColor='#A23B72'
    )
    
    normal_style = ParagraphStyle(
        'CustomNormal',
        parent=styles['Normal'],
        fontSize=10,
        spaceAfter=6
    )
    
    # Read text file
    with open(txt_file, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Build PDF content
    story = []
    lines = content.split('\n')
    
    for line in lines:
        line = line.strip()
        if not line:
            story.append(Spacer(1, 6))
        elif line.startswith('AUTOHIVE Flutter Application'):
            story.append(Paragraph(line, title_style))
        elif line.isupper() and len(line) > 10:
            story.append(Paragraph(line, heading_style))
        else:
            story.append(Paragraph(line, normal_style))
    
    # Build PDF
    doc.build(story)
    print(f"PDF created successfully: {pdf_file}")

if __name__ == "__main__":
    try:
        convert_txt_to_pdf()
    except ImportError:
        print("Error: reportlab not installed. Run: pip install reportlab")
    except Exception as e:
        print(f"Error: {e}")