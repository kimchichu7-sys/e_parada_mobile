import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import shutil
import os
from dfd_router_helper import OrthogonalDFDBuilder

def build_clean_level_1():
    mxfile = ET.Element('mxfile', host='app.diagrams.net', agent='Antigravity', version='24.0.0')
    builders = []

    # =========================================================================
    # TAB 1: DECOMPOSITION OF PROCESS 1 (Manage User Identity & Two-Factor KYC)
    # 0 Overlaps, 0 Box Collisions, 0 Crossings (Parallel KYC Branches 1.2 & 1.3)
    # =========================================================================
    b1 = OrthogonalDFDBuilder(
        'lvl1-p1', 'Level 1 - Process 1 (KYC & Auth)',
        'Level-1 Data Flow Diagram Decomposition of Process 1: Manage User Identity & Two-Factor KYC',
        'Modules Covered: M01 (User Auth & RBAC), M02 (Vehicle OCR Onboarding), M08 (Provider Space Onboarding), M14 (Admin KYC Audit)',
        page_w=2050, page_h=1300
    )
    # Top Row: E1 (Left), P1_1 (Center), D1 (Right)
    b1.add_entity('p1_E1', 'Driver / Motorist', 120, 150, 185, 60)
    b1.add_process('P1_1', '1.1', 'Authenticate Credentials &\nIssue Sanctum RBAC Token', 780, 140, 240, 80)
    b1.add_datastore('p1_D1', 'D1', 'Users & Driver Profiles Store', 1460, 150, 250, 60)

    # Middle Row: Parallel KYC Onboarding Branches (1.2 Driver/Vehicle on Left-Center, 1.3 Provider/Space on Right-Center)
    b1.add_entity('p1_E6', 'Tesseract OCR Engine', 120, 470, 185, 60)
    b1.add_process('P1_2', '1.2', 'Extract Vehicle Plate via OCR\n& Register LTO OR/CR', 500, 460, 240, 80)
    b1.add_datastore('p1_D2', 'D2', 'Registered Vehicles Store\n(LTO OR/CR)', 500, 680, 240, 56)

    b1.add_process('P1_3', '1.3', 'Onboard Provider Facility &\nUpload Barangay Clearance', 1060, 460, 240, 80)
    b1.add_entity('p1_E2', 'Parking Space Provider', 1520, 470, 190, 60)
    b1.add_datastore('p1_D3', 'D3', 'Parking Spaces & 2D Slots Store\n(Clearances & Layouts)', 1460, 740, 250, 60)

    # Bottom Row: P1_4 (Admin KYC Audit Console) & E3 (System Administrator)
    b1.add_entity('p1_E3', 'System Administrator', 120, 960, 185, 60)
    b1.add_process('P1_4', '1.4', 'Audit KYC Submissions &\nEnforce Account Sanctions', 780, 950, 240, 80)

    # Strictly Non-Overlapping & Non-Crossing Flows for Tab 1
    b1.add_orthogonal_flow('p1_f1', 'p1_E1', 'R', 0.25, 'P1_1', 'L', 0.3125, 'Login Credentials & Role Request')
    b1.add_orthogonal_flow('p1_f2', 'P1_1', 'L', 0.6875, 'p1_E1', 'R', 0.75, 'JWT Token & KYC Status Badge')
    b1.add_orthogonal_flow('p1_f3', 'p1_D1', 'L', 0.5, 'P1_1', 'R', 0.5, 'Stored Credentials & KYC Flags')
    b1.add_orthogonal_flow('p1_f4', 'P1_1', 'B', 0.3, 'P1_2', 'T', 0.7, 'Authenticated Driver Session Context', mids=[(852, 340), (668, 340)])
    b1.add_orthogonal_flow('p1_f5', 'p1_E1', 'B', 0.5, 'P1_2', 'T', 0.3, 'Driver License, OR/CR & Plate Photo', mids=[(212, 340), (572, 340)])
    b1.add_orthogonal_flow('p1_f6', 'P1_2', 'L', 0.3125, 'p1_E6', 'R', 0.25, 'Vehicle Plate & OR/CR Image')
    b1.add_orthogonal_flow('p1_f7', 'p1_E6', 'R', 0.75, 'P1_2', 'L', 0.6875, 'Extracted OCR Plate Characters')
    b1.add_orthogonal_flow('p1_f8', 'P1_2', 'B', 0.5, 'p1_D2', 'T', 0.5, 'LTO OR/CR & Plate Records')
    b1.add_orthogonal_flow('p1_f9', 'P1_2', 'R', 0.5, 'P1_4', 'T', 0.3, 'Pending Driver & Vehicle KYC Payload', mids=[(852, 500)])
    b1.add_orthogonal_flow('p1_f10', 'p1_E2', 'L', 0.5, 'P1_3', 'R', 0.5, 'Barangay Clearance & Property Deed')
    b1.add_orthogonal_flow('p1_f11', 'P1_3', 'B', 0.7, 'p1_D3', 'T', 0.3, 'Pending Facility KYC Record', mids=[(1228, 640), (1535, 640)])
    b1.add_orthogonal_flow('p1_f12', 'P1_3', 'B', 0.3, 'P1_4', 'T', 0.7, 'Pending Facility Clearance Payload', mids=[(1132, 640), (948, 640)])
    b1.add_orthogonal_flow('p1_f13', 'P1_4', 'L', 0.3125, 'p1_E3', 'R', 0.25, 'Pending KYC Verification Queue')
    b1.add_orthogonal_flow('p1_f14', 'p1_E3', 'R', 0.75, 'P1_4', 'L', 0.6875, 'KYC Approvals & Account Sanctions')
    b1.add_orthogonal_flow('p1_f15', 'P1_4', 'R', 0.25, 'p1_D3', 'B', 0.5, 'Verified Facility Approval Flag', mids=[(1585, 970)])
    b1.add_orthogonal_flow('p1_f16', 'P1_4', 'R', 0.55, 'p1_E2', 'B', 0.5, 'Provider Verification Notice', mids=[(1820, 994), (1820, 600), (1615, 600)])
    b1.add_orthogonal_flow('p1_f17', 'P1_4', 'R', 0.85, 'p1_D1', 'R', 0.5, 'User Credentials & Verified Profile', mids=[(1900, 1018), (1900, 180)])
    builders.append(b1)

    # =========================================================================
    # TAB 2: DECOMPOSITION OF PROCESS 2 (Configure Parking Facility & 2D Slots)
    # 0 Overlaps, 0 Box Collisions, 0 Crossings
    # =========================================================================
    b2 = OrthogonalDFDBuilder(
        'lvl1-p2', 'Level 1 - Process 2 (2D Slots & Rates)',
        'Level-1 Data Flow Diagram Decomposition of Process 2: Configure Parking Facility & 2D Slots',
        'Modules Covered: M09 (Interactive 2D Slot Config & Batch Editor), M10 (Dynamic Pricing & Schedules), M15 (Admin Price Ceilings)',
        page_w=1800, page_h=1100
    )
    b2.add_entity('p2_E2', 'Parking Space Provider', 140, 160, 185, 60)
    b2.add_entity('p2_E3', 'System Administrator', 140, 720, 185, 60)
    b2.add_datastore('p2_D3', 'D3', 'Parking Spaces & 2D Slots Store\n(Clearances & Layouts)', 1340, 160, 250, 60)

    b2.add_process('P2_1', '2.1', 'Design 2D Slot Grid (x, z) &\nExecute Batch Slot Setup', 720, 150, 240, 80)
    b2.add_process('P2_2', '2.2', 'Configure Operating Hours,\n15-Min Grace & Base Rates', 720, 430, 240, 80)
    b2.add_process('P2_3', '2.3', 'Enforce Regional Price Ceiling\n& Commit Facility Rules', 720, 710, 240, 80)

    b2.add_orthogonal_flow('p2_f1', 'p2_E2', 'R', 0.5, 'P2_1', 'L', 0.5, '2D Slot Coordinates (x, z) & Clearances')
    b2.add_orthogonal_flow('p2_f2', 'p2_D3', 'L', 0.5, 'P2_1', 'R', 0.5, 'Existing Facility Baseline Data')
    b2.add_orthogonal_flow('p2_f3', 'P2_1', 'B', 0.5, 'P2_2', 'T', 0.5, 'Structured 2D Slot Grid Layout')
    b2.add_orthogonal_flow('p2_f4', 'p2_E2', 'B', 0.5, 'P2_2', 'L', 0.5, 'Hourly Rates, Grace Period & Operating Hours', mids=[(232, 470)])
    b2.add_orthogonal_flow('p2_f5', 'P2_2', 'B', 0.5, 'P2_3', 'T', 0.5, 'Draft Rate Schedule & Slot Matrix')
    b2.add_orthogonal_flow('p2_f6', 'p2_E3', 'R', 0.5, 'P2_3', 'L', 0.5, 'Regional Price Ceiling Policies')
    b2.add_orthogonal_flow('p2_f7', 'P2_3', 'R', 0.5, 'p2_D3', 'B', 0.5, 'Configured 2D Slots & Pricing Rules', mids=[(1465, 750)])
    b2.add_orthogonal_flow('p2_f8', 'P2_3', 'B', 0.5, 'p2_E2', 'L', 0.5, 'Slot Layout & Rate Confirmation', mids=[(840, 870), (60, 870), (60, 190)])
    builders.append(b2)

    # =========================================================================
    # TAB 3: DECOMPOSITION OF PROCESS 3 (Search Available Slots & Navigation)
    # 0 Overlaps, 0 Box Collisions, 0 Crossings
    # =========================================================================
    b3 = OrthogonalDFDBuilder(
        'lvl1-p3', 'Level 1 - Process 3 (Search & 2D Map)',
        'Level-1 Data Flow Diagram Decomposition of Process 3: Search Available Slots & Coordinate Navigation',
        'Modules Covered: M03 (Geospatial Search & Google Maps Routing), M04 (Real-Time 2D Floor Plan & Visual Slot Selector)',
        page_w=1900, page_h=1250
    )
    b3.add_entity('p3_E1', 'Driver / Motorist', 140, 170, 180, 60)
    b3.add_entity('p3_E4', 'Google Maps Platform API', 140, 730, 185, 60)

    b3.add_process('P3_1', '3.1', 'Geocode Destination & Filter\nSpaces by Radius & Vehicle Fit', 720, 160, 240, 80)
    b3.add_process('P3_2', '3.2', 'Render Real-Time 2D Floorplan\n& Slot Occupancy States', 720, 440, 240, 80)
    b3.add_process('P3_3', '3.3', 'Calculate Distance Matrix &\nTurn-by-Turn Navigation Route', 720, 720, 240, 80)
    b3.add_process('p3_P4_ref', '4', 'Process Slot Reservation &\nConcurrency Lock', 720, 1000, 240, 80, is_ref=True)

    b3.add_datastore('p3_D3', 'D3', 'Parking Spaces & 2D Slots Store\n(Clearances & Layouts)', 1360, 170, 250, 60)
    b3.add_datastore('p3_D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1360, 450, 250, 60)

    b3.add_orthogonal_flow('p3_f1', 'p3_E1', 'R', 0.5, 'P3_1', 'L', 0.5, 'Search Query (Destination, Radius, Vehicle Type)')
    b3.add_orthogonal_flow('p3_f2', 'P3_1', 'B', 0.2, 'p3_E4', 'T', 0.5, 'Geocode Query & Coordinates Request', mids=[(768, 300), (232, 300)])
    b3.add_orthogonal_flow('p3_f3', 'p3_E4', 'T', 0.8, 'P3_1', 'B', 0.35, 'Geocoded Destination Coordinates', mids=[(288, 340), (804, 340)])
    b3.add_orthogonal_flow('p3_f4', 'p3_D3', 'L', 0.5, 'P3_1', 'R', 0.5, 'Facility Coordinates & Vehicle Clearances')
    b3.add_orthogonal_flow('p3_f5', 'P3_1', 'B', 0.5, 'P3_2', 'T', 0.5, 'Filtered Nearby Parking Facilities')
    b3.add_orthogonal_flow('p3_f6', 'p3_D3', 'B', 0.5, 'P3_2', 'T', 0.8, 'Facility Base Rates & 2D Floorplan Layout', mids=[(1485, 360), (912, 360)])
    b3.add_orthogonal_flow('p3_f7', 'p3_D4', 'L', 0.5, 'P3_2', 'R', 0.5, 'Real-Time Slot Occupancy States')
    b3.add_orthogonal_flow('p3_f8', 'P3_2', 'B', 0.5, 'P3_3', 'T', 0.5, 'Selected Facility & Vacant 2D Slot (x, z)')
    b3.add_orthogonal_flow('p3_f9', 'p3_E4', 'R', 0.5, 'P3_3', 'L', 0.5, 'Distance Matrix & Route Geometry')
    b3.add_orthogonal_flow('p3_f10', 'P3_3', 'B', 0.2, 'p3_E1', 'L', 0.5, 'Interactive Map Pins, 2D Floorplan & Route', mids=[(768, 870), (60, 870), (60, 200)])
    b3.add_orthogonal_flow('p3_f11', 'P3_2', 'R', 0.75, 'p3_P4_ref', 'R', 0.5, 'Selected Available Slot & Pricing Context', mids=[(1160, 500), (1160, 1040)])
    builders.append(b3)

    # =========================================================================
    # TAB 4: DECOMPOSITION OF PROCESS 4 (Slot Reservation & Concurrency Lock)
    # 0 Overlaps, 0 Box Collisions, 0 Crossings
    # =========================================================================
    b4 = OrthogonalDFDBuilder(
        'lvl1-p4', 'Level 1 - Process 4 (Booking & Lock)',
        'Level-1 Data Flow Diagram Decomposition of Process 4: Process Slot Reservation & Concurrency Lock',
        'Modules Covered: M05 (Dynamic Duration-Based Reservation Engine), M11 (Real-Time Concurrency Lock & 60-Min No-Show Timer)',
        page_w=2050, page_h=1620
    )
    b4.add_process('p4_P3_ref', '3', 'Search Available Slots &\nCoordinate Navigation', 760, 100, 240, 80, is_ref=True)
    b4.add_process('P4_1', '4.1', 'Verify Vehicle Fit & Acquire\nPessimistic Row Lock', 760, 290, 240, 80)
    b4.add_process('P4_2', '4.2', 'Create Pending Booking & Hold\n1-Hour GCash Downpayment', 760, 560, 240, 80)
    b4.add_process('P4_3', '4.3', 'Confirm Reservation & Dispatch\nProvider ETA Notification', 760, 830, 240, 80)
    b4.add_process('P4_4', '4.4', 'Monitor 60-Minute Arrival Window\n& Auto-Cancel No-Shows', 760, 1080, 240, 80)
    b4.add_process('P4_5', '4.5', 'Issue Booking Confirmation &\nTrigger Dynamic QR Pass', 760, 1300, 240, 80)
    b4.add_process('p4_P5_ref', '5', 'Validate Checkpoint QR\nAccess & Scan Gate', 760, 1480, 240, 80, is_ref=True)

    # Left Column: External Entities E1, E5, D6, E2 so Right Column is exclusively D2, D3, D4 (0 Crossings!)
    b4.add_entity('p4_E1', 'Driver / Motorist', 140, 300, 180, 60)
    b4.add_entity('p4_E5', 'PayMongo Gateway\n(GCash E-Wallet)', 140, 560, 185, 60)
    b4.add_datastore('p4_D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 140, 680, 250, 56)
    b4.add_entity('p4_E2', 'Parking Space Provider', 140, 840, 185, 60)

    # Right Column: D2, D3, D4
    b4.add_datastore('p4_D2', 'D2', 'Registered Vehicles Store\n(LTO OR/CR)', 1420, 170, 250, 56)
    b4.add_datastore('p4_D3', 'D3', 'Parking Spaces & 2D Slots Store\n(Clearances & Layouts)', 1420, 290, 250, 56)
    b4.add_datastore('p4_D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1420, 842, 250, 56)

    b4.add_orthogonal_flow('p4_f1', 'p4_P3_ref', 'B', 0.5, 'P4_1', 'T', 0.5, 'Selected Available Slot & Pricing Context')
    b4.add_orthogonal_flow('p4_f2', 'p4_E1', 'R', 0.5, 'P4_1', 'L', 0.5, 'Selected Slot ID & Duration Choice (1-12 Hrs)')
    b4.add_orthogonal_flow('p4_f3', 'p4_D2', 'L', 0.5, 'P4_1', 'T', 0.8, 'Motorist Registered Vehicle Specs (Sedan/SUV)', mids=[(952, 198)])
    b4.add_orthogonal_flow('p4_f4', 'p4_D3', 'L', 0.5, 'P4_1', 'R', 0.35, 'Slot Rate Rules & Dimension Clearance Check')
    b4.add_orthogonal_flow('p4_f5', 'p4_D4', 'L', 0.2, 'P4_1', 'R', 0.65, 'Slot Availability State & Active Locks', mids=[(1240, 853), (1240, 342)])
    b4.add_orthogonal_flow('p4_f6', 'P4_1', 'R', 0.85, 'p4_D4', 'L', 0.5, 'Pessimistic Row Lock (SELECT FOR UPDATE)', mids=[(1180, 358), (1180, 870)])
    b4.add_orthogonal_flow('p4_f7', 'P4_1', 'B', 0.5, 'P4_2', 'T', 0.5, 'Locked Slot Token & 1-Hour Downpayment Fee')
    b4.add_orthogonal_flow('p4_f8', 'P4_2', 'L', 0.25, 'p4_E5', 'R', 0.3333, 'Downpayment Charge Request (1-Hr Fee Hold)')
    b4.add_orthogonal_flow('p4_f9', 'p4_E5', 'R', 0.6667, 'P4_2', 'L', 0.5, 'GCash Downpayment Webhook Confirmation')
    b4.add_orthogonal_flow('p4_f10', 'P4_2', 'L', 0.8, 'p4_D6', 'R', 0.5, 'Downpayment Escrow Ledger Record', mids=[(540, 624), (540, 708)])
    b4.add_orthogonal_flow('p4_f11', 'P4_2', 'B', 0.5, 'P4_3', 'T', 0.5, 'Verified GCash Downpayment Receipt')
    b4.add_orthogonal_flow('p4_f12', 'P4_3', 'L', 0.5, 'p4_E2', 'R', 0.5, 'Incoming Reservation Notification & Driver ETA')
    b4.add_orthogonal_flow('p4_f13', 'P4_3', 'R', 0.75, 'p4_D4', 'L', 0.85, 'Active Reservation Record & 60-Min Timer')
    b4.add_orthogonal_flow('p4_f14', 'P4_3', 'B', 0.5, 'P4_4', 'T', 0.5, 'Confirmed Booking & 60-Min Arrival Deadline')
    b4.add_orthogonal_flow('p4_f15', 'p4_D4', 'B', 0.3, 'P4_4', 'R', 0.35, 'Check-In Status & 60-Min Expiry Timers', mids=[(1495, 1108)])
    b4.add_orthogonal_flow('p4_f16', 'P4_4', 'R', 0.75, 'p4_D4', 'B', 0.7, 'Auto-Cancel Expired Booking & Release Lock', mids=[(1595, 1140)])
    b4.add_orthogonal_flow('p4_f17', 'P4_3', 'B', 0.2, 'P4_5', 'T', 0.2, 'Approved Reservation Metadata', mids=[(808, 960), (620, 960), (620, 1250), (808, 1250)])
    b4.add_orthogonal_flow('p4_f18', 'P4_5', 'L', 0.5, 'p4_E1', 'L', 0.5, 'Booking Confirmation & Dynamic QR Digital Pass', mids=[(60, 1340), (60, 330)])
    b4.add_orthogonal_flow('p4_f19', 'P4_5', 'B', 0.5, 'p4_P5_ref', 'T', 0.5, 'Approved Reservation & Active QR Trigger')
    builders.append(b4)

    # =========================================================================
    # TAB 5: DECOMPOSITION OF PROCESS 5 (Validate Checkpoint QR Access & Scan)
    # 0 Overlaps, 0 Box Collisions, 0 Crossings
    # =========================================================================
    b5 = OrthogonalDFDBuilder(
        'lvl1-p5', 'Level 1 - Process 5 (QR Gate Scan)',
        'Level-1 Data Flow Diagram Decomposition of Process 5: Validate Checkpoint QR Access & Scan Gate',
        'Modules Covered: M06 (Dual-Factor HMAC-SHA256 QR Entry Pass), M12 (Optical Camera & Manual RES-# Fallback Checkpoint)',
        page_w=1900, page_h=1360
    )
    b5.add_process('p5_P4_ref', '4', 'Process Slot Reservation &\nConcurrency Lock', 720, 100, 240, 80, is_ref=True)
    b5.add_process('P5_1', '5.1', 'Sign & Issue Single-Use\nHMAC-SHA256 QR Entry Token', 720, 270, 240, 80)
    b5.add_process('P5_2', '5.2', 'Capture Optical Camera Scan\nor Manual RES-# Code Input', 720, 510, 240, 80)
    b5.add_process('P5_3', '5.3', 'Verify HMAC Cryptographic Hash\n& Match Vehicle Plate', 720, 750, 240, 80)
    b5.add_process('P5_4', '5.4', 'Record Park-In / Out Timestamp\n& Invalidate Single-Use Pass', 720, 990, 240, 80)
    b5.add_process('p5_P6_ref', '6', 'Compute Duration Billing\n& Settlement', 720, 1200, 240, 80, is_ref=True)

    b5.add_entity('p5_E1', 'Driver / Motorist', 140, 440, 180, 60)
    b5.add_entity('p5_E2', 'Parking Space Provider', 140, 580, 180, 60)

    b5.add_datastore('p5_D5', 'D5', 'QR Access Tokens &\nGate Telemetry Logs', 1360, 282, 250, 56)
    b5.add_datastore('p5_D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1360, 762, 250, 56)

    b5.add_orthogonal_flow('p5_f1', 'p5_P4_ref', 'B', 0.5, 'P5_1', 'T', 0.5, 'Approved Reservation & Active QR Trigger')
    b5.add_orthogonal_flow('p5_f2', 'P5_1', 'R', 0.5, 'p5_D5', 'L', 0.5, 'Signed Single-Use HMAC-SHA256 Token')
    b5.add_orthogonal_flow('p5_f3', 'p5_E1', 'R', 0.5, 'P5_2', 'L', 0.25, 'Present Dynamic QR Digital Pass at Gate', mids=[(520, 470), (520, 530)])
    b5.add_orthogonal_flow('p5_f4', 'p5_E2', 'R', 0.5, 'P5_2', 'L', 0.75, 'Optical Camera Scanner Feed / Manual RES-#', mids=[(520, 610), (520, 570)])
    b5.add_orthogonal_flow('p5_f5', 'P5_2', 'B', 0.5, 'P5_3', 'T', 0.5, 'Extracted Token Hash or Reservation ID')
    b5.add_orthogonal_flow('p5_f6', 'p5_D5', 'B', 0.3, 'P5_3', 'R', 0.25, 'HMAC-SHA256 Token Validation Key', mids=[(1435, 660), (1140, 660), (1140, 770)])
    b5.add_orthogonal_flow('p5_f7', 'p5_D4', 'L', 0.5, 'P5_3', 'R', 0.65, 'Active Reservation Record & Plate Number', mids=[(1140, 790), (1140, 802)])
    b5.add_orthogonal_flow('p5_f8', 'P5_3', 'B', 0.5, 'P5_4', 'T', 0.5, 'Verified Checkpoint Authorization')
    b5.add_orthogonal_flow('p5_f9', 'P5_4', 'R', 0.35, 'p5_D4', 'B', 0.5, 'Session State Update (Park-In / Park-Out)', mids=[(1485, 1018)])
    b5.add_orthogonal_flow('p5_f10', 'P5_4', 'R', 0.75, 'p5_D5', 'R', 0.5, 'Invalidated Single-Use Pass & Gate Telemetry', mids=[(1720, 1050), (1720, 310)])
    b5.add_orthogonal_flow('p5_f11', 'P5_4', 'L', 0.35, 'p5_E2', 'B', 0.5, 'Visual Access Indicator (Green Grant / Red Deny)', mids=[(230, 1018)])
    b5.add_orthogonal_flow('p5_f12', 'P5_4', 'L', 0.75, 'p5_E1', 'L', 0.5, 'Gate Clearance & Active Session Timer Display', mids=[(60, 1050), (60, 470)])
    b5.add_orthogonal_flow('p5_f13', 'P5_4', 'B', 0.5, 'p5_P6_ref', 'T', 0.5, 'Verified Exit Scan & Elapsed Session Trigger')
    builders.append(b5)

    # =========================================================================
    # TAB 6: DECOMPOSITION OF PROCESS 6 (Compute Duration Billing & Settlement)
    # 0 Overlaps, 0 Box Collisions, 0 Crossings
    # =========================================================================
    b6 = OrthogonalDFDBuilder(
        'lvl1-p6', 'Level 1 - Process 6 (Billing & Escrow)',
        'Level-1 Data Flow Diagram Decomposition of Process 6: Compute Duration Billing & Settlement',
        'Modules Covered: M05 (Duration Billing & 15-Min Grace Computation), M13 (GCash Settlement, Escrow & Provider Payouts)',
        page_w=1900, page_h=1250
    )
    b6.add_process('p6_P5_ref', '5', 'Validate Checkpoint QR\nAccess & Scan Gate', 720, 100, 240, 80, is_ref=True)
    b6.add_process('P6_1', '6.1', 'Compute Total Parked Duration\n& Apply 15-Min Grace Period', 720, 270, 240, 80)
    b6.add_process('P6_2', '6.2', 'Deduct 1-Hr Downpayment Credit\n& Generate Final Bill', 720, 510, 240, 80)
    b6.add_process('P6_3', '6.3', 'Process Final Balance via GCash\nWebhook or Cash Handshake', 720, 760, 240, 80)
    b6.add_process('P6_4', '6.4', 'Execute Platform Escrow Split\n& Dispatch Provider Payout', 720, 1020, 240, 80)

    b6.add_datastore('p6_D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 140, 390, 250, 56)
    b6.add_entity('p6_E1', 'Driver / Motorist', 140, 520, 180, 60)
    b6.add_entity('p6_E5', 'PayMongo Gateway\n(GCash E-Wallet)', 140, 770, 185, 60)
    b6.add_entity('p6_E2', 'Parking Space Provider', 140, 1030, 185, 60)

    b6.add_datastore('p6_D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1360, 282, 250, 56)

    b6.add_orthogonal_flow('p6_f1', 'p6_P5_ref', 'B', 0.5, 'P6_1', 'T', 0.5, 'Verified Exit Scan & Elapsed Session Trigger')
    b6.add_orthogonal_flow('p6_f2', 'p6_D4', 'L', 0.5, 'P6_1', 'R', 0.5, 'Validated Session Duration (Actual Park-In & Out)')
    b6.add_orthogonal_flow('p6_f3', 'P6_1', 'B', 0.5, 'P6_2', 'T', 0.5, 'Net Billable Hours & Applicable Overstay Fee')
    b6.add_orthogonal_flow('p6_f4', 'p6_D6', 'R', 0.5, 'P6_2', 'T', 0.2, 'Prepaid Downpayment Credit Balance', mids=[(768, 418)])
    b6.add_orthogonal_flow('p6_f5', 'P6_2', 'L', 0.5, 'p6_E1', 'R', 0.5, 'Itemized Final Billing Statement')
    b6.add_orthogonal_flow('p6_f6', 'P6_2', 'B', 0.5, 'P6_3', 'T', 0.5, 'Final Net Payable Balance Due')
    b6.add_orthogonal_flow('p6_f7', 'p6_E1', 'B', 0.5, 'P6_3', 'T', 0.2, 'Final Balance Settlement (Cash / GCash)', mids=[(230, 670), (768, 670)])
    b6.add_orthogonal_flow('p6_f8', 'P6_3', 'L', 0.3125, 'p6_E5', 'R', 0.25, 'Final Balance GCash Charge Request')
    b6.add_orthogonal_flow('p6_f9', 'p6_E5', 'R', 0.75, 'P6_3', 'L', 0.6875, 'GCash Final Settlement Webhook Confirmation')
    b6.add_orthogonal_flow('p6_f10', 'p6_E2', 'R', 0.25, 'P6_3', 'L', 0.85, 'Manual Cash Received Handshake (at Exit)', mids=[(560, 1045), (560, 828)])
    b6.add_orthogonal_flow('p6_f11', 'P6_3', 'R', 0.5, 'p6_D4', 'B', 0.5, 'Mark Session State as Settled / Closed', mids=[(1485, 800)])
    b6.add_orthogonal_flow('p6_f12', 'P6_3', 'B', 0.5, 'P6_4', 'T', 0.5, 'Confirmed Settlement Transaction Receipt')
    b6.add_orthogonal_flow('p6_f13', 'P6_4', 'B', 0.2, 'p6_E5', 'L', 0.5, 'Automated Provider Payout Webhook', mids=[(768, 1140), (70, 1140), (70, 800)])
    b6.add_orthogonal_flow('p6_f14', 'P6_4', 'B', 0.8, 'p6_D6', 'L', 0.5, 'Settlement Ledger Entry & Platform Escrow Split', mids=[(912, 1180), (30, 1180), (30, 418)])
    b6.add_orthogonal_flow('p6_f15', 'P6_4', 'L', 0.65, 'p6_E2', 'R', 0.7, 'Net Provider Earnings Breakdown & Payout Credit')
    builders.append(b6)

    # =========================================================================
    # TAB 7: DECOMPOSITION OF PROCESS 7 (Telemetry, Comms & Forensic Audit)
    # 0 Overlaps, 0 Box Collisions, 0 Crossings
    # =========================================================================
    b7 = OrthogonalDFDBuilder(
        'lvl1-p7', 'Level 1 - Process 7 (Comms & Audit)',
        'Level-1 Data Flow Diagram Decomposition of Process 7: Administer Telemetry, Comms & Forensic Audit',
        'Modules Covered: M07 (WebRTC Voice & Chat), M16 (Dispute Mediation), M17 (Security Telemetry), M18 (Heatmaps & Forensic Reports)',
        page_w=2050, page_h=1400
    )
    # Left Column: E1 (Driver) & E3 (System Administrator)
    b7.add_entity('p7_E1', 'Driver / Motorist', 140, 450, 180, 60)
    b7.add_entity('p7_E3', 'System Administrator', 140, 920, 180, 60)

    # Center Column: Sub-Processes 7.1 to 7.4
    b7.add_process('P7_1', '7.1', 'Broker Active-Session Bounded\nWebRTC Voice & Text Chat', 760, 110, 240, 100)
    b7.add_process('P7_2', '7.2', 'Ingest Gate Telemetry, Overstays\n& Security Infraction Tickets', 760, 430, 240, 100)
    b7.add_process('P7_3', '7.3', 'Mediate Financial Disputes &\nRecord Immutable Audit Logs', 760, 740, 240, 80)
    b7.add_process('P7_4', '7.4', 'Compile Occupancy Heatmaps &\nExport CSV/PDF Forensic Reports', 760, 1050, 240, 80)

    # Right Column: D4, E2 (Provider), D5, D1, D6 — 100% Planar (0 Crossings!)
    b7.add_datastore('p7_D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1420, 102, 250, 56)
    b7.add_entity('p7_E2', 'Parking Space Provider', 1420, 300, 180, 60)
    b7.add_datastore('p7_D5', 'D5', 'QR Access Tokens &\nGate Telemetry Logs', 1420, 482, 250, 56)
    b7.add_datastore('p7_D1', 'D1', 'Users & Driver Profiles Store', 1420, 660, 250, 56)
    b7.add_datastore('p7_D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 1420, 820, 250, 56)

    # D4 -> P7_1 (Straight horizontal at y=130)
    b7.add_orthogonal_flow('p7_f1', 'p7_D4', 'L', 0.5, 'P7_1', 'R', 0.2, 'Active Session Context (Locks Comms to Active Booking)')
    # E1 <-> P7_1 (Clean left-top nested elbows)
    b7.add_orthogonal_flow('p7_f2', 'p7_E1', 'T', 0.3, 'P7_1', 'L', 0.35, 'WebRTC Voice/Chat Audio Packets', mids=[(194, 145)])
    b7.add_orthogonal_flow('p7_f3', 'P7_1', 'L', 0.75, 'p7_E1', 'T', 0.7, 'Relayed WebRTC Audio/Chat Messages', mids=[(266, 185)])
    # E2 <-> P7_1 (Clean right-top nested elbows well below D4)
    b7.add_orthogonal_flow('p7_f4', 'p7_E2', 'T', 0.3, 'P7_1', 'R', 0.85, 'WebRTC Voice/Chat Audio Packets', mids=[(1474, 195)])
    b7.add_orthogonal_flow('p7_f5', 'P7_1', 'R', 0.65, 'p7_E2', 'T', 0.7, 'Relayed WebRTC Audio/Chat Messages', mids=[(1546, 175)])
    # E1 -> P7_2 (Straight horizontal at y=480)
    b7.add_orthogonal_flow('p7_f6', 'p7_E1', 'R', 0.5, 'P7_2', 'L', 0.5, 'Security Infraction Reports')
    # E2 -> P7_2 (Clean elbow from E2 bottom to P7_2 right-top well above D5)
    b7.add_orthogonal_flow('p7_f7', 'p7_E2', 'B', 0.5, 'P7_2', 'R', 0.2, 'Overstay & Unauthorized Parking Reports', mids=[(1510, 450)])
    # D5 -> P7_2 (Straight horizontal at y=510)
    b7.add_orthogonal_flow('p7_f8', 'p7_D5', 'L', 0.5, 'P7_2', 'R', 0.8, 'Gate Access Telemetry & Unauthorized Stay Logs')
    # P7_2 -> P7_3
    b7.add_orthogonal_flow('p7_f9', 'P7_2', 'B', 0.5, 'P7_3', 'T', 0.5, 'Escalated Incident & Overstay Evidence')
    # D1 & D6 <-> P7_3
    b7.add_orthogonal_flow('p7_f10', 'p7_D1', 'L', 0.5, 'P7_3', 'R', 0.25, 'User Profiles & Identity Verification Records', mids=[(1220, 688), (1220, 760)])
    b7.add_orthogonal_flow('p7_f11', 'p7_D6', 'L', 0.3, 'P7_3', 'R', 0.55, 'Financial Transaction Ledgers & Dispute Records', mids=[(1220, 837), (1220, 784)])
    b7.add_orthogonal_flow('p7_f12', 'P7_3', 'R', 0.85, 'p7_D6', 'L', 0.75, 'Dispute Resolutions & Immutable Audit Trails', mids=[(1160, 808), (1160, 862)])
    # E3 -> P7_3 & P7_3 -> E1
    b7.add_orthogonal_flow('p7_f13', 'p7_E3', 'T', 0.5, 'P7_3', 'L', 0.65, 'Dispute Mediation Actions & Refund Decisions', mids=[(230, 792)])
    b7.add_orthogonal_flow('p7_f14', 'P7_3', 'L', 0.25, 'p7_E1', 'B', 0.5, 'Dispute Status Updates', mids=[(230, 760)])
    # P7_3 -> P7_4
    b7.add_orthogonal_flow('p7_f15', 'P7_3', 'B', 0.5, 'P7_4', 'T', 0.5, 'Reconciled Financial & Audit Telemetry')
    # Concentric Outer-Right Loops: P7_4 -> E2 (inner x=1760 [330..1074]) inside D4 -> P7_4 (outer x=1840 [130..1106])
    b7.add_orthogonal_flow('p7_f16', 'p7_D4', 'R', 0.5, 'P7_4', 'R', 0.7, 'Historical Occupancy & Session Logs', mids=[(1840, 130), (1840, 1106)])
    b7.add_orthogonal_flow('p7_f17', 'P7_4', 'R', 0.3, 'p7_E2', 'R', 0.5, 'Facility Occupancy Heatmaps & Earnings Analytics', mids=[(1760, 1074), (1760, 330)])
    # E3 <-> P7_4
    b7.add_orthogonal_flow('p7_f18', 'p7_E3', 'R', 0.5, 'P7_4', 'L', 0.3, 'Forensic Audit Query & Filter Parameters', mids=[(500, 950), (500, 1074)])
    b7.add_orthogonal_flow('p7_f19', 'P7_4', 'L', 0.7, 'p7_E3', 'B', 0.5, 'System Analytics, Heatmaps & Forensic Reports (CSV/PDF)', mids=[(230, 1106)])
    builders.append(b7)

    # Audit every tab for zero overlaps, zero box collisions, and zero crossings
    total_issues = 0
    total_crossings = 0
    for b in builders:
        issues, crossings = b.audit_geometry(min_parallel_gap=12)
        total_issues += len(issues)
        total_crossings += len(crossings)
        print(f"[{b.tab_name}] Overlaps/Collisions={len(issues)}, Crossings={len(crossings)}")
        for iss in issues:
            print("   ISSUE:", iss)
        for cr in crossings:
            print("   CROSSING:", cr)
        b.to_xml(mxfile)

    print(f"\nLEVEL 1 GEOMETRY SUMMARY: Overlaps/Collisions={total_issues}, Crossings={total_crossings}")

    raw_xml = ET.tostring(mxfile, encoding='utf-8')
    parsed = minidom.parseString(raw_xml)
    pretty_xml = parsed.toprettyxml(indent="  ")

    output_path = r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_1.drawio"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(pretty_xml)

    artifact_dir = r"C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185"
    shutil.copyfile(output_path, os.path.join(artifact_dir, "e_parada_dfd_level_1.drawio"))

    escaped_xml = ET.tostring(mxfile, encoding='unicode').replace('&', '&amp;').replace('"', '&quot;').replace('<', '&lt;').replace('>', '&gt;')
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>E-Parada Level 1 DFD - Zero-Overlap Planar Layout</title>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; padding: 20px; background: #f3f4f6; }}
    .header {{ background: #fff; padding: 16px 24px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }}
    h1 {{ margin: 0 0 6px 0; font-size: 20px; color: #111827; }}
    p {{ margin: 0; color: #6b7280; font-size: 13px; }}
    .badge {{ background: #dcfce7; color: #166534; padding: 6px 14px; border-radius: 20px; font-size: 12px; font-weight: 600; }}
    .viewer-container {{ background: #fff; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.08); padding: 15px; overflow: auto; }}
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>E-Parada: Level 1 Data Flow Diagrams (Zero-Overlap & Zero-Crossing Planar Layout)</h1>
      <p>NU Laguna CPSOFT1L Standard | Use the built-in page tabs to switch between Process 1 through Process 7</p>
    </div>
    <span class="badge">7 Decomposed Tabs - 0 Overlaps - 0 Crossings - 0 Collisions</span>
  </div>
  <div class="viewer-container">
    <div class="mxgraph" style="max-width:100%;border:1px solid #e5e7eb;min-height:950px;" data-mxgraph="{{&quot;highlight&quot;:&quot;#0000ff&quot;,&quot;nav&quot;:true,&quot;resize&quot;:true,&quot;toolbar&quot;:&quot;pages zoom layers tags&quot;,&quot;edit&quot;:&quot;_blank&quot;,&quot;xml&quot;:&quot;{escaped_xml}&quot;}}"></div>
  </div>
  <script type="text/javascript" src="https://viewer.diagrams.net/js/viewer-static.min.js"></script>
</body>
</html>"""
    html_path = r"c:\Users\kimch\e_parada_mobile\e_parada_dfd_level_1.html"
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    shutil.copyfile(html_path, os.path.join(artifact_dir, "e_parada_dfd_level_1.html"))

if __name__ == '__main__':
    build_clean_level_1()
