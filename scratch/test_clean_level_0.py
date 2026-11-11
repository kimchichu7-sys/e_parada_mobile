import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import shutil
import os
from dfd_router_helper import OrthogonalDFDBuilder

def generate_clean_level_0():
    mxfile = ET.Element('mxfile', host='app.diagrams.net', agent='Antigravity', version='24.0.0')

    b0 = OrthogonalDFDBuilder(
        'level-0-dfd', 'Level 0 DFD',
        'Level 0 - Data Flow Diagram of the E-Parada Parking Marketplace System',
        'CPSOFT1L - Software Design Lab | Gane & Sarson Multi-Process Architecture (18 Modules Mapped - Zero Line Overlaps)',
        page_w=3200, page_h=2200
    )

    # ==========================================
    # 1. ADD EXTERNAL ENTITIES (6 Total)
    # ==========================================
    # E1: Driver / Motorist (Demand side - Left)
    b0.add_entity('E1', 'Driver / Motorist', 60, 480, 180, 140)
    # E6: Tesseract OCR Engine (Helper for P1 - Top Left)
    b0.add_entity('E6', 'Tesseract OCR Engine', 560, 100, 220, 60)
    # E2: Parking Space Provider (Supply side - Top Center)
    b0.add_entity('E2', 'Parking Space Provider', 1200, 100, 240, 60)
    # E4: Google Maps Platform API (Helper for P3 - Top Right)
    b0.add_entity('E4', 'Google Maps Platform API', 1960, 100, 220, 60)
    # E5: PayMongo Gateway (Payment processor - Far Right)
    b0.add_entity('E5', 'PayMongo Gateway\n(GCash E-Wallet)', 2680, 720, 220, 80)
    # E3: System Administrator (Platform governor - Bottom Right)
    b0.add_entity('E3', 'System Administrator', 1960, 1680, 220, 80)

    # ==========================================
    # 2. ADD PROCESSES (7 Total)
    # ==========================================
    # Col 2: Setup & Authentication
    b0.add_process('P1', '1', 'Manage User Identity &\nTwo-Factor KYC', 560, 240, 220, 100)
    # Col 3: Facility Configuration
    b0.add_process('P2', '2', 'Configure Parking Facility\n& 2D Slots', 1200, 240, 240, 100)
    # Col 4: Core Operational Lifecycle (Sequential Downward Pipeline: P3 -> P4 -> P5 -> P6)
    b0.add_process('P3', '3', 'Search Available Slots &\nCoordinate Navigation', 1960, 240, 220, 100)
    b0.add_process('P4', '4', 'Process Slot Reservation\n& Concurrency Lock', 1960, 560, 220, 100)
    b0.add_process('P5', '5', 'Validate Checkpoint QR\nAccess & Scan Gate', 1960, 880, 220, 100)
    b0.add_process('P6', '6', 'Compute Duration Billing\n& Settlement', 1960, 1200, 220, 100)
    # Bottom: Admin Telemetry & Forensics
    b0.add_process('P7', '7', 'Administer Telemetry, Comms\n& Forensic Audit', 1200, 1670, 240, 100)

    # ==========================================
    # 3. ADD DATA STORES (6 Total)
    # ==========================================
    b0.add_datastore('D1', 'D1', 'Users & Driver Profiles\nStore', 280, 440, 220, 60)
    b0.add_datastore('D2', 'D2', 'Registered Vehicles\nStore (LTO OR/CR)', 560, 440, 220, 60)
    b0.add_datastore('D3', 'D3', 'Parking Spaces & 2D Slots\nStore (Clearances & Layouts)', 1200, 440, 240, 60)
    b0.add_datastore('D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1200, 720, 240, 60)
    b0.add_datastore('D5', 'D5', 'QR Access Tokens &\nGate Telemetry Logs', 1200, 960, 240, 60)
    b0.add_datastore('D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 1200, 1260, 240, 60)

    # ==========================================
    # 4. ADD DATA FLOWS (64 Total)
    # ==========================================

    # --- PROCESS 1: Identity & KYC ---
    b0.add_orthogonal_flow('f01', 'E1', 'T', 0.2, 'P1', 'L', 0.3, 'Credentials & Driver License KYC', mids=[(96, 270)])
    b0.add_orthogonal_flow('f02', 'P1', 'L', 0.6, 'E1', 'T', 0.5, 'JWT Token & KYC Status Badge', mids=[(150, 300)])
    b0.add_orthogonal_flow('f03', 'P1', 'T', 0.3, 'E6', 'B', 0.3, 'Vehicle Plate & OR/CR Image')
    b0.add_orthogonal_flow('f04', 'E6', 'B', 0.7, 'P1', 'T', 0.7, 'Extracted OCR Plate Characters')
    b0.add_orthogonal_flow('f05', 'E2', 'L', 0.3, 'P1', 'T', 0.85, 'Barangay Clearance & Property Deed', mids=[(860, 118), (860, 185), (747, 185)])
    b0.add_orthogonal_flow('f06', 'P1', 'T', 0.95, 'E2', 'L', 0.7, 'Provider Verification Notice', mids=[(769, 205), (900, 205), (900, 142)])
    b0.add_orthogonal_flow('f07', 'P1', 'B', 0.15, 'D1', 'T', 0.8, 'User Credentials & Verified Profile', mids=[(593, 396), (456, 396)])
    b0.add_orthogonal_flow('f59', 'D1', 'T', 0.4, 'P1', 'L', 0.85, 'Stored Credentials & KYC Flags', mids=[(368, 325)])
    b0.add_orthogonal_flow('f08', 'P1', 'B', 0.5, 'D2', 'T', 0.5, 'LTO OR/CR & Plate Records')
    b0.add_orthogonal_flow('f09', 'P1', 'R', 0.8, 'D3', 'L', 0.3, 'Pending Facility KYC Record', mids=[(860, 320), (860, 458)])
    # f10: Route via bottom highway y=1980 and left margin x=35
    b0.add_orthogonal_flow('f10', 'E3', 'B', 0.5, 'P1', 'L', 0.15, 'KYC Approvals & Account Sanctions', mids=[(2070, 1980), (35, 1980), (35, 255)])

    # --- PROCESS 2: Facility & Slot Config ---
    b0.add_orthogonal_flow('f11', 'E2', 'B', 0.5, 'P2', 'T', 0.5, '2D Slot Grid, Rates & Operating Hours')
    b0.add_orthogonal_flow('f12', 'P2', 'T', 0.8, 'E2', 'B', 0.8, 'Slot Layout & Rate Confirmation')
    b0.add_orthogonal_flow('f13', 'D3', 'T', 0.3, 'P2', 'B', 0.3, 'Existing Facility Baseline Data')
    b0.add_orthogonal_flow('f14', 'P2', 'B', 0.7, 'D3', 'T', 0.7, 'Configured 2D Slots & Pricing Rules')
    # f15: Route via bottom corridor y=1940 and corridor between Col 2 and 3 x=880
    b0.add_orthogonal_flow('f15', 'E3', 'B', 0.3, 'P2', 'L', 0.8, 'Regional Price Ceiling Policies', mids=[(2026, 1940), (880, 1940), (880, 320)])

    # --- PROCESS 3: Search & Navigation ---
    b0.add_orthogonal_flow('f16', 'E1', 'T', 0.8, 'P3', 'L', 0.2, 'Search Query (Destination, Radius, Vehicle Type)', mids=[(204, 50), (1880, 50), (1880, 260)])
    b0.add_orthogonal_flow('f17', 'P3', 'T', 0.45, 'E4', 'B', 0.45, 'Geocode Query & Coordinates Request')
    b0.add_orthogonal_flow('f18', 'E4', 'B', 0.8, 'P3', 'T', 0.8, 'Geocoded Coordinates & Distance Matrix')
    b0.add_orthogonal_flow('f19', 'D3', 'R', 0.3, 'P3', 'L', 0.5, 'Facility Locations, Base Rates & 2D Floorplan Layout', mids=[(1620, 458), (1620, 290)])
    b0.add_orthogonal_flow('f20', 'D4', 'R', 0.2, 'P3', 'L', 0.8, 'Real-Time Slot Occupancy States', mids=[(1660, 732), (1660, 320)])
    b0.add_orthogonal_flow('f21', 'P3', 'L', 0.35, 'E1', 'L', 0.2, 'Interactive Map Pins, 2D Floorplan & Turn-by-Turn Route', mids=[(1860, 275), (1860, 30), (20, 30), (20, 508)])

    # --- PROCESS 4: Reservation, Lock & Downpayment ---
    # DIRECT DOWNWARD TRIGGER: P3 -> P4
    b0.add_orthogonal_flow('f62', 'P3', 'B', 0.5, 'P4', 'T', 0.5, 'Selected Available Slot & Pricing Context')
    b0.add_orthogonal_flow('f22', 'E1', 'R', 0.3, 'P4', 'L', 0.2, 'Selected Slot ID & Duration Choice (1-12 Hrs)', mids=[(1780, 522), (1780, 580)])
    b0.add_orthogonal_flow('f29', 'P4', 'L', 0.4, 'E1', 'R', 0.5, 'Booking Confirmation & Dynamic QR Digital Pass', mids=[(1820, 600), (1820, 550)])
    b0.add_orthogonal_flow('f60', 'D2', 'B', 0.5, 'P4', 'T', 0.1, 'Motorist Registered Vehicle Specs (Sedan/SUV)', mids=[(670, 520), (1982, 520)])
    b0.add_orthogonal_flow('f23', 'D3', 'R', 0.7, 'P4', 'T', 0.25, 'Slot Rate Rules & Dimension Clearance Check', mids=[(2015, 482)])
    b0.add_orthogonal_flow('f24', 'P4', 'L', 0.6, 'D4', 'R', 0.4, 'Pessimistic Lock & Active Reservation Record', mids=[(1700, 620), (1700, 744)])
    b0.add_orthogonal_flow('f25', 'D4', 'R', 0.7, 'P4', 'L', 0.8, 'Slot Availability State & 60-Min Expiry Timers', mids=[(1680, 762), (1680, 640)])
    b0.add_orthogonal_flow('f26', 'P4', 'R', 0.4, 'E5', 'T', 0.3, 'Downpayment Charge Request (1-Hr Fee Hold)', mids=[(2746, 600)])
    b0.add_orthogonal_flow('f27', 'E5', 'T', 0.7, 'P4', 'R', 0.6, 'GCash Downpayment Webhook Confirmation', mids=[(2834, 620)])
    b0.add_orthogonal_flow('f28', 'P4', 'L', 0.9, 'D6', 'R', 0.2, 'Downpayment Escrow Ledger Record', mids=[(1720, 650), (1720, 1272)])
    # f30: Route via top highway y=80 over E4 into E2 R
    b0.add_orthogonal_flow('f30', 'P4', 'R', 0.2, 'E2', 'T', 0.8, 'Incoming Reservation Notification & Driver ETA', mids=[(2360, 580), (2360, 80), (1392, 80)])

    # --- PROCESS 5: Checkpoint QR Access & Scan Gate ---
    # DIRECT DOWNWARD TRIGGER: P4 -> P5 (Straight vertical line!)
    b0.add_orthogonal_flow('f63', 'P4', 'B', 0.5, 'P5', 'T', 0.5, 'Approved Reservation & Active QR Trigger')
    b0.add_orthogonal_flow('f31', 'E1', 'B', 0.3, 'P5', 'L', 0.2, 'Present Dynamic QR Digital Pass at Gate', mids=[(114, 900)])
    b0.add_orthogonal_flow('f37', 'P5', 'L', 0.35, 'E1', 'B', 0.7, 'Gate Clearance & Active Session Timer Display', mids=[(186, 915)])
    # f32 & f38: Route via top highway y=65 & y=50 over E4 into E2 T
    b0.add_orthogonal_flow('f32', 'E2', 'T', 0.3, 'P5', 'R', 0.3, 'Optical Camera Scanner Feed / Manual RES-# Fallback', mids=[(1272, 65), (2420, 65), (2420, 910)])
    b0.add_orthogonal_flow('f38', 'P5', 'R', 0.5, 'E2', 'T', 0.5, 'Visual Access Indicator (Green Grant / Red Deny)', mids=[(2450, 930), (2450, 50), (1320, 50)])
    b0.add_orthogonal_flow('f33', 'D4', 'B', 0.6, 'P5', 'L', 0.5, 'Active Reservation Record & Plate Number', mids=[(1344, 820), (1650, 820), (1650, 930)])
    b0.add_orthogonal_flow('f36', 'P5', 'L', 0.65, 'D4', 'B', 0.8, 'Session State Update (Park-In / Park-Out Timestamps)', mids=[(1670, 945), (1670, 840), (1392, 840)])
    b0.add_orthogonal_flow('f34', 'D5', 'R', 0.3, 'P5', 'L', 0.8, 'HMAC-SHA256 Token Validation Key', mids=[(1640, 978), (1640, 960)])
    b0.add_orthogonal_flow('f35', 'P5', 'L', 0.95, 'D5', 'R', 0.7, 'Invalidated Single-Use Pass & Gate Telemetry Logs', mids=[(1660, 975), (1660, 1002)])

    # --- PROCESS 6: Duration Billing & Settlement ---
    # DIRECT DOWNWARD TRIGGER: P5 -> P6 (Straight vertical line!)
    b0.add_orthogonal_flow('f64', 'P5', 'B', 0.5, 'P6', 'T', 0.5, 'Verified Exit Scan & Elapsed Session Trigger')
    b0.add_orthogonal_flow('f39', 'D4', 'B', 0.4, 'P6', 'L', 0.2, 'Validated Session Duration (Actual Park-In & Park-Out)', mids=[(1296, 860), (1630, 860), (1630, 1220)])
    b0.add_orthogonal_flow('f40', 'D6', 'R', 0.4, 'P6', 'L', 0.4, 'Prepaid Downpayment Credit Balance', mids=[(1650, 1284), (1650, 1240)])
    b0.add_orthogonal_flow('f46', 'P6', 'L', 0.6, 'D4', 'B', 0.2, 'Mark Session State as Settled / Closed', mids=[(1620, 1260), (1620, 880), (1248, 880)])
    b0.add_orthogonal_flow('f47', 'P6', 'L', 0.8, 'D6', 'R', 0.8, 'Settlement Ledger Entry & Platform Escrow Split', mids=[(1680, 1280), (1680, 1308)])
    b0.add_orthogonal_flow('f41', 'P6', 'L', 0.3, 'E1', 'B', 0.15, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(87, 1230)])
    # f42: Route around D6 below y=1350 into P6 L
    b0.add_orthogonal_flow('f42', 'E1', 'B', 0.85, 'P6', 'L', 0.7, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(213, 1350), (1880, 1350), (1880, 1270)])
    b0.add_orthogonal_flow('f43', 'P6', 'R', 0.3, 'E5', 'B', 0.3, 'Final Balance GCash Charge / Automated Payout Webhook', mids=[(2746, 1230)])
    b0.add_orthogonal_flow('f44', 'E5', 'B', 0.7, 'P6', 'R', 0.6, 'GCash Final Settlement Webhook Confirmation', mids=[(2834, 1260)])
    # f45 & f48: Route via top highway y=35 & y=20 over E4 into E2 T
    b0.add_orthogonal_flow('f45', 'E2', 'T', 0.7, 'P6', 'R', 0.2, 'Manual Cash Received Handshake (at Exit)', mids=[(1368, 35), (2510, 35), (2510, 1220)])
    b0.add_orthogonal_flow('f48', 'P6', 'R', 0.8, 'E2', 'T', 0.9, 'Net Provider Earnings Breakdown & Payout Credit', mids=[(2540, 1280), (2540, 20), (1416, 20)])

    # --- PROCESS 7: Telemetry, Comms & Forensic Audit ---
    b0.add_orthogonal_flow('f49', 'E1', 'B', 0.5, 'P7', 'L', 0.3, 'WebRTC Voice/Chat Audio & Security Infraction Reports', mids=[(150, 1700)])
    b0.add_orthogonal_flow('f50', 'P7', 'L', 0.7, 'E1', 'B', 0.95, 'WebRTC Audio/Chat Packets & Dispute Status Updates', mids=[(231, 1740)])
    # f51 & f52: Route via far-right margin x=2960 and bottom highway y=1880 / y=1900 (clear of E5 and E3)
    b0.add_orthogonal_flow('f51', 'E2', 'T', 0.15, 'P7', 'B', 0.3, 'WebRTC Voice/Chat Audio & Overstay / Infraction Reports', mids=[(1236, 10), (2960, 10), (2960, 1880), (1272, 1880)])
    b0.add_orthogonal_flow('f52', 'P7', 'B', 0.7, 'E2', 'T', 0.05, 'WebRTC Audio/Chat Packets & Facility Occupancy Heatmaps', mids=[(1368, 1900), (2990, 1900), (2990, 5), (1212, 5)])
    b0.add_orthogonal_flow('f61', 'D1', 'B', 0.5, 'P7', 'L', 0.1, 'User Profiles & Identity Verification Records', mids=[(390, 1680)])
    b0.add_orthogonal_flow('f53', 'D4', 'L', 0.5, 'P7', 'T', 0.2, 'Active Session Context (Locks Comms to Active Booking)', mids=[(1160, 750), (1160, 1580), (1248, 1580)])
    b0.add_orthogonal_flow('f54', 'D5', 'L', 0.5, 'P7', 'T', 0.4, 'Gate Access Telemetry & Unauthorized Stay Logs', mids=[(1180, 990), (1180, 1600), (1296, 1600)])
    b0.add_orthogonal_flow('f55', 'D6', 'B', 0.5, 'P7', 'T', 0.6, 'Financial Transaction Ledgers & Dispute Records')
    b0.add_orthogonal_flow('f58', 'P7', 'T', 0.8, 'D6', 'B', 0.8, 'Dispute Resolutions & Immutable Forensic Audit Trails')
    b0.add_orthogonal_flow('f56', 'E3', 'L', 0.25, 'P7', 'R', 0.5, 'Dispute Mediation Actions & Forensic Audit Query')
    b0.add_orthogonal_flow('f57', 'P7', 'R', 0.8, 'E3', 'L', 0.75, 'System Analytics, Heatmaps & Forensic Audit Reports (CSV/PDF)')

    return b0, mxfile

if __name__ == '__main__':
    b0, mxfile = generate_clean_level_0()
    issues, crossings = b0.audit_geometry(min_parallel_gap=8)
    print(f"\nAUDIT RESULTS: Overlaps/Collisions={len(issues)}, Crossings={len(crossings)}")
    for iss in issues:
        print("   ISSUE:", iss)
