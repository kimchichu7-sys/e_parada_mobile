# E-Parada Manuscript Alignment: Copy-Paste Replacement Guide
**(IT Developer Evaluation Alignment + Business Model Removal + Technical Cleanup)**

This document contains the exact, ready-to-paste replacement paragraphs and sections for your manuscript. It is organized in two parts:
* **Section I**: Targeted paragraph replacements for **Chapters 1, 2, and early Chapter 3 (Pages 2–125)**.
* **Section II**: A **complete, continuous replacement for Pages 126–149** (*Data Collection* through the end of Chapter 3), including the corrected **Table numbering (Tables 3–6)** and the missing **D. Reliability** block in the ISO/IEC 25010 questionnaire.

---

## SECTION I: Targeted Replacements for Pages 2–125

### 1. Page 2 — Background of the Study (Paragraph 2)
*(Removes "monetize" to avoid business-model framing)*
> An opportunity to bridge this supply-and-demand gap is presented by the expansion of mobile communication technologies and digital sharing platforms. By applying digital marketplace principles to parking management, property owners with surplus space can list and manage their available slots for short-term use, while motorists obtain affordable, pre-arranged, and accessible parking options in close proximity to their destinations.

---

### 2. Page 6 — Figure 1 (Conceptual Framework IPO Diagram Text Edits)
Update the text inside the boxes of **Figure 1** as follows:
* **INPUT $\rightarrow$ 4. Development Tools (Bullet 3)**:
  * Replace `Database: SQLite (Development) / MySQL (Production)` with:
  * `Database: Supabase (Managed PostgreSQL 15+)`
* **INPUT $\rightarrow$ 5. Testing Inputs (Bullets 2 & 3)**:
  * `• Simulated operational test scenarios and technical benchmark workloads`
  * `• ISO/IEC 25010:2011 Software Product Quality evaluation instrument for IT developers`
* **PROCESS $\rightarrow$ 4. System Integration and Testing (Bullet 3)**:
  * Replace `Beta testing in selected private/residential parking areas` with:
  * `End-to-end scenario validation across driver, provider, and admin workflows`
* **PROCESS $\rightarrow$ 5. System Evaluation (Bullet 2)**:
  * Replace `Statistical analysis of survey responses using Weighted Mean` with:
  * `Statistical analysis of IT developer evaluation ratings using Weighted Mean`

---

### 3. Page 7–9 — Conceptual Framework Narrative (Input, Process, and Output)

#### Page 7 (Bottom Sentence — Testing Inputs):
> Finally, Testing Inputs consist of functional and security test cases, simulated operational scenarios modeled on Calamba City parking workflows, and the ISO/IEC 25010:2011 Software Product Quality evaluation instrument administered to IT developers.

#### Page 8 (Bottom Sentence — System Evaluation):
> Finally, the completed system will be assessed in the System Evaluation phase by purposively selected IT developers using the ISO/IEC 25010:2011 Software Product Quality Model to evaluate technical software product quality in terms of Functional Suitability, Performance Efficiency, Usability, and Reliability, with evaluation ratings analyzed using the weighted mean.

#### Page 9 (Paragraph 1, Last Sentence — Output):
> Ultimately, the output delivers a quality-tested and technically validated cross-platform marketplace platform evaluated and verified by IT developers under ISO/IEC 25010:2011 software quality standards.

---

### 4. Page 13 — Limitations of the Study (Item #10)
*(Replaces end-user field testing with IT developer scenario evaluation)*
> 10. System evaluation is conducted through controlled technical benchmarking and end-to-end software quality assessment by IT developers simulating private and residential parking scenarios in Calamba City, Laguna, rather than large-scale public end-user deployment or multi-level commercial transit terminal operations.

---

### 5. Page 14 — Significance of the Study (Paragraphs 1 & 3)
*(Replaces "e-commerce" and "digital commerce" with technical resource-sharing terminology)*

#### Paragraph 1:
> This section presents the significance of the study entitled “E-Parada: A Digital Marketplace for Parking Spaces.” It explains the importance of the research and identifies the individuals, groups, and institutions that may benefit from the development of the proposed system. It also highlights the potential contributions of the study in addressing problems related to parking accessibility and utilization through the application of mobile and web technologies, QR code validation, and digital resource-sharing principles.

#### Paragraph 3 (Industry Practitioners):
> **Industry Practitioners.** The proposed system can assist professionals in software development, urban planning, and smart mobility systems by improving efficiency, accuracy, and decision-making processes. By demonstrating how mobile and web applications can connect supply (parking space providers) with demand (drivers), the study offers a practical architectural model that industry practitioners may further develop or adapt for real-world applications, particularly in environments requiring secure authentication and flexible payment options such as cash and GCash.

---

### 6. Pages 50 & 51–52 — Chapter 2 RRL (GCash Sections)
*(Removes the business model / subscription / premium revenue stream claims)*

#### Page 50 (Paragraph 2, Last Sentence):
> This supports the study’s objectives of enhancing efficiency, reliability, and accessibility in parking management through modern digital payment solutions.

#### Pages 51–52 (Bottom of Page 51 to Top of Page 52 — Chan, 2026 Synthesis Paragraph):
> This strategic perspective is relevant to E-Parada, as it highlights the importance of aligning digital payment integration with user convenience and transactional reliability. By adopting GCash as its primary cashless payment option via automated webhook verification, E-Parada benefits from the platform’s established security and local accessibility, ensuring seamless, verifiable settlements between drivers and parking space providers.

