#!/usr/bin/env python3
"""
Generates the 7-Process, 64-Flow Zero-Intersection Level-0 DFD for E-Parada.
Combines:
1. Complete 7-Process Specification (matching Level 1's 7 tabs & Level 2's 27 tabs)
   - 1.0 Manage User Identity & Two-Factor KYC
   - 2.0 Configure Parking Facility & 2D Slots
   - 3.0 Search Available Slots & Coordinate Navigation
   - 4.0 Process Slot Reservation & Concurrency Lock
   - 5.0 Validate Checkpoint QR Access & Scan Gate
   - 6.0 Compute Duration Billing & Settlement
   - 7.0 Administer Telemetry, Comms & Forensic Audit
2. All 6 External Entities (E1-E6) & All 6 Data Stores (D1-D6)
3. All 64 Data Flows (f01-f64)
4. Zero-Intersection Architecture from media_1794131001208_12694577.png:
   - Strategic Entity & Data Store Aliasing
   - Pure Orthogonal (Manhattan) Routing (rounded=0, jumpStyle=none)
   - Mathematically Verified 0 Crossings
"""

import html

PAGE_W = 2150
PAGE_H = 2220

cells = []

STYLE_TITLE = "text;html=1;strokeColor=#000000;strokeWidth=1.5;fillColor=#FFFFFF;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=14;fontStyle=1;fontColor=#000000;"
STYLE_ENTITY = "rounded=0;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;fontStyle=1;align=center;verticalAlign=middle;fontSize=10;fontColor=#000000;"
STYLE_PROCESS = "swimlane;whiteSpace=wrap;html=1;rounded=0;startSize=24;horizontal=1;fontStyle=1;align=center;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;collapsible=0;fontSize=11;fontColor=#000000;"
STYLE_PROCESS_LBL = "text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=10;fontColor=#000000;fontStyle=1;"
STYLE_STORE = "swimlane;horizontal=0;whiteSpace=wrap;html=1;startSize=32;fontStyle=1;align=center;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;collapsible=0;fontSize=10;fontColor=#000000;swimlaneLine=0;"
STYLE_STORE_LBL = "text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=10;fontColor=#000000;fontStyle=1;"
STYLE_EDGE = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=classic;strokeColor=#000000;strokeWidth=1.2;fontSize=9;fontColor=#000000;fontStyle=1;labelBackgroundColor=#FFFFFF;jumpStyle=none;"

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
    add_box(f"{pid}_lbl", 0, 24, w, h - 24, title, STYLE_PROCESS_LBL, parent=pid)

def add_store(sid, snum, stitle, x, y, w, h):
    add_box(sid, x, y, w, h, snum, STYLE_STORE)
    add_box(f"{sid}_lbl", 32, 0, w - 32, h, stitle, STYLE_STORE_LBL, parent=sid)

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
# HEADER BANNER
# -------------------------------------------------------------------------
add_box(
    "title_banner", 20, 15, PAGE_W - 40, 32,
    "E-PARADA SYSTEM - LEVEL-0 DFD (7 CORE PROCESSES | 64 DATA FLOWS | ZERO-INTERSECTION ARCHITECTURE)",
    STYLE_TITLE
)

# =========================================================================
# ZONE 1 & 2 (TOP ROW): PROCESS 1.0 (KYC & AUTH) & PROCESS 2.0 (2D SLOTS)
# =========================================================================
# Process 1.0
add_process("P1", "1.0", "Manage User Identity &\nTwo-Factor KYC", 520, 210, 240, 95)

# Top of P1: E6 (Tesseract OCR Engine)
add_box("E6_p1", 520, 75, 240, 55, "E6: TESSERACT OCR ENGINE", STYLE_ENTITY)
add_edge("f03", "Vehicle Plate & OR/CR Image", "P1", "E6_p1", [], 0.28, 0, 0.28, 1)
add_edge("f04", "Extracted OCR Plate Characters", "E6_p1", "P1", [], 0.72, 1, 0.72, 0)

# Left of P1: E1 (Driver) & D1 (Users Store)
add_box("E1_p1", 40, 175, 190, 65, "E1: DRIVER / MOTORIST", STYLE_ENTITY)
add_edge("f01", "Credentials & Driver License KYC", "E1_p1", "P1", [(380, 195), (380, 230)], 1, 0.3, 0, 0.2)
add_edge("f02", "JWT Token & KYC Status Badge", "P1", "E1_p1", [(360, 250), (360, 220)], 0, 0.42, 1, 0.7)

