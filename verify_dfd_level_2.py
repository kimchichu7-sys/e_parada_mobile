import xml.etree.ElementTree as ET

# Parse Level 1 to extract exact parent connections for each of the 27 sub-processes (P1_1 to P7_4)
lvl1_tree = ET.parse(r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_1.drawio")
lvl1_root = lvl1_tree.getroot()

lvl1_subproc_expected = {}  # code '1.1' -> {'in': set(), 'out': set()}


def canonical_node(cid, cells):
    """Maps a cell ID in Level 1 or Level 2 to its canonical node identifier (E1..E6, D1..D6, P3..P6, or sibling 1.1..7.4)."""
    val = (cells.get(cid, {}).get('value') or '').strip()
    if cid.startswith('P') and '_' in cid:
        # e.g. P1_2 -> '1.2'
        return val
    if 'E1' in cid or 'Driver / Motorist' in val:
        return 'E1'
    if 'E2' in cid or 'Parking Space Provider' in val:
        return 'E2'
    if 'E3' in cid or 'System Administrator' in val:
        return 'E3'
    if 'E4' in cid or 'Google Maps' in val:
        return 'E4'
    if 'E5' in cid or 'PayMongo' in val:
        return 'E5'
    if 'E6' in cid or 'Tesseract' in val:
        return 'E6'
    if val in {'D1', 'D2', 'D3', 'D4', 'D5', 'D6'}:
        return val
    if val in {'3', '4', '5', '6'}:
        return f'P{val}'
    if '.' in val and len(val) <= 4:
        return val
    return cid


for diag in lvl1_root.findall('diagram'):
    cells = {c.get('id'): {'value': c.get('value', ''), 'style': c.get('style', ''), 'edge': c.get('edge') == '1', 'src': c.get('source'), 'tgt': c.get('target')}
             for c in diag.findall('.//mxCell')}
    for cid, c in cells.items():
        if cid.startswith('P') and '_' in cid and not cid.endswith('_lbl'):
            code = c['value'].strip()
            lvl1_subproc_expected[code] = {'in': set(), 'out': set()}

    for cid, c in cells.items():
        if c['edge']:
            s, t = c['src'], c['tgt']
            s_can = canonical_node(s, cells)
            t_can = canonical_node(t, cells)
            if s_can in lvl1_subproc_expected:
                lvl1_subproc_expected[s_can]['out'].add(t_can)
            if t_can in lvl1_subproc_expected:
                lvl1_subproc_expected[t_can]['in'].add(s_can)

# Now parse Level 2 and audit all 27 tabs
lvl2_tree = ET.parse(r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_2.drawio")
lvl2_root = lvl2_tree.getroot()
diagrams = lvl2_root.findall('diagram')

print(f"Auditing {len(diagrams)} Level-2 Decomposition Tabs against Level-1 Parent Sub-Processes...")
total_violations = 0

for diag in diagrams:
    d_name = diag.get('name')
    # Extract parent code from tab name, e.g. 'L2 - 1.1 (Auth & RBAC)' -> '1.1'
    parent_code = d_name.split(' - ')[1].split(' ')[0].strip()

    cells = {c.get('id'): {'value': c.get('value', ''), 'style': c.get('style', ''), 'edge': c.get('edge') == '1', 'src': c.get('source'), 'tgt': c.get('target')}
             for c in diag.findall('.//mxCell')}

    micro_procs = {}
    boundary_nodes = {}
    in_deg = {}
    out_deg = {}
    actual_in = set()
    actual_out = set()
    tab_violations = 0

    for cid, c in cells.items():
        if cid in ('0', '1', 'title_banner', 'subtitle_banner') or cid.endswith('_lbl') or c['edge']:
            continue
        if cid in ('P1', 'P2', 'P3', 'P4'):
            micro_procs[cid] = c['value']
            in_deg[cid] = 0
            out_deg[cid] = 0
        else:
            boundary_nodes[cid] = canonical_node(cid, cells)

    edges = [c for c in cells.values() if c['edge']]
    for e in edges:
        s, t, lbl = e['src'], e['tgt'], (e['value'] or '').strip()
        if not lbl:
            print(f"  [{d_name}] VIOLATION: Unlabeled flow {s}->{t}")
            tab_violations += 1
        if s in in_deg:
            out_deg[s] += 1
        if t in in_deg:
            in_deg[t] += 1

        # Check illegal direct boundary-to-boundary flows
        if s in boundary_nodes and t in boundary_nodes:
            print(f"  [{d_name}] VIOLATION: Direct boundary-to-boundary flow {boundary_nodes[s]}->{boundary_nodes[t]}")
            tab_violations += 1

        if s in boundary_nodes and t in micro_procs:
            actual_in.add(boundary_nodes[s])
        if s in micro_procs and t in boundary_nodes:
            actual_out.add(boundary_nodes[t])

    # Check black holes / miracles on micro-processes
    for mp, mp_val in micro_procs.items():
        if in_deg[mp] == 0 or out_deg[mp] == 0:
            print(f"  [{d_name}] VIOLATION: Micro-process {mp_val} has in={in_deg[mp]}, out={out_deg[mp]}")
            tab_violations += 1

    # Check 100% Parent-Child Balancing with Level 1
    exp_in = lvl1_subproc_expected[parent_code]['in']
    exp_out = lvl1_subproc_expected[parent_code]['out']
    if actual_in != exp_in:
        print(f"  [{d_name}] BALANCING MISMATCH (IN): expected {sorted(exp_in)}, got {sorted(actual_in)}")
        tab_violations += 1
    if actual_out != exp_out:
        print(f"  [{d_name}] BALANCING MISMATCH (OUT): expected {sorted(exp_out)}, got {sorted(actual_out)}")
        tab_violations += 1

    total_violations += tab_violations
    print(f"[{d_name}] Micro-Procs={len(micro_procs)}, Flows={len(edges)}, In={sorted(actual_in)}, Out={sorted(actual_out)}, Violations={tab_violations}")

print(f"\nFINAL LEVEL-2 AUDIT RESULT: {total_violations} total violations across all {len(diagrams)} Level-2 tabs!")