---

### 7. Page 55 — Chapter 2 Design Synthesis (Last Paragraph)
*(Fixes leftover "3D visualization" mention to "2D floor plan visualization")*
> E-Parada tries to fill this gap by incorporating these technologies and concepts into a combined, software-driven, two-sided marketplace for parking. The suggested system incorporates parking space listing and searching, verification of parking space suitability for a particular car, managing reservations, navigation with GPS and Google Maps, interactive 2D floor plan visualization of the parking spot, validation of entry and exit using QR codes, billing based on the parking duration, supporting online payments, communicating, and monitoring transactions. On the other hand, the proposed system introduces a decentralized software-driven architecture that coordinates underutilized residential and commercial spaces without requiring costly IoT hardware infrastructure. By integrating cryptographic HMAC-SHA256 QR validation, pessimistic concurrency-controlled booking, and automated duration billing into a unified cross-platform ecosystem, E-Parada provides an accessible, secure, and infrastructure-independent solution for localized parking management.

---

### 8. Pages 56–65 — References Cleanup
* **Keep Pages 56–60** (APA 7th Edition References).
* **Delete Pages 61–65** (Duplicate IEEE `[1]`, `[2]` References list).

---

### 9. Pages 66–67 — Chapter 3: Software Development Model
*(Fixes "3D layout visualization" on Page 66 and replaces end-user respondents with IT developers on Page 67)*

> **Software Development Model**
>
> The engineering and implementation of E-Parada are governed by the Incremental Development Model. The research team selected this model as it enables them to construct and deliver the system in clearly structured, sequential stages, where each increment introduces a distinct functional subsystem that is developed, tested, refined, and integrated before the next set of features is introduced. The system development is divided into five sequential increments: (1) user authentication, RBAC, and identity/vehicle verification; (2) parking space and slot listing, dimension configuration, rate management, and interactive 2D floor plan slot mapping; (3) geolocation search, Google Maps routing, and reservation handling; (4) QR code entry/exit validation, automated duration tracking, billing computation, and GCash payment gateway integration; and (5) reservation-based in-app messaging, WebRTC audio calling, notifications, and administrative dashboard controls. This incremental approach ensures that foundational modules are validated for stability and security before succeeding layers are integrated into the platform.
>
> Furthermore, the effectiveness and performance of the completed system will be evaluated through objective technical benchmarking and structured expert evaluation. Objective performance testing will measure system metrics including API response latency, OCR extraction speed, QR code decoding time, and database concurrency resilience. Software product quality evaluation will be conducted among purposively selected IT developers and software engineering professionals—who will execute complete role workflows across the driver, parking space provider, and administrator modules—to assess the platform’s Functional Suitability, Performance Efficiency, Usability, and Reliability under the ISO/IEC 25010:2011 standard.
>
> The detailed operational workflow, phase milestones, and incremental delivery stages tailored for the E-Parada platform are comprehensively mapped in Figure 26 under the Incremental Development Procedure section.

---

### 10. Pages 68, 70, & 106 — Removing "Three.js" and "SQLite"
* **Page 68 (Figure 6 Diagram — Third Column)**:
  * Replace `SQLite Database` with `Supabase PostgreSQL 15+`
  * Replace `Three.js` with `2D Floor Plan Slot Engine`
* **Page 70 (Paragraph 2, Line 5)**:
  * Remove `Three.js,` so the sentence reads: *"...Tailwind CSS, Alpine.js and JavaScript, Google Maps Platform and Geolocation, Tesseract OCR..."*
* **Page 106 (Table 2: Software Specification — Row 3)**:
  * Replace the `3D Spatial Layout Library | Three.js` row with:

| Category | Component | Specification | Description |
| :--- | :--- | :--- | :--- |
| **2D Spatial Layout Engine** | **Custom Flutter Canvas & HTML5 Grid** | **Responsive 2D Coordinate Mapper (`layout_x`, `layout_z`, `rotation`)** | **Renders interactive 2D parking lot floor plans, aisle lanes, and angled slot orientations across mobile and web viewports.** |

---

### 11. Page 116 — System Flowchart Narrative (Paragraphs 2 & 3)
*(Removes "minus the platform's service fee" and "platform fees" business model remnants)*

> While the vehicle is parked, the system monitors the active session. When the driver is ready to leave, the provider scans the QR code a second time at the exit. The system records the check-out timestamp and automatically calculates the total parking fee based on the elapsed duration, the hourly rate, and any applicable overstay charges if the driver exceeded their reserved time. The itemized bill is displayed on the driver's screen, and the driver selects their preferred payment method. Payment can be made in cash directly to the provider or digitally through GCash via the integrated payment gateway. Once payment is confirmed, the transaction receipt is saved in the database, the provider's cumulative earnings record is updated, and the driver is given the option to rate and review the parking facility.
>
> The final stage covers administrative governance, dispute handling, and system reporting. Any ratings and feedback submitted by drivers are forwarded for admin review, where the administrator can moderate inappropriate content or publish constructive feedback to the provider's profile. If any billing or overstay issues occur, the platform allows the driver and host to review and settle the dispute, with the administrator available to mediate unresolved complaints. In addition, the backend compiles system reports from the database, giving the administrator an overview of total bookings, settled transaction summaries, and active users. The administrator can review these reports and perform maintenance tasks before logging out, which safely concludes the system session.

