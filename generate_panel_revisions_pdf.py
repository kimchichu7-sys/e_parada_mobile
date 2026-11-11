import os
import subprocess
import shutil

WORKSPACE = r'c:\Users\kimch\e_parada_mobile'
ARTIFACT_DIR = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185'
MD_PATH = os.path.join(WORKSPACE, 'E_PARADA_PANEL_REVISIONS_ACTION_PLAN.md')
HTML_PATH = os.path.join(WORKSPACE, 'scratch', 'panel_revisions_print.html')
PDF_PATH = os.path.join(WORKSPACE, 'E_PARADA_PANEL_REVISIONS_ACTION_PLAN.pdf')
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
PYTHON = r'C:\Users\kimch\AppData\Local\Programs\Python\Python310\python.exe'

os.makedirs(os.path.join(WORKSPACE, 'scratch'), exist_ok=True)

md_content = """# E-Parada: Comprehensive Panel Revisions & Action Plan
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
* At physical exit, total billable duration is calculated ($\text{time\_out} - \text{time\_in}$).
* The initial 1-hour downpayment is subtracted:
  $$\text{Balance Due} = \text{Total Computed Bill} - \text{Downpayment Paid}$$
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
| **6** | **System (Backend)** | Implement OR/CR and Driver's License upload and multi-way KYC verification in Admin | ⏳ Pending |
| **7** | **System (Backend)** | Add Barangay Clearance requirement for Parking Space Provider verification | ⏳ Pending |
| **8** | **System (Backend)** | Implement 1-Hour Downpayment (GCash PayMongo) + 1-Hour No-Show auto-cancellation logic | ⏳ Pending |
| **9** | **System (Backend)** | Remove e-bike / bicycle options from database seeds and dropdowns | ⏳ Pending |
| **10** | **System (Mobile)** | Add "Select All" / batch slot configuration checkbox in owner space editor | ⏳ Pending |
| **11** | **System (Mobile)** | Disable/hide in-app chat and WebRTC call buttons for cancelled or rejected bookings | ⏳ Pending |
| **12** | **System (Mobile)** | Overhaul UI colors: Green for Approve/Pay, Red for Cancel/Reject, distinct header cards | ⏳ Pending |
| **13** | **System (Mobile)** | Enlarge typography (14sp–16sp body text) and touch targets (48dp minimum) | ⏳ Pending |
| **14** | **System (Mobile)** | Move past bookings to a separate History tab; implement collapsible cascading cards | ⏳ Pending |
| **15** | **Capstone 3 Prep**| Record high-definition on-site video testing at actual Calamba City parking locations | ⏳ Pending |
| **16** | **Capstone 3 Prep**| Purge placeholder test data; populate with realistic Philippine IDs and OR/CR records | ⏳ Pending |

---
*Prepared for the E-Parada Capstone Proponents | NU Laguna College of Engineering and Architecture*
"""

with open(MD_PATH, 'w', encoding='utf-8') as f:
    f.write(md_content)
shutil.copy(MD_PATH, os.path.join(ARTIFACT_DIR, 'E_PARADA_PANEL_REVISIONS_ACTION_PLAN.md'))
print("Wrote Markdown Action Plan!")

