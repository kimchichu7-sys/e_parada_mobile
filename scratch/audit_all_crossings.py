import xml.etree.ElementTree as ET

tree = ET.parse(r'c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_0.drawio')
root = tree.getroot()

edges = root.findall('.//mxCell[@edge="1"]')
print(f"Total edges: {len(edges)}")

v_lines = []
h_lines = []

for e in edges:
    fid = e.get('id')
    val = e.get('value', '')
    src = e.get('source', '')
    tgt = e.get('target', '')
    geom = e.find('mxGeometry')
    if geom is None: continue
    pts = []
    src_pt = geom.find('mxPoint[@as="sourcePoint"]')
    tgt_pt = geom.find('mxPoint[@as="targetPoint"]')
    arr = geom.find('Array[@as="points"]')
    if src_pt is not None: pts.append((float(src_pt.get('x')), float(src_pt.get('y'))))
    if arr is not None:
        for p in arr.findall('mxPoint'): pts.append((float(p.get('x')), float(p.get('y'))))
    if tgt_pt is not None: pts.append((float(tgt_pt.get('x')), float(tgt_pt.get('y'))))

    for i in range(len(pts)-1):
        p1, p2 = pts[i], pts[i+1]
        x1, y1 = p1
        x2, y2 = p2
        if abs(x1 - x2) < 1e-3:
            v_lines.append((x1, min(y1, y2), max(y1, y2), fid, src, tgt, val))
        elif abs(y1 - y2) < 1e-3:
            h_lines.append((y1, min(x1, x2), max(x1, x2), fid, src, tgt, val))

all_crossings = []
for hy, hx1, hx2, hfid, hsrc, htgt, hval in h_lines:
    for vx, vy1, vy2, vfid, vsrc, vtgt, vval in v_lines:
        if vfid != hfid:
            if vy1 < hy < vy2 and hx1 < vx < hx2:
                all_crossings.append({
                    'x': vx,
                    'y': hy,
                    'h_edge': hfid,
                    'h_desc': f"{hsrc}->{htgt} ({hval[:25]})",
                    'v_edge': vfid,
                    'v_desc': f"{vsrc}->{vtgt} ({vval[:25]})"
                })

print(f"Total crossings found: {len(all_crossings)}")
# Group crossings by region
print("\n--- Crossings in Central Corridor (1400 <= x <= 2000, 500 <= y <= 1500) ---")
central = [c for c in all_crossings if 1400 <= c['x'] <= 2000 and 500 <= c['y'] <= 1500]
print(f"Count: {len(central)}")
for c in central:
    print(f"  at ({c['x']}, {c['y']}): H={c['h_edge']} [{c['h_desc']}] crosses V={c['v_edge']} [{c['v_desc']}]")

print("\n--- All other crossings ---")
other = [c for c in all_crossings if c not in central]
print(f"Count: {len(other)}")
for c in other[:25]:
    print(f"  at ({c['x']}, {c['y']}): H={c['h_edge']} [{c['h_desc']}] crosses V={c['v_edge']} [{c['v_desc']}]")
