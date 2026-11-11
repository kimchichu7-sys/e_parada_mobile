# E-Parada: Capstone Defense Presentation Outline (Copy-Paste Ready)
**Title:** *E-Parada: A Digital Marketplace for Parking Spaces*  
**Authors:** Bustria, Christian Jake C. | Gamad, Leticia C. | Ovilla, Shan Jenis C. | Valiña, Resha Lorraine P.  
**Alignment:** Combines the main structure of **E-Parada (15)** with the updated technology stack of **E-Parada (16)**, aligned to **IT Developer Evaluation Only**, **2D Floor Plan Slot Mapping**, **Supabase PostgreSQL 15+**, and **Zero Business Model / Commission Fees**.

---

# CHAPTER 1: INTRODUCTION

---

## SLIDE 1: Objectives of the Study

### 📋 Slide Content (Copy-Paste to Slide)
**General Objective**
* To enhance efficiency, effectiveness, and reliability in parking management by designing and developing **E-Parada**, a software-driven, cross-platform digital marketplace that connects residential and commercial parking space providers with motorists seeking available parking spaces in Calamba City, Laguna.

**Specific Objectives**
1. **To design** a centralized parking marketplace architecture that incorporates parking area and 2D slot management, OCR-assisted vehicle registration, location-based searching, cryptographic QR code access workflows, automated duration billing computation, and reservation-bound communication.
2. **To develop** the E-Parada software ecosystem—comprising the **Flutter Android mobile application** and the **Laravel 12 administrative web portal** backed by **Supabase (PostgreSQL 15+)**—utilizing the **Incremental Development Model** and integrating third-party APIs for mapping (Google Maps), OCR (Tesseract), voice calling (WebRTC), push notifications (FCM), and payment processing (GCash via PayMongo).
3. **To test and evaluate** the software quality of the developed system through **IT developer evaluation** and objective technical benchmarking using the **ISO/IEC 25010:2011 Software Product Quality Model** in terms of:
   * **Functional Suitability**
   * **Performance Efficiency**
   * **Usability**
   * **Reliability**

> 🎙️ **Speaker Notes:**  
> *"Our study is guided by one general objective and three specific objectives: First, designing the centralized software-only architecture; second, developing the cross-platform Flutter and Laravel ecosystem using the Incremental Model; and third, evaluating the system with IT developers using ISO/IEC 25010:2011 across Functional Suitability, Performance Efficiency, Usability, and Reliability."*

---

## SLIDE 2: Scope of the Study

### 📋 Slide Content (Copy-Paste to Slide)
**System Scope & Core Capabilities**
* **Cross-Platform Access:** Android Mobile Application (Flutter) & Administrative Web Portal (Laravel 12) synchronized via **Supabase (PostgreSQL 15+)**.
* **Target Parking Providers:** Residential driveways, vacant lots, commercial establishments, and select light-industrial parking spaces in **Calamba City, Laguna**.

| Stakeholder Role | Key Functional Scope |
| :--- | :--- |
| **Parking Space Providers** | • Account & property ownership verification<br>• Parking space listing with images & schedules<br>• Interactive **2D floor plan slot configuration** (dimensions, clearance, vehicle types)<br>• Hourly rate setting within admin-approved boundaries<br>• Reservation approval/rejection & **QR code entry/exit scanning** (with manual `RES-#` fallback)<br>• Real-time session monitoring & earnings tracking |
| **Drivers / Motorists** | • Account registration & ID verification<br>• **OCR-assisted vehicle registration** (Tesseract OCR plate extraction)<br>• Geolocation search, compatibility filtering, & **Google Maps** turn-by-turn navigation<br>• Slot reservation & **HMAC-SHA256 QR pass** generation<br>• Automated duration & overstay billing with **Cash or GCash (PayMongo)** settlement<br>• Reservation-bound **in-app chat & WebRTC audio calling** |
| **System Administrators** | • KYC verification of users, property documents, and OCR-extracted vehicles<br>• Listing approval & minimum/maximum parking fee range governance<br>• Real-time reservation, QR log, and payment monitoring<br>• Dispute mediation & **CSV forensic audit report generation** |

---

## SLIDE 3: Limitations of the Study

