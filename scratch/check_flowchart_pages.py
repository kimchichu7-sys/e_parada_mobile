import sys
sys.stdout.reconfigure(encoding='utf-8')
from pypdf import PdfReader

reader = PdfReader(r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf')

for p in range(106, 118):
    page = reader.pages[p - 1]
    text = ' '.join((page.extract_text() or '').split())
    imgs = page.images
    print(f"P.{p}: {len(imgs)} images | Text snippet: {text[:250]}")
    for idx, img in enumerate(imgs):
        print(f"   Image {idx}: {img.name}, size {len(img.data)} bytes")