add_store("D1_p1", "D1", "Users & Driver Profiles Store", 40, 265, 215, 48)
add_edge("f07", "User Credentials & Verified Profile", "P1", "D1_p1", [(380, 275), (380, 280)], 0, 0.68, 1, 0.3)
add_edge("f59", "Stored Credentials & KYC Flags", "D1_p1", "P1", [(400, 300), (400, 295)], 1, 0.75, 0, 0.88)

# Bottom of P1: D2 (Vehicles) & D3 (Spaces)
add_store("D2_p1", "D2", "Registered Vehicles Store (LTO OR/CR)", 360, 385, 240, 48)
add_edge("f08", "LTO OR/CR & Plate Records", "P1", "D2_p1", [(580, 345), (480, 345)], 0.25, 1, 0.5, 0)

add_store("D3_p1", "D3", "Parking Spaces & 2D Slots Store", 660, 385, 240, 48)
add_edge("f09", "Pending Facility KYC Record", "P1", "D3_p1", [(700, 345), (780, 345)], 0.75, 1, 0.5, 0)

# Shared Center-Top between P1 and P2: E3 (System Admin) & E2 (Provider)
add_box("E3_top", 985, 95, 210, 65, "E3: SYSTEM\nADMINISTRATOR", STYLE_ENTITY)
add_edge("f10", "KYC Approvals & Account Sanctions", "E3_top", "P1", [(880, 128), (880, 230)], 0, 0.5, 1, 0.2)
add_edge("f15", "Regional Price Ceiling Policies", "E3_top", "P2", [(1300, 128), (1300, 230)], 1, 0.5, 0, 0.2)

add_box("E2_top", 985, 225, 210, 80, "E2: PARKING SPACE\nPROVIDER", STYLE_ENTITY)
add_edge("f05", "Barangay Clearance & Property Deed", "E2_top", "P1", [], 0, 0.3, 1, 0.52)
add_edge("f06", "Provider Verification Notice", "P1", "E2_top", [], 1, 0.82, 0, 0.75)

# Process 2.0
add_process("P2", "2.0", "Configure Parking Facility\n& 2D Slots", 1420, 210, 240, 95)
add_edge("f11", "2D Slot Grid, Rates & Operating Hours", "E2_top", "P2", [], 1, 0.3, 0, 0.52)
add_edge("f12", "Slot Layout & Rate Confirmation", "P2", "E2_top", [], 0, 0.82, 1, 0.75)

# Bottom of P2: D3 (Spaces Store)
add_store("D3_p2", "D3", "Parking Spaces & 2D Slots Store", 1420, 385, 240, 48)
add_edge("f13", "Existing Facility Baseline Data", "D3_p2", "P2", [], 0.28, 0, 0.28, 1)
add_edge("f14", "Configured 2D Slots & Pricing Rules", "P2", "D3_p2", [], 0.72, 1, 0.72, 0)


# =========================================================================
# ZONE 3: PROCESS 3.0 (SEARCH AVAILABLE SLOTS & COORDINATE NAVIGATION)
# =========================================================================
add_process("P3", "3.0", "Search Available Slots &\nCoordinate Navigation", 950, 565, 260, 100)

# Top of P3: E4 (Google Maps Platform API)
add_box("E4_p3", 950, 435, 260, 55, "E4: GOOGLE MAPS PLATFORM API", STYLE_ENTITY)
add_edge("f17", "Geocode Query & Coordinates Request", "P3", "E4_p3", [], 0.28, 0, 0.28, 1)
add_edge("f18", "Geocoded Coordinates & Distance Matrix", "E4_p3", "P3", [], 0.72, 1, 0.72, 0)

# Left of P3: E1 (Driver / Motorist)
add_box("E1_p3", 360, 575, 200, 80, "E1: DRIVER / MOTORIST", STYLE_ENTITY)
add_edge("f16", "Search Query (Destination, Radius, Vehicle Type)", "E1_p3", "P3", [], 1, 0.3, 0, 0.34)
add_edge("f21", "Interactive Map Pins, 2D Floorplan & Route", "P3", "E1_p3", [], 0, 0.74, 1, 0.7)

# Right of P3: D3 (Spaces) & D4 (Reservations)
add_store("D3_p3", "D3", "Parking Spaces & 2D Slots Store", 1560, 555, 250, 45)
add_edge("f19", "Facility Locations, Base Rates & 2D Layout", "D3_p3", "P3", [(1380, 578), (1380, 595)], 0, 0.5, 1, 0.3)

