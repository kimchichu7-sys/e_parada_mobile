# E-PARADA: LEVEL 2 DATA FLOW DIAGRAM (DFD) ARCHITECTURAL SPECIFICATION
**Department & Academic Standard:** National University – Laguna | School of Engineering & Architecture | CPSOFT1L / IEEE Software Design  
**Methodology & Notation:** Gane & Sarson Selective Decomposition (Single Unified Portrait Tab, **6 Elementary Subprocesses** — Fewest Processes Across All Levels, 28 Zero-Intersection Data Flows)  
**Page Orientation & Canvas:** Single-Tab Portrait (`1180 x 1160 px` — Single-Page Manuscript Fit)  
**Generated Files:**
- Editable Draw.io Diagram (1 Unified Tab): [e_parada_dfd_level_2.drawio](file:///c:/Users/kimch/e_parada_mobile/e_parada_dfd_level_2.drawio)
- Interactive HTML Visualizer: [e_parada_dfd_level_2.html](file:///c:/Users/kimch/e_parada_mobile/e_parada_dfd_level_2.html)

---

## 1. Why Level 2 Has the Fewest Processes (6 Elementary Subprocesses)

In strict **Gane & Sarson and IEEE Structured Analysis**, a **Level 2 DFD** does not re-decompose processes that already reached elementary module status at Level 1.
- Out of the **15 subprocesses on Level 1**, **12 are already 1-to-1 Elementary Modules** (`M01`, `M03`, `M04`, `M06`, `M07`, `M08`, `M09`, `M12`, `M13`, `M16`, `M17`, `M18`), so their decomposition terminates at Level 1.
- Only **3 Compound Processes on Level 1** (`1.1`, `2.3`, and `4.1`) encapsulate multiple modules and require Level 2 decomposition.
- Breaking each of those 3 compound processes into its 2 constituent modules yields **6 Elementary Subprocesses on Level 2** (`1.1.1 [M02]`, `1.1.2 [M14]`, `2.3.1 [M10]`, `2.3.2 [M15]`, `4.1.1 [M11]`, `4.1.2 [M05]`).
- Therefore:
  - **Level 1** has **15 Subprocesses**
  - **Level 0** has **7 Processes**
  - **Level 2** has **6 Subprocesses** (**the fewest processes of all three diagrams!**)
  - And the total count of elementary leaf processes across the DFD hierarchy is **$12 + 6 = 18\text{ System Modules (M01–M18)}$**.

---

## 2. Level 2 Elementary Subprocess Breakdown (6 Processes | 28 Flows)

### A. Decomposition of Level-1 Process `1.1` (*Register User & Vehicle KYC*)
1. **Subprocess `1.1.1`: Extract Vehicle Plate & OR/CR via OCR (`Module M02`)**
   - `f01`: `Vehicle Plate & OR/CR Image` (`DRIVER / END USER` $\rightarrow$ `1.1.1`)
   - `f02`: `Extracted Plate & OR/CR Record` (`1.1.1` $\rightarrow$ `D1: User & Vehicle Records`)
   - `f03`: `OCR Parsed Plate Confirmation` (`1.1.1` $\rightarrow$ `DRIVER / END USER`)
   - `f04`: `Pending KYC & Vehicle Dossier` (`1.1.1` $\rightarrow$ `D1: User & Vehicle Records`)
2. **Subprocess `1.1.2`: Verify Driver & Provider KYC Submissions (`Module M14`)**
   - `f05`: `Unverified Account & OR/CR Queue` (`D1: User & Vehicle Records` $\rightarrow$ `1.1.2`)
   - `f06`: `KYC Approval / Sanction Decision` (`SYSTEM ADMINISTRATOR` $\rightarrow$ `1.1.2`)
   - `f07`: `Verified KYC Status Summary` (`1.1.2` $\rightarrow$ `SYSTEM ADMINISTRATOR`)
   - `f08`: `Verified KYC Status Badge` (`1.1.2` $\rightarrow$ `DRIVER / END USER`)
   - `f09`: `KYC Verification Audit Trail` (`1.1.2` $\rightarrow$ `D6: Feedback & Audit Logs`)

### B. Decomposition of Level-1 Process `2.3` (*Manage Pricing & Rate Caps*)
3. **Subprocess `2.3.1`: Configure Dynamic Pricing & Grace Schedules (`Module M10`)**
   - `f10`: `Hourly Rates, Schedules & 15m Grace` (`PARKING SPACE PROVIDER` $\rightarrow$ `2.3.1`)
   - `f11`: `Operating Schedule & Grace Rules` (`2.3.1` $\rightarrow$ `D2: Parking Spaces & 2D Slots`)
   - `f12`: `Proposed Facility Rate Matrix` (`2.3.1` $\rightarrow$ `D2: Parking Spaces & 2D Slots`)
   - `f13`: `Rate Configuration Notice` (`2.3.1` $\rightarrow$ `PARKING SPACE PROVIDER`)
4. **Subprocess `2.3.2`: Enforce Municipal Price Ceiling Rules (`Module M15`)**
   - `f14`: `Proposed Facility Rate Matrix` (`D2: Parking Spaces & 2D Slots` $\rightarrow$ `2.3.2`)
   - `f15`: `Regional Price Ceiling Policy` (`SYSTEM ADMINISTRATOR` $\rightarrow$ `2.3.2`)
   - `f16`: `Enforced Rate & Ceiling Rules` (`2.3.2` $\rightarrow$ `D2: Parking Spaces & 2D Slots`)
   - `f17`: `Rate Ceiling Compliance Notice` (`2.3.2` $\rightarrow$ `PARKING SPACE PROVIDER`)

### C. Decomposition of Level-1 Process `4.1` (*Lock Slot & Schedule Booking*)
5. **Subprocess `4.1.1`: Acquire Pessimistic Slot Lock & 60m Timer (`Module M11`)**
   - `f18`: `Selected Slot ID & Vehicle Type` (`DRIVER / END USER` $\rightarrow$ `4.1.1`)
   - `f19`: `Slot Availability & Clearance Rules` (`D2: Parking Spaces & 2D Slots` $\rightarrow$ `4.1.1`)
   - `f20`: `60-Min Arrival Countdown Lock` (`4.1.1` $\rightarrow$ `DRIVER / END USER`)
   - `f21`: `Pessimistic Slot Lock & 60m Timer` (`4.1.1` $\rightarrow$ `D3: Reservation Records`)
6. **Subprocess `4.1.2`: Schedule Duration Booking & Fee Hold (`Module M05`)**
   - `f22`: `Locked Slot & 60m Hold Context` (`D3: Reservation Records` $\rightarrow$ `4.1.2`)
   - `f23`: `Booking Duration (1-12h) & Downpayment` (`DRIVER / END USER` $\rightarrow$ `4.1.2`)
   - `f24`: `Confirmed Duration Booking` (`4.1.2` $\rightarrow$ `D3: Reservation Records`)
   - `f25`: `Prepaid Downpayment Receipt` (`4.1.2` $\rightarrow$ `D5: Payment & Receipts`)
   - `f26`: `Downpayment Hold Request` (`4.1.2` $\rightarrow$ `PAYMENT GATEWAY (GCash)`)
   - `f27`: `Downpayment Settlement Webhook` (`PAYMENT GATEWAY (GCash)` $\rightarrow$ `4.1.2`)
   - `f28`: `Confirmed Booking & Slot Lock Notice` (`4.1.2` $\rightarrow$ `PARKING SPACE PROVIDER`)
