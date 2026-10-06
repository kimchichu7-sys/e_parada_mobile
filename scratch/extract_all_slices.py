import os
import sys
sys.stdout.reconfigure(encoding='utf-8')
from pypdf import PdfReader

reader = PdfReader(r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf')
out_dir = r'c:\Users\kimch\e_parada_mobile\scratch\flowchart_slices'
os.makedirs(out_dir, exist_ok=True)

pages = [106, 107, 108, 109, 114, 115, 116, 117, 120]
for p in pages:
    page = reader.pages[p - 1]
    for idx, img in enumerate(page.images):
        name = f"page_{p}_img_{idx}.png"
        path = os.path.join(out_dir, name)
        with open(path, 'wb') as f:
            f.write(img.data)
        print(f"Saved P.{p} -> {name} ({len(img.data)} bytes)")
