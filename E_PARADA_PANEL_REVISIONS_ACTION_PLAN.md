# E-Parada: Comprehensive Panel Revisions & Action Plan
**Document Type:** Post-Defense Panel Critique & System Engineering Revision Guide  
**Project:** *E-Parada: A Digital Marketplace for Parking Spaces*  
**Proponents:** Bustria, Christian Jake C. | Gamad, Leticia C. | Ovilla, Shan Jenis C. | Valiña, Resha Lorraine P.  
**Institution:** College of Engineering and Architecture, National University (NU) Laguna  
**Date of Panel Evaluation:** October 26, 2026 | **Source Audio:** `E-Parada.m4a` (51 mins)  

---

## EXECUTIVE DIRECTIVE

During the 51-minute evaluation and live demonstration session (`E-Parada.m4a`), the thesis panel—led by Doctora and Sir—conducted an exhaustive audit of the E-Parada prototype. While the core concept and technical foundation were acknowledged, the panel issued **mandatory corrections** that must be executed across the **written manuscript** and the **working software system** before proceeding to Capstone 3 final defense.

Most critically, the panel **officially revised the respondent directive**: While IT Developers must still test technical code quality under ISO/IEC 25010, **actual human users (Drivers, Parking Space Providers, and Administrators) MUST evaluate the operational application** across a specified **3–10–10 sample distribution**.

This document is partitioned into two clear operational tracks:
* **PART 1: MANUSCRIPT & PAPER REVISIONS** (Chapter-by-chapter textual, methodological, and framework changes)
* **PART 2: SYSTEM & SOFTWARE ENGINEERING REVISIONS** (Backend logic, database schema, verification workflows, and mobile UI/UX overhaul)
* **PART 3: CAPSTONE 3 COMPLIANCE & VIDEO DOCUMENTATION PROTOCOL** (Mandatory defense requirements)

---

# PART 1: MANUSCRIPT & PAPER REVISIONS

---

### CHAPTER 1: THE PROBLEM AND ITS BACKGROUND

#### 1.1 Revision of Specific Objectives (Objective 3 Pivot)
* **Current Gap:** The paper previously stated that the developed system would be evaluated solely by IT developers.
* **Panel Directive:** The panel clarified that IT developers evaluate the *technical program*, while actual users evaluate the *application usability and acceptance*.
* **Required Revision:** Expand Specific Objective 3 into two distinct sub-objectives:
  > **Revised Objective 3:**  
  > 3a. **To test and evaluate the technical software product quality** of the E-Parada ecosystem through purposive testing by **IT Developers and Software Engineering Professionals** using the **ISO/IEC 25010:2011 Software Product Quality Model** in terms of *Functional Suitability*, *Performance Efficiency*, and *Reliability*.  
  > 3b. **To evaluate the user acceptance, usability, and operational suitability** of the mobile applications and web portal among key stakeholders in Calamba City, Laguna—specifically **Ten (10) Drivers/Motorists**, **Ten (10) Parking Space Providers**, and **Three (3) System Administrators**—measuring *Usability*, *User Error Protection*, *Learnability*, and *Operability*.

#### 1.2 Clarification of Scope: Payment Processing
* **Current Gap:** Cashless transactions were mistakenly listed under limitations or presented ambiguously during the defense.
* **Panel Directive:** The system explicitly supports both Cash and Cashless payments. It must not appear as a system limitation.
* **Required Revision:**
  * **In the Scope Section:** Explicitly declare: *"The system supports a dual-modality settlement framework consisting of: (1) Cashless payments processed via the PayMongo API v1 integrating GCash with automated webhook verification, and (2) On-site Cash settlement with a mutual confirmation handshake between the driver and parking space provider."*
  * **In the Limitations Section:** Remove any phrasing implying that cashless payment is an excluded feature. Only limit it to: *"Reliance on active internet connectivity and third-party payment gateway uptime (PayMongo/GCash) for real-time digital transaction settlement."*

#### 1.3 Scope Delimitation: Exclusion of Non-Registered Vehicles (E-Bikes & Bicycles)
* **Current Gap:** E-bikes and bicycles were informally mentioned, but they lack LTO registration, plate numbers, and driver's licenses.
* **Panel Directive:** Strike out e-bikes and bicycles completely. Focus strictly on legal, registered motor vehicles.
* **Required Revision:**
  * In the Scope & Limitations text, add an explicit clause: *"The system exclusively caters to motor vehicles officially registered with the Land Transportation Office (LTO)—specifically private cars, sedans, SUVs, passenger vans, pickup trucks, and motorcycles. Non-motorized bicycles, electric bicycles (e-bikes), and light mobility scooters are excluded due to the absence of standardized government plate numbers, registration certificates (OR/CR), and driver licensing requirements."*

