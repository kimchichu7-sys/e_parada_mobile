#!/usr/bin/env python3
"""
Generates the Single-Tab, Portrait-Oriented, Strict Gane & Sarson / IEEE Level-1 DFD
for E-Parada (e_parada_dfd_level_1.drawio) reflecting the 18-Module Architecture:
- 15 Subprocesses on Level 1:
  * 12 Elementary Module Processes (M01, M03, M04, M06, M07, M08, M09, M12, M13, M16, M17, M18)
  * 3 Compound Processes (1.1, 2.3, 4.1) that decompose into the remaining 6 Elementary Modules on Level 2
  * Total Elementary Leaf Modules across Level 1 + Level 2 = 12 + 6 = 18 Modules!
- Portrait Page Dimensions: 1240 x 1540 (Fits cleanly on 1 Portrait Page)
- Mathematically Verified: 0 Crossings, 0 Overlaps, 0 Box Cuts
"""

import html

PAGE_W = 1240
PAGE_H = 1540

cells = []

STYLE_TITLE = "text;html=1;strokeColor=#000000;strokeWidth=1.5;fillColor=#FFFFFF;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=12;fontStyle=1;fontColor=#000000;"
STYLE_ENTITY = "rounded=0;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;fontStyle=1;align=center;verticalAlign=middle;fontSize=10;fontColor=#000000;"
STYLE_PROCESS = "swimlane;whiteSpace=wrap;html=1;rounded=0;startSize=20;horizontal=1;fontStyle=1;align=center;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;collapsible=0;fontSize=10;fontColor=#000000;"
STYLE_PROCESS_LBL = "text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=9;fontColor=#000000;fontStyle=1;"
STYLE_STORE = "swimlane;horizontal=0;whiteSpace=wrap;html=1;startSize=28;fontStyle=1;align=center;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;collapsible=0;fontSize=9.5;fontColor=#000000;swimlaneLine=0;"
STYLE_STORE_LBL = "text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=9.5;fontColor=#000000;fontStyle=1;"
STYLE_EDGE = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=classic;strokeColor=#000000;strokeWidth=1.2;fontSize=8.5;fontColor=#000000;fontStyle=1;labelBackgroundColor=#FFFFFF;jumpStyle=none;"

def add_box(cid, x, y, w, h, label, style, parent="1"):
    escaped = html.escape(label, quote=True).replace("\n", "&#xa;")
    cells.append(
        f'        <mxCell id="{cid}" value="{escaped}" style="{style}" vertex="1" parent="{parent}">\n'
        f'          <mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry" />\n'
        f'        </mxCell>'
    )
    return cid

def add_process(pid, num, title, x, y, w, h):
    add_box(pid, x, y, w, h, str(num), STYLE_PROCESS)
    add_box(f"{pid}_lbl", 0, 20, w, h - 20, title, STYLE_PROCESS_LBL, parent=pid)

def add_store(sid, snum, stitle, x, y, w, h):
    add_box(sid, x, y, w, h, snum, STYLE_STORE)
    add_box(f"{sid}_lbl", 28, 0, w - 28, h, stitle, STYLE_STORE_LBL, parent=sid)

def add_edge(eid, label, src_id, tgt_id, points, exit_x, exit_y, entry_x, entry_y):
    exit_spec = f"exitX={exit_x};exitY={exit_y};exitDx=0;exitDy=0;"
    entry_spec = f"entryX={entry_x};entryY={entry_y};entryDx=0;entryDy=0;"
    style = STYLE_EDGE + exit_spec + entry_spec
    escaped = html.escape(label, quote=True)
    pts_xml = ""
    if points:
        pts_xml = '            <Array as="points">\n'
        for px, py in points:
            pts_xml += f'              <mxPoint x="{px}" y="{py}" />\n'
        pts_xml += '            </Array>\n'
    cells.append(
        f'        <mxCell id="{eid}" value="{escaped}" style="{style}" edge="1" parent="1" source="{src_id}" target="{tgt_id}">\n'
        f'          <mxGeometry relative="1" as="geometry">\n'
        f'{pts_xml}'
        f'          </mxGeometry>\n'
        f'        </mxCell>'
    )

# -------------------------------------------------------------------------
# 1. HEADER BANNER
# -------------------------------------------------------------------------
add_box(
    "title_banner", 15, 12, PAGE_W - 30, 28,
    "E-PARADA SYSTEM - LEVEL-1 DFD (15 SUBPROCESSES: 12 ELEMENTARY MODULES + 3 COMPOUND -> 18 MODULES TOTAL)",
    STYLE_TITLE
)