# Now build the styled HTML for PDF printing
HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>E-Parada: Comprehensive Panel Revisions & Action Plan</title>
<style>
  @page {
    size: letter;
    margin: 0.55in 0.6in 0.6in 0.6in;
  }
  * {
    box-sizing: border-box;
  }
  body {
    font-family: "Segoe UI", -apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, sans-serif;
    font-size: 9.8pt;
    line-height: 1.48;
    color: #0F172A;
    margin: 0;
    padding: 0;
  }
  .cover-banner {
    background: linear-gradient(135deg, #0F172A 0%, #1E1B4B 50%, #312E81 100%);
    color: #FFFFFF;
    padding: 20px 24px;
    border-radius: 8px;
    margin-bottom: 18px;
    border-left: 6px solid #4F46E5;
  }
  .cover-banner h1 {
    margin: 0 0 6px 0;
    font-size: 16.5pt;
    font-weight: 800;
    letter-spacing: -0.3px;
  }
  .cover-banner p {
    margin: 2px 0;
    font-size: 9.5pt;
    color: #E0E7FF;
  }
  .badge-row {
    margin-top: 10px;
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }
  .badge {
    background: rgba(255, 255, 255, 0.15);
    border: 1px solid rgba(255, 255, 255, 0.3);
    color: #FFFFFF;
    padding: 3px 10px;
    border-radius: 999px;
    font-size: 8.5pt;
    font-weight: 600;
  }
  .badge-alert {
    background: rgba(239, 68, 68, 0.3);
    border: 1px solid #EF4444;
    color: #FEE2E2;
  }

  .part-banner {
    background-color: #1E1B4B;
    color: #FFFFFF;
    padding: 8px 16px;
    font-size: 12pt;
    font-weight: 700;
    border-radius: 6px;
    margin-top: 18px;
    margin-bottom: 12px;
    letter-spacing: 0.4px;
    page-break-after: avoid;
    border-left: 4px solid #6366F1;
  }

  .card {
    border: 1.5px solid #CBD5E1;
    border-radius: 6px;
    padding: 12px 16px;
    margin-bottom: 14px;
    background: #FFFFFF;
    page-break-inside: avoid;
  }
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1.5px solid #E2E8F0;
    padding-bottom: 5px;
    margin-bottom: 8px;
  }
  .card-title {
    font-size: 11pt;
    font-weight: 700;
    color: #1E1B4B;
  }
  .card-tag {
    font-size: 8pt;
    font-weight: 700;
    padding: 2px 8px;
    border-radius: 4px;
    text-transform: uppercase;
  }
  .tag-paper {
    background: #EEF2FF;
    color: #4338CA;
    border: 1px solid #C7D2FE;
  }
  .tag-system {
    background: #ECFDF5;
    color: #065F46;
    border: 1px solid #A7F3D0;
  }
  .tag-ui {
    background: #FFFBEB;
    color: #92400E;
    border: 1px solid #FDE68A;
  }
  .tag-alert {
    background: #FEF2F2;
    color: #991B1B;
    border: 1px solid #FECACA;
  }

  h3 {
    color: #1E1B4B;
    font-size: 10.8pt;
    margin: 12px 0 6px 0;
  }
  h4 {
    color: #312E81;
    font-size: 10pt;
    margin: 8px 0 4px 0;
  }
  p {
    margin: 4px 0 6px 0;
  }
  ul, ol {
    margin: 4px 0 8px 0;
    padding-left: 20px;
  }
  li {
    margin-bottom: 3.5px;
  }

  blockquote {
    background-color: #F8FAFC;
    border-left: 3.5px solid #6366F1;
    padding: 6px 12px;
    margin: 6px 0 10px 0;
    border-radius: 0 4px 4px 0;
    font-size: 9pt;
    color: #334155;
    font-style: italic;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin: 8px 0 12px 0;
    font-size: 8.8pt;
  }
  th, td {
    border: 1px solid #CBD5E1;
    padding: 5px 7px;
    text-align: left;
    vertical-align: top;
  }
  th {
    background-color: #F1F5F9;
    color: #0F172A;
    font-weight: 700;
  }
  tr:nth-child(even) td {
    background-color: #F8FAFC;
  }

  code {
    background: #EEF2FF;
    color: #3730A3;
    padding: 1px 4px;
    border-radius: 3px;
    font-size: 9pt;
    font-family: Consolas, monospace;
  }
  pre {
    background: #0F172A;
    color: #E2E8F0;
    padding: 8px 12px;
    border-radius: 5px;
    font-size: 8.5pt;
    overflow-x: auto;
    margin: 6px 0;
    font-family: Consolas, monospace;
  }
  .page-break {
    page-break-before: always;
  }
</style>
</head>
<body>

