import os

def generate_word_ready_doc():
    doc_path = r'c:\Users\kimch\e_parada_mobile\E_PARADA_PAGES_126_TO_149_WORD_READY.doc'
    
    html_doc = """<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
<head>
<meta charset="utf-8">
<title>E-Parada Revised Chapter 3 (Pages 126-149)</title>
<style>
  @page {
    size: 8.5in 11in;
    margin: 1in 1in 1in 1.5in;
  }
  body {
    font-family: "Times New Roman", Times, serif;
    font-size: 12pt;
    line-height: 200%;
    color: #000000;
  }
  p {
    margin-top: 0pt;
    margin-bottom: 12pt;
    text-align: justify;
    line-height: 200%;
  }
  p.indent {
    text-indent: 0.5in;
  }
  h3 {
    font-family: "Times New Roman", Times, serif;
    font-size: 12pt;
    font-weight: bold;
    margin-top: 18pt;
    margin-bottom: 6pt;
    text-align: left;
  }
  h4 {
    font-family: "Times New Roman", Times, serif;
    font-size: 12pt;
    font-weight: bold;
    margin-top: 12pt;
    margin-bottom: 6pt;
    text-align: left;
  }
  ol, ul {
    margin-top: 0pt;
    margin-bottom: 12pt;
    line-height: 200%;
  }
  li {
    text-align: justify;
    margin-bottom: 6pt;
  }
  /* APA Table Style */
  table.apa {
    width: 100%;
    border-collapse: collapse;
    margin-top: 6pt;
    margin-bottom: 18pt;
    font-family: "Times New Roman", Times, serif;
    font-size: 11pt;
    line-height: 130%;
    border-top: 1.5pt solid #000000;
    border-bottom: 1.5pt solid #000000;
  }
  table.apa th {
    border-bottom: 1pt solid #000000;
    padding: 6pt 8pt;
    text-align: left;
    font-weight: bold;
    vertical-align: top;
  }
  table.apa td {
    padding: 6pt 8pt;
    text-align: left;
    vertical-align: top;
  }
  /* Boxed Questionnaire Table Style */
  table.grid {
    width: 100%;
    border-collapse: collapse;
    margin-top: 6pt;
    margin-bottom: 16pt;
    font-family: "Times New Roman", Times, serif;
    font-size: 11pt;
    line-height: 130%;
    border: 1pt solid #000000;
  }
  table.grid th, table.grid td {
    border: 1pt solid #000000;
    padding: 6pt 8pt;
    vertical-align: middle;
  }
  .center {
    text-align: center;
  }
  .formula {
    text-align: center;
    font-family: "Cambria Math", "Times New Roman", serif;
    font-size: 13pt;
    font-weight: bold;
    margin: 14pt 0pt;
  }
</style>
</head>
<body>

<p class="indent">Following development, Phase 3 (System Integration and Testing) connects the Android mobile application and administrative web portal to the centralized Laravel REST API and Supabase PostgreSQL database, where complete functional, security, and performance stress tests are conducted. Integration testing validates the end-to-end reservation and payment pipeline, verifying that slot state transitions, PayMongo webhook callbacks, and Supabase WebSocket broadcasts execute deterministically across both native Android devices and web viewports. In Phase 4 (System Evaluation), the integrated platform is evaluated by purposively selected IT developers using the ISO/IEC 25010:2011 Software Product Quality Model (assessing Functional Suitability, Performance Efficiency, Usability, and Reliability), with gathered evaluation ratings analyzed using the weighted mean. Finally, Phase 5 (Output) delivers the complete, evaluated E-Parada system, comprising the Android mobile application for drivers and parking space providers and the centralized administrative web portal.</p>

<h3>Data Collection</h3>

<p>This section outlines the operational test locale, evaluator selection, sampling technique, data gathering procedures, evaluation instrument, and ethical considerations utilized in validating the E-Parada system. The study performs functional scenario validation, objective technical benchmarking, and ISO/IEC 25010:2011 software product quality evaluation conducted by IT developers.</p>

<h3>Research Locale</h3>

<p class="indent">Calamba City, Laguna, Philippines serves as the operational context and spatial simulation locale for the study. Due to its rapid urban growth, high concentration of educational institutions (including National University Laguna), major transport terminals, and bustling commercial districts, the area experiences acute parking shortages and roadside congestion. All geospatial coordinates, Google Maps routing tests, and residential/commercial parking space listings modeled and tested within the E-Parada platform are anchored within Calamba City.</p>

<h3>Evaluators and Sampling Technique</h3>

<p class="indent">To ensure a rigorous and technically grounded assessment of the platform’s software architecture, database integrity, and functional execution, the study utilizes Purposive Sampling to select qualified IT Developers and Software Engineering Professionals as system evaluators. Rather than relying on general end-user surveys, evaluators are purposively selected based on their technical expertise in mobile and web application engineering, relational database management, RESTful API integration, and software quality assurance.</p>

<p class="indent">During the evaluation phase, the participating IT developers perform comprehensive, role-based scenario walkthroughs across both the Flutter Android mobile application and the Laravel administrative web portal—simulating the complete operational workflows of Drivers, Parking Space Providers, and System Administrators. Following hands-on technical inspection, code and security review, and execution of predefined test cases, the evaluators rate the platform using the standardized ISO/IEC 25010:2011 Software Product Quality Model across four core dimensions: Functional Suitability, Performance Efficiency, Usability, and Reliability.</p>

<h3>Data Gathering Procedures</h3>

<p>Data collection and technical validation were executed in two primary phases:</p>

<ol>
  <li><b>Requirements Analysis Phase:</b> Conducted through domain analysis of urban parking workflows in Calamba City, environmental inspection of residential and commercial parking constraints, and a comprehensive review of existing smart parking literature. These technical insights established the functional specifications, vehicle dimension filtering rules, fee boundary parameters, and relational database schema of E-Parada.</li>
  <li><b>System Validation and Technical Evaluation Phase:</b> Following end-to-end system integration, the selected IT developers interacted directly with the working Android mobile application and administrative web portal across predefined operational scenarios (account registration, Tesseract OCR plate extraction, 2D floor plan slot mapping, Google Maps routing, HMAC-SHA256 QR check-in/check-out validation, automated duration billing, GCash payment gateway settlement, and WebRTC communication). After executing all test cases and auditing objective performance benchmarks, the IT developers accomplished the structured ISO/IEC 25010:2011 evaluation instrument.</li>
</ol>

<h3>Ethical Considerations and Data Privacy</h3>

<p class="indent">The Philippine Data Privacy Act of 2012 (Republic Act No. 10173) is strictly complied with throughout all system testing and evaluation procedures. Prior to conducting the evaluation, informed consent is obtained from all participating IT developers, outlining the research objectives, voluntary nature of participation, and confidentiality terms. During scenario testing, synthetic user profiles and consent-authorized developer test vehicles are utilized to ensure no unauthorized personally identifiable information (PII) is exposed. Within the platform, all uploaded identification documents, vehicle photographs, and transaction logs are protected via role-based access control (RBAC) and encrypted storage accessible exclusively to authorized administrators. All evaluation scores and feedback submitted by the IT evaluators are anonymized during statistical tabulation.</p>

<h3>OPERATION AND TESTING PROCEDURE</h3>

<h4>System Operation Procedure</h4>

<p class="indent">This section outlines the operational workflows of the E-Parada platform, categorized according to the distinct roles of Drivers, Parking Space Providers, and System Administrators, alongside the automated QR validation and payment gateway procedures.</p>

<h4>A. Driver Operation Procedure</h4>
<ol>
  <li><b>Application Launch and Authentication</b> — The driver opens the E-Parada mobile application on an Android device and logs in using registered credentials or completes new user registration by submitting their name, email, contact number, password, and valid identification card for administrative review.</li>
  <li><b>OCR-Assisted Vehicle Registration</b> — The driver registers their vehicle by uploading front and rear vehicle photographs. The integrated Tesseract OCR automatically extracts the license plate characters, which the driver reviews, confirms, and submits for administrator verification.</li>
  <li><b>Parking Search and Discovery</b> — The driver searches for available parking spaces by entering a target destination, filtering by distance, vehicle compatibility, spatial dimensions, and hourly rates, or browsing active pins on the Google Maps interface.</li>
  <li><b>Space Inspection and 2D Slot Map Viewing</b> — The driver selects a listing to view detailed facility descriptions, operating schedules, pricing, provider details, and the interactive 2D parking lot lane and slot layout.</li>
  <li><b>Reservation Request</b> — The driver selects an available slot, chooses a registered vehicle, specifies the reservation date, start time, and expected duration, and submits the booking request.</li>
  <li><b>Confirmation and QR Pass Issuance</b> — Once the parking space provider approves the request, the system generates an encrypted, time-bounded QR access pass accessible under the driver's "My Reservations" dashboard.</li>
  <li><b>GPS Route Navigation</b> — The driver utilizes the integrated Google Maps navigation to obtain turn-by-turn driving directions to the reserved parking space.</li>
  <li><b>In-App Communication</b> — If coordination is needed, the driver communicates with the assigned provider via reservation-bound in-app text messaging or WebRTC audio calling.</li>
  <li><b>Check-In and Check-Out Scanning</b> — Upon arrival, the driver presents the QR pass to the provider for entry scanning (logging time-in), and presents it again upon departure for exit scanning (logging time-out).</li>
  <li><b>Billing Review and Payment</b> — The driver reviews the automatically computed bill and settles the balance using cash or the integrated GCash Payment Gateway, receiving an instant digital transaction receipt.</li>
</ol>

<h4>B. Parking Space Provider Operation Procedure</h4>
<ol>
  <li><b>Provider Onboarding and Verification</b> — The provider registers an account via the mobile application or web portal, submits proof of property ownership and valid identification, and awaits administrative verification.</li>
  <li><b>Space and Slot Listing Management</b> — The verified provider creates parking listings by entering property addresses, uploading facility images, specifying spatial dimensions, configuring the 2D slot layout, defining operating hours, and setting individual slot rates within administrator-approved boundaries.</li>
  <li><b>Reservation Management</b> — The provider receives real-time notifications for incoming booking requests, reviews driver and vehicle profiles, and accepts or rejects reservations within a predefined response window.</li>
  <li><b>Entry and Exit Validation</b> — The provider uses the built-in in-app scanner to scan the driver's QR access pass upon arrival to log the time-in (updating slot status to "Occupied") and upon departure to log the time-out (updating slot status to "Available"). If camera scanning is unavailable, the provider manually inputs the alphanumeric reservation code.</li>
  <li><b>Payment and Earnings Tracking</b> — For cash settlements, the provider collects the fee and marks the transaction as "Paid" in the dashboard. For GCash transactions, payment confirmation is received automatically via the payment gateway. The provider monitors active sessions, overstay logs, and cumulative earnings through the provider dashboard.</li>
  <li><b>Driver Coordination</b> — The provider communicates with confirmed drivers through reservation-bound in-app messaging and WebRTC voice calls.</li>
</ol>

<h4>C. System Administrator Operation Procedure</h4>
<ol>
  <li><b>Administrative Authentication</b> — The system administrator securely logs in to the web-based Admin Dashboard or mobile admin view using authenticated credentials.</li>
  <li><b>User, Provider, and Vehicle Verification</b> — The administrator reviews pending account submissions, inspects uploaded identification cards and property documents, verifies OCR-extracted vehicle plate numbers, and approves or rejects registrations.</li>
  <li><b>Parking Listing and Rate Governance</b> — The administrator audits newly submitted parking listings for accuracy and sets the allowable minimum and maximum parking rate boundaries for the platform.</li>
  <li><b>Platform Monitoring and Audit Logging</b> — The administrator monitors platform activities in real time, including active bookings, QR validation audit trails, automated billing summaries, payment gateway transaction logs, user complaints, and system security alerts.</li>
  <li><b>Analytics and Reporting</b> — The administrator generates and exports operational CSV reports concerning platform utilization, transaction summaries, forensic time-in/time-out logs, and violation histories.</li>
</ol>

<h4>D. QR Code Entry and Exit Validation Procedure</h4>
<ol>
  <li><b>Cryptographic Token Generation</b> — Upon reservation approval, the system generates an encrypted, time-bounded opaque QR token (HMAC-SHA256) referencing the reservation record without exposing raw personal user information.</li>
  <li><b>Arrival Check-In (Entry Validation)</b> — The driver's QR code is scanned by the parking space provider upon arrival. The backend authenticates the cryptographic signature, verifies that the scanning provider matches the assigned space, confirms the reservation status is "Approved", checks that the arrival is within the allowed entry window, records the time-in timestamp, updates the slot state to "Occupied", and invalidates the entry state to prevent replay attacks.</li>
  <li><b>Departure Check-Out (Exit Validation)</b> — The QR code is scanned again by the parking space provider upon departure. Once a reservation is confirmed as “Checked-In,” the system records the time-out, determines the total parking duration, changes the reservation status to “Completed,” and releases the parking slot by setting it back to “Available.”</li>
  <li><b>Manual Code Fallback</b> — If the mobile camera or QR code is unreadable, the provider enters the unique alphanumeric reservation code into the provider interface to execute the validation sequence.</li>
</ol>

<h4>E. Payment Settlement Procedure (Cash and GCash Gateway)</h4>
<ol>
  <li><b>Automated Fee Computation</b> — Upon successful exit scanning, the automated billing engine computes the total charges based on elapsed duration, vehicle category, approved hourly rates, grace periods, and applicable overstay fees.</li>
  <li><b>Payment Method Selection</b> — The driver selects either Cash or GCash Payment Gateway on the mobile application.</li>
  <li><b>Cash Payment Settlement</b> — The driver pays the exact computed amount in cash directly to the provider, who confirms receipt on their device, updating the transaction status to "Paid".</li>
  <li><b>GCash Gateway Settlement</b> — If the driver selects digital payment, they are redirected to the secure GCash Payment Gateway (via PayMongo API v1). Upon successful authorization, the gateway dispatches an automated webhook callback to the Laravel backend, which verifies the transaction signature and immediately marks the status as "Paid".</li>
  <li><b>Digital Receipt Generation</b> — The system automatically generates a digital receipt containing the transaction reference number, duration breakdown, and payment timestamp, archiving the record in the centralized database.</li>
</ol>

<h4>F. System Maintenance and Security Procedure</h4>
<ol>
  <li><b>Database Persistence and Backup</b> — Regular automated backups of the Supabase PostgreSQL database are performed to ensure transaction integrity and data recovery.</li>
  <li><b>API and Server Monitoring</b> — Backend server performance, RESTful API response latencies, and WebRTC signaling endpoints are continuously monitored to prevent downtime.</li>
  <li><b>Security and Access Enforcement</b> — Laravel Sanctum token expirations, Role-Based Access Control (RBAC) middleware, and protected media storage routes are maintained to safeguard user credentials, identification documents, and transaction records.</li>
</ol>

<h3>Testing Environment and Setup</h3>

<p class="indent">The testing environment for E-Parada is configured as a software-driven ecosystem operating across consumer mobile devices, web browsers, and cloud server infrastructure without reliance on dedicated physical IoT sensor hardware or automated gate barriers. Testing is conducted using both simulated environments (for automated unit, concurrency, and cross-version regression testing) and physical Android hardware (for validating camera QR scanning, OCR plate extraction, GPS navigation, and WebRTC voice communication).</p>

<h4>Device Testing</h4>
<p class="indent">The Android Studio built-in emulator and physical Android smartphones running Android 8.0 or higher are used for testing. Physical devices ensure accurate validation of hardware-dependent modules—including GPS/geolocation, Google Maps routing, camera-based QR scanning, vehicle plate OCR capture, microphone access, and in-app WebRTC audio calling—while the emulator supports rapid UI testing across multiple screen resolutions. The web portal is tested across modern desktop and mobile web browsers to verify cross-platform consistency and real-time synchronization with the mobile application.</p>

<h4>Backend and Database Configuration</h4>
<p class="indent">For the E-Parada backend, PHP 8.2 and Laravel 12 are employed, while Supabase (managed PostgreSQL 15+) serves as the relational database for system integration testing, performance benchmarking, and end-to-end scenario evaluation. Supabase provides the ACID-compliant transactional environment and row-level locking needed to handle multi-user concurrency. Laravel manages the administrative web portal, RESTful API endpoints, authentication, validation, and application logic, while the Flutter mobile client communicates with the backend over HTTPS using JSON payloads.</p>

<h4>Network Conditions</h4>
<p class="indent">Testing is conducted under varying network conditions, including high-speed broadband Wi-Fi, cellular mobile data (4G/LTE), and simulated low-bandwidth or throttled connections. High-speed Wi-Fi establishes baseline system performance, while 4G/LTE represents typical real-world mobile connectivity for drivers and parking providers. Low-bandwidth conditions are simulated to assess the system’s timeout handling, error notifications, and graceful degradation across reservation synchronization, API connectivity, Google Maps services, in-app messaging, and WebRTC audio communication.</p>

<h3>Testing Phases</h3>

<p class="indent">System testing is conducted across three sequential phases aligned with the Incremental Development Model:</p>

<p style="margin-bottom:2pt;">Table 3</p>
<p style="margin-bottom:6pt;"><i>System Testing Phases and Acceptance Criteria</i></p>

<table class="apa">
  <thead>
    <tr>
      <th style="width:26%;">Testing Phase</th>
      <th style="width:38%;">Scope and Methodology</th>
      <th style="width:36%;">Pass/Fail Acceptance Criteria</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Alpha Testing (Unit &amp; Modular)</b></td>
      <td>Internal modular testing conducted by the development team across all five increments (Auth, Listings, Maps, QR Validation, Automated Billing, GCash Gateway, and WebRTC).</td>
      <td>• 100% pass rate on core authentication, reservation, and billing unit test suites.<br>• Zero critical database integrity violations or fatal unhandled exceptions.</td>
    </tr>
    <tr>
      <td><b>System &amp; Scenario Evaluation (End-to-End Technical Validation)</b></td>
      <td>End-to-end operational and technical evaluation conducted by purposively selected IT developers executing complete multi-role workflows (Driver, Parking Space Provider, and Administrator scenarios).</td>
      <td>• ≥ 95% successful completion rate across end-to-end role journeys (registration and search to QR check-out and payment).<br>• Zero occurrences of unresolved double bookings or unrecorded payments.</td>
    </tr>
    <tr>
      <td><b>Regression Testing</b></td>
      <td>Automated and manual re-testing of previously verified modules after bug fixes, code refactoring, or new increment integrations.</td>
      <td>• 100% pass on all existing test cases; zero regression bugs in reservation states and billing math.</td>
    </tr>
  </tbody>
</table>

<p class="indent">Alpha Testing is conducted internally by the development team during each of the five development increments. Unit and module-level tests are performed to verify core functions, database consistency, and RESTful API operations. Critical functions must achieve a 100% passing rate before proceeding to integration with subsequent modules.</p>

<p class="indent">System and Scenario Evaluation is carried out with purposively selected IT developers and software professionals. Evaluators execute complete end-to-end workflows across all user roles (Driver, Parking Space Provider, and System Administrator) under realistic operating conditions to evaluate the platform’s functional completeness, performance efficiency, usability, and reliability. A minimum scenario completion rate of 95% with zero concurrency double-bookings is enforced as the acceptance criterion.</p>

<p class="indent">Regression Testing is performed whenever modifications are introduced to the system, including code optimizations, bug fixes, and dependency updates, confirming that new changes do not negatively affect previously verified reservation workflows, billing computations, or database operations.</p>

<h3>Test Case Coverage</h3>

<p style="margin-bottom:2pt;">Table 4</p>
<p style="margin-bottom:6pt;"><i>Test Case Coverage Matrix</i></p>

<table class="apa">
  <thead>
    <tr>
      <th style="width:26%;">Test Category</th>
      <th style="width:34%;">Test Case Identifier &amp; Scope</th>
      <th style="width:40%;">Expected Result / Validation Criteria</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Authentication &amp; RBAC</b></td>
      <td>TC-01: User registration, login, and token issuance</td>
      <td>Successful Sanctum token generation and role redirection.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-02: Unauthorized route access enforcement</td>
      <td>Drivers and providers are blocked with HTTP 403 when attempting to access administrative API endpoints.</td>
    </tr>
    <tr>
      <td><b>Vehicle Registration &amp; OCR</b></td>
      <td>TC-03: Vehicle plate character extraction via OCR</td>
      <td>Tesseract OCR extracts alphanumeric characters with ≥ 90% accuracy; user confirms or edits plate data before submission.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-04: Duplicate vehicle registration check</td>
      <td>System rejects duplicate active vehicle registrations for the same license plate number.</td>
    </tr>
    <tr>
      <td><b>Listing &amp; 2D Slot Visualization</b></td>
      <td>TC-05: Space listing and rate boundary validation</td>
      <td>The system prevents providers from saving parking rates outside administrator-approved price boundaries.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-06: Interactive 2D floor plan slot grid rendering</td>
      <td>Responsive 2D parking layout and lane aisles render dynamically across mobile and web interfaces without layout overflow or memory degradation.</td>
    </tr>
    <tr>
      <td><b>Search &amp; Navigation</b></td>
      <td>TC-07: Proximity search and vehicle compatibility filtering</td>
      <td>Query returns only parking spaces matching the driver's vehicle dimensions and proximity radius.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-08: Google Maps route guidance and GPS tracking</td>
      <td>Accurate map pin display and route calculation to the destination.</td>
    </tr>
    <tr>
      <td><b>Reservation &amp; Concurrency</b></td>
      <td>TC-09: Standard reservation booking and provider approval</td>
      <td>Slot status updates to "Reserved" upon provider acceptance; encrypted QR token is generated.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-10: Concurrent booking stress test (Race Condition)</td>
      <td>When two drivers attempt to book the exact same slot for overlapping time windows simultaneously, database row locking (SELECT ... FOR UPDATE) grants one booking and gracefully rejects the second.</td>
    </tr>
    <tr>
      <td><b>QR Validation &amp; Security</b></td>
      <td>TC-11: Valid QR entry and exit validation</td>
      <td>Scanning valid QR logs time_in and time_out timestamps; updates slot state from "Occupied" to "Available".</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-12: QR Replay Attack Prevention</td>
      <td>Attempting to scan a previously used or expired QR code is rejected with an "Access Denied: Token Already Used" error.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-13: Unauthorized provider scan attempt</td>
      <td>Attempting to scan a driver's QR code using an unauthorized provider device is rejected with an "Unauthorized Space" error.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-14: Manual alphanumeric reservation code fallback</td>
      <td>Provider successfully logs entry/exit by entering the reservation code when camera scanning is unavailable.</td>
    </tr>
    <tr>
      <td><b>Billing &amp; Payment Gateway</b></td>
      <td>TC-15: Automated duration, grace period, and billing calculation</td>
      <td>Accurate fee computation applying 15-minute grace period and applicable overstay rate multipliers.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-16: Cash payment settlement confirmation</td>
      <td>Provider confirms cash receipt on dashboard; transaction status updates to "Paid" and issues digital receipt.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-17: GCash Payment Gateway automated checkout &amp; webhook</td>
      <td>Driver completes checkout via GCash gateway; automated webhook callback confirms payment and marks status as "Paid".</td>
    </tr>
    <tr>
      <td><b>In-App Communication</b></td>
      <td>TC-18: Reservation-bound text messaging</td>
      <td>In-app messaging is active only between driver and provider during an active, approved reservation.</td>
    </tr>
    <tr>
      <td></td>
      <td>TC-19: WebRTC one-to-one voice calling</td>
      <td>Successful audio call connection with low latency (&lt; 250 ms) and functional mute/end controls.</td>
    </tr>
    <tr>
      <td><b>Network &amp; Exception Handling</b></td>
      <td>TC-20: Network disconnection and API timeout handling</td>
      <td>Application displays intuitive error dialogue and preserves session state during temporary internet drops.</td>
    </tr>
  </tbody>
</table>

<p class="indent">The test coverage matrix defines specific validation requirements for both normal system operations and critical edge-case scenarios. Aside from core functions such as user authentication, vehicle OCR processing, interactive 2D parking slot mapping, and Google Maps navigation, the matrix gives particular attention to system security and concurrent transactions. TC-10 assesses the system’s ability to prevent double-booking when multiple requests attempt to reserve the same parking slot simultaneously by applying database row-level locking through SELECT ... FOR UPDATE. Security-related test cases, including TC-02, TC-12, and TC-13, verify that unauthorized API access is denied, reused QR codes are rejected through single-use token invalidation, and scanning attempts made by unauthorized parking providers are blocked. In addition, TC-15 to TC-20 examine the accuracy of parking duration and overstay billing computations, real-time processing of GCash payment webhooks, WebRTC audio communication performance, and the system’s ability to handle network interruptions without causing operational failures.</p>

<h3>EVALUATION</h3>

<h4>Evaluation Criteria</h4>

<p class="indent">The <b>ISO/IEC 25010:2011 Software Product Quality Model</b> is utilized to evaluate E-Parada. To assess the technical quality of the developed mobile application and administrative web portal, the system is evaluated by purposively selected IT developers across four core software quality characteristics: Functional Suitability, Performance Efficiency, Usability, and Reliability.</p>

<p class="indent">To ensure a rigorous engineering assessment, the evaluation combines objective technical performance benchmarking (measuring API response latencies, execution speeds, and concurrency resilience) with structured expert software quality evaluation conducted by IT developers.</p>

<h4>ISO/IEC 25010:2011 Software Product Quality Framework</h4>

<p><b>Functional Suitability.</b> This criterion determines the degree to which E-Parada provides functions that meet stated and implied needs when used under specified conditions. Features including authentication, OCR vehicle registration, space/slot listing, interactive 2D slot mapping, Google Maps routing, QR entry/exit validation, automated duration billing, cash and GCash payment gateway settlement, and WebRTC voice communication are assessed under this criterion.</p>

<p><b>Performance Efficiency.</b> This criterion determines the performance of E-Parada relative to the amount of resources used under stated conditions. It assesses the time behavior (response and processing times), resource utilization, and capacity of the mobile application, web portal, and backend RESTful API under standard and concurrent workloads.</p>

<p><b>Usability.</b> This criterion determines the degree to which E-Parada can be understood, learned, operated, and attractive to users across the driver, parking space provider, and administrator interfaces, including built-in user error protection and accessibility.</p>

<p><b>Reliability.</b> This criterion determines the degree to which E-Parada performs specified functions under specified conditions for a specified period of time. It assesses operational maturity, availability, fault tolerance against network drops or invalid inputs, and data recoverability across reservation records, slot states, QR logs, and payment transactions.</p>

<h4>Objective Technical Performance Benchmarks</h4>

<p class="indent">Alongside the ISO/IEC 25010:2011 evaluation, objective technical benchmarking is conducted across six critical system operations. The benchmark metrics, target thresholds, measurement instruments, and evaluated components are summarized in Table 5:</p>

<p style="margin-bottom:2pt;">Table 5</p>
<p style="margin-bottom:6pt;"><i>Objective System Performance Benchmarks</i></p>

<table class="apa">
  <thead>
    <tr>
      <th style="width:22%;">Performance Metric</th>
      <th style="width:24%;">Evaluation Target Threshold</th>
      <th style="width:27%;">Measurement Instrument / Harness</th>
      <th style="width:27%;">Evaluated Architectural Component</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>REST API Latency</b></td>
      <td>Mean Response &lt; 350 ms under 50 req/s</td>
      <td>Apache JMeter / Postman Collection Runner</td>
      <td>Laravel 12 API &amp; Supabase Connection Pooling</td>
    </tr>
    <tr>
      <td><b>QR Validation Speed</b></td>
      <td>Total validation latency &lt; 600 ms</td>
      <td>Physical Android Benchmark Timer</td>
      <td>Base64 Decode, HMAC-SHA256 Recomputation</td>
    </tr>
    <tr>
      <td><b>Concurrency Resilience</b></td>
      <td>Zero double-booking under 25 simultaneous requests</td>
      <td>Automated Python Concurrency Simulation Script</td>
      <td>PostgreSQL Row-Level Lock (SELECT ... FOR UPDATE)</td>
    </tr>
    <tr>
      <td><b>OCR Extraction Latency</b></td>
      <td>Execution &lt; 1.8 s; Character Precision ≥ 90%</td>
      <td>Automated test harness across 50 sample plate photos</td>
      <td>Tesseract OCR Server/CLI Engine</td>
    </tr>
    <tr>
      <td><b>WebRTC Audio Latency</b></td>
      <td>End-to-end packet latency &lt; 200 ms</td>
      <td>Chrome WebRTC Internals &amp; Packet Logger</td>
      <td>Flutter WebRTC P2P / Relayed Session</td>
    </tr>
    <tr>
      <td><b>Payment Webhook Latency</b></td>
      <td>Webhook round-trip &lt; 1.2 s</td>
      <td>PayMongo Webhook Logger</td>
      <td>PayMongo API v1 Event Listener</td>
    </tr>
  </tbody>
</table>

<h4>Evaluation Instrument</h4>

<p class="indent">The primary evaluation instrument is a structured, five-point Likert scale software quality assessment questionnaire adapted directly from the ISO/IEC 25010:2011 Software Product Quality Model and administered to IT developers. Because the instrument utilizes internationally standardized ISO/IEC 25010:2011 quality sub-characteristics, construct validity is established by standard definition.</p>

<p class="indent">The following five-point Likert Scale will be used in interpreting the responses:</p>

<table class="apa" style="width:70%;">
  <thead>
    <tr>
      <th style="width:30%;">Scale</th>
      <th style="width:70%;">Verbal Interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>5</td><td>Strongly Agree</td></tr>
    <tr><td>4</td><td>Agree</td></tr>
    <tr><td>3</td><td>Neutral</td></tr>
    <tr><td>2</td><td>Disagree</td></tr>
    <tr><td>1</td><td>Strongly Disagree</td></tr>
  </tbody>
</table>

<p class="indent">The evaluation questionnaire will contain the following:</p>

<h4>Part I. Evaluator Information</h4>
<p>Name (Optional): ____________________________<br>
Current Position / Title: _______________________</p>

<p><b>Technical Specialization:</b><br>
☐ Software / Full-Stack Developer<br>
☐ Mobile / Frontend Developer<br>
☐ Backend / Database Engineer<br>
☐ QA Engineer / Systems &amp; IT Specialist</p>

<p><b>Years of Software / IT Experience:</b><br>
☐ 1 – 2 Years<br>
☐ 3 – 5 Years<br>
☐ More than 5 Years</p>

<h4>Part II. System Evaluation</h4>
<p><b>Direction:</b><br>
After testing the E-Parada mobile application and administrative web portal across the Driver, Parking Space Provider, and Administrator workflows, please evaluate the system by placing a check (✔) on the number that best describes your assessment of the system.</p>

<h4>A. Functional Suitability</h4>
<table class="grid">
  <thead>
    <tr>
      <th style="width:75%; text-align:left;">Statements</th>
      <th class="center" style="width:5%;">5</th>
      <th class="center" style="width:5%;">4</th>
      <th class="center" style="width:5%;">3</th>
      <th class="center" style="width:5%;">2</th>
      <th class="center" style="width:5%;">1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>1. Functional Completeness:</b> Degree to which the set of functions covers all the specified tasks and user objectives.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>2. Functional Correctness:</b> Degree to which a product or system provides the correct results with the needed degree of precision.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>3. Functional Appropriateness:</b> Degree to which the functions facilitate the accomplishment of specified tasks and objectives.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
  </tbody>
</table>

<h4>B. Performance Efficiency</h4>
<table class="grid">
  <thead>
    <tr>
      <th style="width:75%; text-align:left;">Statements</th>
      <th class="center" style="width:5%;">5</th>
      <th class="center" style="width:5%;">4</th>
      <th class="center" style="width:5%;">3</th>
      <th class="center" style="width:5%;">2</th>
      <th class="center" style="width:5%;">1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>4. Time Behavior:</b> Degree to which response and processing times and throughput rates meet requirements when performing functions.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>5. Resource Utilization:</b> Degree to which the amounts and types of resources used meet requirements.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>6. Capacity:</b> Degree to which the maximum limits of a product or system parameter meet requirements.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
  </tbody>
</table>

<h4>C. Usability</h4>
<table class="grid">
  <thead>
    <tr>
      <th style="width:75%; text-align:left;">Statements</th>
      <th class="center" style="width:5%;">5</th>
      <th class="center" style="width:5%;">4</th>
      <th class="center" style="width:5%;">3</th>
      <th class="center" style="width:5%;">2</th>
      <th class="center" style="width:5%;">1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>7. Appropriateness Recognizability:</b> Degree to which users can recognize whether a product or system is appropriate for their needs.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>8. Learnability:</b> Degree to which a product or system can be used by specified users to achieve specified goals of learning to use it.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>9. Operability:</b> Degree to which a product or system has attributes that make it easy to operate and control.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>10. User Error Protection:</b> Degree to which a system protects users against making errors.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>11. User Interface Aesthetics:</b> Degree to which a user interface enables pleasing and satisfying interaction for the user.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>12. Accessibility:</b> Degree to which a product or system can be used by people with the widest range of characteristics and capabilities.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
  </tbody>
</table>

<h4>D. Reliability</h4>
<table class="grid">
  <thead>
    <tr>
      <th style="width:75%; text-align:left;">Statements</th>
      <th class="center" style="width:5%;">5</th>
      <th class="center" style="width:5%;">4</th>
      <th class="center" style="width:5%;">3</th>
      <th class="center" style="width:5%;">2</th>
      <th class="center" style="width:5%;">1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>13. Maturity:</b> Degree to which a system, product, or component meets needs for reliability under normal operation.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>14. Availability:</b> Degree to which a system, product, or component is operational and accessible when required for use.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>15. Fault Tolerance:</b> Degree to which a system, product, or component operates as intended despite the presence of hardware or software faults.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
    <tr>
      <td><b>16. Recoverability:</b> Degree to which, in the event of an interruption or a failure, a product or system can recover the data directly affected and re-establish the desired state of the system.</td>
      <td></td><td></td><td></td><td></td><td></td>
    </tr>
  </tbody>
</table>

<p class="indent">The evaluation instrument will be administered to the purposively selected IT developers after they inspect and test the appropriate features of the mobile application and administrative web portal across all user roles. The responses gathered from the selected ISO/IEC 25010:2011 characteristics will be used to assess the quality of the developed system using the weighted mean.</p>

<h3>Statistical Treatment and Interpretation of Data</h3>

<p class="indent">This section presents the statistical methods and computation formulas used to evaluate the performance and quality of the proposed system, “E-Parada: A Digital Marketplace for Parking Spaces.” The data gathered from the IT developer evaluation questionnaire will be analyzed using descriptive statistical measures to determine the evaluators' assessment of the E-Parada system based on the selected ISO/IEC 25010:2011 software quality characteristics: Functional Suitability, Performance Efficiency, Usability, and Reliability.</p>

<ol>
  <li><b>Frequency and Percentage Distribution:</b> Used to tabulate and profile the professional background of the IT developer evaluators (technical specialization and years of experience). The formula is expressed as:</li>
</ol>

<div class="formula">P = ( f / N ) × 100</div>

<p>Where:<br>
<b>P</b> = Percentage distribution (%)<br>
<b><i>f</i></b> = Frequency of evaluators in a specific category<br>
<b>N</b> = Total number of IT developer evaluators</p>

<ol start="2">
  <li><b>Weighted Mean:</b> Used to calculate the central tendency and overall average rating for each individual indicator and software quality characteristic. The formula is expressed as:</li>
</ol>

<div class="formula">X̄ = ( ∑ fx ) / N</div>

<p>Where:<br>
<b>X̄</b> = Weighted Mean<br>
<b><i>f</i></b> = Frequency of responses<br>
<b>x</b> = Weight assigned to each response (1–5)<br>
<b>N</b> = Total number of IT developer evaluators</p>

<ol start="3">
  <li><b>Standard Deviation (SD):</b> Used to determine the degree of dispersion or variability of IT developer ratings around the weighted mean, assessing the consistency of responses. The formula is expressed as:</li>
</ol>

<div class="formula">SD = √[ ∑(X - X̄)² / (N - 1) ]</div>

<p>Where:<br>
<b>SD</b> = Sample Standard Deviation<br>
<b>X</b> = Each value from the sample<br>
<b>X̄</b> = The sample mean<br>
<b>N</b> = Total number of IT developer evaluators</p>

<ol start="4">
  <li><b>Scale and Verbal Interpretation Matrix:</b> To interpret the computed weighted means systematically, a five-point Likert scale with corresponding weighted mean intervals is established. Table 6 outlines the scale ranges alongside their respective ISO/IEC 25010:2011 software quality ratings:</li>
</ol>

<p style="margin-bottom:2pt;">Table 6</p>
<p style="margin-bottom:6pt;"><i>Likert Scale Range and Verbal Interpretation Matrix</i></p>

<table class="apa">
  <thead>
    <tr>
      <th style="width:18%;">Numerical Scale</th>
      <th style="width:22%;">Weighted Mean Range</th>
      <th style="width:32%;">ISO/IEC 25010:2011 Software Quality Rating</th>
      <th style="width:28%;">Qualitative Level</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>5</td>
      <td>4.21 – 5.00</td>
      <td>Excellent / Highly Compliant</td>
      <td>Outstanding software quality.</td>
    </tr>
    <tr>
      <td>4</td>
      <td>3.41 – 4.20</td>
      <td>Very Good / Compliant</td>
      <td>High software quality.</td>
    </tr>
    <tr>
      <td>3</td>
      <td>2.61 – 3.40</td>
      <td>Fair / Moderately Compliant</td>
      <td>Moderate software quality.</td>
    </tr>
    <tr>
      <td>2</td>
      <td>1.81 – 2.60</td>
      <td>Poor / Low Compliance</td>
      <td>Substandard software quality.</td>
    </tr>
    <tr>
      <td>1</td>
      <td>1.00 – 1.80</td>
      <td>Very Poor / Non-Compliant</td>
      <td>Unacceptable software quality.</td>
    </tr>
  </tbody>
</table>

</body>
</html>
"""
    with open(doc_path, 'w', encoding='utf-8') as f:
        f.write(html_doc)
    print(f"Generated Word-ready document: {doc_path}")

if __name__ == '__main__':
    generate_word_ready_doc()
