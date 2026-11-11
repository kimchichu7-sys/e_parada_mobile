import xml.etree.ElementTree as ET

lvl0_tree = ET.parse(r'c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_0.drawio')
lvl1_tree = ET.parse(r'c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_1.drawio')

# Extract Level 0 connections per process P1..P7
lvl0_edges = lvl0_tree.getroot().findall('.//mxCell[@edge="1"]')
lvl0_neighbors = {f'P{i}': set() for i in range(1, 8)}

for e in lvl0_edges:
    s, t = e.get('source'), e.get('target')
    if s in lvl0_neighbors:
        lvl0_neighbors[s].add(t)
    if t in lvl0_neighbors:
        lvl0_neighbors[t].add(s)

diagrams = lvl1_tree.getroot().findall('diagram')
print(f'Auditing {len(diagrams)} Level-1 Decomposition Tabs...')

total_violations = 0
for idx, diag in enumerate(diagrams, start=1):
    p_parent = f'P{idx}'
    t_name = diag.get('name')
    edges = diag.findall('.//mxCell[@edge="1"]')
    vertices = diag.findall('.//mxCell[@vertex="1"]')

    entities, stores, subprocs, refprocs = set(), set(), set(), set()
    carried_over = set()

    for v in vertices:
        vid = v.get('id', '')
        if vid.endswith('_lbl') or vid.endswith('_title') or vid.endswith('_subtitle'):
            continue
        if '_E' in vid:
            entities.add(vid)
            carried_over.add(vid.split('_')[1])
        elif '_D' in vid:
            stores.add(vid)
            carried_over.add(vid.split('_')[1])
        elif '_ref' in vid:
            refprocs.add(vid)
            carried_over.add(vid.split('_')[1])
        elif vid.startswith('P'):
            subprocs.add(vid)

    in_deg = {k: 0 for k in subprocs}
    out_deg = {k: 0 for k in subprocs}
    tab_violations = []

    for e in edges:
        s, t = e.get('source'), e.get('target')
        val = e.get('value')
        if s in subprocs:
            out_deg[s] += 1
        if t in subprocs:
            in_deg[t] += 1

        # Check forbidden connections
        if s in entities and t in entities:
            tab_violations.append(f'Entity-to-Entity: {s} -> {t}')
        if (s in entities and t in stores) or (s in stores and t in entities):
            tab_violations.append(f'Entity-to-Store: {s} -> {t}')
        if s in stores and t in stores:
            tab_violations.append(f'Store-to-Store: {s} -> {t}')

    for sp in sorted(subprocs):
        if in_deg[sp] == 0:
            tab_violations.append(f'Miracle sub-process {sp} (0 inputs)')
        if out_deg[sp] == 0:
            tab_violations.append(f'Black-hole sub-process {sp} (0 outputs)')

    missing_from_lvl0 = lvl0_neighbors[p_parent] - carried_over
    if missing_from_lvl0:
        tab_violations.append(f'Missing Level-0 neighbors on Tab {idx}: {missing_from_lvl0}')

    total_violations += len(tab_violations)
    print(f'[{t_name}] Sub-processes={len(subprocs)}, Flows={len(edges)}, Carried-Over Nodes={sorted(carried_over)}, Violations={len(tab_violations)}')
    for v in tab_violations:
        print('   ERROR:', v)

print(f'\nFINAL AUDIT RESULT: {total_violations} total violations across all 7 Level-1 tabs!')
