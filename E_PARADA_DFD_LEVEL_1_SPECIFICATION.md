# E-PARADA: LEVEL 1 DATA FLOW DIAGRAM (DFD) ARCHITECTURAL SPECIFICATION
**Department & Academic Standard:** National University – Laguna | School of Engineering & Architecture | CPSOFT1L / IEEE Software Design  
**Methodology & Notation:** Gane & Sarson Structured Analysis & Design (Single Unified Portrait Tab, 15 Subprocesses: 12 Elementary Modules + 3 Compound Processes, 6 Persistent Data Stores `D1`–`D6`, 4 External Entities)  
**Page Orientation & Canvas:** Single-Tab Portrait (`1240 x 1540 px` — Single-Page Manuscript Fit)  
**Generated Files:**
- Editable Draw.io Diagram (1 Unified Tab): [e_parada_dfd_level_1.drawio](file:///c:/Users/kimch/e_parada_mobile/e_parada_dfd_level_1.drawio)
- Interactive HTML Visualizer: [e_parada_dfd_level_1.html](file:///c:/Users/kimch/e_parada_mobile/e_parada_dfd_level_1.html)

---

## 1. How the 18 Modules Are Mapped Across Level 0, Level 1, and Level 2 (Why Level 2 Has the Least Processes)

In strict **Gane & Sarson / IEEE Top-Down Selective Decomposition**:
1. **Level 0 DFD (`7 Processes`):** Groups all 18 system modules into **7 High-Level Functional Domains (`1.0` to `7.0`)**.
2. **Level 1 DFD (`15 Subprocesses`):** Breaks the 7 functional domains down into **15 Subprocesses**:
   - **12 Elementary Module Processes** (`M01`, `M03`, `M04`, `M06`, `M07`, `M08`, `M09`, `M12`, `M13`, `M16`, `M17`, `M18`) are already fully specified at Level 1. Per IEEE / Gane & Sarson rules, **elementary processes do not decompose further**.
   - **3 Compound Processes** (`1.1`, `2.3`, `4.1`) encapsulate 2 modules each ($3 \times 2 = 6$ modules) and are marked for decomposition at Level 2.
3. **Level 2 DFD (`6 Elementary Subprocesses` — The Least Processes):** Decomposes **only** the 3 compound processes from Level 1 (`1.1` $\rightarrow$ `1.1.1 [M02]`, `1.1.2 [M14]`; `2.3` $\rightarrow$ `2.3.1 [M10]`, `2.3.2 [M15]`; `4.1` $\rightarrow$ `4.1.1 [M11]`, `4.1.2 [M05]`).
   - Thus, **Level 2 has the fewest processes (6 boxes)** compared to Level 0 (7 boxes) and Level 1 (15 boxes).
   - Across the hierarchy, the total number of elementary (leaf) processes is:
     $$\mathbf{12\text{ Elementary Modules (Level 1)} + 6\text{ Elementary Modules (Level 2)} = 18\text{ Total System Modules (M01–M18)}}$$

---

## 2. Master 18-Module Traceability Table Across Levels 0, 1, and 2

| Module ID & Name | Level 0 Domain (`7`) | Level 1 Subprocess (`15`) | Level 2 Elementary Subprocess (`6`) | Status |
| :--- | :--- | :--- | :--- | :--- |
| **M01: User Auth & RBAC** | `1.0` User Registration & KYC | **`1.2` Authenticate & Issue RBAC Token [M01]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M02: Vehicle Registration OCR** | `1.0` User Registration & KYC | `1.1` Register User & Vehicle KYC *(Compound)* | **`1.1.1` Extract Vehicle Plate & OR/CR via OCR [M02]** | **Elementary (L2)** |
| **M03: Geospatial Search Engine** | `3.0` Search & Route Navigation | **`3.1` Geospatial Search Engine [M03]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M04: Real-Time 2D Floor Plan** | `3.0` Search & Route Navigation | **`3.2` Render Real-Time 2D Floorplan [M04]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M05: Duration-Based Booking Engine** | `4.0` Slot Reservations & Locks | `4.1` Lock Slot & Schedule Booking *(Compound)* | **`4.1.2` Schedule Duration Booking & Fee Hold [M05]** | **Elementary (L2)** |
| **M06: Dual-Factor QR Code Pass** | `4.0` Slot Reservations & Locks | **`4.2` Issue Dual-Factor HMAC QR Pass [M06]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M07: Real-Time WebRTC Audio & Chat** | `7.0` Comms, Feedback & Reports | **`7.1` Real-Time WebRTC Audio & Chat [M07]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M08: Provider Property Onboarding** | `2.0` Facility & 2D Slot Layouts | **`2.1` Onboard Provider Property [M08]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M09: Interactive 2D Slot Config** | `2.0` Facility & 2D Slot Layouts | **`2.2` Configure 2D Slot Grid (x, z) [M09]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M10: Provider Dynamic Pricing** | `2.0` Facility & 2D Slot Layouts | `2.3` Manage Pricing & Rate Caps *(Compound)* | **`2.3.1` Configure Dynamic Pricing & Grace [M10]** | **Elementary (L2)** |
| **M11: Real-Time Concurrency Lock** | `4.0` Slot Reservations & Locks | `4.1` Lock Slot & Schedule Booking *(Compound)* | **`4.1.1` Acquire Pessimistic Slot Lock & 60m Timer [M11]** | **Elementary (L2)** |
| **M12: Optical Camera & RES-# QR Gate** | `5.0` Checkpoint QR & Gate | **`5.1` Optical Camera & RES-# QR Gate [M12]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M13: Financial Settlement & GCash** | `6.0` Duration Billing & Settlement | **`6.1` Duration Billing & GCash Escrow [M13]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M14: Admin Verification & KYC Console** | `1.0` User Registration & KYC | `1.1` Register User & Vehicle KYC *(Compound)* | **`1.1.2` Verify Driver & Provider KYC Submissions [M14]** | **Elementary (L2)** |
| **M15: Price Ceiling & Regional Governance** | `2.0` Facility & 2D Slot Layouts | `2.3` Manage Pricing & Rate Caps *(Compound)* | **`2.3.2` Enforce Municipal Price Ceiling Rules [M15]** | **Elementary (L2)** |
| **M16: Financial Audit & Dispute Mediation** | `7.0` Comms, Feedback & Reports | **`7.2` Financial Audit & Disputes [M16]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M17: Security Telemetry & Incident Center** | `7.0` Comms, Feedback & Reports | **`7.3` Security Telemetry & Incidents [M17]** | *(Elementary at Level 1)* | **Elementary (L1)** |
| **M18: Analytics, Heatmaps & Reporting** | `7.0` Comms, Feedback & Reports | **`7.4` Occupancy Heatmaps & Reports [M18]** | *(Elementary at Level 1)* | **Elementary (L1)** |