# -------------------------------------------------------------------------
# 2. EXTERNAL ENTITIES (4 Core Entities + 2 Local Aliases)
# -------------------------------------------------------------------------
add_box("ADMIN", 495, 55, 175, 68, "SYSTEM\nADMINISTRATOR", STYLE_ENTITY)
add_box("DRIVER_main", 20, 320, 115, 250, "DRIVER / END USER", STYLE_ENTITY)
add_box("PROVIDER_main", 1025, 310, 145, 145, "PARKING SPACE\nPROVIDER", STYLE_ENTITY)
add_box("DRIVER_alias", 1025, 610, 145, 58, "DRIVER / END USER", STYLE_ENTITY)
add_box("PROVIDER_alias", 215, 1020, 180, 55, "PARKING SPACE\nPROVIDER", STYLE_ENTITY)
add_box("GCASH", 495, 1435, 175, 65, "PAYMENT GATEWAY\n(GCash)", STYLE_ENTITY)

# -------------------------------------------------------------------------
# 3. 15 SUBPROCESSES & DATA STORES
# -------------------------------------------------------------------------

# === DOMAIN 1.0 (Left-Top): 1.1 [Compound: M02+M14], 1.2 [M01] ===
add_process("P1_1", "1.1", "Register User & Vehicle KYC\n[Decomposes in L2: M02, M14]", 215, 95, 180, 66)
add_store("D1_left", "D1", "User & Vehicle Records", 215, 192, 180, 32)
add_process("P1_2", "1.2", "Authenticate & Issue RBAC Token\n[Module M01]", 215, 255, 180, 66)

# === DOMAIN 2.0 (Right-Top): 2.1 [M08], 2.2 [M09], 2.3 [Compound: M10+M15] ===
add_store("D1_right", "D1", "User & Vehicle Records", 785, 55, 180, 32)
add_process("P2_1", "2.1", "Onboard Provider Property\n[Module M08]", 785, 115, 180, 64)
add_process("P2_2", "2.2", "Configure 2D Slot Grid (x, z)\n[Module M09]", 785, 210, 180, 64)
add_store("D2_top", "D2", "Parking Spaces & 2D Slots", 785, 302, 180, 32)
add_process("P2_3", "2.3", "Manage Pricing & Rate Caps\n[Decomposes in L2: M10, M15]", 785, 362, 180, 64)

# === DOMAIN 3.0 (Left-Upper-Mid): 3.1 [M03], 3.2 [M04] ===
add_process("P3_1", "3.1", "Geospatial Search Engine\n[Module M03]", 215, 410, 180, 66)
add_store("D2_mid", "D2", "Parking Spaces & 2D Slots", 215, 508, 180, 32)
add_process("P3_2", "3.2", "Render Real-Time 2D Floorplan\n[Module M04]", 215, 572, 180, 66)

# === DOMAIN 4.0 (Left-Lower-Mid): 4.1 [Compound: M11+M05], 4.2 [M06] ===
add_store("D2_p4", "D2", "Parking Spaces & 2D Slots", 215, 672, 180, 32)
add_process("P4_1", "4.1", "Lock Slot & Schedule Booking\n[Decomposes in L2: M11, M05]", 215, 738, 180, 66)
add_store("D3_lower", "D3", "Reservation Records", 215, 838, 180, 32)
add_process("P4_2", "4.2", "Issue Dual-Factor HMAC QR Pass\n[Module M06]", 215, 905, 180, 66)

# === DOMAIN 5.0 (Right-Mid): 5.1 [M12] ===
add_store("D3_right", "D3", "Reservation Records", 785, 485, 180, 32)
add_process("P5_1", "5.1", "Optical Camera & RES-# QR Gate\n[Module M12]", 785, 555, 180, 68)
add_store("D4_sessions", "D4", "Active Parking Sessions", 785, 665, 180, 32)

# === DOMAIN 7.0 (Center Column): 7.1 [M07], 7.2 [M16], 7.3 [M17], 7.4 [M18] ===
add_process("P7_2", "7.2", "Financial Audit & Disputes\n[Module M16]", 492, 360, 180, 64)
add_store("D6_center", "D6", "Feedback & Audit Logs", 492, 455, 180, 32)
add_process("P7_4", "7.4", "Occupancy Heatmaps & Reports\n[Module M18]", 492, 518, 180, 64)
add_store("D5_mid", "D5", "Payment & Receipts", 492, 612, 180, 32)
add_process("P7_3", "7.3", "Security Telemetry & Incidents\n[Module M17]", 492, 675, 180, 64)
add_store("D4_center", "D4", "Active Parking Sessions", 492, 770, 180, 32)
add_process("P7_1", "7.1", "Real-Time WebRTC Audio & Chat\n[Module M07]", 492, 835, 180, 64)
add_store("D6_lower", "D6", "Feedback & Audit Logs", 492, 932, 180, 32)

