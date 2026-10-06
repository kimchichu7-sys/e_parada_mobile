from pypdf import PdfReader
import sys

sys.stdout.reconfigure(encoding='utf-8')

pdf_path = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf'
reader = PdfReader(pdf_path)

def dump_page_clean(p_num):
    text = reader.pages[p_num - 1].extract_text() or ''
    # Normalize spaces: pypdf has letters separated by multiple spaces in some headings or normal text
    # Let's clean up multiple whitespace
    cleaned = ' '.join(text.split())
    return cleaned

targets = [5, 6, 9, 14, 48, 49, 54, 62, 69, 111, 125, 133, 135, 136]
for t in targets:
    print(f"\n============================== PAGE {t} ==============================")
    text = dump_page_clean(t)
    print(text[:2500]) # print first 2500 chars
