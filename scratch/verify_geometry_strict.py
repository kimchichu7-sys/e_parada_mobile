import xml.etree.ElementTree as ET

def parse_style(s):
    res = {}
    for item in s.split(';'):
        if '=' in item:
            k, v = item.split('=', 1)
            res[k.strip()] = v.strip()
        elif item.strip():
            res[item.strip()] = True
    return res

def test_true_geometry(filepath):
    tree = ET.parse(filepath)
    root = tree.getroot()
    for diag in root.findall('diagram'):
        d_name = diag.get('name')
        mxGraphModel = diag.find('mxGraphModel')
        if mxGraphModel is None: continue
        
        vertices = {}
        for c in mxGraphModel.iter('mxCell'):
            if c.get('vertex') == '1':
                cid = c.get('id')
                geom = c.find('mxGeometry')
                if geom is not None:
                    parent = c.get('parent')
                    x = float(geom.get('x', 0))
                    y = float(geom.get('y', 0))
                    w = float(geom.get('width', 0))
                    h = float(geom.get('height', 0))
                    vertices[cid] = {'x': x, 'y': y, 'w': w, 'h': h, 'parent': parent}
        
        for cid, v in vertices.items():
            if v['parent'] in vertices:
                p = vertices[v['parent']]
                v['abs_x'] = p['x'] + v['x']
                v['abs_y'] = p['y'] + v['y']
            else:
                v['abs_x'] = v['x']
                v['abs_y'] = v['y']

        edges = [c for c in mxGraphModel.iter('mxCell') if c.get('edge') == '1']
        all_segments = []
        for e in edges:
            eid = e.get('id')
            val = e.get('value', '')
            src_id = e.get('source')
            tgt_id = e.get('target')
            style = parse_style(e.get('style', ''))
            geom = e.find('mxGeometry')
            if geom is None: continue
            
            pts = []
            if src_id in vertices:
                sv = vertices[src_id]
                ex = float(style.get('exitX', 0.5))
                ey = float(style.get('exitY', 0.5))
                pts.append((sv['abs_x'] + ex * sv['w'], sv['abs_y'] + ey * sv['h']))
            elif geom.find('mxPoint[@as="sourcePoint"]') is not None:
                sp = geom.find('mxPoint[@as="sourcePoint"]')
                pts.append((float(sp.get('x')), float(sp.get('y'))))
            
            arr = geom.find('Array[@as="points"]')
            if arr is not None:
                for p in arr.findall('mxPoint'):
                    pts.append((float(p.get('x')), float(p.get('y'))))
            
            if tgt_id in vertices:
                tv = vertices[tgt_id]
                enx = float(style.get('entryX', 0.5))
                eny = float(style.get('entryY', 0.5))
                pts.append((tv['abs_x'] + enx * tv['w'], tv['abs_y'] + eny * tv['h']))
            elif geom.find('mxPoint[@as="targetPoint"]') is not None:
                tp = geom.find('mxPoint[@as="targetPoint"]')
                pts.append((float(tp.get('x')), float(tp.get('y'))))
            
            expanded_pts = [pts[0]] if pts else []
            for i in range(len(pts)-1):
                p1 = pts[i]
                p2 = pts[i+1]
                if abs(p1[0] - p2[0]) > 1e-2 and abs(p1[1] - p2[1]) > 1e-2:
                    if i == 0 and 'exitY' in style and (float(style['exitY']) == 0 or float(style['exitY']) == 1):
                        expanded_pts.append((p1[0], p2[1]))
                    elif i == len(pts)-2 and 'entryY' in style and (float(style['entryY']) == 0 or float(style['entryY']) == 1):
                        expanded_pts.append((p2[0], p1[1]))
                    else:
                        expanded_pts.append((p2[0], p1[1]))
                expanded_pts.append(p2)

            for i in range(len(expanded_pts)-1):
                all_segments.append((expanded_pts[i], expanded_pts[i+1], eid, val, src_id, tgt_id))

        h_segs = []
        v_segs = []
        for p1, p2, eid, val, src_id, tgt_id in all_segments:
            x1, y1 = p1
            x2, y2 = p2
            if abs(y1 - y2) < 1e-2 and abs(x1 - x2) > 1e-2:
                h_segs.append((y1, min(x1, x2), max(x1, x2), eid, val, src_id, tgt_id))
            elif abs(x1 - x2) < 1e-2 and abs(y1 - y2) > 1e-2:
                v_segs.append((x1, min(y1, y2), max(y1, y2), eid, val, src_id, tgt_id))
        
        crossings = []
        for hy, hx1, hx2, heid, hval, _, _ in h_segs:
            for vx, vy1, vy2, veid, vval, _, _ in v_segs:
                if heid != veid:
                    if vy1 + 1e-2 < hy < vy2 - 1e-2 and hx1 + 1e-2 < vx < hx2 - 1e-2:
                        crossings.append((vx, hy, heid, veid, hval, vval))
        
        overlaps = []
        for i in range(len(h_segs)):
            for j in range(i+1, len(h_segs)):
                y1, ax1, ax2, id1, v1, _, _ = h_segs[i]
                y2, bx1, bx2, id2, v2, _, _ = h_segs[j]
                if id1 != id2 and abs(y1 - y2) < 2.0:
                    if max(ax1, bx1) < min(ax2, bx2) - 1e-2:
                        overlaps.append(f"H-overlap y={y1:.1f}: {id1} x {id2}")
        for i in range(len(v_segs)):
            for j in range(i+1, len(v_segs)):
                x1, ay1, ay2, id1, v1, _, _ = v_segs[i]
                x2, by1, by2, id2, v2, _, _ = v_segs[j]
                if id1 != id2 and abs(x1 - x2) < 2.0:
                    if max(ay1, by1) < min(ay2, by2) - 1e-2:
                        overlaps.append(f"V-overlap x={x1:.1f}: {id1} x {id2}")

        box_cuts = []
        top_boxes = {k: v for k, v in vertices.items() if v['parent'] == '1' and k != 'title_banner'}
        for cid, b in top_boxes.items():
            bx1, by1, bx2, by2 = b['abs_x'], b['abs_y'], b['abs_x'] + b['w'], b['abs_y'] + b['h']
            for hy, hx1, hx2, heid, hval, s_id, t_id in h_segs:
                if cid not in (s_id, t_id):
                    if by1 + 1 < hy < by2 - 1 and max(hx1, bx1) < min(hx2, bx2) - 1:
                        box_cuts.append(f"Edge {heid} cuts box {cid}")
            for vx, vy1, vy2, veid, vval, s_id, t_id in v_segs:
                if cid not in (s_id, t_id):
                    if bx1 + 1 < vx < bx2 - 1 and max(vy1, by1) < min(vy2, by2) - 1:
                        box_cuts.append(f"Edge {veid} cuts box {cid}")

        print(f"{filepath} [{d_name}]: {len(edges)} edges | {len(crossings)} crossings | {len(overlaps)} overlaps | {len(box_cuts)} box_cuts")
        for c in crossings:
            print(f"   CROSSING at ({c[0]}, {c[1]}): {c[2]} ('{c[4]}') x {c[3]} ('{c[5]}')")
        for o in overlaps:
            print(f"   OVERLAP: {o}")
        for bc in box_cuts:
            print(f"   BOX CUT: {bc}")

for f in ['e_parada_dfd_level_0.drawio', 'e_parada_dfd_level_1.drawio', 'e_parada_dfd_level_2.drawio']:
    test_true_geometry(rf"c:\Users\kimch\e_parada_mobile\{f}")
