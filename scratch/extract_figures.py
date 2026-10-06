import os
import sys
sys.stdout.reconfigure(encoding='utf-8')
from pypdf import PdfReader

reader = PdfReader(r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\.user_uploaded\media_1790230367520.pdf')
out_dir = r'c:\Users\kimch\e_parada_mobile\scratch\extracted_figures'
os.makedirs(out_dir, exist_ok=True)

targets = [
    (7, "fig1_conceptual_framework"),
    (64, "fig6_system_architecture"),
    (68, "fig7_use_case_diagram"),
    (73, "fig8_activity_diagram"),
    (74, "fig9_core_erd"),
    (75, "fig10_communication_erd"),
    (76, "fig11_audit_erd"),
    (77, "fig12_support_erd"),
    (78, "fig13_core_db_schema"),
    (80, "fig14_ops_db_schema"),
    (81, "fig15_laravel_tables"),
    (83, "fig16_level0_dfd"),
    (86, "fig17_level1_dfd"),
    (88, "fig18_level2_dfd"),
    (90, "fig19_driver_ui"),
    (93, "fig20_owner_ui"),
    (94, "fig20_owner_ui_p94"),
    (95, "fig21_admin_ui"),
    (98, "fig22_website_ui"),
    (100, "fig23_logo"),
    (109, "fig24_system_flowchart"),
    (117, "fig25_subroutines"),
    (120, "fig26_incremental_model")
]

for p_num, name in targets:
    page = reader.pages[p_num - 1]
    for idx, img in enumerate(page.images):
        ext = os.path.splitext(img.name)[1] or '.png'
        filename = f"{name}_{idx}{ext}"
        path = os.path.join(out_dir, filename)
        with open(path, 'wb') as f:
            f.write(img.data)
        print(f"Extracted [P.{p_num}] -> {filename} ({len(img.data)} bytes)")

print("\nAll target figure images extracted successfully!")