---

### 12. Pages 120 & 124 — Diagram Label Fixes
* **Page 120 (Figure 25, Subroutine 2 Header)**: Change column 3 header from `MYSQL DATABASE (TRANSACTION)` to `SUPABASE POSTGRESQL (TRANSACTION)`.
* **Page 124 (Figure 26, Incremental Development Procedure)**:
  * In **Increment 2**: Change `- 3D parking slot layout` to `- 2D parking slot layout`.
  * In **4. System Integration**: Change `- Laravel REST API and MySQL database` to `- Laravel REST API and Supabase PostgreSQL database`.
  * In **6. System Evaluation**: Change `- User acceptance testing` to `- IT developer technical evaluation`.

---
---

## SECTION II: Complete Continuous Replacement for Pages 126–149
*(Highlight everything from the top of **Page 126** to the bottom of **Page 149** in your Word document and replace it with the continuous text below.)*

---

Following development, Phase 3 (System Integration and Testing) connects the Android mobile application and administrative web portal to the centralized Laravel REST API and Supabase PostgreSQL database, where complete functional, security, and performance stress tests are conducted. Integration testing validates the end-to-end reservation and payment pipeline, verifying that slot state transitions, PayMongo webhook callbacks, and Supabase WebSocket broadcasts execute deterministically across both native Android devices and web viewports. In Phase 4 (System Evaluation), the integrated platform is evaluated by purposively selected IT developers using the ISO/IEC 25010:2011 Software Product Quality Model (assessing Functional Suitability, Performance Efficiency, Usability, and Reliability), with gathered evaluation ratings analyzed using the weighted mean. Finally, Phase 5 (Output) delivers the complete, evaluated E-Parada system, comprising the Android mobile application for drivers and parking space providers and the centralized administrative web portal.

### Data Collection

This section outlines the operational test locale, evaluator selection, sampling technique, data gathering procedures, evaluation instrument, and ethical considerations utilized in validating the E-Parada system. The study performs functional scenario validation, objective technical benchmarking, and ISO/IEC 25010:2011 software product quality evaluation conducted by IT developers.

### Research Locale

Calamba City, Laguna, Philippines serves as the operational context and spatial simulation locale for the study. Due to its rapid urban growth, high concentration of educational institutions (including National University Laguna), major transport terminals, and bustling commercial districts, the area experiences acute parking shortages and roadside congestion. All geospatial coordinates, Google Maps routing tests, and residential/commercial parking space listings modeled and tested within the E-Parada platform are anchored within Calamba City.

### Evaluators and Sampling Technique

To ensure a rigorous and technically grounded assessment of the platform’s software architecture, database integrity, and functional execution, the study utilizes **Purposive Sampling** to select qualified **IT Developers and Software Engineering Professionals** as system evaluators. Rather than relying on general end-user surveys, evaluators are purposively selected based on their technical expertise in mobile and web application engineering, relational database management, RESTful API integration, and software quality assurance.

During the evaluation phase, the participating IT developers perform comprehensive, role-based scenario walkthroughs across both the Flutter Android mobile application and the Laravel administrative web portal—simulating the complete operational workflows of Drivers, Parking Space Providers, and System Administrators. Following hands-on technical inspection, code and security review, and execution of predefined test cases, the evaluators rate the platform using the standardized **ISO/IEC 25010:2011 Software Product Quality Model** across four core dimensions: Functional Suitability, Performance Efficiency, Usability, and Reliability.

### Data Gathering Procedures

Data collection and technical validation were executed in two primary phases:

1. **Requirements Analysis Phase**: Conducted through domain analysis of urban parking workflows in Calamba City, environmental inspection of residential and commercial parking constraints, and a comprehensive review of existing smart parking literature. These technical insights established the functional specifications, vehicle dimension filtering rules, fee boundary parameters, and relational database schema of E-Parada.
2. **System Validation and Technical Evaluation Phase**: Following end-to-end system integration, the selected IT developers interacted directly with the working Android mobile application and administrative web portal across predefined operational scenarios (account registration, Tesseract OCR plate extraction, 2D floor plan slot mapping, Google Maps routing, HMAC-SHA256 QR check-in/check-out validation, automated duration billing, GCash payment gateway settlement, and WebRTC communication). After executing all test cases and auditing objective performance benchmarks, the IT developers accomplished the structured ISO/IEC 25010:2011 evaluation instrument.

### Ethical Considerations and Data Privacy

The Philippine Data Privacy Act of 2012 (Republic Act No. 10173) is strictly complied with throughout all system testing and evaluation procedures. Prior to conducting the evaluation, informed consent is obtained from all participating IT developers, outlining the research objectives, voluntary nature of participation, and confidentiality terms. During scenario testing, synthetic user profiles and consent-authorized developer test vehicles are utilized to ensure no unauthorized personally identifiable information (PII) is exposed. Within the platform, all uploaded identification documents, vehicle photographs, and transaction logs are protected via role-based access control (RBAC) and encrypted storage accessible exclusively to authorized administrators. All evaluation scores and feedback submitted by the IT evaluators are anonymized during statistical tabulation.

