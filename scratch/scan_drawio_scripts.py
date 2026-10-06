import sys
sys.stdout.reconfigure(encoding='utf-8')
import os, re

scripts = [
    r'c:\Users\kimch\e_parada_mobile\generate_drawio.py',
    r'c:\Users\kimch\e_parada_mobile\generate_activity_diagram_drawio.py',
    r'c:\Users\kimch\e_parada_mobile\generate_subroutines_drawio.py'
]

terms = ['mysql', 'three', '3d', 'zxing', 'sqlite', 'camera', 'paymongo', 'supabase', 'postgres']

for s in scripts:
    print(f'=== Scanning {os.path.basename(s)} ===')
    with open(s, 'r', encoding='utf-8') as f:
        content = f.read()
    for term in terms:
        matches = list(re.finditer(re.escape(term), content, re.IGNORECASE))
        if matches:
            print(f'  Found {len(matches)} occurrences of "{term}":')
            for m in matches[:3]:
                snippet = content[max(0, m.start()-40):min(len(content), m.end()+40)].replace('\n', ' ')
                print(f'    ...{snippet}...')
