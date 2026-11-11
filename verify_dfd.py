import xml.etree.ElementTree as ET

tree = ET.parse(r'c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_0.drawio')
root = tree.getroot()

entities = {'E1', 'E2', 'E3', 'E4', 'E5', 'E6'}
processes = {'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7'}
datastores = {'D1', 'D2', 'D3', 'D4', 'D5', 'D6'}

edges = root.findall('.//mxCell[@edge="1"]')
print(f'Checking {len(edges)} edges against strict DFD rules...')

violations = []
node_in = {k: 0 for k in (entities | processes | datastores)}
node_out = {k: 0 for k in (entities | processes | datastores)}

for e in edges:
    src = e.get('source')
    tgt = e.get('target')
    val = e.get('value')
    fid = e.get('id')
    
    if not src or not tgt:
        violations.append(f'Edge {fid} missing source or target')
        continue
        
    node_out[src] = node_out.get(src, 0) + 1
    node_in[tgt] = node_in.get(tgt, 0) + 1
    
    # Rule 1: No Entity to Entity
    if src in entities and tgt in entities:
        violations.append(f'Illegal Entity-to-Entity: {src} -> {tgt} ({val})')
    # Rule 2: No Entity to Store
    if src in entities and tgt in datastores:
        violations.append(f'Illegal Entity-to-Store: {src} -> {tgt} ({val})')
    # Rule 3: No Store to Entity
    if src in datastores and tgt in entities:
        violations.append(f'Illegal Store-to-Entity: {src} -> {tgt} ({val})')
    # Rule 4: No Store to Store
    if src in datastores and tgt in datastores:
        violations.append(f'Illegal Store-to-Store: {src} -> {tgt} ({val})')

print('Total Violations:', len(violations))
for v in violations:
    print('  -', v)

print('\n--- Process I/O Audit ---')
for p in sorted(processes):
    print(f'Process {p}: Inputs={node_in[p]}, Outputs={node_out[p]}')
    if node_in[p] == 0:
        print(f'  ERROR: Process {p} has 0 inputs!')
    if node_out[p] == 0:
        print(f'  ERROR: Process {p} has 0 outputs!')

print('\n--- Data Store I/O Audit ---')
for d in sorted(datastores):
    print(f'Store {d}: Inputs={node_in[d]}, Outputs={node_out[d]}')
    if node_in[d] == 0:
        print(f'  WARNING: Store {d} has 0 inputs (read-only)!')
    if node_out[d] == 0:
        print(f'  WARNING: Store {d} has 0 outputs (write-only)!')

print('\n--- Entity I/O Audit ---')
for ent in sorted(entities):
    print(f'Entity {ent}: Inputs={node_in[ent]}, Outputs={node_out[ent]}')