---

### OPERATION AND TESTING PROCEDURE

#### System Operation Procedure

This section outlines the operational workflows of the E-Parada platform, categorized according to the distinct roles of Drivers, Parking Space Providers, and System Administrators, alongside the automated QR validation and payment gateway procedures.

#### A. Driver Operation Procedure
1. **Application Launch and Authentication** — The driver opens the E-Parada mobile application on an Android device and logs in using registered credentials or completes new user registration by submitting their name, email, contact number, password, and valid identification card for administrative review.
2. **OCR-Assisted Vehicle Registration** — The driver registers their vehicle by uploading front and rear vehicle photographs. The integrated Tesseract OCR automatically extracts the license plate characters, which the driver reviews, confirms, and submits for administrator verification.
3. **Parking Search and Discovery** — The driver searches for available parking spaces by entering a target destination, filtering by distance, vehicle compatibility, spatial dimensions, and hourly rates, or browsing active pins on the Google Maps interface.
4. **Space Inspection and 2D Slot Map Viewing** — The driver selects a listing to view detailed facility descriptions, operating schedules, pricing, provider details, and the interactive 2D parking lot lane and slot layout.
5. **Reservation Request** — The driver selects an available slot, chooses a registered vehicle, specifies the reservation date, start time, and expected duration, and submits the booking request.
6. **Confirmation and QR Pass Issuance** — Once the parking space provider approves the request, the system generates an encrypted, time-bounded QR access pass accessible under the driver's "My Reservations" dashboard.
7. **GPS Route Navigation** — The driver utilizes the integrated Google Maps navigation to obtain turn-by-turn driving directions to the reserved parking space.
8. **In-App Communication** — If coordination is needed, the driver communicates with the assigned provider via reservation-bound in-app text messaging or WebRTC audio calling.
9. **Check-In and Check-Out Scanning** — Upon arrival, the driver presents the QR pass to the provider for entry scanning (logging time-in), and presents it again upon departure for exit scanning (logging time-out).
10. **Billing Review and Payment** — The driver reviews the automatically computed bill and settles the balance using cash or the integrated GCash Payment Gateway, receiving an instant digital transaction receipt.

#### B. Parking Space Provider Operation Procedure
1. **Provider Onboarding and Verification** — The provider registers an account via the mobile application or web portal, submits proof of property ownership and valid identification, and awaits administrative verification.
2. **Space and Slot Listing Management** — The verified provider creates parking listings by entering property addresses, uploading facility images, specifying spatial dimensions, configuring the 2D slot layout, defining operating hours, and setting individual slot rates within administrator-approved boundaries.
3. **Reservation Management** — The provider receives real-time notifications for incoming booking requests, reviews driver and vehicle profiles, and accepts or rejects reservations within a predefined response window.
4. **Entry and Exit Validation** — The provider uses the built-in in-app scanner to scan the driver's QR access pass upon arrival to log the time-in (updating slot status to "Occupied") and upon departure to log the time-out (updating slot status to "Available"). If camera scanning is unavailable, the provider manually inputs the alphanumeric reservation code.
5. **Payment and Earnings Tracking** — For cash settlements, the provider collects the fee and marks the transaction as "Paid" in the dashboard. For GCash transactions, payment confirmation is received automatically via the payment gateway. The provider monitors active sessions, overstay logs, and cumulative earnings through the provider dashboard.
6. **Driver Coordination** — The provider communicates with confirmed drivers through reservation-bound in-app messaging and WebRTC voice calls.

#### C. System Administrator Operation Procedure
1. **Administrative Authentication** — The system administrator securely logs in to the web-based Admin Dashboard or mobile admin view using authenticated credentials.
2. **User, Provider, and Vehicle Verification** — The administrator reviews pending account submissions, inspects uploaded identification cards and property documents, verifies OCR-extracted vehicle plate numbers, and approves or rejects registrations.
3. **Parking Listing and Rate Governance** — The administrator audits newly submitted parking listings for accuracy and sets the allowable minimum and maximum parking rate boundaries for the platform.
4. **Platform Monitoring and Audit Logging** — The administrator monitors platform activities in real time, including active bookings, QR validation audit trails, automated billing summaries, payment gateway transaction logs, user complaints, and system security alerts.
5. **Analytics and Reporting** — The administrator generates and exports operational CSV reports concerning platform utilization, transaction summaries, forensic time-in/time-out logs, and violation histories.

#### D. QR Code Entry and Exit Validation Procedure
1. **Cryptographic Token Generation** — Upon reservation approval, the system generates an encrypted, time-bounded opaque QR token (HMAC-SHA256) referencing the reservation record without exposing raw personal user information.
2. **Arrival Check-In (Entry Validation)** — The driver's QR code is scanned by the parking space provider upon arrival. The backend authenticates the cryptographic signature, verifies that the scanning provider matches the assigned space, confirms the reservation status is "Approved", checks that the arrival is within the allowed entry window, records the `time_in` timestamp, updates the slot state to "Occupied", and invalidates the entry state to prevent replay attacks.
3. **Departure Check-Out (Exit Validation)** — The QR code is scanned again by the parking space provider upon departure. Once a reservation is confirmed as "Checked-In," the system records the `time_out`, determines the total parking duration, changes the reservation status to "Completed," and releases the parking slot by setting it back to "Available."
4. **Manual Code Fallback** — If the mobile camera or QR code is unreadable, the provider enters the unique alphanumeric reservation code into the provider interface to execute the validation sequence.