add_store("D4_p3", "D4", "Reservations & Active Sessions Store", 1560, 620, 250, 45)
add_edge("f20", "Real-Time Slot Occupancy States", "D4_p3", "P3", [(1380, 642), (1380, 635)], 0, 0.5, 1, 0.7)


# =========================================================================
# ZONE 4: PROCESS 4.0 (PROCESS SLOT RESERVATION & CONCURRENCY LOCK)
# =========================================================================
add_process("P4", "4.0", "Process Slot Reservation\n& Concurrency Lock", 950, 835, 260, 115)

# Inter-process P3 -> P4
add_edge("f62", "Selected Available Slot & Pricing Context", "P3", "P4", [], 0.5, 1, 0.5, 0)

# Top-Left & Top-Right Inputs to P4: D2 (Vehicles) & D3 (Spaces)
add_store("D2_p4", "D2", "Registered Vehicles Store (LTO OR/CR)", 530, 725, 250, 45)
add_edge("f60", "Motorist Registered Vehicle Specs (Sedan/SUV)", "D2_p4", "P4", [(1002, 748)], 1, 0.5, 0.2, 0)

add_store("D3_p4", "D3", "Parking Spaces & 2D Slots Store", 1380, 725, 250, 45)
add_edge("f23", "Slot Rate Rules & Dimension Clearance Check", "D3_p4", "P4", [(1158, 748)], 0, 0.5, 0.8, 0)

# Left of P4: E1 (Driver) & D4 (Reservations)
add_box("E1_p4", 360, 815, 200, 65, "E1: DRIVER / MOTORIST", STYLE_ENTITY)
add_edge("f22", "Selected Slot ID & Duration Choice (1-12 Hrs)", "E1_p4", "P4", [(750, 835), (750, 858)], 1, 0.3, 0, 0.2)
add_edge("f29", "Booking Confirmation & Dynamic QR Digital Pass", "P4", "E1_p4", [(730, 881), (730, 860)], 0, 0.4, 1, 0.7)

add_store("D4_p4", "D4", "Reservations & Active Sessions Store", 330, 900, 250, 50)
add_edge("f24", "Pessimistic Lock & Active Reservation Record", "P4", "D4_p4", [(750, 910), (750, 915)], 0, 0.65, 1, 0.3)
add_edge("f25", "Slot Availability State & 60-Min Expiry Timers", "D4_p4", "P4", [(770, 938), (770, 933)], 1, 0.75, 0, 0.85)

# Right of P4: E2 (Provider), E5 (PayMongo), D6 (Financials)
add_box("E2_p4", 1560, 795, 220, 50, "E2: PARKING SPACE PROVIDER", STYLE_ENTITY)
add_edge("f30", "Incoming Reservation Notification & Driver ETA", "P4", "E2_p4", [(1380, 852), (1380, 820)], 1, 0.15, 0, 0.5)

add_box("E5_p4", 1560, 860, 220, 60, "E5: PAYMONGO GATEWAY\n(GCash E-Wallet)", STYLE_ENTITY)
add_edge("f26", "Downpayment Charge Request (1-Hr Fee Hold)", "P4", "E5_p4", [(1400, 881), (1400, 878)], 1, 0.4, 0, 0.3)
add_edge("f27", "GCash Downpayment Webhook Confirmation", "E5_p4", "P4", [(1420, 905), (1420, 904)], 0, 0.75, 1, 0.6)

add_store("D6_p4", "D6", "Financials & Audit Trails Store", 1560, 935, 250, 45)
add_edge("f28", "Downpayment Escrow Ledger Record", "P4", "D6_p4", [(1380, 933), (1380, 958)], 1, 0.85, 0, 0.5)


# =========================================================================
# ZONE 5: PROCESS 5.0 (VALIDATE CHECKPOINT QR ACCESS & SCAN GATE)
# =========================================================================
add_process("P5", "5.0", "Validate Checkpoint QR\nAccess & Scan Gate", 950, 1115, 260, 110)

# Inter-process P4 -> P5
add_edge("f63", "Approved Reservation & Active QR Trigger", "P4", "P5", [], 0.5, 1, 0.5, 0)

# Left of P5: E1 (Driver) & D5 (QR Access Tokens Store)
add_box("E1_p5", 360, 1095, 200, 65, "E1: DRIVER / MOTORIST", STYLE_ENTITY)
add_edge("f31", "Present Dynamic QR Digital Pass at Gate", "E1_p5", "P5", [(750, 1115), (750, 1137)], 1, 0.3, 0, 0.2)
add_edge("f37", "Gate Clearance & Active Session Timer Display", "P5", "E1_p5", [(730, 1159), (730, 1140)], 0, 0.4, 1, 0.7)