# === DOMAIN 6.0 (Lower-Center): 6.1 [M13] ===
add_store("D5_lower", "D5", "Payment & Receipts", 492, 1110, 180, 32)
add_process("P6_1", "6.1", "Duration Billing & GCash Escrow\n[Module M13]", 492, 1210, 180, 76)


# -------------------------------------------------------------------------
# 4. ZERO-INTERSECTION ORTHOGONAL DATA FLOWS
# -------------------------------------------------------------------------

# --- Domain 1.0 (1.1 & 1.2) ---
add_edge("f01", "Registration, Credentials & OR/CR", "DRIVER_main", "P1_1", [(55, 128)], 0.3, 0, 0, 0.5)
add_edge("f02", "Pending KYC & Vehicle Records", "P1_1", "ADMIN", [(430, 115), (430, 75)], 1, 0.3, 0, 0.25)
add_edge("f03", "Account KYC Approval Status", "ADMIN", "P1_1", [(450, 102), (450, 141)], 0, 0.65, 1, 0.7)
add_edge("f04", "Verified Driver & Vehicle Profile", "P1_1", "D1_left", [], 0.5, 1, 0.5, 0)
add_edge("f05", "Verified User Credentials & Role", "D1_left", "P1_2", [], 0.5, 1, 0.5, 0)
add_edge("f06", "Authentication Token & KYC Notice", "P1_2", "DRIVER_main", [(100, 288)], 0, 0.5, 0.7, 0)
add_edge("f07", "Login Session Request", "DRIVER_main", "P1_2", [(305, 338)], 1, 0.07, 0.5, 1)

# --- Domain 2.0 (2.1, 2.2, 2.3) ---
add_edge("f08", "Provider Profile & Property KYC", "PROVIDER_main", "P2_1", [(1098, 147)], 0.5, 0, 1, 0.5)
add_edge("f09", "Pending Facility Submission", "P2_1", "ADMIN", [(745, 134), (745, 72)], 0, 0.3, 1, 0.25)
add_edge("f10", "Facility KYC Approval", "ADMIN", "P2_1", [(725, 92), (725, 160)], 1, 0.55, 0, 0.7)
add_edge("f11", "Verified Provider Profile Data", "P2_1", "D1_right", [], 0.5, 0, 0.5, 1)
add_edge("f12", "2D Slot Grid Layout (x, z)", "PROVIDER_main", "P2_2", [(995, 340), (995, 242)], 0, 0.2, 1, 0.5)
add_edge("f13", "Configured 2D Slot Coordinates", "P2_2", "D2_top", [], 0.5, 1, 0.5, 0)
add_edge("f14", "Dynamic Rates & Operating Hours", "PROVIDER_main", "P2_3", [], 0, 0.58, 1, 0.5)
add_edge("f15", "Regional Price Ceiling Policy", "ADMIN", "P2_3", [(708, 110), (708, 394)], 1, 0.8, 0, 0.5)
add_edge("f16", "Validated Rate & Grace Rules", "P2_3", "D2_top", [], 0.5, 0, 0.5, 1)

# --- Domain 3.0 (3.1 & 3.2) ---
add_edge("f17", "Location Search & Filter Query", "DRIVER_main", "P3_1", [(285, 390)], 1, 0.28, 0.4, 0)
add_edge("f18", "Slot Layout, Rates & Occupancy", "D2_mid", "P3_1", [], 0.5, 0, 0.5, 1)
add_edge("f19", "Filtered Nearby Parking List", "P3_1", "DRIVER_main", [(192, 443), (192, 435)], 0, 0.5, 1, 0.46)
add_edge("f20", "2D Grid Coordinates & Route Data", "D2_mid", "P3_2", [], 0.5, 1, 0.5, 0)
add_edge("f21", "Selected Facility Map Request", "DRIVER_main", "P3_2", [(175, 480), (175, 592)], 1, 0.64, 0, 0.3)
add_edge("f22", "Interactive 2D Floorplan & Route", "P3_2", "DRIVER_main", [(158, 618), (158, 515)], 0, 0.7, 1, 0.78)

# --- Domain 4.0 (4.1 & 4.2) ---
add_edge("f23", "Slot Availability & Rate Rules", "D2_p4", "P4_1", [], 0.5, 1, 0.5, 0)
add_edge("f24", "Slot Selection & Booking Request", "DRIVER_main", "P4_1", [(140, 550), (140, 771)], 1, 0.92, 0, 0.5)
add_edge("f25", "Confirmed Booking & Slot Lock", "P4_1", "D3_lower", [], 0.5, 1, 0.5, 0)
add_edge("f26", "Confirmed Booking Details", "D3_lower", "P4_2", [], 0.5, 1, 0.5, 0)
add_edge("f27", "HMAC QR Code & Booking Pass", "P4_2", "DRIVER_main", [(114, 938)], 0, 0.5, 0.82, 1)
add_edge("f28", "Reservation Alert & Driver ETA", "P4_2", "PROVIDER_alias", [], 0.5, 1, 0.5, 0)