#### E. Payment Settlement Procedure (Cash and GCash Gateway)
1. **Automated Fee Computation** — Upon successful exit scanning, the automated billing engine computes the total charges based on elapsed duration, vehicle category, approved hourly rates, grace periods, and applicable overstay fees.
2. **Payment Method Selection** — The driver selects either Cash or GCash Payment Gateway on the mobile application.
3. **Cash Payment Settlement** — The driver pays the exact computed amount in cash directly to the provider, who confirms receipt on their device, updating the transaction status to "Paid".
4. **GCash Gateway Settlement** — If the driver selects digital payment, they are redirected to the secure GCash Payment Gateway (via PayMongo API v1). Upon successful authorization, the gateway dispatches an automated webhook callback to the Laravel backend, which verifies the transaction signature and immediately marks the status as "Paid".
5. **Digital Receipt Generation** — The system automatically generates a digital receipt containing the transaction reference number, duration breakdown, and payment timestamp, archiving the record in the centralized database.

#### F. System Maintenance and Security Procedure
1. **Database Persistence and Backup** — Regular automated backups of the Supabase PostgreSQL database are performed to ensure transaction integrity and data recovery.
2. **API and Server Monitoring** — Backend server performance, RESTful API response latencies, and WebRTC signaling endpoints are continuously monitored to prevent downtime.
3. **Security and Access Enforcement** — Laravel Sanctum token expirations, Role-Based Access Control (RBAC) middleware, and protected media storage routes are maintained to safeguard user credentials, identification documents, and transaction records.

---

### Testing Environment and Setup

The testing environment for E-Parada is configured as a software-driven ecosystem operating across consumer mobile devices, web browsers, and cloud server infrastructure without reliance on dedicated physical IoT sensor hardware or automated gate barriers. Testing is conducted using both simulated environments (for automated unit, concurrency, and cross-version regression testing) and physical Android hardware (for validating camera QR scanning, OCR plate extraction, GPS navigation, and WebRTC voice communication).

#### Device Testing
The Android Studio built-in emulator and physical Android smartphones running Android 8.0 or higher are used for testing. Physical devices ensure accurate validation of hardware-dependent modules—including GPS/geolocation, Google Maps routing, camera-based QR scanning, vehicle plate OCR capture, microphone access, and in-app WebRTC audio calling—while the emulator supports rapid UI testing across multiple screen resolutions. The web portal is tested across modern desktop and mobile web browsers to verify cross-platform consistency and real-time synchronization with the mobile application.

#### Backend and Database Configuration
For the E-Parada backend, PHP 8.2 and Laravel 12 are employed, while Supabase (managed PostgreSQL 15+) serves as the relational database for system integration testing, performance benchmarking, and end-to-end scenario evaluation. Supabase provides the ACID-compliant transactional environment and row-level locking needed to handle multi-user concurrency. Laravel manages the administrative web portal, RESTful API endpoints, authentication, validation, and application logic, while the Flutter mobile client communicates with the backend over HTTPS using JSON payloads.

#### Network Conditions
Testing is conducted under varying network conditions, including high-speed broadband Wi-Fi, cellular mobile data (4G/LTE), and simulated low-bandwidth or throttled connections. High-speed Wi-Fi establishes baseline system performance, while 4G/LTE represents typical real-world mobile connectivity for drivers and parking providers. Low-bandwidth conditions are simulated to assess the system’s timeout handling, error notifications, and graceful degradation across reservation synchronization, API connectivity, Google Maps services, in-app messaging, and WebRTC audio communication.

---

### Testing Phases

System testing is conducted across three sequential phases aligned with the Incremental Development Model:

**Table 3**  
*System Testing Phases and Acceptance Criteria*

| Testing Phase | Scope and Methodology | Pass/Fail Acceptance Criteria |
| :--- | :--- | :--- |
| **Alpha Testing (Unit & Modular)** | Internal modular testing conducted by the development team across all five increments (Auth, Listings, Maps, QR Validation, Automated Billing, GCash Gateway, and WebRTC). | • 100% pass rate on core authentication, reservation, and billing unit test suites.<br>• Zero critical database integrity violations or fatal unhandled exceptions. |
| **System & Scenario Evaluation (End-to-End Technical Validation)** | End-to-end operational and technical evaluation conducted by purposively selected IT developers executing complete multi-role workflows (Driver, Parking Space Provider, and Administrator scenarios). | • ≥ 95% successful completion rate across end-to-end role journeys (registration and search to QR check-out and payment).<br>• Zero occurrences of unresolved double bookings or unrecorded payments. |
| **Regression Testing** | Automated and manual re-testing of previously verified modules after bug fixes, code refactoring, or new increment integrations. | • 100% pass on all existing test cases; zero regression bugs in reservation states and billing math. |

Alpha Testing is conducted internally by the development team during each of the five development increments. Unit and module-level tests are performed to verify core functions, database consistency, and RESTful API operations. Critical functions must achieve a 100% passing rate before proceeding to integration with subsequent modules.

