import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
from dfd_router_helper import OrthogonalDFDBuilder

def test_zero_crossings_central():
    b0 = OrthogonalDFDBuilder(
        'level-0-dfd', 'Level 0 DFD',
        'Level 0 - Data Flow Diagram of the E-Parada Parking Marketplace System',
        'CPSOFT1L - Software Design Lab | Gane & Sarson Multi-Process Architecture (18 Modules Mapped - Zero Line Overlaps)',
        page_w=3400, page_h=2300
    )

    # 1. ENTITIES
    b0.add_entity('E1', 'Driver / Motorist', 60, 520, 180, 160)
    b0.add_entity('E6', 'Tesseract OCR Engine', 560, 100, 220, 60)
    b0.add_entity('E2', 'Parking Space Provider', 2600, 240, 240, 100)
    b0.add_entity('E4', 'Google Maps Platform API', 1960, 100, 220, 60)
    b0.add_entity('E5', 'PayMongo Gateway\n(GCash E-Wallet)', 2600, 720, 240, 80)
    b0.add_entity('E3', 'System Administrator', 1960, 1720, 220, 80)

    # 2. PROCESSES
    b0.add_process('P1', '1', 'Manage User Identity &\nTwo-Factor KYC', 560, 240, 220, 100)
    b0.add_process('P2', '2', 'Configure Parking Facility\n& 2D Slots', 1200, 240, 240, 100)
    b0.add_process('P3', '3', 'Search Available Slots &\nCoordinate Navigation', 1960, 240, 220, 100)
    b0.add_process('P4', '4', 'Process Slot Reservation\n& Concurrency Lock', 1960, 560, 220, 100)
    b0.add_process('P5', '5', 'Validate Checkpoint QR\nAccess & Scan Gate', 1960, 880, 220, 100)
    b0.add_process('P6', '6', 'Compute Duration Billing\n& Settlement', 1960, 1200, 220, 100)
    b0.add_process('P7', '7', 'Administer Telemetry, Comms\n& Forensic Audit', 1200, 1710, 240, 100)

    # 3. DATA STORES
    b0.add_datastore('D1', 'D1', 'Users & Driver Profiles\nStore', 280, 440, 220, 60)
    b0.add_datastore('D2', 'D2', 'Registered Vehicles\nStore (LTO OR/CR)', 560, 440, 220, 60)
    b0.add_datastore('D3', 'D3', 'Parking Spaces & 2D Slots\nStore (Clearances & Layouts)', 1200, 440, 240, 60)
    b0.add_datastore('D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1200, 720, 240, 60)
    b0.add_datastore('D5', 'D5', 'QR Access Tokens &\nGate Telemetry Logs', 1200, 960, 240, 60)
    b0.add_datastore('D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 1200, 1260, 240, 60)

    # 4. FLOWS

    # --- P1 ---
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

    # --- P2 ---
    b0.add_orthogonal_flow('f11', 'E2', 'L', 0.2, 'P2', 'R', 0.3, '2D Slot Grid, Rates & Operating Hours', mids=[(2540, 260), (2540, 190), (1480, 190), (1480, 270)])
    b0.add_orthogonal_flow('f12', 'P2', 'R', 0.7, 'E2', 'L', 0.5, 'Slot Layout & Rate Confirmation', mids=[(1460, 310), (1460, 210), (2560, 210), (2560, 290)])
    b0.add_orthogonal_flow('f13', 'D3', 'T', 0.3, 'P2', 'B', 0.3, 'Existing Facility Baseline Data')
    b0.add_orthogonal_flow('f14', 'P2', 'B', 0.7, 'D3', 'T', 0.7, 'Configured 2D Slots & Pricing Rules')
    b0.add_orthogonal_flow('f15', 'E3', 'B', 0.3, 'P2', 'L', 0.8, 'Regional Price Ceiling Policies', mids=[(2026, 1960), (880, 1960), (880, 320)])

    # --- P3 ---
    b0.add_orthogonal_flow('f16', 'E1', 'T', 0.8, 'P3', 'L', 0.2, 'Search Query (Destination, Radius, Vehicle Type)', mids=[(204, 30), (1880, 30), (1880, 260)])
    b0.add_orthogonal_flow('f17', 'P3', 'T', 0.45, 'E4', 'B', 0.45, 'Geocode Query & Coordinates Request')
    b0.add_orthogonal_flow('f18', 'E4', 'B', 0.8, 'P3', 'T', 0.8, 'Geocoded Coordinates & Distance Matrix')
    b0.add_orthogonal_flow('f19', 'D3', 'R', 0.3, 'P3', 'L', 0.5, 'Facility Locations, Base Rates & 2D Floorplan Layout', mids=[(1620, 458), (1620, 290)])
    # f20: Route via D4 L (x=1200) -> x=1080 -> y=380 -> into P3 L (y=320) (ZERO CROSSINGS!)
    b0.add_orthogonal_flow('f20', 'D4', 'L', 0.15, 'P3', 'L', 0.8, 'Real-Time Slot Occupancy States', mids=[(1080, 729), (1080, 380), (1860, 380), (1860, 320)])
    b0.add_orthogonal_flow('f21', 'P3', 'L', 0.35, 'E1', 'L', 0.2, 'Interactive Map Pins, 2D Floorplan & Turn-by-Turn Route', mids=[(1860, 275), (1860, 10), (20, 10), (20, 552)])

    # --- P4 ---
    b0.add_orthogonal_flow('f62', 'P3', 'B', 0.5, 'P4', 'T', 0.5, 'Selected Available Slot & Pricing Context')
    b0.add_orthogonal_flow('f22', 'E1', 'R', 0.3, 'P4', 'L', 0.2, 'Selected Slot ID & Duration Choice (1-12 Hrs)', mids=[(1780, 568), (1780, 580)])
    b0.add_orthogonal_flow('f29', 'P4', 'L', 0.4, 'E1', 'R', 0.5, 'Booking Confirmation & Dynamic QR Digital Pass', mids=[(1820, 600), (1820, 600)])
    b0.add_orthogonal_flow('f60', 'D2', 'B', 0.5, 'P4', 'T', 0.1, 'Motorist Registered Vehicle Specs (Sedan/SUV)', mids=[(670, 520), (1982, 520)])
    b0.add_orthogonal_flow('f23', 'D3', 'R', 0.7, 'P4', 'T', 0.25, 'Slot Rate Rules & Dimension Clearance Check', mids=[(2015, 482)])
    # f24 and f25: PARALLEL NESTED (Zero Crossings!)
    b0.add_orthogonal_flow('f24', 'P4', 'L', 0.6, 'D4', 'R', 0.2, 'Pessimistic Lock & Active Reservation Record', mids=[(1700, 620), (1700, 732)])
    b0.add_orthogonal_flow('f25', 'D4', 'R', 0.6, 'P4', 'L', 0.8, 'Slot Availability State & 60-Min Expiry Timers', mids=[(1720, 756), (1720, 640)])
    b0.add_orthogonal_flow('f26', 'P4', 'R', 0.4, 'E5', 'L', 0.3, 'Downpayment Charge Request (1-Hr Fee Hold)', mids=[(2380, 600), (2380, 744)])
    b0.add_orthogonal_flow('f27', 'E5', 'L', 0.7, 'P4', 'R', 0.6, 'GCash Downpayment Webhook Confirmation', mids=[(2400, 776), (2400, 620)])
    # f28: Route DOWN on RIGHT of Col 4 (x=2240) below P6 (y=1380) into D6 B! (ZERO CUTS with P5!)
    b0.add_orthogonal_flow('f28', 'P4', 'R', 0.85, 'D6', 'B', 0.7, 'Downpayment Escrow Ledger Record', mids=[(2240, 645), (2240, 1380), (1368, 1380)])
    b0.add_orthogonal_flow('f30', 'P4', 'R', 0.2, 'E2', 'B', 0.3, 'Incoming Reservation Notification & Driver ETA', mids=[(2340, 580), (2340, 380), (2672, 380)])

    # --- P5 ---
    b0.add_orthogonal_flow('f63', 'P4', 'B', 0.5, 'P5', 'T', 0.5, 'Approved Reservation & Active QR Trigger')
    # f31 & f37: Enter P5 L at y=900 & y=920
    b0.add_orthogonal_flow('f31', 'E1', 'B', 0.3, 'P5', 'L', 0.2, 'Present Dynamic QR Digital Pass at Gate', mids=[(114, 900), (1960, 900)])
    b0.add_orthogonal_flow('f37', 'P5', 'L', 0.4, 'E1', 'B', 0.7, 'Gate Clearance & Active Session Timer Display', mids=[(1960, 920), (186, 920)])
    b0.add_orthogonal_flow('f32', 'E2', 'B', 0.6, 'P5', 'R', 0.65, 'Optical Camera Scanner Feed / Manual RES-# Fallback', mids=[(2744, 400), (2420, 400), (2420, 945)])
    b0.add_orthogonal_flow('f38', 'P5', 'R', 0.8, 'E2', 'B', 0.8, 'Visual Access Indicator (Green Grant / Red Deny)', mids=[(2460, 960), (2460, 420), (2792, 420)])
    # f33 & f36: Connect D4 R directly to P5 T at y=880 in parallel! (ZERO CROSSINGS!)
    b0.add_orthogonal_flow('f33', 'D4', 'R', 0.8, 'P5', 'T', 0.2, 'Active Reservation Record & Plate Number', mids=[(1660, 768), (1660, 840), (2004, 840)])
    b0.add_orthogonal_flow('f36', 'P5', 'T', 0.35, 'D4', 'R', 0.95, 'Session State Update (Park-In / Park-Out Timestamps)', mids=[(2037, 860), (1680, 860), (1680, 777)])
    # f34 & f35: Connect D5 R to P5 L (y=960..975) below y=920! (ZERO CROSSINGS!)
    b0.add_orthogonal_flow('f34', 'D5', 'R', 0.3, 'P5', 'L', 0.8, 'HMAC-SHA256 Token Validation Key', mids=[(1640, 978), (1640, 960)])
    b0.add_orthogonal_flow('f35', 'P5', 'L', 0.95, 'D5', 'R', 0.7, 'Invalidated Single-Use Pass & Gate Telemetry Logs', mids=[(1660, 975), (1660, 1002)])

    # --- P6 ---
    b0.add_orthogonal_flow('f64', 'P5', 'B', 0.5, 'P6', 'T', 0.5, 'Verified Exit Scan & Elapsed Session Trigger')
    # f39 & f46: Route down LEFT of Col 3 (x=1100, x=1120) below D6 (y=1340, y=1360) into P6 B! (ZERO CUTS with P5!)
    b0.add_orthogonal_flow('f39', 'D4', 'L', 0.3, 'P6', 'B', 0.2, 'Validated Session Duration (Actual Park-In & Park-Out)', mids=[(1100, 738), (1100, 1340), (2004, 1340)])
    b0.add_orthogonal_flow('f46', 'P6', 'B', 0.35, 'D4', 'L', 0.7, 'Mark Session State as Settled / Closed', mids=[(2037, 1360), (1120, 1360), (1120, 762)])
    b0.add_orthogonal_flow('f40', 'D6', 'R', 0.4, 'P6', 'L', 0.4, 'Prepaid Downpayment Credit Balance', mids=[(1650, 1284), (1650, 1240)])
    b0.add_orthogonal_flow('f47', 'P6', 'L', 0.8, 'D6', 'R', 0.8, 'Settlement Ledger Entry & Platform Escrow Split', mids=[(1680, 1280), (1680, 1308)])
    # f41 & f42: CONCENTRIC NESTED routing (Zero Crossings!)
    # f42 is OUTER (y=1130, x=1760 into P6 L at y=1270)
    # f41 is INNER (y=1150, x=1720 from P6 L at y=1205)
    b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'L', 0.7, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1130), (1760, 1130), (1760, 1270)])
    b0.add_orthogonal_flow('f41', 'P6', 'L', 0.05, 'E1', 'B', 0.15, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(1720, 1205), (1720, 1150), (87, 1150)])
    b0.add_orthogonal_flow('f43', 'P6', 'R', 0.35, 'E5', 'B', 0.3, 'Final Balance GCash Charge / Automated Payout Webhook', mids=[(2672, 1235)])
    b0.add_orthogonal_flow('f44', 'E5', 'B', 0.7, 'P6', 'R', 0.55, 'GCash Final Settlement Webhook Confirmation', mids=[(2768, 1255)])
    b0.add_orthogonal_flow('f45', 'E2', 'R', 0.7, 'P6', 'R', 0.25, 'Manual Cash Received Handshake (at Exit)', mids=[(2900, 310), (2900, 1225)])
    b0.add_orthogonal_flow('f48', 'P6', 'R', 0.85, 'E2', 'R', 0.9, 'Net Provider Earnings Breakdown & Payout Credit', mids=[(2930, 1285), (2930, 330)])

    # --- P7 ---
    b0.add_orthogonal_flow('f49', 'E1', 'B', 0.5, 'P7', 'L', 0.3, 'WebRTC Voice/Chat Audio & Security Infraction Reports', mids=[(150, 1740)])
    b0.add_orthogonal_flow('f50', 'P7', 'L', 0.7, 'E1', 'B', 0.95, 'WebRTC Audio/Chat Packets & Dispute Status Updates', mids=[(231, 1780)])
    b0.add_orthogonal_flow('f51', 'E2', 'R', 0.3, 'P7', 'R', 0.15, 'WebRTC Voice/Chat Audio & Overstay / Infraction Reports', mids=[(2960, 270), (2960, 1840), (1480, 1840), (1480, 1725)])
    b0.add_orthogonal_flow('f52', 'P7', 'R', 0.25, 'E2', 'R', 0.5, 'WebRTC Audio/Chat Packets & Facility Occupancy Heatmaps', mids=[(1500, 1735), (1500, 1860), (2990, 1860), (2990, 290)])
    b0.add_orthogonal_flow('f61', 'D1', 'B', 0.5, 'P7', 'L', 0.1, 'User Profiles & Identity Verification Records', mids=[(390, 1720)])
    b0.add_orthogonal_flow('f53', 'D4', 'L', 0.5, 'P7', 'T', 0.2, 'Active Session Context (Locks Comms to Active Booking)', mids=[(1180, 750), (1180, 1620), (1248, 1620)])
    b0.add_orthogonal_flow('f54', 'D5', 'L', 0.5, 'P7', 'T', 0.4, 'Gate Access Telemetry & Unauthorized Stay Logs', mids=[(1160, 990), (1160, 1640), (1296, 1640)])
    b0.add_orthogonal_flow('f55', 'D6', 'B', 0.5, 'P7', 'T', 0.6, 'Financial Transaction Ledgers & Dispute Records')
    b0.add_orthogonal_flow('f58', 'P7', 'T', 0.8, 'D6', 'B', 0.8, 'Dispute Resolutions & Immutable Forensic Audit Trails')
    b0.add_orthogonal_flow('f56', 'E3', 'L', 0.25, 'P7', 'R', 0.5, 'Dispute Mediation Actions & Forensic Audit Query')
    b0.add_orthogonal_flow('f57', 'P7', 'R', 0.8, 'E3', 'L', 0.75, 'System Analytics, Heatmaps & Forensic Audit Reports (CSV/PDF)')

    return b0