#### 1.4 Inclusion of Downpayment & No-Show Cancellation Policy in System Scope
* **Panel Directive:** Address the physical risk of drivers booking a slot and failing to show up.
* **Required Revision:** Document the mandatory **1-Hour Downpayment Rule** and **1-Hour No-Show Cancellation Window** under the operational scope of the reservation subsystem.

---

### CHAPTER 2: REVIEW OF RELATED LITERATURE AND STUDIES

#### 2.1 Synthesis on Digital Document Verification & Anti-Theft Protocols
* **Required Addition:** Enhance the Chapter 2 Thematic Synthesis by citing literature on **digital document verification** and **anti-theft safeguards in sharing economy platforms**.
* **Key Context:** Note that while peer-to-peer sharing unlocks private resources, unverified asset onboarding exposes providers to stolen vehicle parking and illegal compound usage. Cite the necessity of validating government-issued **Certificate of Registration (CR)** and **Official Receipt (OR)** alongside physical license plate OCR.

#### 2.2 Literature on User Acceptance Models (TAM / ISO Hybrid)
* **Required Addition:** Include literature supporting dual-tier evaluations combining technical software engineering standards (ISO/IEC 25010) with user acceptance assessments across two-sided marketplace actors (providers vs. motorists).

---

### CHAPTER 3: METHODOLOGY

#### 3.1 Research Design: Dual-Tier Evaluation Framework
* **Current Gap:** Methodology only described IT developer evaluations.
* **Required Revision:** Restructure the descriptive evaluation design into two distinct evaluation panels:
  1. **Technical Software Engineering Evaluation:** Conducted by purposively sampled **IT developers** executing white-box/black-box stress tests, security validation, and ISO/IEC 25010 technical metrics.
  2. **Stakeholder Usability & Acceptance Evaluation:** Conducted by actual prospective end-users in Calamba City simulating real-world parking discovery, reservation, check-in, and billing.

#### 3.2 Participants and Sampling Technique (The 3–10–10 Distribution)
* **Panel Mandate:** The panel explicitly specified the respondent quota:
  * **Parking Space Providers:** Exactly **10 respondents** (owners of driveways, vacant commercial/residential lots in Calamba).
  * **Drivers / Motorists:** Exactly **10 respondents** (active vehicle owners/drivers navigating Calamba City).
  * **System Administrators:** Exactly **3 respondents** (administrative/facility personnel managing KYC and disputes).
  * **Total Stakeholder Evaluators:** **23 End-User Respondents** (plus the IT Developer panel).
* **Sampling Technique:** Purposive Sampling based on verified driver licensing, property custody, and system administrative roles.

#### 3.3 Instrumentation & Evaluation Tools
* **Required Revision:**
  * **Instrument A (IT Developers):** ISO/IEC 25010:2011 5-Point Likert Scale focused on *Functional Completeness, Performance Efficiency (latency/benchmarks), and Reliability (concurrency/error recovery)*.
  * **Instrument B (Drivers & Providers):** Usability & System Acceptability Questionnaire focused on *Learnability, Ease of Operation, Visual Aesthetics, Navigation Clarity, and User Error Protection*.
  * **Instrument C (Administrators):** Administrative Usability Questionnaire assessing *KYC document verification clarity, dispute audit efficiency, and listing governance*.

#### 3.4 Data Flow Diagrams (DFDs) & Activity Flow Updates
* **DFD Level-1 (Process 1.0 & 2.0):** Update data flows to show the intake of **Driver's License**, **Vehicle OR/CR**, and **Barangay Clearance** into Data Store `D1 (User & Vehicle Verification Store)` and `D2 (Parking Spaces Store)`.
* **DFD Level-1 (Process 3.0 & 5.0):** Add the **Downpayment Transaction** workflow that locks the slot upon payment verification before activating the entry QR code.

---

# PART 2: SYSTEM & SOFTWARE ENGINEERING REVISIONS

---

### 1. USER REGISTRATION & ROLE DIFFERENTIATION

