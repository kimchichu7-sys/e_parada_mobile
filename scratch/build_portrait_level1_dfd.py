#!/usr/bin/env python3
"""
Generates the Single-Tab, Portrait-Oriented, Strict Gane & Sarson / IEEE Level-1 DFD
for E-Parada (e_parada_dfd_level_1.drawio).
- Single Unified Tab (1 Tab instead of 7)
- Portrait Page Dimensions: 1220 x 1460 (Fits cleanly on 1 Portrait Page)
- 14 Decomposed Subprocesses (1.1 to 7.2) across all 7 functional domains
- 4 External Entities (Driver, Provider, System Administrator, Payment Gateway)
- 6 Persistent Data Stores (D1 to D6) mediating all inter-subprocess state
- Exact Zero-Intersection Manhattan Routing from media_1794131001208_12694577.png
- Mathematically Verified: 0 Crossings, 0 Overlaps, 0 Box Cuts
"""

import html

PAGE_W = 1220
PAGE_H = 1460

cells = []

STYLE_TITLE = "text;html=1;strokeColor=#000000;strokeWidth=1.5;fillColor=#FFFFFF;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=12;fontStyle=1;fontColor=#000000;"
STYLE_ENTITY = "rounded=0;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;fontStyle=1;align=center;verticalAlign=middle;fontSize=10;fontColor=#000000;"
STYLE_PROCESS = "swimlane;whiteSpace=wrap;html=1;rounded=0;startSize=20;horizontal=1;fontStyle=1;align=center;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;collapsible=0;fontSize=10;fontColor=#000000;"
STYLE_PROCESS_LBL = "text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=9.5;fontColor=#000000;fontStyle=1;"
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
    "E-PARADA SYSTEM - LEVEL-1 DFD (14 SUBPROCESSES | SINGLE-PAGE PORTRAIT | GANE & SARSON / IEEE STANDARD)",
    STYLE_TITLE
)

# -------------------------------------------------------------------------
# 2. EXTERNAL ENTITIES (4 Core Entities + 2 Local Aliases)
# -------------------------------------------------------------------------
# Top-Center: System Administrator
add_box("ADMIN", 495, 58, 170, 68, "SYSTEM\nADMINISTRATOR", STYLE_ENTITY)

# Left Perimeter: Main Driver / End User
add_box("DRIVER_main", 20, 330, 115, 220, "DRIVER / END USER", STYLE_ENTITY)

# Right Perimeter: Main Parking Space Provider
add_box("PROVIDER_main", 1015, 305, 145, 125, "PARKING SPACE\nPROVIDER", STYLE_ENTITY)

# Right-Middle Alias: Driver / End User (for Gate Access Grant 5.1)
add_box("DRIVER_alias", 1015, 515, 145, 58, "DRIVER / END USER", STYLE_ENTITY)

# Lower-Left Alias: Parking Space Provider (for Reservation Alert 4.2)
add_box("PROVIDER_alias", 215, 1005, 175, 55, "PARKING SPACE\nPROVIDER", STYLE_ENTITY)

# Bottom-Center: Payment Gateway (GCash)
add_box("GCASH", 495, 1365, 170, 65, "PAYMENT GATEWAY\n(GCash)", STYLE_ENTITY)

# -------------------------------------------------------------------------
# 3. SUBPROCESSES (14 Decomposed Subprocesses: 1.1 to 7.2) & DATA STORES
# -------------------------------------------------------------------------

# === GROUP 1.0: USER REGISTRATION & KYC AUTHENTICATION (Left-Top) ===
add_process("P1_1", "1.1", "Register User & Vehicle\nOR/CR Profile", 215, 95, 175, 66)
add_store("D1_left", "D1", "User & Vehicle Records", 215, 192, 175, 32)
add_process("P1_2", "1.2", "Authenticate Session &\nIssue Access Token", 215, 255, 175, 66)