if __name__ == '__main__':
    b0 = test_zero_crossings_central()
    issues, crossings = b0.audit_geometry(min_parallel_gap=6)
    print(f"\nAUDIT: Issues={len(issues)}, Crossings={len(crossings)}")
    for iss in issues:
        print("  ", iss)

    v_lines = []
    h_lines = []
    for e in b0.edges:
        pts = e['full_pts']
        fid = e['id']
        val = e['label']
        src = e['src']
        tgt = e['tgt']
        for i in range(len(pts)-1):
            p1, p2 = pts[i], pts[i+1]
            if abs(p1[0]-p2[0]) < 1e-3:
                v_lines.append((p1[0], min(p1[1], p2[1]), max(p1[1], p2[1]), fid, src, tgt, val))
            elif abs(p1[1]-p2[1]) < 1e-3:
                h_lines.append((p1[1], min(p1[0], p2[0]), max(p1[0], p2[0]), fid, src, tgt, val))

    central_cuts = []
    for hy, hx1, hx2, hfid, hsrc, htgt, hval in h_lines:
        for vx, vy1, vy2, vfid, vsrc, vtgt, vval in v_lines:
            if vfid != hfid and vy1 < hy < vy2 and hx1 < vx < hx2:
                if 1400 <= vx <= 2000 and 500 <= hy <= 1500:
                    central_cuts.append((vx, hy, hfid, vfid, hval[:25], vval[:25]))

    print(f"\nCENTRAL CORRIDOR CROSSINGS (The ones from user screenshot): {len(central_cuts)}")
    for vx, hy, hfid, vfid, hval, vval in central_cuts:
        print(f"  at ({vx}, {hy}): H={hfid} [{hval}] crosses V={vfid} [{vval}]")
