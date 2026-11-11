import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')

path = r'c:\Users\kimch\e_parada_mobile\scratch\test_zero_central_v5.py'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Test f11 & f12 concentric nesting:
# Currently:
# f11: mids=[(2540, 260), (2540, 190), (1480, 190), (1480, 270)]
# f12: mids=[(1460, 310), (1460, 210), (2560, 210), (2560, 290)]
# We change:
# f11: mids=[(2540, 260), (2540, 190), (1460, 190), (1460, 270)]
# f12: mids=[(1480, 310), (1480, 210), (2560, 210), (2560, 290)]

old_f11_f12 = """    b0.add_orthogonal_flow('f11', 'E2', 'L', 0.2, 'P2', 'R', 0.3, '2D Slot Grid, Rates & Operating Hours', mids=[(2540, 260), (2540, 190), (1480, 190), (1480, 270)])
    b0.add_orthogonal_flow('f12', 'P2', 'R', 0.7, 'E2', 'L', 0.5, 'Slot Layout & Rate Confirmation', mids=[(1460, 310), (1460, 210), (2560, 210), (2560, 290)])"""

new_f11_f12 = """    b0.add_orthogonal_flow('f11', 'E2', 'L', 0.2, 'P2', 'R', 0.3, '2D Slot Grid, Rates & Operating Hours', mids=[(2540, 260), (2540, 190), (1460, 190), (1460, 270)])
    b0.add_orthogonal_flow('f12', 'P2', 'R', 0.7, 'E2', 'L', 0.5, 'Slot Layout & Rate Confirmation', mids=[(1480, 310), (1480, 210), (2560, 210), (2560, 290)])"""

text = text.replace(old_f11_f12, new_f11_f12)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated f11 and f12.")