#### A. Multi-Role User Profile Selection
* **Problem in Demo:** The app confusingly treated all users as just "driver" or "user", blurring the line between vehicle drivers and vehicle owners.
* **System Fix:** During registration and onboarding, allow users to explicitly specify their role:
  1. **Driver Only:** Transports vehicles; must submit a valid **Driver's License**.
  2. **Vehicle Owner Only:** Owns the vehicle but may have a designated driver; must submit **OR/CR + Government ID**.
  3. **Vehicle Owner & Driver (Both):** Owns and drives the vehicle; submits **both Driver's License and OR/CR**.
  4. **Parking Space Provider:** Offers parking spaces; routed to property onboarding.

#### B. Database Schema Update (`users` & `vehicles` tables)
```sql
-- Add explicit role flags and document tracking
ALTER TABLE users ADD COLUMN user_subtype VARCHAR(30) DEFAULT 'driver'; 
-- Values: 'driver', 'vehicle_owner', 'owner_driver', 'parking_provider'

ALTER TABLE vehicles ADD COLUMN or_cr_photo_url TEXT NULL;
ALTER TABLE vehicles ADD COLUMN registration_expiry DATE NULL;
ALTER TABLE vehicles ADD COLUMN is_owner_driving BOOLEAN DEFAULT TRUE;
```

---

### 2. RIGOROUS KYC & ASSET VERIFICATION WORKFLOWS

#### A. Vehicle Verification: OR/CR + Driver's License
* **Panel Critique:** *"Ano ang inyong verification aside from tingnan niyo lang yung plate number? How will you verify if itong sasakyan na to ay hindi nakaw?"*
* **System Fix:**
  1. **Driver Interface:** When registering a vehicle, the user must upload:
     * Photo of the vehicle (with license plate visible for Tesseract OCR).
     * Official LTO **Certificate of Registration (CR)**.
     * Official LTO **Official Receipt (OR)** (current year).
     * Valid **Driver's License**.
  2. **Admin Verification Portal:** The admin screen must display a **4-way comparison view**:
     * Extracted OCR Plate Text vs. License Plate Photo.
     * Plate Number & Vehicle Model on the uploaded OR/CR document.
     * Full Name on the Driver's License vs. Full Name on the User Account.
     * Admin action buttons: `[Approve Vehicle]` or `[Reject with Reason]`.

#### B. Parking Space Provider Verification: Barangay Clearance
* **Panel Critique:** *"Valid ID lang? Paano ive-verify na ako'y land owner talaga noon? Paano kung sabihin ko lang na akin yung bakanteng lote at ipa-renta ko?"*
* **System Fix:**
  1. **Mandatory Documents for Space Providers:**
     * **Valid Government ID** (with residential address).
     * **Barangay Clearance / Certificate of Parking Operation** issued by the local Calamba barangay where the space is located, explicitly certifying that the applicant has custody of the property.
     * *(Optional/Secondary upload):* Real Property Tax Declaration or Land Title (TCT).
  2. **Database Update (`parking_spaces` table):**
     ```sql
     ALTER TABLE parking_spaces ADD COLUMN barangay_clearance_url TEXT NOT NULL;
     ALTER TABLE parking_spaces ADD COLUMN tax_declaration_url TEXT NULL;
     ALTER TABLE parking_spaces ADD COLUMN verified_by_admin_id BIGINT NULL;
     ```

---

### 3. RESERVATION ENGINE & FINANCIAL WORKFLOWS

#### A. Mandatory 1-Hour Downpayment via GCash (PayMongo)
* **Panel Critique:** *"Paano pag no-show yung driver? Hindi dumating yung driver na nag-book?... Dapat pag nag-reserve siya, magbayad agad siya ng 1 hour downpayment."*
* **System Fix:**
  1. When a driver selects an available slot and requests a reservation, the status is set to `Pending_Downpayment`.
  2. The driver is prompted to pay an initial **1-hour downpayment** (e.g., ₱50.00) via PayMongo GCash.
  3. Upon PayMongo webhook confirmation, the reservation atomically transitions to `Approved` and the **Entry QR Code Pass** is unlocked and rendered.

#### B. 1-Hour No-Show Cancellation Rule
* **System Fix:**
  1. If the driver fails to scan the Entry QR code within **60 minutes after the scheduled reservation start time**, a background cron job automatically triggers:
     * Reservation status updates to `Cancelled_NoShow`.
     * The slot is immediately unlocked and returned to the public search pool.
     * The 1-hour downpayment is **forfeited by the driver and credited to the parking space provider's earnings**.
  2. A clear **Terms & Agreement Dialog** must be confirmed by the driver prior to checkout:
     > *"By proceeding, you agree to deposit a 1-hour non-refundable reservation fee. If you fail to arrive within 60 minutes of your scheduled time, your booking will be cancelled and the fee will be forfeited to the lot owner."*