<div class="cover-banner">
  <h1>E-Parada: Post-Defense Panel Revisions &amp; Action Plan</h1>
  <p><b>Comprehensive Roadmap for Paper Revisions, Backend Engineering, &amp; UI/UX Overhaul</b></p>
  <p><b>College of Engineering and Architecture — National University (NU) Laguna</b></p>
  <p><b>Proponents:</b> Bustria, Christian Jake C. &bull; Gamad, Leticia C. &bull; Ovilla, Shan Jenis C. &bull; Valiña, Resha Lorraine P.</p>
  <div class="badge-row">
    <span class="badge badge-alert">🚨 Evaluation Respondent Pivot (3–10–10 Rule)</span>
    <span class="badge">✔ Two-Factor Vehicle KYC (OR/CR + License)</span>
    <span class="badge">✔ Provider Barangay Clearance</span>
    <span class="badge">✔ 1-Hour Downpayment &amp; No-Show Clause</span>
    <span class="badge">✔ Color-Coded UI Overhaul</span>
    <span class="badge">✔ Mandatory On-Site Video Testing</span>
  </div>
</div>

<!-- ===================================================================== -->
<!-- PART 1: MANUSCRIPT & PAPER REVISIONS                                  -->
<!-- ===================================================================== -->
<div class="part-banner">PART 1: MANUSCRIPT &amp; PAPER REVISIONS (By Chapter &amp; Section)</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">1. Chapter 1: Specific Objectives Revision (The Respondent Pivot)</span>
    <span class="card-tag tag-paper">Chapter 1</span>
  </div>
  <p><b>The Problem:</b> The paper previously stated that only IT developers would evaluate the system. The panel strictly corrected this: IT developers evaluate technical code and architectural quality, but <b>actual stakeholders must evaluate the operational application</b>.</p>
  <blockquote>"Ang IT developer, ite-test lang po niya is yung technical ng program... pero yung APPLICATION mismo, dapat USERS ang magte-test niyan! User acceptance / user evaluation!" — Thesis Panel</blockquote>
  <h4>Required Textual Revision for Specific Objective 3:</h4>
  <ul>
    <li><b>Objective 3a (Technical Software Quality):</b> To test and evaluate the technical software product quality of the E-Parada ecosystem through purposive testing by <b>IT Developers and Software Engineering Professionals</b> using the <b>ISO/IEC 25010:2011 Software Product Quality Model</b> in terms of <i>Functional Suitability</i>, <i>Performance Efficiency</i>, and <i>Reliability</i>.</li>
    <li><b>Objective 3b (User Acceptance &amp; Usability):</b> To evaluate the user acceptance, usability, and operational suitability of the mobile applications and web portal among key stakeholders in Calamba City, Laguna—specifically <b>Ten (10) Drivers/Motorists</b>, <b>Ten (10) Parking Space Providers</b>, and <b>Three (3) System Administrators</b>—measuring <i>Usability</i>, <i>User Error Protection</i>, <i>Learnability</i>, and <i>Operability</i>.</li>
  </ul>
</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">2. Chapter 1: Scope &amp; Limitations Alignment</span>
    <span class="card-tag tag-paper">Chapter 1</span>
  </div>
  <ul>
    <li><b>Payment Processing Modality:</b> Correct any ambiguity regarding cashless payments. State explicitly in Scope that E-Parada implements a dual-modality settlement framework: (1) Cashless payments via <b>PayMongo API v1 integrating GCash</b> with automated webhook verification, and (2) On-site <b>Cash settlement</b> with mutual confirmation handshakes. In Limitations, clarify that cashless payment is fully supported but dependent on third-party gateway uptime and active data connectivity.</li>
    <li><b>Exclusion of E-Bikes and Bicycles:</b> Explicitly delimit in Chapter 1 that the platform strictly caters to <b>LTO-registered motor vehicles</b> (Cars, Sedans, SUVs, Vans, Pickups, and Motorcycles). Bicycles, e-bikes, and light electric scooters are excluded due to the lack of government plate numbers, registration certificates (OR/CR), and licensing requirements.</li>
    <li><b>Downpayment &amp; No-Show Policy:</b> Document the operational policy requiring an initial 1-hour downpayment upon reservation to protect parking owners from no-show cancellations.</li>
  </ul>
