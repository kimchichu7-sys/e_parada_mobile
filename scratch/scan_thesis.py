from pypdf import PdfReader
import re

pdf_path = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf'
reader = PdfReader(pdf_path)

terms = [
    'mysql', 'java', 'android studio', 'three.js', 'threejs', '3d', 'zxing',
    'sqlite', 'apache', 'xampp', 'hardware', 'no hardware', 'gamage', 'vovveti',
    'nielsen', 'figure 33', 'figure 34', 'figure 35', 'paymongo', 'supabase',
    'postgresql', 'postgres', 'docker', 'render', 'cpu', 'latency', 'bandwidth',
    'jmeter', 'locust', 'tesseract'
]

results = {term: [] for term in terms}

for idx, page in enumerate(reader.pages):
    page_num = idx + 1
    text = page.extract_text() or ''
    text_lower = text.lower()
    
    for term in terms:
        if term in text_lower:
            # find snippets
            matches = [m.start() for m in re.finditer(re.escape(term), text_lower)]
            snippets = []
            for m in matches:
                start = max(0, m - 40)
                end = min(len(text), m + len(term) + 40)
                snippet = text[start:end].replace('\n', ' ')
                snippets.append(snippet)
            results[term].append((page_num, snippets))

print("=== SCAN RESULTS ===")
for term, occurrences in results.items():
    if occurrences:
        pages = [p for p, _ in occurrences]
        print(f"Term '{term}': {len(pages)} pages -> {pages}")
        for p, snips in occurrences[:3]:  # print first 3 samples
            for s in snips[:2]:
                print(f"   [P.{p}]: ...{s}...")
    else:
        print(f"Term '{term}': NOT FOUND")