#### C. Remaining Balance Settlement at Check-Out
* At physical exit, total billable duration is calculated ($	ext{time\_out} - 	ext{time\_in}$).
* The initial 1-hour downpayment is subtracted:
  $$	ext{Balance Due} = 	ext{Total Computed Bill} - 	ext{Downpayment Paid}$$
* The driver settles the remaining balance via **Cash (confirmed on-site by owner)** or **GCash (PayMongo webhook)**.

---

### 4. PARKING SPACE & SLOT CONFIGURATION

#### A. Batch Slot Creation ("Select All" Feature)
* **Panel Critique:** In the demo, adding 15 or 50 slots required manually clicking and setting vehicle types for every single slot. The panel noted: *"Dapat may 'Select All' or checkbox para hindi nakakapagod."*
* **System Fix:**
  * Add a **"Select All" master checkbox** at the top of the slot layout list.
  * Allow the provider to select all slots (or a multi-selected group) and apply:
    * Supported vehicle type (e.g., "Set all to Car/SUV" or "Set all to Motorcycle").
    * Base dimensions and clearance.
  * Greatly simplifies onboarding for spaces with 20+ slots.

---

### 5. COMMUNICATION & IN-APP CHAT WORKFLOWS

#### A. Restrict Chat/Call to Active Bookings Only
* **Panel Critique:** The panel noticed an active "Message Provider" button on past and cancelled bookings, which is unnecessary and confusing.
* **System Fix:**
  * Hide and disable the in-app chat and WebRTC call buttons if the reservation status is `Cancelled`, `Rejected`, or `Completed`.
  * Communication channels must strictly exist while the reservation is in `Approved` or `Checked-In` status.

---

### 6. FRONT-END MOBILE & WEB UI/UX OVERHAUL

The panel spent significant time critiquing the user experience. The following front-end changes are mandatory:

| UI/UX Issue Observed in Demo | Panel Critique | Required System Modification |
| :--- | :--- | :--- |
| **Monochromatic Blue Palette** | *"Puro blue, ang dumi tingnan... walang distinction."* | **Implement Functional Color-Coding:**<br>• **Green (`#10B981` / `#059669`):** Approve, Check-In, Pay Now, Success badges.<br>• **Red (`#EF4444` / `#DC2626`):** Cancel, Reject, Delete, Overstay alerts.<br>• **Amber (`#F59E0B`):** Pending review, Downpayment awaiting.<br>• **Neutral Slate (`#1E293B` / `#F8FAFC`):** Card containers and text. |
| **Tiny Font Sizes & Poor Readability** | *"Napakaliit ng text... paano kung matanda ang driver o owner? Hahabulin ng magnifying glass?"* | **Typography Overhaul:**<br>• Increase base mobile body text from 11sp–12sp to **14sp–16sp**.<br>• Set headers to **18sp–22sp Bold**.<br>• Increase button heights to a minimum of **48dp** (standard Android touch target accessibility). |
| **Screen Clutter on Active Dashboard** | *"Ang gulo... ang daming nakasulat na hindi maintindihan kung ano ang pipindutin."* | **Information Architecture Restructuring:**<br>• Separate **Active Sessions** from **History**.<br>• Move past/completed reservations to a dedicated **"Booking History" tab**.<br>• The main dashboard should ONLY display the currently active reservation card. |
| **Booking Cards Display Format** | Raw text dumped across the entire card. | **Adopt Cascading / Collapsible Cards:**<br>• Display parking spaces as clean summary cards (Name, Rate, Distance, Available Slots).<br>• Clicking a card smoothly expands (*cascading view*) to reveal 2D floor plans and operational rules. |

---

# PART 3: CAPSTONE 3 COMPLIANCE & DEFENSE PROTOCOL

The lead panelist delivered a strict warning regarding the upcoming final presentation for Capstone 3:

### 1. Mandatory On-Site Video Evidence
> 🎙️ **Lead Panelist:** *"Kumuha kayo ng VIDEO, hindi lang picture! Kailangan videohan ninyo na ginagamit nila yung system sa actual parking space. Pagbalik niyo sa Capstone 3 at walang video, papaulitin ko kayo ng defense!"*
* **Execution Plan:**
  * During the upcoming term break, visit actual parking facilities, driveways, or vacant commercial spaces in Calamba City.
  * Record continuous video clips showing:
    1. A parking provider configuring their lot and printing/accessing the QR validation screen.
    2. A driver searching for the location on Google Maps, booking a slot, and paying the downpayment.
    3. The driver arriving at the physical gate and the provider scanning the driver's QR code pass with their smartphone.
    4. Successful automated check-in and checkout billing.
  * Compile this into a polished 2-to-3 minute demo video for the final presentation.