</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">3. Chapter 3: Methodology &amp; Sampling Design (The 3–10–10 Rule)</span>
    <span class="card-tag tag-paper">Chapter 3</span>
  </div>
  <h4>Dual-Tier Evaluation Design:</h4>
  <table>
    <thead>
      <tr>
        <th style="width:25%;">Evaluation Tier</th>
        <th style="width:25%;">Target Evaluators</th>
        <th style="width:25%;">Evaluation Instrument</th>
        <th style="width:25%;">Core Characteristics</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>Tier 1: Technical Software Quality</b></td>
        <td><b>Purposively Selected IT Developers</b> (Software Engineers)</td>
        <td>ISO/IEC 25010:2011 Evaluation Instrument &amp; Automated Stress Harness</td>
        <td>Functional Suitability, Performance Efficiency, Reliability, ACID Locking (<code>FOR UPDATE</code>).</td>
      </tr>
      <tr>
        <td><b>Tier 2: User Acceptance &amp; Usability</b></td>
        <td><b>23 Stakeholder Respondents:</b><br>&bull; 10 Drivers / Motorists<br>&bull; 10 Parking Space Providers<br>&bull; 3 System Administrators</td>
        <td>Usability &amp; System Acceptance Questionnaire (5-Point Likert Scale)</td>
        <td>Recognizability, Learnability, Operability, User Error Protection, UI Aesthetics.</td>
      </tr>
    </tbody>
  </table>
  <p><b>Sampling Technique:</b> Purposive Sampling based on verified driver licensing, parking property ownership/custody, and institutional administration credentials in Calamba City, Laguna.</p>
</div>

<div class="page-break"></div>

<!-- ===================================================================== -->
<!-- PART 2: SYSTEM & SOFTWARE ENGINEERING REVISIONS                       -->
<!-- ===================================================================== -->
<div class="part-banner">PART 2: SYSTEM &amp; SOFTWARE ENGINEERING REVISIONS</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">1. User Roles &amp; Vehicle Ownership Differentiation</span>
    <span class="card-tag tag-system">Backend / Database</span>
  </div>
  <p><b>Problem Identified by Panel:</b> The app assumed the driver is always the vehicle owner. What if someone drives a family car or company vehicle?</p>
  <ul>
    <li><b>Registration Options:</b> Allow users to register as:
      <ol>
        <li><b>Driver Only:</b> Submits a valid <b>Driver's License</b>.</li>
        <li><b>Vehicle Owner Only:</b> Submits Government ID + <b>OR/CR in their name</b>.</li>
        <li><b>Owner &amp; Driver (Both):</b> Submits both Driver's License and OR/CR.</li>
        <li><b>Parking Space Provider:</b> Routes to property onboarding.</li>
      </ol>
    </li>
  </ul>
</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">2. Two-Factor Vehicle &amp; Space KYC Verification</span>
    <span class="card-tag tag-system">Security &amp; Verification</span>
  </div>
  <blockquote>"Paano ive-verify kung hindi nakaw? Baka nakapark doon nakaw pala, demandahan pa yung may-ari nung parking!... Hindi pwedeng Valid ID lang sa provider, laging dalawa ang verification!" — Thesis Panel</blockquote>
  <ul>
    <li><b>Vehicle Registration KYC:</b> Drivers must upload:
      <ol>
        <li>Vehicle photo with visible license plate (for <b>Tesseract OCR</b> plate extraction).</li>
        <li>Official <b>Certificate of Registration (CR)</b> issued by the LTO.</li>
        <li>Current-year <b>Official Receipt (OR)</b> issued by the LTO.</li>
        <li>Valid <b>Driver's License</b>.</li>
      </ol>
    </li>
    <li><b>Parking Space Provider KYC:</b> Providers must upload:
      <ol>
        <li>Valid Government ID (with matching home address).</li>
        <li><b>Barangay Clearance / Certificate of Parking Operation</b> issued by the local Calamba barangay explicitly authorizing parking operations at that specific address.</li>
        <li><i>(Optional upload slot):</i> Real Property Tax Declaration or Land Title (TCT).</li>
      </ol>
    </li>
    <li><b>Admin Portal Review Interface:</b> Provide side-by-side verification tabs allowing administrators to inspect the vehicle photo, OCR plate, OR/CR document, and license before issuing approval.</li>
  </ul>
