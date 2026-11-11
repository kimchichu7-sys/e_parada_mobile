import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
from dfd_router_helper import OrthogonalDFDBuilder

# Let's test zero crossings in central corridor:
with open(r'c:\Users\kimch\e_parada_mobile\scratch\test_zero_central_v2.py', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix f33 & f36 nesting:
# f36 inside: P5 T (x=2037) -> up to y=840 -> x=1660 -> y=760 -> D4 R (x=1440, y=760)
# f33 outside: D4 R (x=1440, y=740) -> x=1700 -> y=860 -> into P5 T (x=2004)
old_f33_f36 = """    # f33 & f36: Connect D4 R directly to P5 T at y=880 in parallel! (ZERO CROSSINGS!)
    b0.add_orthogonal_flow('f33', 'D4', 'R', 0.8, 'P5', 'T', 0.2, 'Active Reservation Record & Plate Number', mids=[(1660, 768), (1660, 840), (2004, 840)])
    b0.add_orthogonal_flow('f36', 'P5', 'T', 0.35, 'D4', 'R', 0.95, 'Session State Update (Park-In / Park-Out Timestamps)', mids=[(2037, 860), (1680, 860), (1680, 777)])"""

new_f33_f36 = """    # f33 & f36: Concentric nested routing (ZERO CROSSINGS!)
    b0.add_orthogonal_flow('f33', 'D4', 'R', 0.35, 'P5', 'T', 0.2, 'Active Reservation Record & Plate Number', mids=[(1700, 741), (1700, 860), (2004, 860)])
    b0.add_orthogonal_flow('f36', 'P5', 'T', 0.35, 'D4', 'R', 0.7, 'Session State Update (Park-In / Park-Out Timestamps)', mids=[(2037, 840), (1660, 840), (1660, 762)])"""

# Fix f42 entering P6 B at y=1380:
old_f42 = """    b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'L', 0.7, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1130), (1760, 1130), (1760, 1270)])"""

new_f42 = """    b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'B', 0.8, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1400), (2136, 1400)])"""

text = text.replace(old_f33_f36, new_f33_f36).replace(old_f42, new_f42)

with open(r'c:\Users\kimch\e_parada_mobile\scratch\test_zero_central_v3.py', 'w', encoding='utf-8') as f:
    f.write(text)

import test_zero_central_v3
b0 = test_zero_central_v3.test_zero_crossings_central()
issues, crossings = b0.audit_geometry(min_parallel_gap=6)
print(f"\nAUDIT: Issues={len(issues)}, Crossings={len(crossings)}")
for iss in issues:
    print("  ", iss)

v_lines = []
h_lines = []
for e in b0.edges:
    pts = e['full_pts']
    fid = e['id']
    val = e['label']
    src = e['src']
    tgt = e['tgt']
    for i in range(len(pts)-1):
        p1, p2 = pts[i], pts[i+1]
        if abs(p1[0]-p2[0]) < 1e-3:
            v_lines.append((p1[0], min(p1[1], p2[1]), max(p1[1], p2[1]), fid, src, tgt, val))
        elif abs(p1[1]-p2[1]) < 1e-3:
            h_lines.append((p1[1], min(p1[0], p2[0]), max(p1[0], p2[0]), fid, src, tgt, val))

central_cuts = []
for hy, hx1, hx2, hfid, hsrc, htgt, hval in h_lines:
    for vx, vy1, vy2, vfid, vsrc, vtgt, vval in v_lines:
        if vfid != hfid and vy1 < hy < vy2 and hx1 < vx < hx2:
            if 1400 <= vx <= 2000 and 500 <= hy <= 1500:
                central_cuts.append((vx, hy, hfid, vfid, hval[:25], vval[:25]))

print(f"\nCENTRAL CORRIDOR CROSSINGS (The ones from user screenshot): {len(central_cuts)}")
for vx, hy, hfid, vfid, hval, vval in central_cuts:
    print(f"  at ({vx}, {hy}): H={hfid} [{hval}] crosses V={vfid} [{vval}]")