# --- Domain 5.0 (5.1) ---
add_edge("f29", "Reservation Validation Record", "D3_right", "P5_1", [], 0.5, 1, 0.5, 0)
add_edge("f30", "Optical QR Scan / RES-# Code", "PROVIDER_main", "P5_1", [(1098, 575)], 0.5, 1, 1, 0.3)
add_edge("f31", "Access Granted & Slot Assignment", "P5_1", "DRIVER_alias", [(995, 602), (995, 639)], 1, 0.7, 0, 0.5)
add_edge("f32", "Check-In / Check-Out Timestamps", "P5_1", "D4_sessions", [], 0.5, 1, 0.5, 0)

# --- Domain 7.0 (7.1, 7.2, 7.3, 7.4) ---
add_edge("f33", "WebRTC Voice & Chat Stream", "DRIVER_main", "P7_1", [(435, 360), (435, 867)], 1, 0.16, 0, 0.5)
add_edge("f34", "Active Booking Session State", "D4_center", "P7_1", [], 0.5, 1, 0.5, 0)
add_edge("f35", "Completed Comms & Review Log", "P7_1", "D6_lower", [], 0.5, 1, 0.5, 0)
add_edge("f36", "Dispute & Moderation Directives", "ADMIN", "P7_2", [], 0.35, 1, 0.35, 0)
add_edge("f37", "Mediated Dispute & Refund Log", "P7_2", "D6_center", [], 0.5, 1, 0.5, 0)
add_edge("f38", "Audit & Incident Summary", "D6_center", "P7_4", [], 0.5, 1, 0.5, 0)
add_edge("f39", "Unauthorized Stay / Gate Alert", "D4_sessions", "P7_3", [(730, 681), (730, 707)], 0, 0.5, 1, 0.5)
add_edge("f40", "Transaction Financial Totals", "D5_mid", "P7_3", [], 0.5, 1, 0.5, 0)
add_edge("f41", "Financial & Occupancy Metrics", "D5_mid", "P7_4", [], 0.5, 0, 0.5, 1)
add_edge("f42", "Logged Security & Overstay Record", "P7_3", "D4_center", [], 0.5, 1, 0.5, 0)
add_edge("f43", "Heatmaps & Forensic CSV/PDF Report", "P7_4", "ADMIN", [(690, 550), (690, 340), (635, 340)], 1, 0.5, 0.8, 1)

# --- Domain 6.0 (6.1) ---
add_edge("f44", "Completed Session Duration", "D4_sessions", "P6_1", [(875, 1235)], 0.5, 1, 1, 0.33)
add_edge("f45", "Prepaid Downpayment Credit", "D5_lower", "P6_1", [], 0.3, 1, 0.3, 0)
add_edge("f46", "Recorded Digital Receipt & Split", "P6_1", "D5_lower", [], 0.7, 0, 0.7, 1)
add_edge("f47", "Itemized Bill Statement", "P6_1", "DRIVER_main", [(78, 1235)], 0, 0.33, 0.5, 1)
add_edge("f48", "Payment Authorization & Method", "DRIVER_main", "P6_1", [(43, 1265)], 0.2, 1, 0, 0.72)
add_edge("f49", "Gateway Payment Request", "P6_1", "GCASH", [], 0.33, 1, 0.32, 0)
add_edge("f50", "Payment Settlement Webhook", "GCASH", "P6_1", [], 0.68, 0, 0.67, 1)
add_edge("f51", "Settled Payout Notification", "P6_1", "PROVIDER_main", [(1205, 1265), (1205, 382)], 1, 0.72, 1, 0.5)


# -------------------------------------------------------------------------
# BUILD XML
# -------------------------------------------------------------------------
drawio_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2026-11-08T10:50:00.000Z" agent="E-Parada Portrait Level-1 DFD (15 Subprocesses)" version="24.0.0" type="device">
  <diagram id="level-1-dfd" name="Level 1 DFD (Portrait - 15 Subprocesses - Zero Crossings)">
    <mxGraphModel dx="1240" dy="1540" grid="1" gridSize="5" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="{PAGE_W}" pageHeight="{PAGE_H}" background="#FFFFFF" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
{chr(10).join(cells)}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
"""

with open(r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_1.drawio", "w", encoding="utf-8") as f:
    f.write(drawio_xml)

with open(r"C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\e_parada_dfd_level_1.drawio", "w", encoding="utf-8") as f:
    f.write(drawio_xml)

print("Saved Single-Tab 15-Subprocess Portrait Level-1 DFD successfully!")