</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">3. 1-Hour Downpayment &amp; 1-Hour No-Show Cancellation Logic</span>
    <span class="card-tag tag-system">Reservation &amp; Billing</span>
  </div>
  <p><b>Problem:</b> Drivers who book a slot and never show up tie up the space and cause revenue loss for the provider.</p>
  <ul>
    <li><b>Mandatory 1-Hour Downpayment:</b> When reserving, the driver must immediately pay a downpayment equal to <b>1 hour of parking</b> (e.g., ₱50 via GCash PayMongo).</li>
    <li><b>Automated 60-Minute No-Show Cancellation:</b> If the driver fails to arrive and scan the entry QR code within <b>60 minutes of the scheduled start time</b>:
      <ul>
        <li>The reservation is automatically cancelled (<code>Cancelled_NoShow</code>).</li>
        <li>The slot is immediately returned to the available inventory.</li>
        <li>The 1-hour downpayment is <b>forfeited by the driver and credited to the parking owner</b> as compensation.</li>
      </ul>
    </li>
    <li><b>Remaining Balance Settlement:</b> At exit, total duration is calculated: $\text{Balance Due} = \text{Total Computed Bill} - \text{Downpayment Paid}$, payable via Cash or GCash.</li>
  </ul>
</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">4. Space Management: Batch Slot Configuration ("Select All")</span>
    <span class="card-tag tag-system">Provider Portal</span>
  </div>
  <p><b>Problem:</b> Adding 15, 50, or 100 slots one by one is exhausting and impractical for providers.</p>
  <ul>
    <li>Implement a <b>"Select All" / Checkbox feature</b> in the parking slot editor.</li>
    <li>Allows providers to batch-assign vehicle types (e.g., set all to "Car/Sedan" or "SUV"), dimensions, and clearance with one click.</li>
  </ul>
</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">5. Communication Rules: Deactivate Chat on Inactive Bookings</span>
    <span class="card-tag tag-system">WebRTC &amp; Chat</span>
  </div>
  <ul>
    <li>Hide and deactivate the in-app chat and WebRTC call buttons if the reservation is <b>Cancelled</b>, <b>Rejected</b>, or <b>Completed</b>. Communication is strictly reservation-bound.</li>
  </ul>
</div>

<div class="page-break"></div>

