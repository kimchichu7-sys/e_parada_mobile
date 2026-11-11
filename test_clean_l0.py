from dfd_router_helper import OrthogonalDFDBuilder
import xml.etree.ElementTree as ET

b = OrthogonalDFDBuilder(
    'level-0-dfd', 'Level 0 DFD',
    'Level 0 - Data Flow Diagram of the E-Parada Parking Marketplace System',
    'CPSOFT1L - Software Design Lab | Gane & Sarson Multi-Process Architecture (18 Modules Mapped - Clean Columnar Layout)',
    page_w=2500, page_h=1700
)

# Column 1 (Left): Driver E1 & OCR E6
b.add_entity('E6', 'Tesseract OCR Engine', 120, 130, 200, 60)
b.add_entity('E1', 'Driver / Motorist', 120, 520, 200, 160)

# Column 2 (Center-Left): 7 Processes stacked vertically
b.add_process('P1', '1', 'Manage User Identity &\nTwo-Factor KYC', 680, 120, 240, 80)
b.add_process('P2', '2', 'Configure Parking Facility\n& 2D Slots', 680, 320, 240, 80)
b.add_process('P3', '3', 'Search Available Slots &\nCoordinate Navigation', 680, 520, 240, 80)
b.add_process('P4', '4', 'Process Slot Reservation\n& Concurrency Lock', 680, 720, 240, 80)
b.add_process('P5', '5', 'Validate Checkpoint QR\nAccess & Scan Gate', 680, 920, 240, 80)
b.add_process('P6', '6', 'Compute Duration Billing\n& Settlement', 680, 1120, 240, 80)
b.add_process('P7', '7', 'Administer Telemetry, Comms\n& Forensic Audit', 680, 1340, 240, 80)

