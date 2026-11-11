import xml.etree.ElementTree as ET

for name in ['e_parada_dfd_level_0.drawio', 'e_parada_dfd_level_1.drawio', 'e_parada_dfd_level_2.drawio']:
    path = rf'c:\Users\kimch\e_parada_mobile\{name}'
    tree = ET.parse(path)
    root = tree.getroot()
    diagrams = root.findall('diagram')
    print(f'=== {name} ===')
    for d in diagrams:
        print(f"  - [{d.get('id')}] {d.get('name')}")
