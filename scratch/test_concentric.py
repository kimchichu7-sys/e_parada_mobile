import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
from dfd_router_helper import OrthogonalDFDBuilder

# Let's test concentric routing for f31, f37, f41, f42, f49, f50:
# Higher destination (P5 at y=880) -> Inner track: x_right=2300, 2320, y_bottom=2020, 2040
# Lower destination (P6 at y=1200) -> Outer track: x_right=2360, 2380, y_bottom=2080, 2100
# Lowest destination (P7 at y=1710) -> Outermost track: y_bottom=2140, 2160

with open(r'c:\Users\kimch\e_parada_mobile\scratch\build_clean_l0.py', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's inspect where f31, f37, f41, f42 are currently in build_clean_l0.py
print("Loaded build_clean_l0.py")