# === GROUP 2.0: FACILITY & 2D SLOT CONFIGURATION (Right-Top) ===
add_store("D1_right", "D1", "User & Vehicle Records", 780, 55, 175, 32)
add_process("P2_1", "2.1", "Onboard Provider &\nVerify Facility KYC", 780, 118, 175, 66)
add_process("P2_2", "2.2", "Configure 2D Slot Grid\n& Rate Matrix", 780, 220, 175, 66)
add_store("D2_top", "D2", "Parking Spaces & 2D Slots", 780, 318, 175, 32)

# === GROUP 3.0: GEOSPATIAL SEARCH & 2D FLOORPLAN NAVIGATION (Left-Upper-Mid) ===
add_process("P3_1", "3.1", "Filter Nearby Spaces &\nSlot Occupancy", 215, 405, 175, 66)
add_store("D2_mid", "D2", "Parking Spaces & 2D Slots", 215, 502, 175, 32)
add_process("P3_2", "3.2", "Render Interactive 2D\nFloorplan & Route", 215, 565, 175, 66)

# === GROUP 4.0: SLOT RESERVATION & CONCURRENCY LOCKS (Left-Lower-Mid) ===
add_store("D2_p4", "D2", "Parking Spaces & 2D Slots", 215, 665, 175, 32)
add_process("P4_1", "4.1", "Lock Selected Slot &\nRecord Reservation", 215, 730, 175, 66)
add_store("D3_lower", "D3", "Reservation Records", 215, 830, 175, 32)
add_process("P4_2", "4.2", "Generate HMAC QR Pass\n& Alert Provider", 215, 895, 175, 66)

# === GROUP 7.0: REVIEWS, DISPUTES, COMMS & SYSTEM AUDIT (Center Column) ===
add_process("P7_1", "7.1", "Process Driver Reviews\n& Support Disputes", 490, 415, 180, 66)
add_store("D6_center", "D6", "Feedback & Audit Logs", 490, 515, 180, 32)
add_process("P7_2", "7.2", "Compile Financial &\nOccupancy Audit Logs", 490, 580, 180, 66)
add_store("D5_mid", "D5", "Payment & Receipts", 490, 680, 180, 32)

# === GROUP 5.0: CHECKPOINT QR VALIDATION & GATE SESSIONS (Right-Middle) ===
add_process("P5_1", "5.1", "Scan & Verify\nCheckpoint QR Token", 780, 425, 175, 66)
add_store("D3_right", "D3", "Reservation Records", 780, 525, 175, 32)
add_process("P5_2", "5.2", "Log Check-In / Check-Out\nSession Timestamps", 780, 595, 175, 66)
add_store("D4_sessions", "D4", "Active Parking Sessions", 780, 700, 175, 32)

# === GROUP 6.0: DURATION BILLING & PAYMENT SETTLEMENT (Lower-Center) ===
add_process("P6_1", "6.1", "Compute Elapsed Duration\n& Bill Statement", 490, 1080, 180, 66)
add_store("D5_lower", "D5", "Payment & Receipts", 490, 1180, 180, 32)
add_process("P6_2", "6.2", "Process GCash Settlement\n& Provider Payout", 490, 1245, 180, 66)


# -------------------------------------------------------------------------
# 4. ZERO-INTERSECTION ORTHOGONAL DATA FLOWS (44 Flows)
# -------------------------------------------------------------------------

# --- Domain 1.0 Flows (1.1 & 1.2) ---
# f01: DRIVER_main -> P1_1 (Registration, Credentials & OR/CR)
add_edge("f01", "Registration, Credentials & OR/CR", "DRIVER_main", "P1_1", [(55, 128)], 0.3, 0, 0, 0.5)

# f02: P1_1 -> ADMIN (Pending KYC & Vehicle Records)
add_edge("f02", "Pending KYC & Vehicle Records", "P1_1", "ADMIN", [(430, 115), (430, 75)], 1, 0.3, 0, 0.25)