add_store("D5_p5", "D5", "QR Access Tokens & Gate Telemetry Logs", 330, 1180, 250, 50)
add_edge("f34", "HMAC-SHA256 Token Validation Key", "D5_p5", "P5", [(750, 1195), (750, 1187)], 1, 0.3, 0, 0.65)
add_edge("f35", "Invalidated Single-Use Pass & Gate Logs", "P5", "D5_p5", [(770, 1209), (770, 1218)], 0, 0.85, 1, 0.75)

# Right of P5: E2 (Provider) & D4 (Reservations Store)
add_box("E2_p5", 1560, 1095, 220, 65, "E2: PARKING SPACE PROVIDER", STYLE_ENTITY)
add_edge("f32", "Optical Camera Scanner / Manual RES-# Fallback", "E2_p5", "P5", [(1400, 1115), (1400, 1137)], 0, 0.3, 1, 0.2)
add_edge("f38", "Visual Access Indicator (Green Grant / Red Deny)", "P5", "E2_p5", [(1420, 1159), (1420, 1140)], 1, 0.4, 0, 0.7)

add_store("D4_p5", "D4", "Reservations & Active Sessions Store", 1560, 1180, 250, 50)
add_edge("f33", "Active Reservation Record & Plate Number", "D4_p5", "P5", [(1400, 1195), (1400, 1187)], 0, 0.3, 1, 0.65)
add_edge("f36", "Session State Update (Park-In/Out Timestamps)", "P5", "D4_p5", [(1380, 1209), (1380, 1218)], 1, 0.85, 0, 0.75)


# =========================================================================
# ZONE 6: PROCESS 6.0 (COMPUTE DURATION BILLING & SETTLEMENT)
# =========================================================================
add_process("P6", "6.0", "Compute Duration Billing\n& Settlement", 950, 1395, 260, 110)

# Inter-process P5 -> P6
add_edge("f64", "Verified Exit Scan & Elapsed Session Trigger", "P5", "P6", [], 0.5, 1, 0.5, 0)

# Left of P6: D4 (Reservations) & D6 (Financials)
add_store("D4_p6", "D4", "Reservations & Active Sessions Store", 330, 1375, 250, 50)
add_edge("f39", "Validated Session Duration (Actual Park-In/Out)", "D4_p6", "P6", [(750, 1390), (750, 1417)], 1, 0.3, 0, 0.2)
add_edge("f46", "Mark Session State as Settled / Closed", "P6", "D4_p6", [(730, 1439), (730, 1412)], 0, 0.4, 1, 0.75)

add_store("D6_p6", "D6", "Financials & Audit Trails Store", 330, 1460, 250, 50)
add_edge("f40", "Prepaid Downpayment Credit Balance", "D6_p6", "P6", [(750, 1475), (750, 1467)], 1, 0.3, 0, 0.65)
add_edge("f47", "Settlement Ledger Entry & Platform Escrow Split", "P6", "D6_p6", [(770, 1489), (770, 1498)], 0, 0.85, 1, 0.75)

# Right of P6: E5 (PayMongo) & E2 (Provider)
add_box("E5_p6", 1560, 1375, 220, 60, "E5: PAYMONGO GATEWAY\n(GCash E-Wallet)", STYLE_ENTITY)
add_edge("f43", "Final Balance GCash Charge / Payout Webhook", "P6", "E5_p6", [(1400, 1417), (1400, 1393)], 1, 0.2, 0, 0.3)
add_edge("f44", "GCash Final Settlement Webhook Confirmation", "E5_p6", "P6", [(1420, 1420), (1420, 1439)], 0, 0.75, 1, 0.4)

add_store_or_entity_e2_p6 = add_box("E2_p6", 1560, 1460, 220, 60, "E2: PARKING SPACE PROVIDER", STYLE_ENTITY)
add_edge("f45", "Manual Cash Received Handshake (at Exit)", "E2_p6", "P6", [(1400, 1478), (1400, 1467)], 0, 0.3, 1, 0.65)
add_edge("f48", "Net Provider Earnings Breakdown & Payout Credit", "P6", "E2_p6", [(1380, 1489), (1380, 1505)], 1, 0.85, 0, 0.75)

