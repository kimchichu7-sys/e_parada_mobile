from pypdf import PdfReader
import sys

sys.stdout.reconfigure(encoding='utf-8')

pdf_path = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf'
reader = PdfReader(pdf_path)

targets = [5, 6, 9, 14, 48, 49, 54, 62, 69, 111]
for t in targets:
    print(f"\n============================== PAGE {t} ==============================")
    text = ' '.join((reader.pages[t - 1].extract_text() or '').split())
    print(text)