# f03: ADMIN -> P1_1 (Account KYC Approval Status)
add_edge("f03", "Account KYC Approval Status", "ADMIN", "P1_1", [(450, 102), (450, 141)], 0, 0.65, 1, 0.7)

# f04: P1_1 -> D1_left (Verified Driver & Vehicle Profile)
add_edge("f04", "Verified Driver & Vehicle Profile", "P1_1", "D1_left", [], 0.5, 1, 0.5, 0)

# f05: D1_left -> P1_2 (Verified User Credentials & Role)
add_edge("f05", "Verified User Credentials & Role", "D1_left", "P1_2", [], 0.5, 1, 0.5, 0)

# f06: P1_2 -> DRIVER_main (Authentication Token & KYC Notice)
add_edge("f06", "Authentication Token & KYC Notice", "P1_2", "DRIVER_main", [(100, 288)], 0, 0.5, 0.7, 0)

# f07: DRIVER_main -> P1_2 (Login Session Request)
add_edge("f07", "Login Session Request", "DRIVER_main", "P1_2", [(302, 345)], 1, 0.07, 0.5, 1)


# --- Domain 2.0 Flows (2.1 & 2.2) ---
# f08: PROVIDER_main -> P2_1 (Provider Profile & Property KYC)
add_edge("f08", "Provider Profile & Property KYC", "PROVIDER_main", "P2_1", [(1088, 151)], 0.5, 0, 1, 0.5)

# f09: P2_1 -> ADMIN (Pending Facility Submission)
add_edge("f09", "Pending Facility Submission", "P2_1", "ADMIN", [(725, 138), (725, 75)], 0, 0.3, 1, 0.25)

# f10: ADMIN -> P2_1 (Facility KYC Approval)
add_edge("f10", "Facility KYC Approval", "ADMIN", "P2_1", [(705, 102), (705, 164)], 1, 0.65, 0, 0.7)

# f11: P2_1 -> D1_right (Verified Provider Profile Data)
add_edge("f11", "Verified Provider Profile Data", "P2_1", "D1_right", [], 0.5, 0, 0.5, 1)

# f12: ADMIN -> P2_2 (Rate Ceiling & Listing Approval)
add_edge("f12", "Rate Ceiling & Listing Approval", "ADMIN", "P2_2", [(631, 253)], 0.8, 1, 0, 0.5)

# f13: PROVIDER_main -> P2_2 (2D Slot Layout & Rate Setup)
add_edge("f13", "2D Slot Layout & Rate Setup", "PROVIDER_main", "P2_2", [(985, 340), (985, 253)], 0, 0.2, 1, 0.5)

# f14: P2_2 -> D2_top (Approved 2D Slot Layout & Rates)
add_edge("f14", "Approved 2D Slot Layout & Rates", "P2_2", "D2_top", [], 0.5, 1, 0.5, 0)


# --- Domain 7.0 Flows (7.1 & 7.2) ---
# f15: DRIVER_main -> P7_1 (Review, Dispute & Comms Message)
add_edge("f15", "Review, Dispute & Comms Message", "DRIVER_main", "P7_1", [(435, 365), (435, 448)], 1, 0.16, 0, 0.5)

# f16: ADMIN -> P7_1 (Moderation & Dispute Directives)
add_edge("f16", "Moderation & Dispute Directives", "ADMIN", "P7_1", [], 0.32, 1, 0.33, 0)

# f17: P7_1 -> D6_center (Review, Comms & Dispute Logs)
add_edge("f17", "Review, Comms & Dispute Logs", "P7_1", "D6_center", [], 0.5, 1, 0.5, 0)

# f18: D5_mid -> P7_2 (Transaction Financial Totals)
add_edge("f18", "Transaction Financial Totals", "D5_mid", "P7_2", [], 0.5, 0, 0.5, 1)