### 📋 Slide Content (Copy-Paste to Slide)
**System & Operational Limitations**
1. **Platform Support:** Limited to Android devices (Android 8.0+) and standard web browsers.
2. **Connectivity:** Requires an active internet connection for real-time database synchronization, mapping, and payment webhooks.
3. **Geolocation Precision:** GPS accuracy depends on mobile device location sensors and the Google Maps Platform API.
4. **Gate Validation:** Entry and exit QR validation is performed through the parking provider’s authorized mobile device.
5. **Hardware Independence (Exclusions):** Operating strictly as a **software-driven solution**, the system **does not include**:
   * Automated physical gate barriers or turnstiles
   * RFID hardware tags or readers
   * Stationary IoT ultrasonic/infrared ground sensors
   * AI-based predictive parking demand modeling
   * Live CCTV video streaming
6. **Verification Scope:** Relies on administrative review of uploaded IDs, vehicle photos, and property documents within the platform (no direct LTO/PNP government database lookup).
7. **Billing & Rate Boundaries:** Automated billing is strictly computed from validated QR `time-in` and `time-out` timestamps; provider rates must remain within admin-established fee boundaries.
8. **Third-Party Gateway Dependency:** Cashless transactions rely on the external GCash/PayMongo payment gateway.
9. **Evaluation Scope:** System evaluation is conducted through controlled technical benchmarking and end-to-end software quality assessment by **IT developers** simulating Calamba City parking scenarios, rather than public mass-market deployment.

---

## SLIDE 4: Conceptual Framework (IPO Model)

### 📋 Slide Content (Copy-Paste to Slide)
**Input–Process–Output (IPO) Model** *(Insert Figure 1 Diagram)*

| INPUT | PROCESS | OUTPUT |
| :--- | :--- | :--- |
| **1. System Requirements**<br>• Driver, Parking Provider, & Admin functional requirements<br>• Android (8.0+) & Web compatibility, GPS & internet connectivity<br><br>**2. System Design Inputs**<br>• Use Case Diagrams, System Flowcharts, DFDs, & Crow's Foot ERDs<br>• 2D Floor Plan UI/UX wireframes, REST API & WebRTC signaling specs<br><br>**3. Development Data Inputs**<br>• User IDs, vehicle specs & plate photos, space dimensions, slot layouts, rate boundaries, & QR logs<br><br>**4. Development Tools (Updated Stack)**<br>• **Mobile:** Flutter 3.x / Dart SDK<br>• **Backend:** PHP 8.2 / Laravel 12 (Docker & Nginx on Render)<br>• **Database:** Supabase (Managed PostgreSQL 15+ with Realtime CDC)<br>• **APIs & Engines:** Google Maps API, Tesseract OCR CLI, Google ML Kit & CameraX (`mobile_scanner`), `qr_flutter`, WebRTC (`flutter_webrtc`), FCM, Brevo SMTP, & PayMongo API v1 (GCash)<br><br>**5. Testing & Evaluation Inputs**<br>• 20 Functional & Security Test Cases<br>• Technical Benchmark Workloads<br>• ISO/IEC 25010:2011 Evaluation Instrument for IT Developers | **1. System Planning & Analysis**<br>• Analysis of Calamba City parking constraints<br>• Formulation of objectives, scope, & role requirements<br><br>**2. System Design**<br>• UI/UX prototyping & 2D slot layout design<br>• PostgreSQL schema modeling & REST API routing<br>• HMAC-SHA256 QR & billing algorithm design<br><br>**3. Incremental System Development**<br>• **Increment 1:** Auth, RBAC, & KYC/Vehicle OCR verification<br>• **Increment 2:** Space listing, rate bounds, & 2D floor plan slot mapping<br>• **Increment 3:** Geolocation search, Google Maps routing, & concurrency-locked booking<br>• **Increment 4:** QR entry/exit validation, duration/overstay billing, & GCash/PayMongo checkout<br>• **Increment 5:** In-app chat, WebRTC calling, FCM/Brevo alerts, & Admin CSV reports<br><br>**4. System Integration & Testing**<br>• Alpha testing, regression testing, & end-to-end scenario validation<br><br>**5. System Evaluation**<br>• Technical benchmarking & **IT Developer evaluation** under ISO/IEC 25010:2011 (Weighted Mean & SD) | **E-Parada: A Digital Marketplace for Parking Spaces**<br><br>• Verified Cross-Platform **Flutter Android Mobile App** & **Laravel Administrative Web Portal** |

