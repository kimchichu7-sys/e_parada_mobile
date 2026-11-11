import sys
sys.path.append(r'c:\Users\kimch\e_parada_mobile')
import xml.etree.ElementTree as ET
from dfd_router_helper import OrthogonalDFDBuilder

def build_perfect_level_0():
    b0 = OrthogonalDFDBuilder(
        'level-0-dfd', 'Level 0 DFD',
        'Level 0 - Data Flow Diagram of the E-Parada Parking Marketplace System',
        'CPSOFT1L - Software Design Lab | Gane & Sarson Multi-Process Architecture (18 Modules Mapped - Zero Line Overlaps)',
        page_w=3400, page_h=2400
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
    # E3: System Administrator (Platform Governor - Bottom Right)
    b0.add_entity('E3', 'System Administrator', 1960, 1720, 220, 80)

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
    b0.add_process('P7', '7', 'Administer Telemetry, Comms\n& Forensic Audit', 1200, 1710, 240, 100)

    # ==========================================
    # 3. ADD DATA STORES (6 Total)
    # ==========================================
    b0.add_datastore('D1', 'D1', 'Users & Driver Profiles\nStore', 280, 440, 220, 60)
    b0.add_datastore('D2', 'D2', 'Registered Vehicles\nStore (LTO OR/CR)', 560, 440, 220, 60)
    b0.add_datastore('D3', 'D3', 'Parking Spaces & 2D Slots\nStore (Clearances & Layouts)', 1200, 440, 240, 60)
    b0.add_datastore('D4', 'D4', 'Reservations & Active Sessions\nStore (Locks & Timers)', 1200, 720, 240, 60)
    b0.add_datastore('D5', 'D5', 'QR Access Tokens &\nGate Telemetry Logs', 1200, 960, 240, 60)
    b0.add_datastore('D6', 'D6', 'Financials & Audit Trails\nStore (Ledger & Escrow)', 1200, 1260, 240, 60)

    return b0

if __name__ == '__main__':
    b0 = build_perfect_level_0()
    print("Boxes placed.")
    for b in b0.boxes:
        print(f"  {b['id']}: ({b['x']}, {b['y']}, {b['w']}, {b['h']})")
