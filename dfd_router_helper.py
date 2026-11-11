import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import shutil
import os

class OrthogonalDFDBuilder:
    def __init__(self, diag_id, tab_name, title_text, subtitle_text, page_w=1900, page_h=1500, jump_style=None):
        self.diag_id = diag_id
        self.tab_name = tab_name
        self.title_text = title_text
        self.subtitle_text = subtitle_text
        self.page_w = page_w
        self.page_h = page_h
        self.jump_style = jump_style
        self.boxes = {}      # id -> (x, y, w, h, kind, code)
        self.edges = []      # list of dicts: id, src, tgt, label, points [(x,y)...], label_offset

    def add_entity(self, e_id, name, x, y, w=185, h=60, code=None):
        self.boxes[e_id] = (x, y, w, h, 'entity', code or e_id, name)

    def add_process(self, p_id, num_str, name, x, y, w=230, h=84, is_ref=False, code=None):
        kind = 'ref_process' if is_ref else 'process'
        self.boxes[p_id] = (x, y, w, h, kind, code or num_str, name)

    def add_datastore(self, d_id, code_str, name, x, y, w=245, h=56):
        self.boxes[d_id] = (x, y, w, h, 'datastore', code_str, name)

    def get_port_point(self, box_id, side, frac=0.5):
        x, y, w, h, _, _, _ = self.boxes[box_id]
        if side == 'L':
            return (round(x), round(y + h * frac), 0, frac)
        elif side == 'R':
            return (round(x + w), round(y + h * frac), 1, frac)
        elif side == 'T':
            return (round(x + w * frac), round(y), frac, 0)
        elif side == 'B':
            return (round(x + w * frac), round(y + h), frac, 1)
        raise ValueError(f"Unknown side {side}")

    def add_orthogonal_flow(self, flow_id, src, src_side, src_frac, tgt, tgt_side, tgt_frac, label, mids=None, lbl_pos=0.0):
        """
        mids: list of intermediate coordinates to turn at.
        Every segment from start -> w1 -> w2 -> ... -> end must be strictly horizontal or vertical!
        """
        sx, sy, exitX, exitY = self.get_port_point(src, src_side, src_frac)
        tx, ty, entryX, entryY = self.get_port_point(tgt, tgt_side, tgt_frac)
        
        if mids is None and sx != tx and sy != ty:
            if src_side in ('L', 'R') and tgt_side in ('L', 'R'):
                mid_x = round((sx + tx) / 2)
                waypoints = [(mid_x, sy), (mid_x, ty)]
            elif src_side in ('T', 'B') and tgt_side in ('T', 'B'):
                mid_y = round((sy + ty) / 2)
                waypoints = [(sx, mid_y), (tx, mid_y)]
            elif src_side in ('L', 'R') and tgt_side in ('T', 'B'):
                waypoints = [(tx, sy)]
            elif src_side in ('T', 'B') and tgt_side in ('L', 'R'):
                waypoints = [(sx, ty)]
            else:
                waypoints = []
        else:
            waypoints = mids or []

        full_pts = [(sx, sy)] + [(round(px), round(py)) for px, py in waypoints] + [(tx, ty)]

        # Validate strict orthogonality
        for i in range(len(full_pts) - 1):
            x1, y1 = full_pts[i]
            x2, y2 = full_pts[i + 1]
            if x1 != x2 and y1 != y2:
                raise ValueError(
                    f"[{self.tab_name}] Flow {flow_id} ({src}->{tgt}) has NON-ORTHOGONAL segment "
                    f"({x1},{y1}) -> ({x2},{y2})! Full points: {full_pts}"
                )

        self.edges.append({
            'id': flow_id,
            'src': src,
            'tgt': tgt,
            'label': label,
            'exitX': exitX,
            'exitY': exitY,
            'entryX': entryX,
            'entryY': entryY,
            'waypoints': [(round(px), round(py)) for px, py in waypoints],
            'full_pts': full_pts,
            'lbl_pos': lbl_pos
        })

    def audit_geometry(self, min_parallel_gap=12):
        issues = []
        segments = []  # (edge_id, src, tgt, x1, y1, x2, y2, orient)
        for e in self.edges:
            pts = e['full_pts']
            for i in range(len(pts) - 1):
                x1, y1 = pts[i]
                x2, y2 = pts[i + 1]
                if x1 == x2 and y1 == y2:
                    continue
                orient = 'V' if x1 == x2 else 'H'
                segments.append((e['id'], e['src'], e['tgt'], min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2), orient))

        # 1. Check segment vs unrelated box collision
        for eid, s_id, t_id, x1, y1, x2, y2, orient in segments:
            for bid, (bx, by, bw, bh, _, _, _) in self.boxes.items():
                if bid in (s_id, t_id):
                    continue
                # Expand box by 4px margin
                rx1, ry1, rx2, ry2 = bx - 4, by - 4, bx + bw + 4, by + bh + 4
                if orient == 'H':
                    if ry1 <= y1 <= ry2 and max(x1, rx1) <= min(x2, rx2):
                        issues.append(f"BOX COLLISION: Edge {eid} ({s_id}->{t_id}) H-segment y={y1} [{x1}..{x2}] hits box {bid} [{bx}..{bx+bw}, {by}..{by+bh}]")
                else:
                    if rx1 <= x1 <= rx2 and max(y1, ry1) <= min(y2, ry2):
                        issues.append(f"BOX COLLISION: Edge {eid} ({s_id}->{t_id}) V-segment x={x1} [{y1}..{y2}] hits box {bid} [{bx}..{bx+bw}, {by}..{by+bh}]")

        # 2. Check parallel/collinear overlap and perpendicular crossings
        crossings = []
        for i in range(len(segments)):
            eid1, s1, t1, ax1, ay1, ax2, ay2, o1 = segments[i]
            for j in range(i + 1, len(segments)):
                eid2, s2, t2, bx1, by1, bx2, by2, o2 = segments[j]
                if eid1 == eid2:
                    continue
                if o1 == o2:
                    if o1 == 'H':
                        # Check if intervals on X overlap and Y is too close
                        overlap_x = min(ax2, bx2) - max(ax1, bx1)
                        if overlap_x > 0 and abs(ay1 - by1) < min_parallel_gap:
                            issues.append(f"PARALLEL OVERLAP (H): {eid1} (y={ay1}) and {eid2} (y={by1}) overlap on x=[{max(ax1,bx1)}..{min(ax2,bx2)}]")
                    else:
                        overlap_y = min(ay2, by2) - max(ay1, by1)
                        if overlap_y > 0 and abs(ax1 - bx1) < min_parallel_gap:
                            issues.append(f"PARALLEL OVERLAP (V): {eid1} (x={ax1}) and {eid2} (x={bx1}) overlap on y=[{max(ay1,by1)}..{min(ay2,by2)}]")
                else:
                    # One is H, one is V
                    h_seg = (eid1, ax1, ay1, ax2, ay2) if o1 == 'H' else (eid2, bx1, by1, bx2, by2)
                    v_seg = (eid2, bx1, by1, bx2, by2) if o1 == 'H' else (eid1, ax1, ay1, ax2, ay2)
                    _, hx1, hy, hx2, _ = h_seg
                    _, vx, vy1, _, vy2 = v_seg
                    # Strict interior crossing
                    if hx1 < vx < hx2 and vy1 < hy < vy2:
                        crossings.append(f"CROSSING: {eid1} ({s1}->{t1}) crosses {eid2} ({s2}->{t2}) at ({vx}, {hy})")
                    # Endpoint T-junction on unrelated line
                    elif (hx1 <= vx <= hx2 and vy1 <= hy <= vy2) and not ({s1, t1} & {s2, t2}):
                        issues.append(f"T-TOUCH ON UNRELATED LINE: {eid1} touches {eid2} at ({vx}, {hy})")

        return issues, crossings

    def to_xml(self, mxfile):
        diagram = ET.SubElement(mxfile, 'diagram', id=self.diag_id, name=self.tab_name)
        model = ET.SubElement(
            diagram, 'mxGraphModel',
            dx='1420', dy='860', grid='1', gridSize='10', guides='1',
            tooltips='1', connect='1', arrows='1', fold='1', page='1',
            pageScale='1', pageWidth=str(self.page_w), pageHeight=str(self.page_h), math='0', shadow='0'
        )
        root = ET.SubElement(model, 'root')
        ET.SubElement(root, 'mxCell', id='0')
        ET.SubElement(root, 'mxCell', id='1', parent='0')

        # Title Banner
        t_cell = ET.SubElement(
            root, 'mxCell', id=f'{self.diag_id}_title', value=self.title_text,
            style='text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=17;fontStyle=1;fontColor=#111827;',
            vertex='1', parent='1'
        )
        ET.SubElement(t_cell, 'mxGeometry', x='100', y='18', width=str(self.page_w - 200), height='32', **{'as': 'geometry'})

        s_cell = ET.SubElement(
            root, 'mxCell', id=f'{self.diag_id}_subtitle', value=self.subtitle_text,
            style='text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=12;fontStyle=2;fontColor=#4B5563;',
            vertex='1', parent='1'
        )
        ET.SubElement(s_cell, 'mxGeometry', x='100', y='50', width=str(self.page_w - 200), height='22', **{'as': 'geometry'})

        # Add boxes
        for bid, (x, y, w, h, kind, code, name) in self.boxes.items():
            if kind == 'entity':
                cell = ET.SubElement(
                    root, 'mxCell', id=bid, value=name,
                    style='rounded=0;whiteSpace=wrap;html=1;fillColor=#ffffff;strokeColor=#1F2937;strokeWidth=2;fontStyle=1;align=center;verticalAlign=middle;fontSize=11;fontColor=#111827;',
                    vertex='1', parent='1'
                )
                ET.SubElement(cell, 'mxGeometry', x=str(x), y=str(y), width=str(w), height=str(h), **{'as': 'geometry'})
            elif kind in ('process', 'ref_process'):
                fill = '#F3F4F6' if kind == 'ref_process' else '#ffffff'
                cell = ET.SubElement(
                    root, 'mxCell', id=bid, value=str(code),
                    style=f'swimlane;whiteSpace=wrap;html=1;rounded=1;arcSize=14;startSize=26;horizontal=1;fontStyle=1;align=center;fillColor={fill};strokeColor=#1F2937;strokeWidth=2;collapsible=0;fontSize=12;fontColor=#111827;',
                    vertex='1', parent='1'
                )
                ET.SubElement(cell, 'mxGeometry', x=str(x), y=str(y), width=str(w), height=str(h), **{'as': 'geometry'})
                lbl = ET.SubElement(
                    root, 'mxCell', id=f'{bid}_lbl', value=name,
                    style='text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=11;fontColor=#111827;fontStyle=0;',
                    vertex='1', parent=bid
                )
                ET.SubElement(lbl, 'mxGeometry', y='26', width=str(w), height=str(h - 26), **{'as': 'geometry'})
            elif kind == 'datastore':
                cell = ET.SubElement(
                    root, 'mxCell', id=bid, value=str(code),
                    style='swimlane;horizontal=0;whiteSpace=wrap;html=1;startSize=30;fontStyle=1;align=center;fillColor=#ffffff;strokeColor=#1F2937;strokeWidth=2;collapsible=0;fontSize=12;fontColor=#111827;',
                    vertex='1', parent='1'
                )
                ET.SubElement(cell, 'mxGeometry', x=str(x), y=str(y), width=str(w), height=str(h), **{'as': 'geometry'})
                lbl = ET.SubElement(
                    root, 'mxCell', id=f'{bid}_lbl', value=name,
                    style='text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=11;fontColor=#111827;fontStyle=0;',
                    vertex='1', parent=bid
                )
                ET.SubElement(lbl, 'mxGeometry', x='30', y='0', width=str(w - 30), height=str(h), **{'as': 'geometry'})

        # Add edges (clean orthogonal connectors, no bridge hops if jump_style is None)
        for e in self.edges:
            style = (
                f"edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
                f"endArrow=classic;strokeColor=#1F2937;strokeWidth=1.5;fontSize=10;fontColor=#111827;"
                f"labelBackgroundColor=#ffffff;"
            )
            if self.jump_style:
                style += f"jumpStyle={self.jump_style};jumpSize=10;"
            style += (
                f"exitX={e['exitX']};exitY={e['exitY']};exitDx=0;exitDy=0;"
                f"entryX={e['entryX']};entryY={e['entryY']};entryDx=0;entryDy=0;"
            )
            edge = ET.SubElement(root, 'mxCell', id=e['id'], value=e['label'], style=style, edge='1', parent='1', source=e['src'], target=e['tgt'])
            geo = ET.SubElement(edge, 'mxGeometry', x=str(e['lbl_pos']), relative='1', **{'as': 'geometry'})
            if e['waypoints']:
                arr = ET.SubElement(geo, 'Array', **{'as': 'points'})
                for wx, wy in e['waypoints']:
                    ET.SubElement(arr, 'mxPoint', x=str(wx), y=str(wy))

print("OrthogonalDFDBuilder helper ready.")
