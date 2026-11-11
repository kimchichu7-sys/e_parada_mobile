import xml.etree.ElementTree as ET

def audit_file(filepath):
    tree = ET.parse(filepath)
    root = tree.getroot()
    diagrams = root.findall('diagram')
    print(f"\n=======================================================")
    print(f"AUDITING: {filepath}")
    print(f"=======================================================")
    total_file_crossings = 0
    for diag in diagrams:
        d_name = diag.get('name')
        d_id = diag.get('id')
        mxGraphModel = diag.find('mxGraphModel')
        if mxGraphModel is None: continue
        edges = [c for c in mxGraphModel.iter('mxCell') if c.get('edge') == '1']
        
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
                if abs(x1 - x2) < 1e-2:
                    v_lines.append((x1, min(y1, y2), max(y1, y2), fid, src, tgt, val))
                elif abs(y1 - y2) < 1e-2:
                    h_lines.append((y1, min(x1, x2), max(x1, x2), fid, src, tgt, val))
        
        crossings = []
        for hy, hx1, hx2, hfid, hsrc, htgt, hval in h_lines:
            for vx, vy1, vy2, vfid, vsrc, vtgt, vval in v_lines:
                if vfid != hfid:
                    if vy1 + 1e-3 < hy < vy2 - 1e-3 and hx1 + 1e-3 < vx < hx2 - 1e-3:
                        crossings.append((vx, hy, hfid, vfid, hval[:20], vval[:20]))
        
        print(f"  Tab [{d_id}] {d_name:<40} : {len(edges):3d} edges | {len(crossings):3d} crossings")
        total_file_crossings += len(crossings)
    print(f"Total crossings in file: {total_file_crossings}")

for f in ['e_parada_dfd_level_0.drawio', 'e_parada_dfd_level_1.drawio', 'e_parada_dfd_level_2.drawio']:
    audit_file(rf'c:\Users\kimch\e_parada_mobile\{f}')
