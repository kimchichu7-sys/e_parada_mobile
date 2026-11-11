import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')

path = r'c:\Users\kimch\e_parada_mobile\scratch\test_zero_central_v4.py'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# P7 is at x=1200, w=240.
# x=1360 is ratio 2/3 (160/240).
# x=1400 is ratio 5/6 (200/240).
# f51 (E2->P7): E2 R (0.3) -> mids -> P7 B (5/6):
# mids=[(2960, 270), (2960, 1840), (1400, 1840)]
# f52 (P7->E2): P7 B (2/3) -> mids -> E2 R (0.5):
# mids=[(1360, 1860), (2990, 1860), (2990, 290)]

old_f51_f52 = """    b0.add_orthogonal_flow('f51', 'E2', 'R', 0.3, 'P7', 'R', 0.15, 'WebRTC Voice/Chat Audio & Overstay / Infraction Reports', mids=[(2960, 270), (2960, 1840), (1480, 1840), (1480, 1725)])
    b0.add_orthogonal_flow('f52', 'P7', 'R', 0.25, 'E2', 'R', 0.5, 'WebRTC Audio/Chat Packets & Facility Occupancy Heatmaps', mids=[(1500, 1735), (1500, 1860), (2990, 1860), (2990, 290)])"""

new_f51_f52 = """    b0.add_orthogonal_flow('f51', 'E2', 'R', 0.3, 'P7', 'B', 5/6, 'WebRTC Voice/Chat Audio & Overstay / Infraction Reports', mids=[(2960, 270), (2960, 1840), (1400, 1840)])
    b0.add_orthogonal_flow('f52', 'P7', 'B', 2/3, 'E2', 'R', 0.5, 'WebRTC Audio/Chat Packets & Facility Occupancy Heatmaps', mids=[(1360, 1860), (2990, 1860), (2990, 290)])"""

assert old_f51_f52 in text, "old_f51_f52 not found"
text = text.replace(old_f51_f52, new_f51_f52)

with open(r'c:\Users\kimch\e_parada_mobile\scratch\test_zero_central_v5.py', 'w', encoding='utf-8') as f:
    f.write(text)

print("Created test_zero_central_v5.py")
