import sys
sys.stdout.reconfigure(encoding='utf-8')
from pypdf import PdfReader

reader = PdfReader(r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf')

def examine_figure_page(page_num, title):
    page = reader.pages[page_num - 1]
    text = page.extract_text() or ''
    images = page.images
    print(f"\n==================== PAGE {page_num}: {title} ====================")
    print(f"Number of embedded images: {len(images)}")
    for img in images:
        print(f"  Image name: {img.name}, size: {len(img.data)} bytes")
    # Search for specific technical keywords on this page
    keywords = ['mysql', 'sqlite', 'three.js', 'three', '3d', 'zxing', 'java', 'android studio', 'docker', 'render', 'supabase', 'postgres', 'paymongo', 'figure 33', 'figure 34']
    found = [kw for kw in keywords if kw in text.lower()]
    print(f"Keywords found on page: {found}")
    # Print the full page text cleanly
    print("Page Text Summary:")
    print(' '.join(text.split())[:1000])

targets = [
    (7, "Fig 1: Conceptual Framework"),
    (64, "Fig 6: System Architecture"),
    (68, "Fig 7: Use Case Diagram"),
    (73, "Fig 8: Activity Diagram"),
    (74, "Fig 9: Core ERD"),
    (75, "Fig 10: Communication ERD"),
    (76, "Fig 11: Audit ERD"),
    (77, "Fig 12: Support ERD"),
    (78, "Fig 13: Core DB Schema"),
    (80, "Fig 14: Ops DB Schema"),
    (81, "Fig 15: Laravel Tables"),
    (83, "Fig 16: Level 0 DFD"),
    (86, "Fig 17: Level 1 DFD"),
    (88, "Fig 18: Level 2 DFD"),
    (90, "Fig 19: Driver UI Mockups"),
    (93, "Fig 20: Owner UI Mockups"),
    (95, "Fig 21: Admin UI Mockups"),
    (98, "Fig 22: Website Mockups"),
    (109, "Fig 24: System Flowchart"),
    (117, "Fig 25: Subroutine Flowcharts"),
    (120, "Fig 26: Incremental Procedure")
]

for p, t in targets:
    examine_figure_page(p, t)