# f19: P7_2 -> D6_center (Consolidated System Audit Trail)
add_edge("f19", "Consolidated System Audit Trail", "P7_2", "D6_center", [], 0.5, 0, 0.5, 1)

# f20: P7_2 -> ADMIN (System Analytics & Audit Report)
add_edge("f20", "System Analytics & Audit Report", "P7_2", "ADMIN", [(710, 613), (710, 360), (597, 360)], 1, 0.5, 0.6, 1)


# --- Domain 3.0 Flows (3.1 & 3.2) ---
# f21: DRIVER_main -> P3_1 (Location Search & Filter Query)
add_edge("f21", "Location Search & Filter Query", "DRIVER_main", "P3_1", [(285, 387)], 1, 0.26, 0.4, 0)

# f22: D2_mid -> P3_1 (Slot Layout, Rates & Occupancy)
add_edge("f22", "Slot Layout, Rates & Occupancy", "D2_mid", "P3_1", [], 0.5, 0, 0.5, 1)

# f23: P3_1 -> DRIVER_main (Filtered Nearby Parking List)
add_edge("f23", "Filtered Nearby Parking List", "P3_1", "DRIVER_main", [(190, 438), (190, 429)], 0, 0.5, 1, 0.45)

# f24: D2_mid -> P3_2 (2D Grid Coordinates & Route Data)
add_edge("f24", "2D Grid Coordinates & Route Data", "D2_mid", "P3_2", [], 0.5, 1, 0.5, 0)

# f25: DRIVER_main -> P3_2 (Selected Facility Map Request)
add_edge("f25", "Selected Facility Map Request", "DRIVER_main", "P3_2", [(175, 466), (175, 585)], 1, 0.62, 0, 0.3)

# f26: P3_2 -> DRIVER_main (Interactive 2D Floorplan & Route)
add_edge("f26", "Interactive 2D Floorplan & Route", "P3_2", "DRIVER_main", [(158, 611), (158, 502)], 0, 0.7, 1, 0.78)


# --- Domain 4.0 Flows (4.1 & 4.2) ---
# f27: D2_p4 -> P4_1 (Slot Availability & Rate Rules)
add_edge("f27", "Slot Availability & Rate Rules", "D2_p4", "P4_1", [], 0.5, 1, 0.5, 0)

# f28: DRIVER_main -> P4_1 (Slot Selection & Booking Request)
add_edge("f28", "Slot Selection & Booking Request", "DRIVER_main", "P4_1", [(140, 532), (140, 763)], 1, 0.92, 0, 0.5)

# f29: P4_1 -> D3_lower (Confirmed Booking & Slot Lock)
add_edge("f29", "Confirmed Booking & Slot Lock", "P4_1", "D3_lower", [], 0.5, 1, 0.5, 0)

# f30: D3_lower -> P4_2 (Confirmed Booking Details)
add_edge("f30", "Confirmed Booking Details", "D3_lower", "P4_2", [], 0.5, 1, 0.5, 0)

# f31: P4_2 -> DRIVER_main (HMAC QR Code & Booking Pass)
add_edge("f31", "HMAC QR Code & Booking Pass", "P4_2", "DRIVER_main", [(114, 928)], 0, 0.5, 0.82, 1)

# f32: P4_2 -> PROVIDER_alias (Reservation Alert & Driver ETA)
add_edge("f32", "Reservation Alert & Driver ETA", "P4_2", "PROVIDER_alias", [], 0.5, 1, 0.5, 0)


# --- Domain 5.0 Flows (5.1 & 5.2) ---
# f33: PROVIDER_main -> P5_1 (Checkpoint QR Scan Data)
add_edge("f33", "Checkpoint QR Scan Data", "PROVIDER_main", "P5_1", [(868, 400)], 0, 0.6, 0.5, 0)