<div class="card">
  <div class="card-header">
    <span class="card-title">6. Front-End Mobile &amp; Web UI/UX Overhaul</span>
    <span class="card-tag tag-ui">Mobile UI / UX</span>
  </div>
  <p>The panel strongly criticized the visual clutter, tiny text, and monochromatic color scheme in the demo:</p>
  <table>
    <thead>
      <tr>
        <th style="width:25%;">UI / UX Dimension</th>
        <th style="width:35%;">Panel Observation</th>
        <th style="width:40%;">Required Technical Implementation</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>Functional Color-Coding</b></td>
        <td><i>"Puro blue, ang dumi tingnan... walang distinction."</i></td>
        <td>• <b>Green buttons:</b> Approve, Confirm, Pay Now.<br>• <b>Red buttons:</b> Cancel, Reject, Delete, Overstay alert.<br>• <b>Neutral slate/white:</b> Card containers and headers.</td>
      </tr>
      <tr>
        <td><b>Typography &amp; Readability</b></td>
        <td><i>"Napakaliit ng text... paano kung matanda ang driver o owner? Hahabulin ng magnifying glass?"</i></td>
        <td>• Enlarge base body text from 11sp to <b>14sp–16sp</b>.<br>• Headers set to <b>18sp–22sp Bold</b>.<br>• Minimum touch target height of <b>48dp</b> on all buttons.</td>
      </tr>
      <tr>
        <td><b>Screen Clutter &amp; Architecture</b></td>
        <td><i>"Ang gulo... ang daming nakasulat na hindi maintindihan kung ano ang pipindutin."</i></td>
        <td>• <b>Separate History Tab:</b> Move past/cancelled bookings to a dedicated History screen.<br>• Main screen displays ONLY the currently active reservation card.</td>
      </tr>
      <tr>
        <td><b>Card Presentation</b></td>
        <td>Raw text dumped across the entire screen.</td>
        <td>• <b>Cascading / Collapsible Cards:</b> Clean summary cards that smoothly expand when clicked to reveal details and 2D floor plans.</td>
      </tr>
    </tbody>
  </table>
</div>

<!-- ===================================================================== -->
<!-- PART 3: CAPSTONE 3 COMPLIANCE & DEFENSE PROTOCOL                      -->
<!-- ===================================================================== -->
<div class="part-banner">PART 3: CAPSTONE 3 COMPLIANCE &amp; DEFENSE PROTOCOL</div>

<div class="card">
  <div class="card-header">
    <span class="card-title">Mandatory Requirements for Capstone 3 Final Defense</span>
    <span class="card-tag tag-alert">Critical Mandate</span>
  </div>
  <blockquote>"Kumuha kayo ng VIDEO, hindi lang picture! Kailangan videohan ninyo na ginagamit nila yung system sa actual parking space. Pagbalik niyo sa Capstone 3 at walang video, papaulitin ko kayo ng defense!" — Lead Panelist</blockquote>
  <ol>
    <li><b>On-Site Video Documentation:</b>
      <ul>
        <li>During the term break, visit actual parking lots/driveways in Calamba City.</li>
        <li>Record high-definition video of real drivers and real lot owners conducting live reservations, QR code gate scans, and checkout billing.</li>
        <li>Produce a 2–3 minute video presentation reel for the final defense.</li>
      </ul>
    </li>
    <li><b>Elimination of Dummy Demo Data:</b>
      <ul>
        <li>Purge placeholder names (like "Rasha"), generic text, and sample images.</li>
        <li>Populate the database with authentic Philippine vehicle models, realistic plate photos (`ABC-1234`), genuine Calamba street addresses, and real sample OR/CR and Driver's Licenses.</li>
      </ul>
    </li>
    <li><b>Three-Device Live Demonstration Setup:</b>
      <ul>
        <li><b>Device 1 (Web / Laptop):</b> System Administrator Portal (live KYC audits and telemetry).</li>
        <li><b>Device 2 (Android Phone A):</b> Parking Space Provider App (camera QR scanner and slot manager).</li>
        <li><b>Device 3 (Android Phone B):</b> Driver Mobile App (interactive map search, slot booking, and QR pass viewer).</li>
      </ul>
    </li>
  </ol>
</div>

<!-- ===================================================================== -->
<!-- PART 4: SUMMARY COMPLIANCE MATRIX                                     -->
<!-- ===================================================================== -->
<div class="part-banner">PART 4: SUMMARY COMPLIANCE CHECKLIST</div>

