import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
from dfd_router_helper import OrthogonalDFDBuilder
from collections import defaultdict, Counter

def analyze_crossings(b):
    issues, crossings = b.audit_geometry(min_parallel_gap=8)
    
    # Check for bundles cut by lines
    v_lines = []
    h_lines = []
    for fid, segs in b.edge_segments.items():
        for p1, p2 in segs:
            if abs(p1[0] - p2[0]) < 1e-3:
                v_lines.append((p1[0], min(p1[1], p2[1]), max(p1[1], p2[1]), fid))
            elif abs(p1[1] - p2[1]) < 1e-3:
                h_lines.append((p1[1], min(p1[0], p2[0]), max(p1[0], p2[0]), fid))
                
    multi_cuts = []
    for hy, hx1, hx2, hfid in h_lines:
        cuts = []
        for vx, vy1, vy2, vfid in v_lines:
            if vfid != hfid and (vy1 < hy < vy2) and (hx1 < vx < hx2):
                cuts.append((vfid, vx))
        if len(cuts) >= 3:
            multi_cuts.append((hfid, hy, len(cuts), cuts))
            
    return issues, crossings, multi_cuts

print("Helper loaded.")