System and Scenario Evaluation is carried out with purposively selected IT developers and software professionals. Evaluators execute complete end-to-end workflows across all user roles (Driver, Parking Space Provider, and System Administrator) under realistic operating conditions to evaluate the platform’s functional completeness, performance efficiency, usability, and reliability. A minimum scenario completion rate of 95% with zero concurrency double-bookings is enforced as the acceptance criterion.

Regression Testing is performed whenever modifications are introduced to the system, including code optimizations, bug fixes, and dependency updates, confirming that new changes do not negatively affect previously verified reservation workflows, billing computations, or database operations.

---

### Test Case Coverage

**Table 4**  
*Test Case Coverage Matrix*

| Test Category | Test Case Identifier & Scope | Expected Result / Validation Criteria |
| :--- | :--- | :--- |
| **Authentication & RBAC** | **TC-01**: User registration, login, and token issuance | Successful Sanctum token generation and role redirection. |
| | **TC-02**: Unauthorized route access enforcement | Drivers and providers are blocked with HTTP 403 when attempting to access administrative API endpoints. |
| **Vehicle Registration & OCR** | **TC-03**: Vehicle plate character extraction via OCR | Tesseract OCR extracts alphanumeric characters with ≥ 90% accuracy; user confirms or edits plate data before submission. |
| | **TC-04**: Duplicate vehicle registration check | System rejects duplicate active vehicle registrations for the same license plate number. |
| **Listing & 2D Slot Visualization** | **TC-05**: Space listing and rate boundary validation | The system prevents providers from saving parking rates outside administrator-approved price boundaries. |
| | **TC-06**: Interactive 2D floor plan slot grid rendering | Responsive 2D parking layout and lane aisles render dynamically across mobile and web interfaces without layout overflow or memory degradation. |
| **Search & Navigation** | **TC-07**: Proximity search and vehicle compatibility filtering | Query returns only parking spaces matching the driver's vehicle dimensions and proximity radius. |
| | **TC-08**: Google Maps route guidance and GPS tracking | Accurate map pin display and route calculation to the destination. |
| **Reservation & Concurrency** | **TC-09**: Standard reservation booking and provider approval | Slot status updates to "Reserved" upon provider acceptance; encrypted QR token is generated. |
| | **TC-10**: Concurrent booking stress test (Race Condition) | When two drivers attempt to book the exact same slot for overlapping time windows simultaneously, database row locking (`SELECT ... FOR UPDATE`) grants one booking and gracefully rejects the second. |
| **QR Validation & Security** | **TC-11**: Valid QR entry and exit validation | Scanning valid QR logs `time_in` and `time_out` timestamps; updates slot state from "Occupied" to "Available". |
| | **TC-12**: QR Replay Attack Prevention | Attempting to scan a previously used or expired QR code is rejected with an "Access Denied: Token Already Used" error. |
| | **TC-13**: Unauthorized provider scan attempt | Attempting to scan a driver's QR code using an unauthorized provider device is rejected with an "Unauthorized Space" error. |
| | **TC-14**: Manual alphanumeric reservation code fallback | Provider successfully logs entry/exit by entering the reservation code when camera scanning is unavailable. |
| **Billing & Payment Gateway** | **TC-15**: Automated duration, grace period, and billing calculation | Accurate fee computation applying 15-minute grace period and applicable overstay rate multipliers. |
| | **TC-16**: Cash payment settlement confirmation | Provider confirms cash receipt on dashboard; transaction status updates to "Paid" and issues digital receipt. |
| | **TC-17**: GCash Payment Gateway automated checkout & webhook | Driver completes checkout via GCash gateway; automated webhook callback confirms payment and marks status as "Paid". |
| **In-App Communication** | **TC-18**: Reservation-bound text messaging | In-app messaging is active only between driver and provider during an active, approved reservation. |
| | **TC-19**: WebRTC one-to-one voice calling | Successful audio call connection with low latency (< 250 ms) and functional mute/end controls. |
| **Network & Exception Handling** | **TC-20**: Network disconnection and API timeout handling | Application displays intuitive error dialogue and preserves session state during temporary internet drops. |

The test coverage matrix defines specific validation requirements for both normal system operations and critical edge-case scenarios. Aside from core functions such as user authentication, vehicle OCR processing, interactive 2D parking slot mapping, and Google Maps navigation, the matrix gives particular attention to system security and concurrent transactions. TC-10 assesses the system’s ability to prevent double-booking when multiple requests attempt to reserve the same parking slot simultaneously by applying database row-level locking through `SELECT ... FOR UPDATE`. Security-related test cases, including TC-02, TC-12, and TC-13, verify that unauthorized API access is denied, reused QR codes are rejected through single-use token invalidation, and scanning attempts made by unauthorized parking providers are blocked. In addition, TC-15 to TC-20 examine the accuracy of parking duration and overstay billing computations, real-time processing of GCash payment webhooks, WebRTC audio communication performance, and the system’s ability to handle network interruptions without causing operational failures.

---

### EVALUATION

#### Evaluation Criteria

The **ISO/IEC 25010:2011 Software Product Quality Model** is utilized to evaluate E-Parada. To assess the technical quality of the developed mobile application and administrative web portal, the system is evaluated by purposively selected IT developers across four core software quality characteristics: **Functional Suitability**, **Performance Efficiency**, **Usability**, and **Reliability**.

