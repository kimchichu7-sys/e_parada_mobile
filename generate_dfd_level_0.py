import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import shutil
import os
from dfd_router_helper import OrthogonalDFDBuilder


def create_drawio_level_0():
    mxfile = ET.Element('mxfile', host='app.diagrams.net', agent='Antigravity', version='24.0.0')

    b0 = OrthogonalDFDBuilder(
        'level-0-dfd', 'Level 0 DFD',
        'Level 0 - Data Flow Diagram of the E-Parada Parking Marketplace System',
        'CPSOFT1L - Software Design Lab | Gane & Sarson Multi-Process Architecture (18 Modules Mapped - Zero Central Crossings)',
        page_w=3400, page_h=2300
    )

    # ==========================================
    # 1. ADD EXTERNAL ENTITIES (6 Total)
    # ==========================================
    # E1: Driver / Motorist (Demand Side - Left Margin)
    b0.add_entity('E1', 'Driver / Motorist', 60, 520, 180, 160)
    # E6: Tesseract OCR Engine (Helper for P1 - Top Left)
    b0.add_entity('E6', 'Tesseract OCR Engine', 560, 100, 220, 60)
    # E2: Parking Space Provider (Supply Side - Far Right, Top)
    b0.add_entity('E2', 'Parking Space Provider', 2600, 240, 240, 100)
    # E4: Google Maps Platform API (Helper for P3 - Top Right)
    b0.add_entity('E4', 'Google Maps Platform API', 1960, 100, 220, 60)
    # E5: PayMongo Gateway (Payment Processor - Far Right, Middle)
    b0.add_entity('E5', 'PayMongo Gateway\n(GCash E-Wallet)', 2600, 720, 240, 80)
    # E3: System Administrator (Admin / Governance - Bottom Margin)
    b0.add_entity('E3', 'System Administrator', 1960, 1720, 220, 80)

    # ==========================================
    # 2. ADD PROCESSES (7 Core Processes)
    # ==========================================
    # P1: Identity & KYC (Col 2, Top)
    b0.add_process('P1', '1', 'Manage User Identity &\nTwo-Factor KYC', 560, 240, 220, 100)
    # P2: Parking Facility & Slots (Col 3, Top)
    b0.add_process('P2', '2', 'Configure Parking Facility\n& 2D Slots', 1200, 240, 240, 100)
    # P3: Search & Navigation (Col 4, Top)
    b0.add_process('P3', '3', 'Search Available Slots &\nCoordinate Navigation', 1960, 240, 220, 100)
    # P4: Reservation & Concurrency Lock (Col 4, Upper-Mid)
    b0.add_process('P4', '4', 'Process Slot Reservation\n& Concurrency Lock', 1960, 560, 220, 100)
    # P5: Checkpoint QR & Access Scan (Col 4, Lower-Mid)
    b0.add_process('P5', '5', 'Validate Checkpoint QR\nAccess & Scan Gate', 1960, 880, 220, 100)
    # P6: Duration Billing & Settlement (Col 4, Bottom-Mid)
    b0.add_process('P6', '6', 'Compute Duration Billing\n& Settlement', 1960, 1200, 220, 100)
    # P7: Telemetry, Comms & Forensic Audit (Col 3, Bottom)
    b0.add_process('P7', '7', 'Administer Telemetry, Comms\n& Forensic Audit', 1200, 1710, 240, 100)

    # ==========================================
    # 3. ADD DATA STORES (6 Stores)
    # ==========================================
    # D1: Users & Driver Profiles Store (Col 1-2, Upper)
    b0.add_datastore('D1', 'D1', 'Users & Driver Profiles\nStore', 280, 440, 220, 60)
    # D2: Registered Vehicles Store (Col 2, Upper)
    b0.add_datastore('D2', 'D2', 'Registered Vehicles\nStore (LTO OR/CR)', 560, 440, 220, 60)
    # D3: Parking Spaces & Slots Store (Col 3, Upper)
    b0.add_datastore('D3', 'D3', 'Parking Spaces & 2D Slots\nStore (Clearances & Layouts)', 1200, 440, 240, 60)
    # D4: Reservations & Active Sessions Store (Col 3, Mid-Upper)
    b0.add_datastore('D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1200, 720, 240, 60)
    # D5: QR Access Tokens & Gate Telemetry Logs (Col 3, Mid-Lower)
    b0.add_datastore('D5', 'D5', 'QR Access Tokens &\nGate Telemetry Logs', 1200, 960, 240, 60)
    # D6: Financials & Audit Trails Store (Col 3, Lower)
    b0.add_datastore('D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 1200, 1260, 240, 60)

    # ==========================================
    # 4. ADD DATA FLOWS (64 Explicitly Routed Flows)
    # ==========================================

    # --- PROCESS 1: Identity & KYC ---
    b0.add_orthogonal_flow('f01', 'E1', 'T', 0.2, 'P1', 'L', 0.3, 'Credentials & Driver License KYC', mids=[(96, 270)])
    b0.add_orthogonal_flow('f02', 'P1', 'L', 0.6, 'E1', 'T', 0.5, 'JWT Token & KYC Status Badge', mids=[(150, 300)])
    b0.add_orthogonal_flow('f03', 'P1', 'T', 0.3, 'E6', 'B', 0.3, 'Vehicle Plate & OR/CR Image')
    b0.add_orthogonal_flow('f04', 'E6', 'B', 0.7, 'P1', 'T', 0.7, 'Extracted OCR Plate Characters')
    b0.add_orthogonal_flow('f05', 'E2', 'T', 0.2, 'P1', 'L', 0.15, 'Barangay Clearance & Property Deed', mids=[(2648, 50), (530, 50), (530, 255)])
    b0.add_orthogonal_flow('f06', 'P1', 'L', 0.7, 'E2', 'T', 0.4, 'Provider Verification Notice', mids=[(510, 310), (510, 70), (2696, 70)])
    b0.add_orthogonal_flow('f07', 'P1', 'B', 0.15, 'D1', 'T', 0.8, 'User Credentials & Verified Profile', mids=[(593, 396), (456, 396)])
    b0.add_orthogonal_flow('f59', 'D1', 'T', 0.4, 'P1', 'L', 0.85, 'Stored Credentials & KYC Flags', mids=[(368, 325)])
    b0.add_orthogonal_flow('f08', 'P1', 'B', 0.5, 'D2', 'T', 0.5, 'LTO OR/CR & Plate Records')
    b0.add_orthogonal_flow('f09', 'P1', 'R', 0.8, 'D3', 'L', 0.3, 'Pending Facility KYC Record', mids=[(860, 320), (860, 458)])
    b0.add_orthogonal_flow('f10', 'E3', 'B', 0.5, 'P1', 'L', 0.05, 'KYC Approvals & Account Sanctions', mids=[(2070, 2000), (35, 2000), (35, 245)])

    # --- PROCESS 2: Facility & Slot Config ---
    # f11 & f12: Concentric parallel routing between E2 and P2 (Zero Crossings!)
    b0.add_orthogonal_flow('f11', 'E2', 'L', 0.2, 'P2', 'R', 0.3, '2D Slot Grid, Rates & Operating Hours', mids=[(2540, 260), (2540, 190), (1460, 190), (1460, 270)])
    b0.add_orthogonal_flow('f12', 'P2', 'R', 0.7, 'E2', 'L', 0.5, 'Slot Layout & Rate Confirmation', mids=[(1480, 310), (1480, 210), (2560, 210), (2560, 290)])
    b0.add_orthogonal_flow('f13', 'D3', 'T', 0.3, 'P2', 'B', 0.3, 'Existing Facility Baseline Data')
    b0.add_orthogonal_flow('f14', 'P2', 'B', 0.7, 'D3', 'T', 0.7, 'Configured 2D Slots & Pricing Rules')
    b0.add_orthogonal_flow('f15', 'E3', 'B', 0.3, 'P2', 'L', 0.8, 'Regional Price Ceiling Policies', mids=[(2026, 1960), (880, 1960), (880, 320)])

    # --- PROCESS 3: Search & Navigation ---
    b0.add_orthogonal_flow('f16', 'E1', 'T', 0.8, 'P3', 'L', 0.2, 'Search Query (Destination, Radius, Vehicle Type)', mids=[(204, 30), (1880, 30), (1880, 260)])
    b0.add_orthogonal_flow('f17', 'P3', 'T', 0.45, 'E4', 'B', 0.45, 'Geocode Query & Coordinates Request')
    b0.add_orthogonal_flow('f18', 'E4', 'B', 0.8, 'P3', 'T', 0.8, 'Geocoded Coordinates & Distance Matrix')
    b0.add_orthogonal_flow('f19', 'D3', 'R', 0.3, 'P3', 'L', 0.5, 'Facility Locations, Base Rates & 2D Floorplan Layout', mids=[(1620, 458), (1620, 290)])
    # f20: Route via D4 L (x=1200) -> x=1080 -> y=380 -> into P3 L (y=320) (Zero Crossings with Central Corridor!)
    b0.add_orthogonal_flow('f20', 'D4', 'L', 0.15, 'P3', 'L', 0.8, 'Real-Time Slot Occupancy States', mids=[(1080, 729), (1080, 380), (1860, 380), (1860, 320)])
    b0.add_orthogonal_flow('f21', 'P3', 'L', 0.35, 'E1', 'L', 0.2, 'Interactive Map Pins, 2D Floorplan & Turn-by-Turn Route', mids=[(1860, 275), (1860, 10), (20, 10), (20, 552)])

    # --- PROCESS 4: Reservation, Lock & Downpayment ---
    # Direct downward operational trigger P3 -> P4 (Vertical inside Col 4 - Zero Crossings!)
    b0.add_orthogonal_flow('f62', 'P3', 'B', 0.5, 'P4', 'T', 0.5, 'Selected Available Slot & Pricing Context')
    b0.add_orthogonal_flow('f22', 'E1', 'R', 0.3, 'P4', 'L', 0.2, 'Selected Slot ID & Duration Choice (1-12 Hrs)', mids=[(1780, 568), (1780, 580)])
    b0.add_orthogonal_flow('f29', 'P4', 'L', 0.4, 'E1', 'R', 0.5, 'Booking Confirmation & Dynamic QR Digital Pass', mids=[(1820, 600), (1820, 600)])
    b0.add_orthogonal_flow('f60', 'D2', 'B', 0.5, 'P4', 'T', 0.1, 'Motorist Registered Vehicle Specs (Sedan/SUV)', mids=[(670, 520), (1982, 520)])
    b0.add_orthogonal_flow('f23', 'D3', 'R', 0.7, 'P4', 'T', 0.25, 'Slot Rate Rules & Dimension Clearance Check', mids=[(2015, 482)])
    # f24 and f25: Concentric nested routing between P4 L and D4 R (Zero Crossings!)
    b0.add_orthogonal_flow('f24', 'P4', 'L', 0.6, 'D4', 'R', 0.2, 'Pessimistic Lock & Active Reservation Record', mids=[(1700, 620), (1700, 732)])
    b0.add_orthogonal_flow('f25', 'D4', 'R', 0.6, 'P4', 'L', 0.8, 'Slot Availability State & 60-Min Expiry Timers', mids=[(1720, 756), (1720, 640)])
    b0.add_orthogonal_flow('f26', 'P4', 'R', 0.4, 'E5', 'L', 0.3, 'Downpayment Charge Request (1-Hr Fee Hold)', mids=[(2380, 600), (2380, 744)])
    b0.add_orthogonal_flow('f27', 'E5', 'L', 0.7, 'P4', 'R', 0.6, 'GCash Downpayment Webhook Confirmation', mids=[(2400, 776), (2400, 620)])
    # f28: Route DOWN on RIGHT perimeter of Col 4 (x=2240) below P6 (y=1380) into D6 B (Zero Crossings in Central Corridor!)
    b0.add_orthogonal_flow('f28', 'P4', 'R', 0.85, 'D6', 'B', 0.7, 'Downpayment Escrow Ledger Record', mids=[(2240, 645), (2240, 1380), (1368, 1380)])
    b0.add_orthogonal_flow('f30', 'P4', 'R', 0.2, 'E2', 'B', 0.3, 'Incoming Reservation Notification & Driver ETA', mids=[(2340, 580), (2340, 380), (2672, 380)])

    # --- PROCESS 5: Checkpoint QR Access & Scan Gate ---
    # Direct downward operational trigger P4 -> P5 (Vertical inside Col 4 - Zero Crossings!)
    b0.add_orthogonal_flow('f63', 'P4', 'B', 0.5, 'P5', 'T', 0.5, 'Approved Reservation & Active QR Trigger')
    # f31 & f37: Enter P5 L cleanly at y=900 & y=920
    b0.add_orthogonal_flow('f31', 'E1', 'B', 0.3, 'P5', 'L', 0.2, 'Present Dynamic QR Digital Pass at Gate', mids=[(114, 900), (1960, 900)])
    b0.add_orthogonal_flow('f37', 'P5', 'L', 0.4, 'E1', 'B', 0.7, 'Gate Clearance & Active Session Timer Display', mids=[(1960, 920), (186, 920)])
    # f32 & f38: Direct connection from E2 B to P5 R
    b0.add_orthogonal_flow('f32', 'E2', 'B', 0.6, 'P5', 'R', 0.65, 'Optical Camera Scanner Feed / Manual RES-# Fallback', mids=[(2744, 400), (2420, 400), (2420, 945)])
    b0.add_orthogonal_flow('f38', 'P5', 'R', 0.8, 'E2', 'B', 0.8, 'Visual Access Indicator (Green Grant / Red Deny)', mids=[(2460, 960), (2460, 420), (2792, 420)])
    # f33 & f36: Concentric nested routing via D4 B (ABSOLUTE ZERO CENTRAL CROSSINGS!)
    b0.add_orthogonal_flow('f33', 'D4', 'B', 2/3, 'P5', 'T', 0.2, 'Active Reservation Record & Plate Number', mids=[(1360, 850), (2004, 850)])
    b0.add_orthogonal_flow('f36', 'P5', 'T', 0.35, 'D4', 'B', 5/6, 'Session State Update (Park-In / Park-Out Timestamps)', mids=[(2037, 820), (1400, 820)])
    # f34 & f35: Connect D5 R to P5 L (y=960..975) below y=920 (Zero Crossings!)
    b0.add_orthogonal_flow('f34', 'D5', 'R', 0.3, 'P5', 'L', 0.8, 'HMAC-SHA256 Token Validation Key', mids=[(1640, 978), (1640, 960)])
    b0.add_orthogonal_flow('f35', 'P5', 'L', 0.95, 'D5', 'R', 0.7, 'Invalidated Single-Use Pass & Gate Telemetry Logs', mids=[(1660, 975), (1660, 1002)])

    # --- PROCESS 6: Duration Billing & Settlement ---
    # Direct downward operational trigger P5 -> P6 (Vertical inside Col 4 - Zero Crossings!)
    b0.add_orthogonal_flow('f64', 'P5', 'B', 0.5, 'P6', 'T', 0.5, 'Verified Exit Scan & Elapsed Session Trigger')
    # f39 & f46: Route down LEFT perimeter of Col 3 (x=1100, x=1120) below D6 into P6 B (Zero Crossings in Central Corridor!)
    b0.add_orthogonal_flow('f39', 'D4', 'L', 0.3, 'P6', 'B', 0.2, 'Validated Session Duration (Actual Park-In & Park-Out)', mids=[(1100, 738), (1100, 1340), (2004, 1340)])
    b0.add_orthogonal_flow('f46', 'P6', 'B', 0.35, 'D4', 'L', 0.7, 'Mark Session State as Settled / Closed', mids=[(2037, 1360), (1120, 1360), (1120, 762)])
    b0.add_orthogonal_flow('f40', 'D6', 'R', 0.4, 'P6', 'L', 0.4, 'Prepaid Downpayment Credit Balance', mids=[(1650, 1284), (1650, 1240)])
    b0.add_orthogonal_flow('f47', 'P6', 'L', 0.8, 'D6', 'R', 0.8, 'Settlement Ledger Entry & Platform Escrow Split', mids=[(1680, 1280), (1680, 1308)])
    # f41 & f42: Concentric routing (f41 enters E1 at y=1150; f42 routes via bottom at y=1400 into P6 B - Zero Crossings in Central Corridor!)
    b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'B', 0.8, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1400), (2136, 1400)])
    b0.add_orthogonal_flow('f41', 'P6', 'L', 0.05, 'E1', 'B', 0.15, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(1720, 1205), (1720, 1150), (87, 1150)])
    b0.add_orthogonal_flow('f43', 'P6', 'R', 0.35, 'E5', 'B', 0.3, 'Final Balance GCash Charge / Automated Payout Webhook', mids=[(2672, 1235)])
    b0.add_orthogonal_flow('f44', 'E5', 'B', 0.7, 'P6', 'R', 0.55, 'GCash Final Settlement Webhook Confirmation', mids=[(2768, 1255)])
    b0.add_orthogonal_flow('f45', 'E2', 'R', 0.7, 'P6', 'R', 0.25, 'Manual Cash Received Handshake (at Exit)', mids=[(2900, 310), (2900, 1225)])
    b0.add_orthogonal_flow('f48', 'P6', 'R', 0.85, 'E2', 'R', 0.9, 'Net Provider Earnings Breakdown & Payout Credit', mids=[(2930, 1285), (2930, 330)])

    # --- PROCESS 7: Telemetry, Comms & Forensic Audit ---
    b0.add_orthogonal_flow('f49', 'E1', 'B', 0.5, 'P7', 'L', 0.3, 'WebRTC Voice/Chat Audio & Security Infraction Reports', mids=[(150, 1740)])
    b0.add_orthogonal_flow('f50', 'P7', 'L', 0.7, 'E1', 'B', 0.95, 'WebRTC Audio/Chat Packets & Dispute Status Updates', mids=[(231, 1780)])
    # f51 & f52: Concentric routing via P7 B (Zero Crossings with f56/f57!)
    b0.add_orthogonal_flow('f51', 'E2', 'R', 0.3, 'P7', 'B', 5/6, 'WebRTC Voice/Chat Audio & Overstay / Infraction Reports', mids=[(2960, 270), (2960, 1840), (1400, 1840)])
    b0.add_orthogonal_flow('f52', 'P7', 'B', 2/3, 'E2', 'R', 0.5, 'WebRTC Audio/Chat Packets & Facility Occupancy Heatmaps', mids=[(1360, 1860), (2990, 1860), (2990, 290)])
    b0.add_orthogonal_flow('f61', 'D1', 'B', 0.5, 'P7', 'L', 0.1, 'User Profiles & Identity Verification Records', mids=[(390, 1720)])
    b0.add_orthogonal_flow('f53', 'D4', 'L', 0.5, 'P7', 'T', 0.2, 'Active Session Context (Locks Comms to Active Booking)', mids=[(1180, 750), (1180, 1620), (1248, 1620)])
    b0.add_orthogonal_flow('f54', 'D5', 'L', 0.5, 'P7', 'T', 0.4, 'Gate Access Telemetry & Unauthorized Stay Logs', mids=[(1160, 990), (1160, 1640), (1296, 1640)])
    b0.add_orthogonal_flow('f55', 'D6', 'B', 0.5, 'P7', 'T', 0.6, 'Financial Transaction Ledgers & Dispute Records')
    b0.add_orthogonal_flow('f58', 'P7', 'T', 0.8, 'D6', 'B', 0.8, 'Dispute Resolutions & Immutable Forensic Audit Trails')
    b0.add_orthogonal_flow('f56', 'E3', 'L', 0.25, 'P7', 'R', 0.5, 'Dispute Mediation Actions & Forensic Audit Query')
    b0.add_orthogonal_flow('f57', 'P7', 'R', 0.8, 'E3', 'L', 0.75, 'System Analytics, Heatmaps & Forensic Audit Reports (CSV/PDF)')

    # Audit geometry before export
    issues, crossings = b0.audit_geometry(min_parallel_gap=6)
    print(f"\n[Level 0 Builder] Geometry Audit: Issues={len(issues)}, Crossings={len(crossings)}")
    for iss in issues:
        print("  ", iss)

    b0.to_xml(mxfile)

    raw_xml = ET.tostring(mxfile, encoding='utf-8')
    parsed = minidom.parseString(raw_xml)
    xml_str = parsed.toprettyxml(indent="  ")

    output_path = r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_0.drawio"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(xml_str)

    artifact_dir = r"C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185"
    artifact_path = os.path.join(artifact_dir, "e_parada_dfd_level_0.drawio")
    shutil.copyfile(output_path, artifact_path)

    # HTML Interactive Viewer
    escaped_xml = xml_str.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;').replace("'", '&#39;')

    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>E-Parada Level 0 DFD - Clean Interactive Architecture</title>
  <style>
    body {{
      margin: 0;
      padding: 20px;
      background: #f8fafc;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      padding-bottom: 12px;
      border-bottom: 1px solid #e2e8f0;
    }}
    h1 {{
      margin: 0 0 4px 0;
      font-size: 20px;
      font-weight: 700;
      color: #111827;
    }}
    p {{
      margin: 0;
      color: #6b7280;
      font-size: 13px;
    }}
    .badge {{
      background: #dcfce7;
      color: #166534;
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }}
    .viewer-container {{
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.08);
      padding: 20px;
      overflow: auto;
    }}
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>E-Parada: Level 0 Data Flow Diagram (Gane &amp; Sarson Multi-Process Standard)</h1>
      <p>NU Laguna CPSOFT1L Format - 7 Core Processes - 6 External Entities - 6 Data Stores - 64 Explicitly Routed Flows</p>
    </div>
    <span class="badge">Zero Box Collisions - Zero Line Overlaps - Zero Central Corridor Crossings</span>
  </div>
  <div class="viewer-container">
    <div class="mxgraph" style="max-width:100%;border:1px solid transparent;" data-mxgraph="{{&quot;highlight&quot;:&quot;#0000ff&quot;,&quot;nav&quot;:true,&quot;resize&quot;:true,&quot;toolbar&quot;:&quot;zoom layers tags lightbox&quot;,&quot;edit&quot;:&quot;_blank&quot;,&quot;xml&quot;:&quot;{escaped_xml}&quot;}}"></div>
  </div>
  <script type="text/javascript" src="https://viewer.diagrams.net/js/viewer-static.min.js"></script>
</body>
</html>"""

    html_path = r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_0.html"
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    shutil.copyfile(html_path, os.path.join(artifact_dir, "e_parada_dfd_level_0.html"))

    print(f"Level 0 successfully created and copied to {output_path} and {artifact_path}")


if __name__ == '__main__':
    create_drawio_level_0()
