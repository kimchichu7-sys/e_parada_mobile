# E-PARADA: LEVEL 0 DATA FLOW DIAGRAM (DFD) ARCHITECTURAL SPECIFICATION
**Department & Academic Standard:** National University – Laguna | School of Engineering & Architecture | CPSOFT1L / IEEE Software Design  
**Methodology & Notation:** Gane & Sarson Structured Analysis & Design (Top-Partitioned Process Boxes, Left-Partitioned Open-Ended Data Stores, Sharp Rectangular External Entities)  
**Page Orientation & Canvas:** Portrait (`1180 x 1310 px` — Single-Page Manuscript Fit)  
**Generated Files:**
- Editable Draw.io Diagram: [e_parada_dfd_level_0.drawio](file:///c:/Users/kimch/e_parada_mobile/e_parada_dfd_level_0.drawio)
- Interactive HTML Visualizer: [e_parada_dfd_level_0.html](file:///c:/Users/kimch/e_parada_mobile/e_parada_dfd_level_0.html)

---

## 1. Strict Gane & Sarson / IEEE Level 0 DFD Compliance Revisions

A **Level 0 Data Flow Diagram** is a high-level architectural model that expands the Context Diagram to show the **main functional processes** of the system, how they connect with **external entities**, and where persistent state is held in **data stores**. To strictly comply with Gane & Sarson and IEEE Structured Analysis standards, the specification and diagram were refined as follows:

1. **Elimination of Direct Process-to-Process Control Triggers:**
   - *Previous Issue:* Processes `3.0` $\rightarrow$ `4.0` $\rightarrow$ `5.0` $\rightarrow$ `6.0` had direct process-to-process trigger arrows (`Selected Available Slot`, `Active QR Trigger`, `Elapsed Session Trigger`), which behave like flowchart control arrows rather than asynchronous data flows.
   - *IEEE / Gane & Sarson Fix:* All 7 top-level processes now communicate strictly through **Persistent Data Stores (`D1`–`D6`)**. For example, Process `3.0` and `4.0` share `D2 (Parking Spaces & 2D Slots)`, Process `4.0` writes confirmed bookings to `D3 (Reservation Records)` which Process `5.0` reads for gate validation, and Process `5.0` logs session timestamps to `D4 (Active Parking Sessions)` which Process `6.0` reads for duration billing.
2. **Encapsulation of Internal SDKs/Libraries Within Processes:**
   - *Previous Issue:* Internal helper services (`Tesseract OCR Engine` and `Google Maps SDK`) were exposed at Level 0 as external entities, creating unnecessary low-level clutter.
   - *IEEE / Gane & Sarson Fix:* Internal OCR parsing and geospatial map calculation are encapsulated inside **Process `1.0`** and **Process `3.0`** at Level 0 (and decomposed at Levels 1 and 2). Only the **4 true external boundary actors/systems** (`DRIVER / END USER`, `PARKING SPACE PROVIDER`, `SYSTEM ADMINISTRATOR`, and `PAYMENT GATEWAY (GCash)`) appear at Level 0.
3. **High-Level Composite Data Flows (33 Flows vs. 64 Micro-Flows):**
   - Low-level request/response sub-packets have been consolidated into **33 high-level composite data flows** with zero redundant parallel wires.
4. **Portrait Single-Page Zero-Intersection Routing (`1180 x 1310 px`):**
   - Uses a single primary `DRIVER / END USER` entity on the left perimeter (connecting to 5 processes via nested Manhattan corridors) plus 1 strategic local alias on the lower-right for Process `5.0`, and a single primary `PARKING SPACE PROVIDER` entity on the right perimeter (connecting to 3 processes) plus 1 strategic local alias on the lower-left for Process `4.0`.
   - Mathematically verified: **0 Line Crossings, 0 Line Overlaps, 0 Box Cuts, and `jumpStyle=none`**.

---

## 2. External Entities Specification (4 Core Entities)

| Entity Name | Gane & Sarson Representation | Role & System Boundary Interaction |
| :--- | :--- | :--- |
| **`DRIVER / END USER`** | Main Box (Left Perimeter) + 1 Local Alias (Lower-Right) | Primary motorist registering vehicles, searching 2D floorplans, booking parking slots, presenting QR passes at checkpoints, settling bills, and submitting reviews/disputes. |
| **`PARKING SPACE PROVIDER`** | Main Box (Right Perimeter) + 1 Local Alias (Lower-Left) | Facility owner/operator onboarding parking properties, configuring 2D slots and rates, scanning driver QR passes at the gate, and receiving settled payouts. |
| **`SYSTEM ADMINISTRATOR`** | Single Box (Top-Center) | Governing platform authority verifying driver/provider KYC records, approving facility listings and rate ceilings, and issuing content moderation/audit directives. |
| **`PAYMENT GATEWAY (GCash)`** | Single Box (Bottom-Center) | External financial payment processor (PayMongo / GCash) handling digital checkout requests and returning asynchronous payment settlement webhooks. |

---

## 3. Persistent Data Stores Specification (6 Core Stores)

| Store ID | Data Store Name | Stored Schema & Functional Purpose |
| :---: | :--- | :--- |
| **`D1`** | **User & Vehicle Records** | Verified driver/provider profiles, role credentials, KYC verification statuses, and LTO OR/CR registered vehicle records. |
| **`D2`** | **Parking Spaces & 2D Slots** | Approved facility listings, 2D slot coordinate layouts, dimension clearances, hourly rates, and real-time slot occupancy states. |
| **`D3`** | **Reservation Records** | Confirmed slot bookings, pessimistic concurrency lock states, HMAC-SHA256 QR token signatures, and arrival validity windows. |
| **`D4`** | **Active Parking Sessions** | Validated gate check-in and check-out timestamps, active session timers, and completed parking durations. |
| **`D5`** | **Payment & Receipts** | Itemized digital receipts, downpayment credits, platform commission splits, and financial transaction ledgers. |
| **`D6`** | **Feedback & Audit Logs** | Driver star ratings, support/dispute tickets, WebRTC communication metadata, and immutable administrative audit trails. |

---

## 4. Core Functional Processes & 33 Data Flows (7 Processes)

### Process `1.0`: Manage User Registration & KYC Authentication
- **Purpose:** Authenticates users, processes driver/vehicle registration (including OCR plate/OR-CR extraction), and routes pending KYC profiles for administrative approval.
- **Data Flows:**
  1. `Registration, Credentials & OR/CR` (`DRIVER / END USER` $\rightarrow$ `1.0`)
  2. `Pending KYC & Vehicle Records` (`1.0` $\rightarrow$ `SYSTEM ADMINISTRATOR`)
  3. `Account KYC Approval Status` (`SYSTEM ADMINISTRATOR` $\rightarrow$ `1.0`)
  4. `Verified Driver & Vehicle Profile` (`1.0` $\rightarrow$ `D1: User & Vehicle Records`)
  5. `Authentication Token & KYC Notice` (`1.0` $\rightarrow$ `DRIVER / END USER`)

### Process `2.0`: Manage Parking Facilities & 2D Slot Layouts
- **Purpose:** Enables parking providers to onboard facilities and configure interactive 2D slot grids and pricing schedules subject to administrative approval.
- **Data Flows:**
  6. `Provider Profile & 2D Slot Setup` (`PARKING SPACE PROVIDER` $\rightarrow$ `2.0`)
  7. `Pending Facility & Slot Submission` (`2.0` $\rightarrow$ `SYSTEM ADMINISTRATOR`)
  8. `Facility & Rate Approval Decision` (`SYSTEM ADMINISTRATOR` $\rightarrow$ `2.0`)
  9. `Approved 2D Slot Layout & Rates` (`2.0` $\rightarrow$ `D2: Parking Spaces & 2D Slots`)
  10. `Verified Provider Profile Data` (`2.0` $\rightarrow$ `D1: User & Vehicle Records`)

### Process `3.0`: Search Available Parking & Navigate Routes
- **Purpose:** Processes driver location and vehicle filter queries, retrieves real-time 2D slot layouts and rates from `D2`, and returns interactive floorplans and navigation routes.
- **Data Flows:**
  15. `Location Search & 2D Map Query` (`DRIVER / END USER` $\rightarrow$ `3.0`)
  16. `Available 2D Floorplan & Route` (`3.0` $\rightarrow$ `DRIVER / END USER`)
  17. `Slot Layout, Rates & Occupancy` (`D2: Parking Spaces & 2D Slots` $\rightarrow$ `3.0`)

### Process `4.0`: Process Slot Reservations & Concurrency Locks
- **Purpose:** Validates slot availability and pricing rules from `D2`, locks selected slots against double-booking, records confirmed bookings in `D3`, issues HMAC QR passes to the driver, and alerts the provider.
- **Data Flows:**
  18. `Slot Availability & Rate Rules` (`D2: Parking Spaces & 2D Slots` $\rightarrow$ `4.0`)
  19. `Slot Selection & Booking Request` (`DRIVER / END USER` $\rightarrow$ `4.0`)
  20. `HMAC QR Code & Booking Pass` (`4.0` $\rightarrow$ `DRIVER / END USER`)
  21. `Reservation Alert & Driver ETA` (`4.0` $\rightarrow$ `PARKING SPACE PROVIDER`)
  22. `Confirmed Booking & Slot Lock` (`4.0` $\rightarrow$ `D3: Reservation Records`)

### Process `5.0`: Validate Checkpoint QR Access & Gate Sessions
- **Purpose:** Validates optical QR scans and fallback reservation codes at the facility checkpoint against `D3`, grants slot access to the driver, and logs park-in/park-out timestamps in `D4`.
- **Data Flows:**
  23. `Checkpoint QR Scan Data` (`PARKING SPACE PROVIDER` $\rightarrow$ `5.0`)
  24. `Reservation Validation Record` (`D3: Reservation Records` $\rightarrow$ `5.0`)
  25. `Access Granted & Slot Assignment` (`5.0` $\rightarrow$ `DRIVER / END USER`)
  26. `Check-In / Check-Out Timestamps` (`5.0` $\rightarrow$ `D4: Active Parking Sessions`)

### Process `6.0`: Compute Duration Billing & Payment Settlement
- **Purpose:** Computes net parking charges from completed session durations in `D4`, presents the itemized bill to the driver, processes e-wallet checkout via GCash, records digital receipts in `D5`, and notifies the provider of settled payouts.
- **Data Flows:**
  27. `Completed Session Duration` (`D4: Active Parking Sessions` $\rightarrow$ `6.0`)
  28. `Recorded Digital Receipt` (`6.0` $\rightarrow$ `D5: Payment & Receipts`)
  29. `Itemized Bill Statement` (`6.0` $\rightarrow$ `DRIVER / END USER`)
  30. `Payment Authorization & Method` (`DRIVER / END USER` $\rightarrow$ `6.0`)
  31. `Gateway Payment Request` (`6.0` $\rightarrow$ `PAYMENT GATEWAY (GCash)`)
  32. `Payment Settlement Webhook` (`PAYMENT GATEWAY (GCash)` $\rightarrow$ `6.0`)
  33. `Settled Payout Notification` (`6.0` $\rightarrow$ `PARKING SPACE PROVIDER`)

### Process `7.0`: Manage Comms, Feedback & System Reports
- **Purpose:** Handles driver ratings, disputes, and in-app communication logs, incorporates administrative moderation directives and financial totals from `D5`, and writes audit/feedback records to `D6`.
- **Data Flows:**
  11. `Review, Dispute & Comms Message` (`DRIVER / END USER` $\rightarrow$ `7.0`)
  12. `Moderation & Audit Directives` (`SYSTEM ADMINISTRATOR` $\rightarrow$ `7.0`)
  13. `Transaction Financial Totals` (`D5: Payment & Receipts` $\rightarrow$ `7.0`)
  14. `Review, Comms & Audit Records` (`7.0` $\rightarrow$ `D6: Feedback & Audit Logs`)