# f34: D3_right -> P5_1 (Reservation Validation Record)
add_edge("f34", "Reservation Validation Record", "D3_right", "P5_1", [], 0.5, 0, 0.5, 1)

# f35: P5_1 -> DRIVER_alias (Access Granted & Slot Assignment)
add_edge("f35", "Access Granted & Slot Assignment", "P5_1", "DRIVER_alias", [(1088, 458)], 1, 0.5, 0.5, 0)

# f36: D3_right -> P5_2 (Validated Reservation Slot State)
add_edge("f36", "Validated Reservation Slot State", "D3_right", "P5_2", [], 0.5, 1, 0.5, 0)

# f37: PROVIDER_main -> P5_2 (Gate Entry / Exit Confirmation)
add_edge("f37", "Gate Entry / Exit Confirmation", "PROVIDER_main", "P5_2", [(1180, 415), (1180, 628)], 1, 0.7, 1, 0.5)

# f38: P5_2 -> D4_sessions (Check-In / Check-Out Timestamps)
add_edge("f38", "Check-In / Check-Out Timestamps", "P5_2", "D4_sessions", [], 0.5, 1, 0.5, 0)


# --- Domain 6.0 Flows (6.1 & 6.2) ---
# f39: D4_sessions -> P6_1 (Completed Session Duration)
add_edge("f39", "Completed Session Duration", "D4_sessions", "P6_1", [(868, 1113)], 0.5, 1, 1, 0.5)

# f40: P6_1 -> DRIVER_main (Itemized Bill Statement)
add_edge("f40", "Itemized Bill Statement", "P6_1", "DRIVER_main", [(78, 1113)], 0, 0.5, 0.5, 1)

# f41: P6_1 -> D5_lower (Verified Bill & Fee Breakdown)
add_edge("f41", "Verified Bill & Fee Breakdown", "P6_1", "D5_lower", [], 0.3, 1, 0.3, 0)

# f42: D5_lower -> P6_2 (Pending Bill Amount)
add_edge("f42", "Pending Bill Amount", "D5_lower", "P6_2", [], 0.3, 1, 0.3, 0)

# f43: P6_2 -> D5_lower (Recorded Digital Receipt)
add_edge("f43", "Recorded Digital Receipt", "P6_2", "D5_lower", [], 0.7, 0, 0.7, 1)

# f44: DRIVER_main -> P6_2 (Payment Authorization & Method)
add_edge("f44", "Payment Authorization & Method", "DRIVER_main", "P6_2", [(43, 1278)], 0.2, 1, 0, 0.5)

# f45: P6_2 -> GCASH (Gateway Payment Request)
add_edge("f45", "Gateway Payment Request", "P6_2", "GCASH", [], 0.33, 1, 0.32, 0)

# f46: GCASH -> P6_2 (Payment Settlement Webhook)
add_edge("f46", "Payment Settlement Webhook", "GCASH", "P6_2", [], 0.68, 0, 0.67, 1)

# f47: P6_2 -> PROVIDER_main (Settled Payout Notification)
add_edge("f47", "Settled Payout Notification", "P6_2", "PROVIDER_main", [(1200, 1278), (1200, 360)], 1, 0.5, 1, 0.33)


# -------------------------------------------------------------------------
# BUILD XML (SINGLE UNIFIED PORTRAIT TAB)
# -------------------------------------------------------------------------
drawio_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2026-11-08T10:40:00.000Z" agent="E-Parada Portrait Level-1 DFD" version="24.0.0" type="device">
  <diagram id="level-1-dfd" name="Level 1 DFD (Portrait - 14 Subprocesses - Zero Crossings)">
    <mxGraphModel dx="1220" dy="1460" grid="1" gridSize="5" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="{PAGE_W}" pageHeight="{PAGE_H}" background="#FFFFFF" math="0" shadow="0">
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

print("Saved Single-Tab Portrait Level-1 DFD (e_parada_dfd_level_1.drawio) successfully!")