---
---

# CHAPTER 2: REVIEW OF RELATED LITERATURE AND STUDIES

---

## SLIDE 5: Literature Matrix

### 📋 Slide Content (Copy-Paste to Slide)
**[ INSERT LITERATURE MATRIX TABLE HERE ]**

*(Leave blank on this outline—paste your Literature Matrix table directly into this slide.)*

---

## SLIDE 6: Literature & Design Synthesis

### 📋 Slide Content (Copy-Paste to Slide)
**Thematic Synthesis & Research Gap**

* **1. Geolocation & Urban Navigation** *(Raza et al., 2022; Jagelčák et al., 2024; Bastani et al., 2021; Grepon et al., 2023; Kim et al., 2023)*
  * Consumer GNSS sensors experience multipath drift in dense urban corridors; coupling device GPS with the **Google Maps Platform API** provides reliable pin discovery and turn-by-turn routing to decentralized residential slots.
* **2. Smart Parking & Reservation Systems** *(Barde et al., 2022; Sudhakar et al., 2023; Gamage, 2025; Guzman et al., 2024; Larraquel, 2023)*
  * Conventional smart parking relies on costly stationary IoT hardware (ultrasonic sensors, Raspberry Pi controllers, automated barriers). E-Parada bridges this gap through a **100% software-driven architecture** using consumer smartphones as edge scanners and interactive **2D floor plan slot mapping**.
* **3. Digital Sharing Economy & Resource Optimization** *(Pouri & Hilty, 2021; Wang, 2025; Ahmed et al., 2023)*
  * Digital marketplaces unlock underutilized private assets (driveways and vacant lots) without new physical construction, balancing urban supply and demand.
* **4. Cryptographic QR Validation & Replay Protection** *(Skurowski et al., 2022; Alsuhibany, 2025; Desale et al., 2025; Bekavac et al., 2024)*
  * Static QR codes are vulnerable to screenshot sharing and forgery. E-Parada enforces **HMAC-SHA256 cryptographic signing**, provider-space authority checks, and single-use state transitions (`Approved` $\rightarrow$ `Checked-In` $\rightarrow$ `Completed`).
* **5. Cross-Platform Synchronization & Transactional Integrity** *(Ali & Dauwed, 2022; Wahyudi et al., 2021; Kueh Wee Xin, 2025; Ahmed et al., 2024)*
  * Combining **Flutter + Laravel 12 + Supabase (PostgreSQL 15+)** delivers strict ACID compliance and pessimistic row-level locking (`SELECT ... FOR UPDATE`) to prevent double-bookings, paired with WebSocket Change Data Capture (CDC) for real-time updates.
* **6. Automated Duration Billing & Cashless Settlement** *(Vovveti, 2024; Afable, 2024; Fabro et al., 2025)*
  * Automated timestamp-delta billing eliminates manual calculation errors, while **GCash (via PayMongo API v1)** provides trusted, webhook-verified cashless settlement alongside cash options.

---
---

# CHAPTER 3: METHODOLOGY

---

## SLIDE 7: Research Design and Development Method

### 📋 Slide Content (Copy-Paste to Slide)
**Research Design: Descriptive-Developmental Method**
* **Developmental Aspect:** Systematic software engineering, multi-tenant database modeling, RESTful API integration, and cross-platform implementation of the Android mobile app and web portal.
* **Descriptive Aspect:** Quantitative assessment of the developed system’s software product quality by **IT developers** using the **ISO/IEC 25010:2011** standard and objective performance benchmarks.