<table>
  <thead>
    <tr>
      <th style="width:8%;">Item</th>
      <th style="width:18%;">Category</th>
      <th style="width:58%;">Specific Action Item</th>
      <th style="width:16%;">Target Scope</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:center;"><b>1</b></td>
      <td><b>Paper (Ch 1)</b></td>
      <td>Split Specific Objective 3 into Technical Software Quality (IT Devs) &amp; User Usability (End-Users).</td>
      <td>Manuscript</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>2</b></td>
      <td><b>Paper (Ch 1)</b></td>
      <td>Explicitly state Cash + Cashless support in Scope; remove cashless from limitations.</td>
      <td>Manuscript</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>3</b></td>
      <td><b>Paper (Ch 1)</b></td>
      <td>Delimit vehicle scope: strictly LTO-registered motor vehicles; remove e-bikes and bicycles.</td>
      <td>Manuscript</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>4</b></td>
      <td><b>Paper (Ch 3)</b></td>
      <td>Adopt the <b>3–10–10 Rule</b>: 10 Drivers, 10 Parking Providers, 3 Admins + IT Developer panel.</td>
      <td>Manuscript</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>5</b></td>
      <td><b>Paper (Ch 3)</b></td>
      <td>Update DFD Level-1 to reflect OR/CR, Driver's License, Barangay Clearance, and Downpayment flow.</td>
      <td>Manuscript</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>6</b></td>
      <td><b>System (Backend)</b></td>
      <td>Add OR/CR and Driver's License upload fields and side-by-side admin audit screen.</td>
      <td>Laravel API / DB</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>7</b></td>
      <td><b>System (Backend)</b></td>
      <td>Add Barangay Clearance requirement for Parking Space Provider verification.</td>
      <td>Laravel API / DB</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>8</b></td>
      <td><b>System (Backend)</b></td>
      <td>Implement 1-Hour Downpayment (GCash PayMongo) + 60-Minute No-Show auto-cancellation logic.</td>
      <td>Billing Engine</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>9</b></td>
      <td><b>System (Backend)</b></td>
      <td>Purge e-bike / bicycle options from database seeds, validation rules, and UI dropdowns.</td>
      <td>Database / API</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>10</b></td>
      <td><b>System (Mobile)</b></td>
      <td>Add "Select All" / batch slot configuration checkbox in provider space editor.</td>
      <td>Flutter App</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>11</b></td>
      <td><b>System (Mobile)</b></td>
      <td>Disable/hide in-app chat and WebRTC call buttons for cancelled or rejected bookings.</td>
      <td>Flutter App</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>12</b></td>
      <td><b>System (Mobile)</b></td>
      <td>Overhaul UI colors: Green for Approve/Pay, Red for Cancel/Reject, distinct header cards.</td>
      <td>Flutter App</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>13</b></td>
      <td><b>System (Mobile)</b></td>
      <td>Enlarge typography (14sp–16sp body text) and touch targets (48dp minimum).</td>
      <td>Flutter App</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>14</b></td>
      <td><b>System (Mobile)</b></td>
      <td>Move past bookings to a separate History tab; implement collapsible cascading cards.</td>
      <td>Flutter App</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>15</b></td>
      <td><b>Capstone 3 Prep</b></td>
      <td>Record high-definition on-site video testing at actual Calamba City parking locations.</td>
      <td>Field Testing</td>
    </tr>
    <tr>
      <td style="text-align:center;"><b>16</b></td>
      <td><b>Capstone 3 Prep</b></td>
      <td>Purge placeholder test data; populate with realistic Philippine IDs and OR/CR records.</td>
      <td>Database Seed</td>
    </tr>
  </tbody>
</table>

</body>
</html>
"""

with open(HTML_PATH, 'w', encoding='utf-8') as f:
    f.write(HTML_TEMPLATE)

# Invoke headless chrome
print("Invoking Chrome to render PDF...")
cmd = [
    CHROME,
    '--headless=new',
    '--disable-gpu',
    '--no-pdf-header-footer',
    f'--print-to-pdf={PDF_PATH}',
    'file:///' + HTML_PATH.replace('\\', '/')
]
subprocess.run(cmd, check=True, timeout=120)

shutil.copy(PDF_PATH, os.path.join(ARTIFACT_DIR, 'E_PARADA_PANEL_REVISIONS_ACTION_PLAN.pdf'))

from pypdf import PdfReader
reader = PdfReader(PDF_PATH)
print(f"Successfully generated PDF! Total pages: {len(reader.pages)}")