### 2. Elimination of Fake / Sample Demo Data
* **Panel Critique:** Panelists noticed dummy names like "Rasha", placeholder images, and invalid license plate formats during the live demonstration.
* **Execution Plan:**
  * Wipe all dummy database records.
  * Seed the database with authentic, high-fidelity data:
    * Real registered Philippine vehicle models (Toyota Vios, Honda Click, Mitsubishi Xpander).
    * Realistic license plate images with valid LTO formats (`ABC-1234`).
    * Real Calamba City barangays (Parian, Halang, Real, Bucal, Canlubang).
    * Valid sample Driver's Licenses and Barangay Clearances for demonstration accounts.

### 3. Three-Device Live Demonstration Setup
* For Capstone 3, prepare and label three physical devices:
  * **Device 1 (Laptop / External Display):** System Administrator Web Portal (running live KYC audits and telemetry).
  * **Device 2 (Android Smartphone A):** Parking Space Provider Mobile App (demonstrating camera QR scanning).
  * **Device 3 (Android Smartphone B):** Driver Mobile App (demonstrating map browsing, slot selection, and QR pass generation).

---

# PART 4: SUMMARY COMPLIANCE CHECKLIST

| Item | Category | Specific Revision Task | Status |
| :---: | :--- | :--- | :---: |
| **1** | **Paper (Ch 1)** | Split Objective 3 into Technical Software Quality (IT Devs) and User Acceptance (End-Users) | ⏳ Pending |
| **2** | **Paper (Ch 1)** | Fix Scope to state Cash + Cashless support; remove cashless from limitations | ⏳ Pending |
| **3** | **Paper (Ch 1)** | Delimit vehicle scope: strictly LTO-registered motor vehicles; remove e-bikes/bicycles | ⏳ Pending |
| **4** | **Paper (Ch 3)** | Update sampling: 23 End-Users (10 Drivers, 10 Providers, 3 Admins) + IT Developer panel | ⏳ Pending |
| **5** | **Paper (Ch 3)** | Add user acceptance evaluation methodology and questionnaires (TAM/Usability) | ⏳ Pending |
| **6** | **System (Backend)** | Implement OR/CR and Driver's License upload and multi-way KYC verification in Admin | ✅ Completed |
| **7** | **System (Backend)** | Add Barangay Clearance requirement for Parking Space Provider verification | ✅ Completed |
| **8** | **System (Backend)** | Implement 1-Hour Downpayment (GCash PayMongo) + 1-Hour No-Show auto-cancellation logic | ✅ Completed |
| **9** | **System (Backend)** | Remove e-bike / bicycle options from database seeds and dropdowns | ✅ Completed |
| **10** | **System (Mobile)** | Add "Select All" / batch slot configuration checkbox in owner space editor | ✅ Completed |
| **11** | **System (Mobile)** | Disable/hide in-app chat and WebRTC call buttons for cancelled or rejected bookings | ✅ Completed |
| **12** | **System (Mobile)** | Overhaul UI colors: Green for Approve/Pay, Red for Cancel/Reject, distinct header cards | ✅ Completed |
| **13** | **System (Mobile)** | Enlarge typography (14sp–16sp body text) and touch targets (48dp minimum) | ✅ Completed |
| **14** | **System (Mobile)** | Move past bookings to a separate History tab; implement collapsible cascading cards | ✅ Completed |
| **15** | **Capstone 3 Prep**| Record high-definition on-site video testing at actual Calamba City parking locations | 🎬 Protocol Ready ([Guide](file:///c:/Users/kimch/e_parada_mobile/CAPSTONE_3_ON_SITE_VIDEO_PROTOCOL.md)) |
| **16** | **Capstone 3 Prep**| Purge placeholder test data; populate with realistic Philippine IDs and OR/CR records | ✅ Completed ([DatabaseSeeder.php](file:///c:/Users/kimch/e-parada/database/seeders/DatabaseSeeder.php)) |

---
*Prepared for the E-Parada Capstone Proponents | NU Laguna College of Engineering and Architecture*
