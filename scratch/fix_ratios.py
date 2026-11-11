import re

path = r'c:\Users\kimch\e_parada_mobile\scratch\test_zero_central_v4.py'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("'D4', 'B', 0.67,", "'D4', 'B', 2/3,")
text = text.replace("'D4', 'B', 0.833,", "'D4', 'B', 5/6,")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated ratios in test_zero_central_v4.py successfully.")
