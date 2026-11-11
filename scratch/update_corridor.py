import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
from dfd_router_helper import OrthogonalDFDBuilder

# Let's test direct left-entry for f31, f37, f41, f42
# In build_clean_l0:
with open(r'c:\Users\kimch\e_parada_mobile\scratch\build_clean_l0.py', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace f31 and f37:
old_f31_f37 = """    # ROUTE f31 & f37 VIA BOTTOM HIGHWAY (y=2060, y=2080) and RIGHT GUTTER (x=2480, x=2500)
    b0.add_orthogonal_flow('f31', 'E1', 'B', 0.3, 'P5', 'R', 0.2, 'Present Dynamic QR Digital Pass at Gate', mids=[(114, 2060), (2480, 2060), (2480, 900)])
    b0.add_orthogonal_flow('f37', 'P5', 'R', 0.35, 'E1', 'B', 0.7, 'Gate Clearance & Active Session Timer Display', mids=[(2500, 915), (2500, 2080), (186, 2080)])"""

new_f31_f37 = """    # DIRECT CORRIDOR ENTRY: f31 & f37 enter P5 L through clear band y=890, y=905
    b0.add_orthogonal_flow('f31', 'E1', 'B', 0.3, 'P5', 'L', 0.15, 'Present Dynamic QR Digital Pass at Gate', mids=[(114, 890), (1960, 890)])
    b0.add_orthogonal_flow('f37', 'P5', 'L', 0.3, 'E1', 'B', 0.7, 'Gate Clearance & Active Session Timer Display', mids=[(1960, 910), (186, 910)])"""

old_f41_f42 = """    # ROUTE f41 & f42 VIA BOTTOM HIGHWAY (y=2020, y=2040) and RIGHT GUTTER (x=2440, x=2460)
    b0.add_orthogonal_flow('f41', 'P6', 'R', 0.15, 'E1', 'B', 0.15, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(2440, 1215), (2440, 2020), (87, 2020)])
    b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'R', 0.7, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 2040), (2460, 2040), (2460, 1270)])"""

new_f41_f42 = """    # DIRECT CORRIDOR ENTRY: f41 & f42 enter P6 L through clear band y=1140, y=1160
    b0.add_orthogonal_flow('f41', 'P6', 'L', 0.2, 'E1', 'B', 0.15, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(1960, 1215), (1700, 1215), (1700, 1140), (87, 1140)])
    b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'L', 0.7, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1160), (1720, 1160), (1720, 1270), (1960, 1270)])"""

text = text.replace(old_f31_f37, new_f31_f37).replace(old_f41_f42, new_f41_f42)

with open(r'c:\Users\kimch\e_parada_mobile\scratch\build_clean_l0.py', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated build_clean_l0.py with direct corridor entry.")