To ensure a rigorous engineering assessment, the evaluation combines objective technical performance benchmarking (measuring API response latencies, execution speeds, and concurrency resilience) with structured expert software quality evaluation conducted by IT developers.

#### ISO/IEC 25010:2011 Software Product Quality Framework

* **Functional Suitability.** This criterion determines the degree to which E-Parada provides functions that meet stated and implied needs when used under specified conditions. Features including authentication, OCR vehicle registration, space/slot listing, interactive 2D slot mapping, Google Maps routing, QR entry/exit validation, automated duration billing, cash and GCash payment gateway settlement, and WebRTC voice communication are assessed under this criterion.
* **Performance Efficiency.** This criterion determines the performance of E-Parada relative to the amount of resources used under stated conditions. It assesses the time behavior (response and processing times), resource utilization, and capacity of the mobile application, web portal, and backend RESTful API under standard and concurrent workloads.
* **Usability.** This criterion determines the degree to which E-Parada can be understood, learned, operated, and attractive to users across the driver, parking space provider, and administrator interfaces, including built-in user error protection and accessibility.
* **Reliability.** This criterion determines the degree to which E-Parada performs specified functions under specified conditions for a specified period of time. It assesses operational maturity, availability, fault tolerance against network drops or invalid inputs, and data recoverability across reservation records, slot states, QR logs, and payment transactions.

---

#### Objective Technical Performance Benchmarks

Alongside the ISO/IEC 25010:2011 evaluation, objective technical benchmarking is conducted across six critical system operations. The benchmark metrics, target thresholds, measurement instruments, and evaluated components are summarized in Table 5:

**Table 5**  
*Objective System Performance Benchmarks*

| Performance Metric | Evaluation Target Threshold | Measurement Instrument / Harness | Evaluated Architectural Component |
| :--- | :--- | :--- | :--- |
| **REST API Latency** | Mean Response < 350 ms under 50 req/s | Apache JMeter / Postman Collection Runner | Laravel 12 API & Supabase Connection Pooling |
| **QR Validation Speed** | Total validation latency < 600 ms | Physical Android Benchmark Timer | Base64 Decode, HMAC-SHA256 Recomputation |
| **Concurrency Resilience** | Zero double-booking under 25 simultaneous requests | Automated Python Concurrency Simulation Script | PostgreSQL Row-Level Lock (`SELECT ... FOR UPDATE`) |
| **OCR Extraction Latency** | Execution < 1.8 s; Character Precision ≥ 90% | Automated test harness across 50 sample plate photos | Tesseract OCR Server/CLI Engine |
| **WebRTC Audio Latency** | End-to-end packet latency < 200 ms | Chrome WebRTC Internals & Packet Logger | Flutter WebRTC P2P / Relayed Session |
| **Payment Webhook Latency** | Webhook round-trip < 1.2 s | PayMongo Webhook Logger | PayMongo API v1 Event Listener |

---

#### Evaluation Instrument

The primary evaluation instrument is a structured, five-point Likert scale software quality assessment questionnaire adapted directly from the **ISO/IEC 25010:2011 Software Product Quality Model** and administered to IT developers. Because the instrument utilizes internationally standardized ISO/IEC 25010:2011 quality sub-characteristics, construct validity is established by standard definition.

The following five-point Likert Scale is used in scoring the evaluation items:

| Scale | Verbal Interpretation |
| :---: | :--- |
| **5** | Strongly Agree |
| **4** | Agree |
| **3** | Neutral |
| **2** | Disagree |
| **1** | Strongly Disagree |

The evaluation questionnaire contains the following sections:

---

**Part I. Evaluator Information**

Name (Optional): \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_  
Current Position / Title: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Technical Specialization:**  
☐ Software / Full-Stack Developer  
☐ Mobile / Frontend Developer  
☐ Backend / Database Engineer  
☐ QA Engineer / Systems & IT Specialist  

**Years of Software / IT Experience:**  
☐ 1 – 2 Years  
☐ 3 – 5 Years  
☐ More than 5 Years  

---

**Part II. ISO/IEC 25010:2011 Software Product Quality Evaluation**

**Direction:**  
After testing the E-Parada mobile application and administrative web portal across the Driver, Parking Space Provider, and Administrator workflows, please evaluate the system by placing a check (✔) on the number that best corresponds to your technical assessment.

**A. Functional Suitability**

| Statements | 5 | 4 | 3 | 2 | 1 |
| :--- | :-: | :-: | :-: | :-: | :-: |
| **1. Functional Completeness:** Degree to which the set of functions (registration, OCR, 2D slot mapping, reservation, QR validation, automated billing, GCash checkout, and WebRTC communication) covers all specified tasks and objectives. | | | | | |
| **2. Functional Correctness:** Degree to which the system provides accurate results with the needed degree of precision (e.g., exact duration fee computation, overstay math, and conflict-free slot locking). | | | | | |
| **3. Functional Appropriateness:** Degree to which the implemented functions facilitate the accomplishment of specified tasks across Driver, Provider, and Administrator roles. | | | | | |

**B. Performance Efficiency**

