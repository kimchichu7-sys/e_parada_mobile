import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
sys.path.append(r'c:\Users\kimch\e_parada_mobile\scratch')
import test_zero_central_v4

b0 = test_zero_central_v4.test_zero_crossings_central()
issues, crossings = b0.audit_geometry(min_parallel_gap=6)
print(f"AUDIT GEOMETRY: Issues={len(issues)}, Crossings={len(crossings)}")
for iss in issues:
    print("  ISSUE:", iss)

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

print(f"\n==========================================")
print(f"CENTRAL CORRIDOR CROSSINGS: {len(central_cuts)}")
print(f"==========================================")
for vx, hy, hfid, vfid, hval, vval in central_cuts:
    print(f"  at ({vx}, {hy}): H={hfid} [{hval}] crosses V={vfid} [{vval}]")