**Software Development Methodology: Incremental Development Model** *(Insert Figure 26)*
* **Phase 1 — Planning & System Design:** Calamba City domain analysis, UI/UX wireframing, Crow's Foot ERD modeling, and Docker/Supabase environment setup.
* **Phase 2 — Incremental Feature Development (5 Sequential Increments):**
  * **Increment 1 (Core User Access):** Registration, Sanctum RBAC, KYC ID upload, & **Tesseract OCR** vehicle plate extraction.
  * **Increment 2 (Parking & 2D Slot Management):** Space listing, admin fee boundary enforcement, & **interactive 2D floor plan slot mapping**.
  * **Increment 3 (Search & Concurrency Booking):** Geolocation filtering, **Google Maps** routing, & pessimistic row-locked reservation handling (`SELECT ... FOR UPDATE`).
  * **Increment 4 (QR Validation & Automated Billing):** **HMAC-SHA256 QR** entry/exit scanning (Google ML Kit/CameraX), duration/overstay fee calculation, & **GCash (PayMongo v1)** + Cash settlement.
  * **Increment 5 (Real-Time Communication & Governance):** Reservation-bound chat, **WebRTC** voice calling, **FCM & Brevo** notifications, dispute mediation, & Admin CSV forensic reports.
* **Phase 3 — System Integration & Testing:** End-to-end API, webhook, and concurrency stress testing.
* **Phase 4 — System Evaluation:** Technical evaluation by **IT developers** using ISO/IEC 25010:2011.
* **Phase 5 — Output:** Deployed E-Parada Mobile App & Administrative Web Portal.

---

## SLIDE 8: System Architecture & Database Design

### 📋 Slide Content (Copy-Paste to Slide)
**Three-Tier System Architecture** *(Insert Figure 6: System Architecture & Figure 7: Use Case Diagram)*
1. **Data Gathering Layer:** Captures operational requirements from two primary user roles (**Drivers** and **Parking Space Providers**) governed by **System Administrators**.
2. **Acquired Knowledge & Feature Layer:** Translates urban parking constraints into 18 integrated functional modules (RBAC, OCR verification, 2D slot mapping, pessimistic booking, HMAC QR validation, automated billing, and WebRTC/Chat coordination).
3. **Computer Program / Technology Layer:**
   * **Client Tier:** Flutter 3.x / Dart (Android Mobile App & PWA) + Laravel Blade, Tailwind CSS 3.x, & Alpine.js 3.x (Web Portal).
   * **Application & API Tier:** PHP 8.2 / Laravel 12 RESTful API containerized with **Docker & Nginx on Render Cloud**.
   * **Data Tier:** **Supabase (Managed PostgreSQL 15+)** with Connection Pooler, Row-Level Security (RLS), and Realtime WebSockets.