# Column 3 (Center-Right): 6 Data Stores stacked beside processes
b.add_datastore('D1', 'D1', 'Users & Driver Profiles\nStore', 1240, 130, 240, 56)
b.add_datastore('D2', 'D2', 'Registered Vehicles\nStore (LTO OR/CR)', 1240, 230, 240, 56)
b.add_datastore('D3', 'D3', 'Parking Spaces & 2D Slots\nStore (Clearances & Layouts)', 1240, 370, 240, 56)
b.add_datastore('D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1240, 730, 240, 56)
b.add_datastore('D5', 'D5', 'QR Access Tokens &\nGate Telemetry Logs', 1240, 930, 240, 56)
b.add_datastore('D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 1240, 1130, 240, 56)

# Column 4 (Right): External Services
b.add_entity('E2', 'Parking Space Provider', 1820, 320, 220, 80)
b.add_entity('E4', 'Google Maps Platform API', 1820, 530, 220, 60)
b.add_entity('E5', 'PayMongo Gateway\n(GCash E-Wallet)', 1820, 820, 220, 80)
b.add_entity('E3', 'System Administrator', 1820, 1340, 220, 80)

# --- PROCESS 1: Identity & KYC ---
b.add_orthogonal_flow('f01', 'E1', 'T', 0.2, 'P1', 'L', 0.3, 'Credentials & Driver License KYC', mids=[(160, 144)])
b.add_orthogonal_flow('f02', 'P1', 'L', 0.7, 'E1', 'T', 0.4, 'JWT Token & KYC Status Badge', mids=[(200, 176)])
b.add_orthogonal_flow('f03', 'P1', 'T', 0.25, 'E6', 'R', 0.3, 'Vehicle Plate & OR/CR Image', mids=[(740, 80), (320, 80), (320, 148)])
b.add_orthogonal_flow('f04', 'E6', 'R', 0.7, 'P1', 'T', 0.75, 'Extracted OCR Plate Characters', mids=[(340, 172), (340, 100), (860, 100)])
b.add_orthogonal_flow('f05', 'E2', 'T', 0.3, 'P1', 'T', 0.9, 'Barangay Clearance & Property Deed', mids=[(1886, 60), (896, 60)])
b.add_orthogonal_flow('f06', 'P1', 'R', 0.2, 'E2', 'T', 0.7, 'Provider Verification Notice', mids=[(1050, 136), (1050, 80), (1974, 80)])
b.add_orthogonal_flow('f07', 'P1', 'R', 0.4, 'D1', 'T', 0.3, 'User Credentials & Verified Profile', mids=[(1080, 152), (1080, 110), (1312, 110)])
b.add_orthogonal_flow('f59', 'D1', 'L', 0.5, 'P1', 'R', 0.6, 'Stored Credentials & KYC Flags', mids=[(1080, 158), (1080, 168)])
b.add_orthogonal_flow('f08', 'P1', 'B', 0.5, 'D2', 'L', 0.5, 'LTO OR/CR & Plate Records', mids=[(800, 258)])
b.add_orthogonal_flow('f09', 'P1', 'B', 0.8, 'D3', 'L', 0.25, 'Pending Facility KYC Record', mids=[(872, 280), (1080, 280), (1080, 384)])
b.add_orthogonal_flow('f10', 'E3', 'B', 0.8, 'P1', 'L', 0.15, 'KYC Approvals & Account Sanctions', mids=[(1996, 1620), (50, 1620), (50, 132)])

# --- PROCESS 2: Facility & Slot Config ---
b.add_orthogonal_flow('f11', 'E2', 'L', 0.3, 'P2', 'R', 0.3, '2D Slot Grid, Rates & Operating Hours', mids=[(1600, 344), (1600, 310), (1080, 310), (1080, 344)])
b.add_orthogonal_flow('f12', 'P2', 'R', 0.7, 'E2', 'L', 0.7, 'Slot Layout & Rate Confirmation', mids=[(1080, 376), (1080, 340), (1600, 340), (1600, 376)])
b.add_orthogonal_flow('f13', 'D3', 'L', 0.5, 'P2', 'R', 0.5, 'Existing Facility Baseline Data')
b.add_orthogonal_flow('f14', 'P2', 'B', 0.8, 'D3', 'L', 0.85, 'Configured 2D Slots & Pricing Rules', mids=[(872, 418)])
b.add_orthogonal_flow('f15', 'E3', 'T', 0.2, 'P2', 'R', 0.15, 'Regional Price Ceiling Policies', mids=[(1864, 1260), (1700, 1260), (1700, 300), (1020, 300), (1020, 332)])

# --- PROCESS 3: Search & Navigation ---
b.add_orthogonal_flow('f16', 'E1', 'R', 0.2, 'P3', 'L', 0.25, 'Search Query (Destination, Radius, Vehicle Type)')
b.add_orthogonal_flow('f21', 'P3', 'L', 0.75, 'E1', 'R', 0.4, 'Interactive Map Pins, 2D Floorplan & Turn-by-Turn Route')
b.add_orthogonal_flow('f17', 'P3', 'R', 0.3, 'E4', 'L', 0.3, 'Geocode Query & Coordinates Request', mids=[(1100, 544), (1100, 480), (1700, 480), (1700, 548)])
b.add_orthogonal_flow('f18', 'E4', 'L', 0.7, 'P3', 'R', 0.7, 'Geocoded Coordinates & Distance Matrix', mids=[(1700, 572), (1700, 500), (1100, 500), (1100, 576)])
b.add_orthogonal_flow('f19', 'D3', 'B', 0.3, 'P3', 'T', 0.8, 'Facility Locations, Base Rates & 2D Floorplan Layout', mids=[(1312, 460), (872, 460)])
b.add_orthogonal_flow('f20', 'D4', 'T', 0.3, 'P3', 'B', 0.8, 'Real-Time Slot Occupancy States', mids=[(1312, 660), (872, 660)])
b.add_orthogonal_flow('f62', 'P3', 'B', 0.5, 'P4', 'T', 0.5, 'Selected Available Slot & Pricing Context')

# --- PROCESS 4: Reservation, Lock & Downpayment ---
b.add_orthogonal_flow('f22', 'E1', 'R', 0.6, 'P4', 'L', 0.25, 'Selected Slot ID & Duration Choice (1-12 Hrs)', mids=[(460, 616), (460, 740)])
b.add_orthogonal_flow('f29', 'P4', 'L', 0.75, 'E1', 'R', 0.8, 'Booking Confirmation & Dynamic QR Digital Pass', mids=[(480, 780), (480, 648)])
b.add_orthogonal_flow('f60', 'D2', 'B', 0.5, 'P4', 'T', 0.8, 'Motorist Registered Vehicle Specs (Sedan/SUV)', mids=[(1360, 310), (1140, 310), (1140, 680), (872, 680)])
b.add_orthogonal_flow('f23', 'D3', 'B', 0.7, 'P4', 'T', 0.65, 'Slot Rate Rules & Dimension Clearance Check', mids=[(1408, 480), (1160, 480), (1160, 700), (836, 700)])
b.add_orthogonal_flow('f24', 'P4', 'R', 0.3, 'D4', 'L', 0.3, 'Pessimistic Lock & Active Reservation Record')
b.add_orthogonal_flow('f25', 'D4', 'L', 0.7, 'P4', 'R', 0.7, 'Slot Availability State & 60-Min Expiry Timers')
b.add_orthogonal_flow('f26', 'P4', 'R', 0.5, 'E5', 'L', 0.3, 'Downpayment Charge Request (1-Hr Fee Hold)', mids=[(1100, 760), (1100, 830), (1700, 830), (1700, 844)])
b.add_orthogonal_flow('f27', 'E5', 'L', 0.7, 'P4', 'R', 0.85, 'GCash Downpayment Webhook Confirmation', mids=[(1700, 876), (1700, 860), (1100, 860), (1100, 788)])
b.add_orthogonal_flow('f28', 'P4', 'B', 0.8, 'D6', 'T', 0.3, 'Downpayment Escrow Ledger Record', mids=[(872, 880), (1160, 880), (1160, 1080), (1312, 1080)])
b.add_orthogonal_flow('f30', 'P4', 'R', 0.15, 'E2', 'B', 0.5, 'Incoming Reservation Notification & Driver ETA', mids=[(1060, 732), (1060, 640), (1930, 640)])
b.add_orthogonal_flow('f63', 'P4', 'B', 0.5, 'P5', 'T', 0.5, 'Approved Reservation & Active QR Trigger')

# --- PROCESS 5: Checkpoint QR Access & Scan Gate ---
b.add_orthogonal_flow('f31', 'E1', 'B', 0.3, 'P5', 'L', 0.25, 'Present Dynamic QR Digital Pass at Gate', mids=[(180, 820), (520, 820), (520, 940)])
b.add_orthogonal_flow('f37', 'P5', 'L', 0.75, 'E1', 'B', 0.6, 'Gate Clearance & Active Session Timer Display', mids=[(540, 980), (540, 840), (240, 840)])
b.add_orthogonal_flow('f32', 'E2', 'B', 0.8, 'P5', 'R', 0.15, 'Optical Camera Scanner Feed / Manual RES-# Fallback', mids=[(1996, 680), (1100, 680), (1100, 932)])
b.add_orthogonal_flow('f38', 'P5', 'R', 0.35, 'E2', 'B', 0.2, 'Visual Access Indicator (Green Grant / Red Deny)', mids=[(1080, 948), (1080, 660), (1864, 660)])
b.add_orthogonal_flow('f33', 'D4', 'B', 0.5, 'P5', 'T', 0.8, 'Active Reservation Record & Plate Number', mids=[(1360, 850), (872, 850)])
b.add_orthogonal_flow('f36', 'P5', 'T', 0.65, 'D4', 'B', 0.2, 'Session State Update (Park-In / Park-Out Timestamps)', mids=[(836, 830), (1288, 830)])
b.add_orthogonal_flow('f34', 'D5', 'L', 0.3, 'P5', 'R', 0.65, 'HMAC-SHA256 Token Validation Key')
b.add_orthogonal_flow('f35', 'P5', 'R', 0.85, 'D5', 'L', 0.7, 'Invalidated Single-Use Pass & Gate Telemetry Logs')
b.add_orthogonal_flow('f64', 'P5', 'B', 0.5, 'P6', 'T', 0.5, 'Verified Exit Scan & Elapsed Session Trigger')

# --- PROCESS 6: Duration Billing & Settlement ---
b.add_orthogonal_flow('f41', 'P6', 'L', 0.25, 'E1', 'B', 0.8, 'Itemized Final Billing Statement (Hours, Grace, Net Balance)', mids=[(500, 1140), (500, 860), (280, 860)])
b.add_orthogonal_flow('f42', 'E1', 'L', 0.7, 'P6', 'L', 0.75, 'Final Balance Settlement (Cash at Gate / GCash)', mids=[(80, 632), (80, 1180)])
b.add_orthogonal_flow('f39', 'D4', 'B', 0.8, 'P6', 'T', 0.8, 'Validated Session Duration (Actual Park-In & Park-Out)', mids=[(1432, 900), (1140, 900), (1140, 1060), (872, 1060)])
b.add_orthogonal_flow('f46', 'P6', 'T', 0.65, 'D4', 'B', 0.65, 'Mark Session State as Settled / Closed', mids=[(836, 1040), (1120, 1040), (1120, 870), (1396, 870)])
b.add_orthogonal_flow('f40', 'D6', 'L', 0.3, 'P6', 'R', 0.3, 'Prepaid Downpayment Credit Balance')
b.add_orthogonal_flow('f47', 'P6', 'R', 0.7, 'D6', 'L', 0.7, 'Settlement Ledger Entry & Platform Escrow Split')
b.add_orthogonal_flow('f43', 'P6', 'R', 0.5, 'E5', 'B', 0.3, 'Final Balance GCash Charge / Automated Payout Webhook', mids=[(1060, 1160), (1060, 1000), (1886, 1000)])
b.add_orthogonal_flow('f44', 'E5', 'B', 0.7, 'P6', 'R', 0.85, 'GCash Final Settlement Webhook Confirmation', mids=[(1974, 1020), (1040, 1020), (1040, 1188)])
b.add_orthogonal_flow('f45', 'E2', 'R', 0.5, 'P6', 'R', 0.15, 'Manual Cash Received Handshake (at Exit)', mids=[(2120, 360), (2120, 1100), (1080, 1100), (1080, 1132)])
b.add_orthogonal_flow('f48', 'P6', 'R', 0.2, 'E2', 'R', 0.8, 'Net Provider Earnings Breakdown & Payout Credit', mids=[(1090, 1136), (1090, 1090), (2140, 1090), (2140, 384)])

# --- PROCESS 7: Telemetry, Comms & Forensic Audit ---
b.add_orthogonal_flow('f49', 'E1', 'L', 0.3, 'P7', 'L', 0.25, 'WebRTC Voice/Chat Audio & Security Infraction Reports', mids=[(60, 568), (60, 1360)])
b.add_orthogonal_flow('f50', 'P7', 'L', 0.75, 'E1', 'L', 0.5, 'WebRTC Audio/Chat Packets & Dispute Status Updates', mids=[(40, 1400), (40, 600)])
b.add_orthogonal_flow('f61', 'D1', 'B', 0.8, 'P7', 'T', 0.35, 'User Profiles & Identity Verification Records', mids=[(1432, 210), (1600, 210), (1600, 1280), (764, 1280)])
b.add_orthogonal_flow('f53', 'D4', 'B', 0.35, 'P7', 'T', 0.65, 'Active Session Context (Locks Comms to Active Booking)', mids=[(1324, 820), (1040, 820), (1040, 1300), (836, 1300)])
b.add_orthogonal_flow('f54', 'D5', 'B', 0.5, 'P7', 'T', 0.8, 'Gate Access Telemetry & Unauthorized Stay Logs', mids=[(1360, 1020), (1020, 1020), (1020, 1320), (872, 1320)])
b.add_orthogonal_flow('f55', 'D6', 'B', 0.5, 'P7', 'R', 0.25, 'Financial Transaction Ledgers & Dispute Records', mids=[(1360, 1220), (1020, 1220), (1020, 1360)])
b.add_orthogonal_flow('f58', 'P7', 'R', 0.5, 'D6', 'B', 0.8, 'Dispute Resolutions & Immutable Forensic Audit Trails', mids=[(1040, 1380), (1040, 1240), (1432, 1240)])
b.add_orthogonal_flow('f51', 'E2', 'R', 0.2, 'P7', 'R', 0.7, 'WebRTC Voice/Chat Audio & Overstay / Infraction Reports', mids=[(2160, 336), (2160, 1396)])
b.add_orthogonal_flow('f52', 'P7', 'R', 0.85, 'E2', 'R', 0.9, 'WebRTC Audio/Chat Packets & Facility Occupancy Heatmaps', mids=[(2180, 1408), (2180, 392)])
b.add_orthogonal_flow('f56', 'E3', 'L', 0.3, 'P7', 'R', 0.15, 'Dispute Mediation Actions & Forensic Audit Query', mids=[(1700, 1364), (1700, 1352)])
b.add_orthogonal_flow('f57', 'P7', 'R', 0.6, 'E3', 'L', 0.7, 'System Analytics, Heatmaps & Forensic Audit Reports (CSV/PDF)', mids=[(1700, 1388), (1700, 1396)])

issues, crossings = b.audit_geometry(min_parallel_gap=10)
print(f"CLEAN LAYOUT RESULT: Issues={len(issues)}, Crossings={len(crossings)}")
for iss in issues:
    print("   ISSUE:", iss)
