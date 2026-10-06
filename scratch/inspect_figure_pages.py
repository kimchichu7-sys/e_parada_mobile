import sys
sys.stdout.reconfigure(encoding='utf-8')
from pypdf import PdfReader

reader = PdfReader(r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf')

figure_pages = [7, 33, 35, 42, 44, 50, 64, 68, 73, 74, 75, 76, 77, 78, 80, 81, 83, 86, 88, 90, 93, 95, 98, 100, 109, 117, 120]

for p in figure_pages:
    text = reader.pages[p - 1].extract_text() or ''
    cleaned = ' '.join(text.split())
    print(f"\n==================== PAGE {p} ====================")
    # Check for keywords on the page
    for kw in ['mysql', 'sqlite', 'three', '3d', 'zxing', 'java', 'android studio', 'docker', 'render', 'supabase', 'postgres', 'paymongo', 'figure']:
        if kw in cleaned.lower():
            print(f"  [Found '{kw}']")
    # print snippet
    print(cleaned[:600] + ('...' if len(cleaned) > 600 else ''))