| Statements | 5 | 4 | 3 | 2 | 1 |
| :--- | :-: | :-: | :-: | :-: | :-: |
| **4. Time Behavior:** Degree to which API response times, QR code validation speed, map rendering, and real-time status updates meet latency requirements when performing functions. | | | | | |
| **5. Resource Utilization:** Degree to which the mobile client and web portal utilize device memory, CPU, network bandwidth, and database connections efficiently. | | | | | |
| **6. Capacity:** Degree to which the database and backend architecture handle concurrent reservation requests, multiple active parking sessions, and simultaneous user connections without degradation. | | | | | |

**C. Usability**

| Statements | 5 | 4 | 3 | 2 | 1 |
| :--- | :-: | :-: | :-: | :-: | :-: |
| **7. Appropriateness Recognizability:** Degree to which users and evaluators can recognize whether the platform and its role-specific modules are appropriate for their parking management needs. | | | | | |
| **8. Learnability:** Degree to which the mobile application and web dashboard can be easily learned and navigated to accomplish core tasks. | | | | | |
| **9. Operability:** Degree to which the system has attributes that make it easy to operate and control (e.g., interactive 2D slot selection, one-tap QR scanning, and clear reservation progress tracking). | | | | | |
| **10. User Error Protection:** Degree to which the system protects users against making errors (e.g., form input validation, fee boundary checks, and prevention of double bookings). | | | | | |
| **11. User Interface Aesthetics:** Degree to which the mobile and web user interfaces present a clean, cohesive, and visually pleasing design. | | | | | |
| **12. Accessibility:** Degree to which the platform interfaces, readable typography, and status indicators can be effectively used across diverse Android devices and web browsers. | | | | | |

**D. Reliability**

| Statements | 5 | 4 | 3 | 2 | 1 |
| :--- | :-: | :-: | :-: | :-: | :-: |
| **13. Maturity:** Degree to which the system meets needs for reliability under normal operation without unhandled runtime exceptions or crashes. | | | | | |
| **14. Availability:** Degree to which the mobile application, Laravel REST API, and Supabase PostgreSQL database are operational and accessible when required for use. | | | | | |
| **15. Fault Tolerance:** Degree to which the system operates as intended despite the presence of network fluctuations, invalid QR scan attempts, or fallback to manual reservation code entry. | | | | | |
| **16. Recoverability:** Degree to which, in the event of an interruption or connection drop, the system can re-establish its state and recover affected transaction and reservation data directly from the centralized database. | | | | | |

---

The evaluation instrument is administered to the purposively selected IT developers after they inspect and test the appropriate features of the mobile application and administrative web portal. The ratings gathered from the ISO/IEC 25010:2011 characteristics are used to determine the overall software quality of the developed system using the weighted mean and standard deviation.

---

### Statistical Treatment and Interpretation of Data

This section presents the statistical methods and computation formulas used to analyze the evaluation data for **“E-Parada: A Digital Marketplace for Parking Spaces.”** The ratings gathered from the IT developer evaluation questionnaire are analyzed using descriptive statistical measures across the four selected ISO/IEC 25010:2011 software quality characteristics: Functional Suitability, Performance Efficiency, Usability, and Reliability.

1. **Frequency and Percentage Distribution**: Used to tabulate and profile the professional background of the IT developer evaluators (technical specialization and years of experience). The formula is expressed as:

$$P = \left(\frac{f}{N}\right) \times 100$$

Where:
* $P$ = Percentage distribution (%)
* $f$ = Frequency of evaluators in a specific category
* $N$ = Total number of IT developer evaluators

2. **Weighted Mean**: Used to calculate the central tendency and overall average rating for each individual indicator and software quality characteristic. The formula is expressed as:

$$\bar{X} = \frac{\sum fx}{N}$$

Where:
* $\bar{X}$ = Weighted Mean
* $f$ = Frequency of responses for each scale weight
* $x$ = Weight assigned to each response ($1\text{–}5$)
* $N$ = Total number of IT developer evaluators

3. **Standard Deviation ($SD$)**: Used to determine the degree of dispersion or variability of the IT developer ratings around the weighted mean, assessing the consistency of expert evaluations. The formula is expressed as:

$$SD = \sqrt{\frac{\sum (X - \bar{X})^2}{N - 1}}$$

Where:
* $SD$ = Sample Standard Deviation
* $X$ = Individual rating from an evaluator
* $\bar{X}$ = Sample mean
* $N$ = Total number of IT developer evaluators

4. **Scale and Verbal Interpretation Matrix**: To interpret the computed weighted means systematically, a five-point Likert scale with corresponding weighted mean intervals is established. Table 6 outlines the scale ranges alongside their respective ISO/IEC 25010:2011 software quality ratings:

**Table 6**  
*Likert Scale Range and Verbal Interpretation Matrix*

| Numerical Scale | Weighted Mean Range | ISO/IEC 25010:2011 Software Quality Rating | Qualitative Level |
| :---: | :---: | :--- | :--- |
| **5** | 4.21 – 5.00 | Excellent / Highly Compliant | Outstanding software quality. |
| **4** | 3.41 – 4.20 | Very Good / Compliant | High software quality. |
| **3** | 2.61 – 3.40 | Fair / Moderately Compliant | Moderate software quality. |
| **2** | 1.81 – 2.60 | Poor / Low Compliance | Substandard software quality. |
| **1** | 1.00 – 1.80 | Very Poor / Non-Compliant | Unacceptable software quality. |
