import xml.etree.ElementTree as ET

tree = ET.parse(r'c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_0.drawio')
root = tree.getroot()

edges = root.findall('.//mxCell[@edge="1"]')

print(f"Edges: {len(edges)}")

# Inspect lines in the region of D4, D5, D6 and P4, P5, P6
# D4 is y=720, D5 is y=960, D6 is y=1260
# P4 is y=560, P5 is y=880, P6 is y=1200
# Column 3 is x=1200..1440, Column 4 is x=1960..2180
# So the corridor is x=1440..1960, y=700..1400

corridor_v = []
corridor_h = []

for e in edges:
    fid = e.get('id')
    val = e.get('value', '')
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
        if abs(x1 - x2) < 1e-3: # vertical
            x = x1
            ymin, ymax = min(y1, y2), max(y1, y2)
            if 1400 <= x <= 2000 and (ymin <= 1400 and ymax >= 700):
                corridor_v.append((x, ymin, ymax, fid, val))
        elif abs(y1 - y2) < 1e-3: # horizontal
            y = y1
            xmin, xmax = min(x1, x2), max(x1, x2)
            if 700 <= y <= 1400 and (xmin <= 2000 and xmax >= 1400):
                corridor_h.append((y, xmin, xmax, fid, val))

print(f"Corridor V-segments ({len(corridor_v)}):")
for x, y1, y2, fid, val in corridor_v:
    print(f"  V-line {fid} at x={x}: y=[{y1}..{y2}] | {val[:30]}")

print(f"\nCorridor H-segments ({len(corridor_h)}):")
for y, x1, x2, fid, val in corridor_h:
    print(f"  H-line {fid} at y={y}: x=[{x1}..{x2}] | {val[:30]}")

print("\nIntersections in corridor:")
for y, hx1, hx2, hfid, hval in corridor_h:
    cuts = []
    for x, vy1, vy2, vfid, vval in corridor_v:
        if vfid != hfid and (vy1 < y < vy2) and (hx1 < x < hx2):
            cuts.append((vfid, x))
    if cuts:
        print(f"  H-line {hfid} (y={y}, x=[{hx1}..{hx2}]) cuts {len(cuts)} V-lines: {cuts}")
