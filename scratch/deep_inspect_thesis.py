from pypdf import PdfReader
import sys

# ensure utf-8 output
sys.stdout.reconfigure(encoding='utf-8')

pdf_path = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf'
reader = PdfReader(pdf_path)

def inspect_pages(target_pages, search_terms):
    for p_num in target_pages:
        page_text = reader.pages[p_num - 1].extract_text() or ''
        lines = page_text.split('\n')
        print(f"\n==================== PAGE {p_num} ====================")
        for i, line in enumerate(lines):
            line_clean = " ".join(line.split())
            if any(t.lower() in line_clean.lower() for t in search_terms):
                # print line with context
                start = max(0, i - 1)
                end = min(len(lines), i + 2)
                context = " ".join([l.strip() for l in lines[start:end]])
                context = " ".join(context.split())
                print(f"  [L{i+1}]: {context}\n")

print("--- 3D & THREE.JS OCCURRENCES ---")
inspect_pages([9, 56, 62, 66, 69, 104, 106, 111, 121, 125, 133, 135, 136], ['3d', 'three.js'])

print("--- MYSQL & SQLITE OCCURRENCES ---")
inspect_pages([8, 46, 48, 49, 66, 103, 104, 105, 110, 121, 122, 129, 130], ['mysql', 'sqlite'])

print("--- HARDWARE OCCURRENCES IN CH 1 ---")
inspect_pages([4, 5, 6, 14, 56, 62], ['hardware', 'iot sensor', 'sensor'])

print("--- GAMAGE & VOVVETI ON PAGE 54 ---")
inspect_pages([36, 41, 54, 59, 60], ['gamage', 'vovveti'])

print("--- ZXING OCCURRENCES ---")
inspect_pages([8, 105, 106], ['zxing'])