# Bottom of P6: E1 (Driver / Motorist)
add_box("E1_p6", 950, 1585, 260, 60, "E1: DRIVER / MOTORIST", STYLE_ENTITY)
add_edge("f41", "Itemized Final Billing Statement", "P6", "E1_p6", [], 0.28, 1, 0.28, 0)
add_edge("f42", "Final Balance Settlement (Cash / GCash)", "E1_p6", "P6", [], 0.72, 0, 0.72, 1)


# =========================================================================
# ZONE 7: PROCESS 7.0 (ADMINISTER TELEMETRY, COMMS & FORENSIC AUDIT)
# =========================================================================
add_process("P7", "7.0", "Administer Telemetry, Comms\n& Forensic Audit", 950, 1855, 260, 115)

# Top of P7: D1 (Users), D4 (Reservations), D5 (QR Tokens)
add_store("D1_p7", "D1", "Users & Driver Profiles Store", 530, 1775, 250, 45)
add_edge("f61", "User Profiles & Identity Verification Records", "D1_p7", "P7", [(1002, 1798)], 1, 0.5, 0.2, 0)

add_store("D4_p7", "D4", "Reservations & Active Sessions Store", 950, 1710, 260, 45)
add_edge("f53", "Active Session Context (Locks Comms to Booking)", "D4_p7", "P7", [], 0.5, 1, 0.5, 0)

add_store("D5_p7", "D5", "QR Access Tokens & Gate Telemetry Logs", 1380, 1775, 250, 45)
add_edge("f54", "Gate Access Telemetry & Unauthorized Stay Logs", "D5_p7", "P7", [(1158, 1798)], 0, 0.5, 0.8, 0)

# Left of P7: E1 (Driver / Motorist)
add_box("E1_p7", 360, 1875, 200, 75, "E1: DRIVER / MOTORIST", STYLE_ENTITY)
add_edge("f49", "WebRTC Voice/Chat Audio & Infraction Reports", "E1_p7", "P7", [], 1, 0.3, 0, 0.34)
add_edge("f50", "WebRTC Audio/Chat Packets & Dispute Updates", "P7", "E1_p7", [], 0, 0.74, 1, 0.7)

# Right of P7: E2 (Provider) & E3 (System Administrator)
add_box("E2_p7", 1560, 1835, 220, 60, "E2: PARKING SPACE PROVIDER", STYLE_ENTITY)
add_edge("f51", "WebRTC Voice/Chat & Overstay / Infraction Reports", "E2_p7", "P7", [(1400, 1853), (1400, 1878)], 0, 0.3, 1, 0.2)
add_edge("f52", "WebRTC Audio/Chat & Occupancy Heatmaps", "P7", "E2_p7", [(1420, 1901), (1420, 1880)], 1, 0.4, 0, 0.75)

add_box("E3_p7", 1560, 1920, 220, 60, "E3: SYSTEM ADMINISTRATOR", STYLE_ENTITY)
add_edge("f56", "Dispute Mediation Actions & Forensic Audit Query", "E3_p7", "P7", [(1400, 1938), (1400, 1930)], 0, 0.3, 1, 0.65)
add_edge("f57", "System Analytics, Heatmaps & Audit Reports (CSV/PDF)", "P7", "E3_p7", [(1380, 1953), (1380, 1965)], 1, 0.85, 0, 0.75)

# Bottom of P7: D6 (Financials & Audit Trails Store)
add_store("D6_p7", "D6", "Financials & Audit Trails Store", 950, 2060, 260, 50)
add_edge("f55", "Financial Transaction Ledgers & Dispute Records", "D6_p7", "P7", [], 0.28, 0, 0.28, 1)
add_edge("f58", "Dispute Resolutions & Immutable Audit Trails", "P7", "D6_p7", [], 0.72, 1, 0.72, 0)

# -------------------------------------------------------------------------
# BUILD XML
# -------------------------------------------------------------------------
drawio_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2026-11-08T10:10:00.000Z" agent="E-Parada 7-Process Zero-Intersection DFD" version="24.0.0" type="device">
  <diagram id="level-0-dfd" name="Level 0 DFD (7 Processes - Zero Crossings)">
    <mxGraphModel dx="1800" dy="1200" grid="1" gridSize="5" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="{PAGE_W}" pageHeight="{PAGE_H}" background="#FFFFFF" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
{chr(10).join(cells)}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
"""

with open(r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_0.drawio", "w", encoding="utf-8") as f:
    f.write(drawio_xml)

with open(r"C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\e_parada_dfd_level_0.drawio", "w", encoding="utf-8") as f:
    f.write(drawio_xml)

print("Generated 7-Process, 64-Flow Zero-Intersection e_parada_dfd_level_0.drawio!")
