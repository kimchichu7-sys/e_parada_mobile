with open(r'c:\Users\kimch\e_parada_mobile\scratch\build_clean_l0.py', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix f42 x=1740:
text = text.replace(
    "b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'L', 0.7, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1160), (1720, 1160), (1720, 1270), (1960, 1270)])",
    "b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'L', 0.7, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1160), (1750, 1160), (1750, 1270), (1960, 1270)])"
)

# Fix f41 y=1205:
text = text.replace(
    "b0.add_orthogonal_flow('f41', 'P6', 'L', 0.2, 'E1', 'B', 0.15, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(1960, 1215), (1700, 1215), (1700, 1140), (87, 1140)])",
    "b0.add_orthogonal_flow('f41', 'P6', 'L', 0.05, 'E1', 'B', 0.15, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(1960, 1205), (1700, 1205), (1700, 1140), (87, 1140)])"
)

with open(r'c:\Users\kimch\e_parada_mobile\scratch\build_clean_l0.py', 'w', encoding='utf-8') as f:
    f.write(text)

import importlib
import build_clean_l0
importlib.reload(build_clean_l0)
b0, mxfile = build_clean_l0.create_drawio_level_0()
issues, crossings = b0.audit_geometry(min_parallel_gap=6)
print(f"FINAL AUDIT: Issues={len(issues)}, Crossings={len(crossings)}")
for iss in issues:
    print("  ", iss)
