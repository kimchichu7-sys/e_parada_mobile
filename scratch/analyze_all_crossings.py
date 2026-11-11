import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
sys.path.append(r'c:\Users\kimch\e_parada_mobile\scratch')
import test_zero_central_v4
from collections import defaultdict

b0 = test_zero_central_v4.test_zero_crossings_central()
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

all_crossings = []
for hy, hx1, hx2, hfid, hsrc, htgt, hval in h_lines:
    for vx, vy1, vy2, vfid, vsrc, vtgt, vval in v_lines:
        if vfid != hfid and vy1 < hy < vy2 and hx1 < vx < hx2:
            all_crossings.append((vx, hy, hfid, vfid, hsrc, htgt, vsrc, vtgt))

print(f"Total crossings: {len(all_crossings)}")
zone_counts = defaultdict(int)
for vx, hy, hfid, vfid, hsrc, htgt, vsrc, vtgt in all_crossings:
    # Classify by zone:
    zone = "Other"
    if vx < 500:
        zone = "Left margin (x < 500)"
    elif vx > 2300:
        zone = "Right margin (x > 2300)"
    elif hy < 200:
        zone = "Top perimeter (y < 200)"
    elif hy > 1700:
        zone = "Bottom perimeter (y > 1700)"
    elif 1400 <= vx <= 2000:
        zone = "Central corridor (1400 <= x <= 2000)"
    elif 500 <= vx <= 1200:
        zone = "Col 1-2 corridor (500 <= x <= 1200)"
    zone_counts[zone] += 1

for zone, count in sorted(zone_counts.items(), key=lambda x: -x[1]):
    print(f"  {zone}: {count}")