**Modular Relational Database Schema (Crow's Foot ERD)** *(Insert Figures 13, 14, & 15)*
* **Core Booking Subsystem (6 Tables):** `users`, `vehicles`, `parking_spaces`, `parking_slots`, `reservations`, `parking_space_feedback`
* **Communications & Notification Subsystem (5 Tables):** `reservation_messages`, `reservation_calls`, `reservation_call_signals`, `notifications`, `user_device_tokens`
* **Security Audit & Telemetry Subsystem (3 Tables):** `activity_logs`, `qr_transaction_logs`, `support_requests`

---

## SLIDE 9: Proposed Prototype & User Interfaces

### 📋 Slide Content (Copy-Paste to Slide)
**Cross-Platform User Interfaces** *(Insert Figures 19, 20, 21, 22, & 23)*

* **a. Driver Mobile Interface (Figure 19):**
  * **Browse Parking:** Interactive Google Maps pin discovery & proximity/vehicle-compatibility filtering around Calamba City.
  * **Space Inspection:** Operating hours, hourly rates, and interactive **2D floor plan slot layout** selection.
  * **My Reservations:** 6-stage real-time progress tracker (`Requested` $\rightarrow$ `Approved` $\rightarrow$ `Checked In` $\rightarrow$ `Checked Out` $\rightarrow$ `Payment Sent` $\rightarrow$ `Paid`), encrypted **Entry QR Code**, reschedule/cancel controls, and provider chat/call buttons.
  * **Driver Profile & Vehicles:** KYC verification badges and OCR-assisted vehicle registration slots (up to 3 vehicles).
* **b. Parking Space Provider Mobile Interface (Figure 20):**
  * **Owner Dashboard:** Live counters for registered spaces, active slots, pending requests, and payments to verify.
  * **My Parking Spaces:** Property editor, 2D slot layout configurator, and operating schedule manager.
  * **Entry & Exit Checkpoint Validator:** Hardware-accelerated camera QR scanner (`mobile_scanner`) with manual `RES-#` fallback and checkpoint mismatch detection.
* **c. System Administrator Mobile & Web Portal (Figures 21 & 22):**
  * **Admin Reviews (KYC & OCR Audit):** Side-by-side inspection of user IDs, property proofs, and OCR-extracted license plates vs. vehicle photos.
  * **Reservation & Platform Operations Monitor:** Live transaction tracking, dispute resolution, QR scan telemetry logs, and 1-click **CSV audit report export**.

---

## SLIDE 10: Hardware and Software Components

### 📋 Slide Content (Copy-Paste to Slide)
**Table 1: Hardware Specification**

| Category | Component | Minimum Specification | Purpose |
| :--- | :--- | :--- | :--- |
| **Development Workstation** | Laptop / Desktop PC | Intel Core i3 / AMD Ryzen 3, 8 GB RAM, 256 GB SSD | Compiling Flutter builds, running Laravel/Docker containers, and database management. |
| **Mobile Test Device** | Android Smartphone | Android 8.0 (Oreo) or higher, 4 GB RAM, Camera, GPS, Microphone | Executing on-device QR scanning, OCR plate capture, GPS navigation, and WebRTC voice calls. |
| **Network Equipment** | Wi-Fi Router / 4G LTE | Stable broadband / cellular data connection | Enabling HTTPS REST API, WebSocket, and payment webhook communication. |

**Table 2: Updated Software Specification (E-Parada 16 Stack)**

| Category | Technology / Component | Specification / Version | Architectural Role |
| :--- | :--- | :--- | :--- |
| **Mobile Framework** | **Flutter & Dart SDK** | Flutter 3.x / Dart `^3.12.2` | Cross-platform Android client & hardware-accelerated 2D UI rendering. |
| **Backend Framework** | **PHP & Laravel** | PHP 8.2 / Laravel 12.0 | MVC RESTful API engine, Sanctum RBAC, HMAC signing, & billing logic. |
| **Cloud Database (DBMS)** | **Supabase (PostgreSQL)** | Managed PostgreSQL 15+ | ACID transactions, `SELECT ... FOR UPDATE` row locking, RLS, & Realtime CDC. |
| **Cloud Hosting** | **Docker & Render Cloud** | Alpine Linux + Nginx + PHP-FPM | Multi-stage containerized production deployment with automated SSL. |
| **Web Frontend** | **Laravel Blade + Tailwind + Alpine.js** | Tailwind 3.x / Alpine 3.x | Responsive administrative dashboard and web portal interface. |
| **2D Spatial Layout** | **2D Floor Plan Slot Engine** | Custom Flutter Painter & HTML5 Grid | Renders interactive 2D parking lot lanes and angled slot layouts (`layout_x`, `layout_z`). |
| **Mapping & Routing** | **Google Maps Platform** | Google Maps SDK & Directions API | Geolocation pin discovery, distance calculation, and turn-by-turn routing. |
| **License Plate OCR** | **Tesseract OCR Engine** | CLI / Server-Side (PSM 11 + LTO Regex) | Adaptive thresholding & automated alphanumeric license plate extraction. |
| **QR Scanner & Generator** | **Google ML Kit, CameraX & `qr_flutter`** | `mobile_scanner: ^7.4.0` | Low-latency optical QR pass decoding and encrypted barcode rendering. |
| **Voice & Push Alerts** | **WebRTC, FCM, & Brevo SMTP** | `flutter_webrtc` / Firebase / Brevo | Reservation-bound VoIP audio calling, push alerts, and transactional KYC emails. |
| **Payment Gateway** | **GCash via PayMongo API** | PayMongo API v1 (Webhooks) | Authenticated cashless checkout sessions and automated payment verification. |

---

## SLIDE 11: Data Flow and Control Logic (Activity Diagram, DFD, & Subroutines)

### 📋 Slide Content (Copy-Paste to Slide)
**1. Cross-Functional Activity Diagram & 12-Phase System Flowchart** *(Insert Figures 8 & 24)*
* Models the end-to-end control flow across **5 Swimlanes** (*Driver*, *Laravel Core Backend*, *Parking Space Provider*, *System Services [Maps/OCR/PayMongo/FCM]*, and *System Administrator*):
  * **Phases 1–3:** Account Registration, Brevo Email Verification, Admin KYC/OCR Approval, & Role-Based Routing.
  * **Phases 4–6:** Space Listing Creation, Geolocation Search, Pessimistic Slot Locking, Provider Approval, & HMAC QR Generation.
  * **Phases 7–9:** Gate QR Entry Scan (`time_in`), Active Session Monitoring, QR Exit Scan (`time_out`), Automated Duration + Overstay Billing, Cash/GCash Settlement, & Feedback.
  * **Phases 10–12:** Admin Listing/User Governance, Dispute Mediation, & CSV Audit Report Export.

**2. Partitioned Data Flow Diagrams (DFD Levels 0, 1, & 2)** *(Insert Figures 16, 17, & 18)*
* **Level-0 DFD (Figure 16):** 6 Core Processes interacting with 6 Data Stores (`D1 User/Vehicles`, `D2 Spaces/Slots`, `D3 Reservations`, `D4 Active Sessions`, `D5 Payments/Receipts`, `D6 Feedback/Audit Logs`).
* **Level-1 DFD (Figure 17):** Decomposes **Process 3.0 (Driver Search & Reservations)** into 6 subprocesses (`3.1 Query` $\rightarrow$ `3.2 Dimension Filter` $\rightarrow$ `3.3 Validate` $\rightarrow$ `3.4 Conflict Check` $\rightarrow$ `3.5 HMAC QR Generation` $\rightarrow$ `3.6 Dispatch Pass`).
* **Level-2 DFD (Figure 18):** Decomposes **Process 3.5 (Generate Secure HMAC QR Code)** (`Extract Tuple` $\rightarrow$ `Retrieve Secret Key` $\rightarrow$ `Compute 256-bit HMAC-SHA256 Signature` $\rightarrow$ `Encode Base64 2D Matrix`).

**3. Four Encapsulated Technical Subroutines** *(Insert Figure 25)*
* **Subroutine 1 (Tesseract OCR):** Grayscale + contrast boost + adaptive binarization $\rightarrow$ PSM 11 extraction $\rightarrow$ LTO format regex validation.
* **Subroutine 2 (Pessimistic Concurrency Locking):** `BEGIN` $\rightarrow$ `SELECT ... FOR UPDATE` on `parking_slots` $\rightarrow$ temporal overlap check $\neg(\text{new\_end} \le \text{start\_time} \lor \text{new\_start} \ge \text{end\_time})$ $\rightarrow$ `COMMIT` or `ROLLBACK`.
* **Subroutine 3 (Cryptographic QR Replay Guard):** Base64 decode $\rightarrow$ recompute `HMAC-SHA256` $\rightarrow$ verify single-use state & checkpoint match $\rightarrow$ log to immutable `qr_transaction_logs`.
* **Subroutine 4 (Automated Duration & Overstay Billing):** Compute $\Delta t = \text{time\_out} - \text{time\_in}$ minus 15-min grace period $\rightarrow$ apply ceiling-rounded hourly & overstay rates $\rightarrow$ process Cash or PayMongo GCash webhook.

---

## SLIDE 12: Testing Environment, Phases, and Test Coverage

### 📋 Slide Content (Copy-Paste to Slide)
**Testing Environment Configuration**
* **Client Environment:** Physical Android smartphones (Android 8.0–14.0) for camera QR/OCR, GPS, and WebRTC hardware validation + Android Studio Emulator & Desktop/Mobile Web Browsers.
* **Server & Database Environment:** Containerized PHP 8.2 / Laravel 12 backend on Render connected to **Supabase PostgreSQL 15+**.
* **Network Scenarios:** High-speed Wi-Fi (baseline), 4G/LTE cellular data (field mobility), and throttled low-bandwidth connections (fault-tolerance & timeout testing).

**Three Sequential Testing Phases (Table 3)**
1. **Alpha Testing (Unit & Modular):** Internal testing across all 5 development increments (**Criteria:** 100% pass rate on auth, booking, and billing test suites; 0 critical DB violations).
2. **System & Scenario Evaluation (End-to-End Technical Validation):** Conducted by purposively selected **IT Developers** executing complete Driver, Provider, and Administrator workflows (**Criteria:** $\ge 95\%$ end-to-end scenario completion; 0 double-bookings).
3. **Regression Testing:** Automated and manual re-verification after each increment integration (**Criteria:** 100% pass on all 20 test cases; 0 regression defects).

**20-Item Test Case Coverage Matrix (Table 4 Summary)**
* **TC-01 to TC-02:** Authentication & Sanctum RBAC (`HTTP 403` unauthorized route blocking)
* **TC-03 to TC-04:** Vehicle Registration, Tesseract OCR ($\ge 90\%$ precision), & Duplicate Plate Prevention
* **TC-05 to TC-06:** Space Listing Fee Bounds & Interactive **2D Floor Plan Slot Grid** Rendering
* **TC-07 to TC-08:** Geolocation Proximity Search, Vehicle Dimension Filtering, & Google Maps Routing
* **TC-09 to TC-10:** Standard Booking & **Concurrent Race-Condition Stress Test (`SELECT ... FOR UPDATE`)**
* **TC-11 to TC-14:** QR Entry/Exit Logging, **Replay Attack Rejection**, Unauthorized Scanner Blocking, & Manual `RES-#` Fallback
* **TC-15 to TC-17:** Automated Duration/Overstay Math, Cash Confirmation, & **GCash PayMongo Webhook** Settlement
* **TC-18 to TC-20:** Reservation-Bound Chat, **WebRTC Voice Calling (`< 250 ms`)**, & Network Drop Recovery

---

## SLIDE 13: Evaluation and Statistical Treatment

### 📋 Slide Content (Copy-Paste to Slide)
**Evaluators & Sampling Design**
* **Sampling Method:** **Purposive Sampling** of qualified **IT Developers and Software Engineering Professionals** (replacing general end-user respondents).
* **Evaluation Protocol:** IT developers execute full role-based scenario walkthroughs (Driver, Parking Space Provider, and System Administrator), inspect security/database operations, and evaluate the platform using the **ISO/IEC 25010:2011 Software Product Quality Model**:
  1. **Functional Suitability** (*Completeness, Correctness, Appropriateness*)
  2. **Performance Efficiency** (*Time Behavior, Resource Utilization, Capacity*)
  3. **Usability** (*Recognizability, Learnability, Operability, User Error Protection, UI Aesthetics, Accessibility*)
  4. **Reliability** (*Maturity, Availability, Fault Tolerance, Recoverability*)

**Objective Technical Performance Benchmarks (Table 5)**

| Performance Metric | Target Threshold | Measurement Tool / Harness |
| :--- | :--- | :--- |
| **1. REST API Latency** | Mean Response `< 350 ms` (at 50 req/s) | Apache JMeter / Postman Collection Runner |
| **2. QR Validation Speed** | Total Validation `< 600 ms` | Physical Android Benchmark Timer |
| **3. Concurrency Resilience** | `0` Double-Bookings (under 25 simultaneous requests) | Automated Python Concurrency Stress Script |
| **4. OCR Extraction Latency** | Execution `< 1.8 s`; Precision `≥ 90%` | Automated Test Harness (50 sample plate photos) |
| **5. WebRTC Audio Latency** | Packet Latency `< 200 ms` | Chrome WebRTC Internals & Packet Logger |
| **6. Payment Webhook Latency** | Round-Trip `< 1.2 s` | PayMongo API v1 Webhook Logger |

**Statistical Treatment Formulas & Interpretation Matrix (Table 6)**
* **1. Percentage Distribution (Evaluator Profile):** $P = \left(\frac{f}{N}\right) \times 100$
* **2. Weighted Mean (Quality Rating):** $\bar{X} = \frac{\sum fx}{N}$
* **3. Standard Deviation (Rating Consistency):** $SD = \sqrt{\frac{\sum (X - \bar{X})^2}{N - 1}}$

| Scale | Weighted Mean Range | ISO/IEC 25010:2011 Rating | Qualitative Level |
| :---: | :---: | :--- | :--- |
| **5** | `4.21 – 5.00` | **Excellent / Highly Compliant** | Outstanding software quality |
| **4** | `3.41 – 4.20` | **Very Good / Compliant** | High software quality |
| **3** | `2.61 – 3.40` | **Fair / Moderately Compliant** | Moderate software quality |
| **2** | `1.81 – 2.60` | **Poor / Low Compliance** | Substandard software quality |
| **1** | `1.00 – 1.80` | **Very Poor / Non-Compliant** | Unacceptable software quality |
