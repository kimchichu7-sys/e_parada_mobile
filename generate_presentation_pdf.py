import os
import subprocess
import shutil

def generate_presentation_outline_pdf():
    workspace = r'c:\Users\kimch\e_parada_mobile'
    html_path = os.path.join(workspace, 'scratch', 'presentation_outline_print.html')
    pdf_path = os.path.join(workspace, 'E_PARADA_PRESENTATION_OUTLINE.pdf')
    artifact_pdf = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\E_PARADA_PRESENTATION_OUTLINE.pdf'

    os.makedirs(os.path.dirname(html_path), exist_ok=True)

    html_content = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>E-Parada: Capstone Defense Presentation Outline (Copy-Paste Ready)</title>
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
    font-size: 10pt;
    line-height: 1.48;
    color: #0F172A;
    margin: 0;
    padding: 0;
  }
  /* Header Banner */
  .cover-banner {
    background: linear-gradient(135deg, #1E1B4B 0%, #432098 100%);
    color: #FFFFFF;
    padding: 22px 26px;
    border-radius: 8px;
    margin-bottom: 18px;
  }
  .cover-banner h1 {
    margin: 0 0 6px 0;
    font-size: 17pt;
    font-weight: 700;
  }
  .cover-banner p {
    margin: 2px 0;
    font-size: 10pt;
    color: #E0E7FF;
  }
  .badge-row {
    margin-top: 10px;
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }
  .badge {
    background: rgba(255, 255, 255, 0.16);
    border: 1px solid rgba(255, 255, 255, 0.3);
    color: #FFFFFF;
    padding: 2px 9px;
    border-radius: 999px;
    font-size: 8.5pt;
    font-weight: 600;
  }

  /* Chapter Headers */
  .chapter-banner {
    background-color: #1E1B4B;
    color: #FFFFFF;
    padding: 8px 16px;
    font-size: 12.5pt;
    font-weight: 700;
    border-radius: 6px;
    margin-top: 18px;
    margin-bottom: 12px;
    letter-spacing: 0.4px;
    page-break-after: avoid;
  }

  /* Slide Cards */
  .slide-card {
    border: 1.5px solid #CBD5E1;
    border-top: 4px solid #432098;
    border-radius: 6px;
    padding: 14px 18px;
    margin-bottom: 16px;
    background: #FFFFFF;
    page-break-inside: avoid;
  }
  .slide-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1.5px solid #E2E8F0;
    padding-bottom: 6px;
    margin-bottom: 10px;
  }
  .slide-num {
    background: #432098;
    color: #FFFFFF;
    font-size: 8.5pt;
    font-weight: 700;
    padding: 2px 8px;
    border-radius: 4px;
    text-transform: uppercase;
  }
  .slide-title {
    font-size: 12pt;
    font-weight: 700;
    color: #1E1B4B;
    margin-left: 8px;
    flex: 1;
  }
  .fig-ref {
    font-size: 8.5pt;
    color: #475569;
    font-style: italic;
  }

  h4 {
    color: #1E1B4B;
    font-size: 10.2pt;
    margin: 8px 0 4px 0;
  }
  p {
    margin: 4px 0 8px 0;
  }
  ul, ol {
    margin: 4px 0 8px 0;
    padding-left: 20px;
  }
  li {
    margin-bottom: 3.5px;
  }

  /* Tables */
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 8px 0 10px 0;
    font-size: 9pt;
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

  /* Speaker Notes */
  .speaker-note {
    background-color: #F8FAFC;
    border-left: 3.5px solid #6366F1;
    padding: 7px 12px;
    margin-top: 8px;
    border-radius: 0 4px 4px 0;
    font-size: 9pt;
    color: #334155;
  }
  .blank-matrix {
    border: 2px dashed #94A3B8;
    background: #F8FAFC;
    border-radius: 6px;
    padding: 40px 20px;
    text-align: center;
    color: #475569;
    font-weight: 600;
    font-size: 11pt;
    margin: 10px 0;
  }
  .formula-row {
    display: flex;
    gap: 12px;
    margin: 8px 0;
  }
  .formula-pill {
    flex: 1;
    background: #F8FAFC;
    border: 1px solid #CBD5E1;
    border-radius: 5px;
    padding: 6px 10px;
    text-align: center;
    font-size: 9.2pt;
  }
  .formula-math {
    font-family: "Cambria Math", "Times New Roman", serif;
    font-size: 11pt;
    font-weight: bold;
    color: #1E1B4B;
    margin-top: 3px;
  }
  .page-break {
    page-break-before: always;
  }
</style>
</head>
<body>

<div class="cover-banner">
  <h1>E-Parada: A Digital Marketplace for Parking Spaces</h1>
  <p><b>Capstone Defense Presentation Outline (Copy-Paste Ready)</b> — College of Engineering and Architecture, NU Laguna</p>
  <p><b>Presenters:</b> Bustria, Christian Jake C. &bull; Gamad, Leticia C. &bull; Ovilla, Shan Jenis C. &bull; Valiña, Resha Lorraine P.</p>
  <div class="badge-row">
    <span class="badge">✔ E-Parada (15) Structure + E-Parada (16) Tech Stack</span>
    <span class="badge">✔ IT Developer Evaluation Only</span>
    <span class="badge">✔ 2D Floor Plan Slot Mapping</span>
    <span class="badge">✔ Supabase PostgreSQL 15+</span>
    <span class="badge">✔ Zero Business Model / Commission Fees</span>
  </div>
</div>

<!-- ===================================================================== -->
<!-- CHAPTER 1: INTRODUCTION                                               -->
<!-- ===================================================================== -->
<div class="chapter-banner">CHAPTER 1: INTRODUCTION (Objectives, Scope &amp; Limitations, Conceptual Framework)</div>

<!-- SLIDE 1 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 1</span>
    <span class="slide-title">Objectives of the Study</span>
    <span class="fig-ref">Chapter 1</span>
  </div>
  <h4>General Objective</h4>
  <ul>
    <li>To enhance efficiency, effectiveness, and reliability in parking management by designing and developing <b>E-Parada</b>, a software-driven, cross-platform digital marketplace that connects residential and commercial parking space providers with motorists seeking available parking spaces in Calamba City, Laguna.</li>
  </ul>
  <h4>Specific Objectives</h4>
  <ol>
    <li><b>To design</b> a centralized parking marketplace architecture that incorporates parking area and 2D slot management, OCR-assisted vehicle registration, location-based searching, cryptographic QR code access workflows, automated duration billing computation, and reservation-bound communication.</li>
    <li><b>To develop</b> the E-Parada software ecosystem—comprising the <b>Flutter Android mobile application</b> and the <b>Laravel 12 administrative web portal</b> backed by <b>Supabase (PostgreSQL 15+)</b>—utilizing the <b>Incremental Development Model</b> and integrating third-party APIs for mapping (Google Maps), OCR (Tesseract), voice calling (WebRTC), push notifications (FCM), and payment processing (GCash via PayMongo).</li>
    <li><b>To test and evaluate</b> the software quality of the developed system through <b>IT developer evaluation</b> and objective technical benchmarking using the <b>ISO/IEC 25010:2011 Software Product Quality Model</b> in terms of:
      <ul>
        <li><b>Functional Suitability</b> &bull; <b>Performance Efficiency</b> &bull; <b>Usability</b> &bull; <b>Reliability</b></li>
      </ul>
    </li>
  </ol>
  <div class="speaker-note">
    <b>🎙️ Presenter Note:</b> "Our study is anchored on three specific objectives: designing a 100% software-driven parking marketplace architecture, developing the cross-platform Flutter and Laravel ecosystem using the Incremental Model, and evaluating software quality with IT developers under ISO/IEC 25010:2011."
  </div>
</div>

<!-- SLIDE 2 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 2</span>
    <span class="slide-title">Scope of the Study</span>
    <span class="fig-ref">Chapter 1</span>
  </div>
  <ul>
    <li><b>Cross-Platform Access:</b> Android Mobile Application (Flutter) &amp; Administrative Web Portal (Laravel 12) synchronized via <b>Supabase (PostgreSQL 15+)</b>.</li>
    <li><b>Target Coverage:</b> Residential driveways, vacant lots, commercial establishments, and select light-industrial parking spaces in <b>Calamba City, Laguna</b>.</li>
  </ul>
  <table>
    <thead>
      <tr>
        <th style="width:24%;">Stakeholder Role</th>
        <th style="width:76%;">Key Functional Scope</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>Parking Space Providers</b></td>
        <td>• Account &amp; property ownership verification<br>• Parking space listing with images, operating schedules, &amp; overstay grace rules<br>• Interactive <b>2D floor plan slot configuration</b> (dimensions, clearance, supported vehicle types)<br>• Hourly rate setting within administrator-approved fee boundaries<br>• Reservation approval/rejection &amp; <b>QR code entry/exit scanning</b> (with manual <code>RES-#</code> fallback)<br>• Real-time active session monitoring &amp; cumulative earnings tracking</td>
      </tr>
      <tr>
        <td><b>Drivers / Motorists</b></td>
        <td>• Account registration &amp; valid ID upload<br>• <b>OCR-assisted vehicle registration</b> (Tesseract OCR license plate extraction)<br>• Geolocation search, vehicle dimension filtering, &amp; <b>Google Maps</b> turn-by-turn navigation<br>• Slot reservation &amp; <b>HMAC-SHA256 QR pass</b> generation<br>• Automated duration &amp; overstay billing with <b>Cash or GCash (PayMongo)</b> settlement<br>• Reservation-bound <b>in-app chat &amp; WebRTC audio calling</b> + incident reporting</td>
      </tr>
      <tr>
        <td><b>System Administrators</b></td>
        <td>• KYC verification of users, property documents, and OCR-extracted vehicles<br>• Listing approval &amp; minimum/maximum parking fee range governance<br>• Real-time reservation, QR log, and payment monitoring<br>• Dispute mediation &amp; <b>CSV forensic audit report generation</b></td>
      </tr>
    </tbody>
  </table>
</div>

<!-- SLIDE 3 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 3</span>
    <span class="slide-title">Limitations of the Study</span>
    <span class="fig-ref">Chapter 1</span>
  </div>
  <ol>
    <li><b>Platform Support:</b> Limited to Android devices (Android 8.0+) and standard web browsers.</li>
    <li><b>Connectivity:</b> Requires a stable internet connection for real-time database synchronization, mapping, and payment webhooks.</li>
    <li><b>Geolocation Precision:</b> GPS accuracy depends on mobile device location hardware and the Google Maps Platform API.</li>
    <li><b>Gate Validation:</b> Entry and exit QR validation is performed through the parking space provider’s authorized mobile device.</li>
    <li><b>Hardware Independence (Exclusions):</b> Operating strictly as a <b>software-driven solution</b>, the system <b>does not include</b>:
      <ul>
        <li>Automated physical gate barriers or turnstiles &bull; RFID tags/readers &bull; Stationary IoT ultrasonic/IR ground sensors &bull; AI parking prediction &bull; Live CCTV streaming</li>
      </ul>
    </li>
    <li><b>Verification Scope:</b> Relies on administrative document review within the platform (no automated lookup against external LTO or PNP government databases).</li>
    <li><b>Billing &amp; Rate Boundaries:</b> Automated billing is strictly computed from validated QR <code>time-in</code> and <code>time-out</code> scans; provider rates must remain within admin-established fee ranges.</li>
    <li><b>Third-Party Gateway Dependency:</b> Cashless transactions rely on the external GCash/PayMongo payment gateway.</li>
    <li><b>Evaluation Scope:</b> System evaluation is conducted through controlled technical benchmarking and end-to-end software quality assessment by <b>IT developers</b> simulating Calamba City parking scenarios, rather than large-scale public deployment.</li>
  </ol>
</div>

<!-- SLIDE 4 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 4</span>
    <span class="slide-title">Conceptual Framework (IPO Model)</span>
    <span class="fig-ref">Figure 1</span>
  </div>
  <table>
    <thead>
      <tr>
        <th style="width:36%;">INPUT</th>
        <th style="width:40%;">PROCESS</th>
        <th style="width:24%;">OUTPUT</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>
          <b>1. System Requirements</b><br>
          • Driver, Provider, &amp; Admin functional requirements<br>
          • Android 8.0+ &amp; Web compatibility, GPS &amp; internet<br><br>
          <b>2. System Design Inputs</b><br>
          • Use Case, System Flowchart, DFDs, &amp; Crow's Foot ERDs<br>
          • 2D Floor Plan UI/UX wireframes, REST API &amp; WebRTC specs<br><br>
          <b>3. Development Data Inputs</b><br>
          • User IDs, vehicle specs &amp; plate photos, space dimensions, 2D slot coordinates, rate bounds, &amp; QR logs<br><br>
          <b>4. Development Tools (Updated E-Parada 16 Stack)</b><br>
          • <b>Mobile:</b> Flutter 3.x / Dart SDK<br>
          • <b>Backend:</b> PHP 8.2 / Laravel 12 (Docker &amp; Nginx on Render)<br>
          • <b>Database:</b> Supabase (Managed PostgreSQL 15+ &amp; Realtime)<br>
          • <b>APIs &amp; Libraries:</b> Google Maps API, Tesseract OCR CLI, Google ML Kit &amp; CameraX (<code>mobile_scanner</code>), <code>qr_flutter</code>, WebRTC (<code>flutter_webrtc</code>), FCM, Brevo SMTP, &amp; PayMongo API v1 (GCash)<br><br>
          <b>5. Testing &amp; Evaluation Inputs</b><br>
          • 20 Functional &amp; Security Test Cases<br>
          • Technical Benchmark Workloads<br>
          • ISO/IEC 25010:2011 Evaluation Instrument for IT Developers
        </td>
        <td>
          <b>1. System Planning &amp; Analysis</b><br>
          • Analysis of Calamba City parking constraints<br>
          • Formulation of objectives, scope, &amp; role requirements<br><br>
          <b>2. System Design</b><br>
          • UI/UX prototyping &amp; 2D slot layout design<br>
          • PostgreSQL schema modeling &amp; REST API routing<br>
          • HMAC-SHA256 QR &amp; billing algorithm design<br><br>
          <b>3. Incremental System Development</b><br>
          • <b>Increment 1:</b> Auth, RBAC, &amp; KYC/Vehicle OCR verification<br>
          • <b>Increment 2:</b> Space listing, rate bounds, &amp; 2D floor plan slot mapping<br>
          • <b>Increment 3:</b> Geolocation search, Google Maps routing, &amp; concurrency-locked booking<br>
          • <b>Increment 4:</b> QR entry/exit validation, duration/overstay billing, &amp; GCash/PayMongo checkout<br>
          • <b>Increment 5:</b> In-app chat, WebRTC calling, FCM/Brevo alerts, &amp; Admin CSV reports<br><br>
          <b>4. System Integration &amp; Testing</b><br>
          • Alpha testing, regression testing, &amp; end-to-end scenario validation<br><br>
          <b>5. System Evaluation</b><br>
          • Technical benchmarking &amp; <b>IT Developer evaluation</b> under ISO/IEC 25010:2011 (Weighted Mean &amp; SD)
        </td>
        <td style="vertical-align:middle; text-align:center;">
          <b>E-Parada: A Digital Marketplace for Parking Spaces</b><br><br>
          • Verified Cross-Platform <b>Flutter Android Mobile App</b> &amp; <b>Laravel Administrative Web Portal</b>
        </td>
      </tr>
    </tbody>
  </table>
</div>

<div class="page-break"></div>

<!-- ===================================================================== -->
<!-- CHAPTER 2: REVIEW OF RELATED LITERATURE AND STUDIES                   -->
<!-- ===================================================================== -->
<div class="chapter-banner">CHAPTER 2: REVIEW OF RELATED LITERATURE AND STUDIES</div>

<!-- SLIDE 5 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 5</span>
    <span class="slide-title">Literature Matrix</span>
    <span class="fig-ref">Chapter 2</span>
  </div>
  <div class="blank-matrix">
    [ INSERT LITERATURE MATRIX TABLE HERE ]<br>
    <span style="font-size:9pt; font-weight:normal;">(Intentionally left blank as requested — paste your Literature Matrix table on this slide)</span>
  </div>
</div>

<!-- SLIDE 6 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 6</span>
    <span class="slide-title">Literature &amp; Design Synthesis</span>
    <span class="fig-ref">Chapter 2</span>
  </div>
  <ul>
    <li><b>1. Geolocation &amp; Urban Navigation</b> <i>(Raza et al., 2022; Sartayeva et al., 2023; Jagelčák et al., 2024; Bastani et al., 2021; Grepon et al., 2023; Kim et al., 2023)</i><br>
      Consumer GNSS sensors experience multipath drift in dense urban corridors; coupling device GPS with the <b>Google Maps Platform API</b> provides reliable pin discovery and turn-by-turn routing to decentralized residential parking slots.</li>
    <li><b>2. Smart Parking &amp; Reservation Systems</b> <i>(Barde et al., 2022; Sudhakar et al., 2023; Gamage, 2025; Guzman et al., 2024; Larraquel, 2023)</i><br>
      Existing smart parking systems depend heavily on costly stationary IoT hardware (ultrasonic sensors, Raspberry Pi controllers, automated barriers) inside single facilities. E-Parada bridges this gap through a <b>100% software-driven architecture</b> using consumer smartphones and interactive <b>2D floor plan slot mapping</b>.</li>
    <li><b>3. Digital Sharing Economy &amp; Resource Optimization</b> <i>(Pouri &amp; Hilty, 2021; Wang, 2025; Ahmed et al., 2023)</i><br>
      Digital resource-sharing platforms unlock underutilized private parking spaces (driveways and vacant lots) without requiring new physical infrastructure construction.</li>
    <li><b>4. Cryptographic QR Validation &amp; Replay Protection</b> <i>(Skurowski et al., 2022; Alsuhibany, 2025; Desale et al., 2025; Bekavac et al., 2024)</i><br>
      Static QR codes are vulnerable to screenshot sharing and forgery. E-Parada treats the QR code as a signed access token verified server-side via <b>HMAC-SHA256</b>, provider-space authority checks, and single-use state transitions.</li>
    <li><b>5. Cross-Platform Synchronization &amp; Transactional Integrity</b> <i>(Ali &amp; Dauwed, 2022; Wahyudi et al., 2021; Kueh Wee Xin, 2025; Ahmed et al., 2024)</i><br>
      Combining <b>Flutter + Laravel 12 + Supabase (PostgreSQL 15+)</b> delivers strict ACID compliance and pessimistic row-level locking (<code>SELECT ... FOR UPDATE</code>) to prevent double-bookings, paired with WebSocket Change Data Capture (CDC) for real-time updates.</li>
    <li><b>6. Automated Duration Billing &amp; Cashless Settlement</b> <i>(Vovveti, 2024; Afable, 2024; Fabro et al., 2025)</i><br>
      Automated timestamp-delta billing eliminates manual calculation errors, while <b>GCash (via PayMongo API v1)</b> provides trusted, webhook-verified cashless settlement alongside cash options.</li>
  </ul>
</div>

<!-- ===================================================================== -->
<!-- CHAPTER 3: METHODOLOGY                                                -->
<!-- ===================================================================== -->
<div class="chapter-banner">CHAPTER 3: METHODOLOGY</div>

<!-- SLIDE 7 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 7</span>
    <span class="slide-title">Research Design and Development Method</span>
    <span class="fig-ref">Figure 26</span>
  </div>
  <h4>Research Design: Descriptive-Developmental Method</h4>
  <ul>
    <li><b>Developmental Aspect:</b> Systematic software engineering, multi-tenant PostgreSQL database modeling, RESTful API integration, and cross-platform implementation of the Android mobile application and administrative web portal.</li>
    <li><b>Descriptive Aspect:</b> Quantitative assessment of software product quality by <b>IT developers</b> using the <b>ISO/IEC 25010:2011</b> standard and objective technical performance benchmarks.</li>
  </ul>
  <h4>Software Development Model: Incremental Development Model (5 Sequential Increments)</h4>
  <table>
    <thead>
      <tr>
        <th style="width:22%;">Development Phase / Increment</th>
        <th style="width:78%;">Core Engineering Deliverables</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>Phase 1: Planning &amp; Design</b></td>
        <td>Calamba City domain analysis, UI/UX wireframes, Crow's Foot ERDs, REST API specs, &amp; Docker/Supabase setup.</td>
      </tr>
      <tr>
        <td><b>Increment 1: Core User Access</b></td>
        <td>User registration, Laravel Sanctum RBAC, KYC ID upload, &amp; <b>Tesseract OCR</b> license plate extraction.</td>
      </tr>
      <tr>
        <td><b>Increment 2: Parking &amp; 2D Slots</b></td>
        <td>Parking space listing, admin fee boundary enforcement, &amp; <b>interactive 2D floor plan slot mapping</b>.</td>
      </tr>
      <tr>
        <td><b>Increment 3: Search &amp; Booking</b></td>
        <td>Geolocation proximity filtering, <b>Google Maps</b> routing, &amp; pessimistic row-locked booking (<code>SELECT ... FOR UPDATE</code>).</td>
      </tr>
      <tr>
        <td><b>Increment 4: QR &amp; Billing</b></td>
        <td><b>HMAC-SHA256 QR</b> entry/exit scanning (Google ML Kit/CameraX), duration/overstay fee math, &amp; <b>GCash (PayMongo v1)</b> + Cash settlement.</td>
      </tr>
      <tr>
        <td><b>Increment 5: Comms &amp; Admin</b></td>
        <td>Reservation-bound chat, <b>WebRTC</b> voice calling, <b>FCM &amp; Brevo</b> notifications, dispute mediation, &amp; Admin CSV audit reports.</td>
      </tr>
      <tr>
        <td><b>Phases 3–5: Testing &amp; Evaluation</b></td>
        <td>Alpha/Regression testing, objective benchmarking, &amp; <b>IT Developer evaluation</b> under ISO/IEC 25010:2011.</td>
      </tr>
    </tbody>
  </table>
</div>

<div class="page-break"></div>

<!-- SLIDE 8 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 8</span>
    <span class="slide-title">System Architecture, Use Case, &amp; Database Schema</span>
    <span class="fig-ref">Figures 6, 7, &amp; 9–15</span>
  </div>
  <h4>Three-Column System Architecture (Figure 6) &amp; Use Case Diagram (Figure 7)</h4>
  <ul>
    <li><b>1. Data Gathering Component:</b> Captures operational inputs from <b>Drivers</b> (search, vehicle specs, booking, payment) and <b>Parking Space Providers</b> (space listings, 2D slot layouts, rate bounds, QR validation) overseen by <b>System Administrators</b>.</li>
    <li><b>2. Acquired Knowledge &amp; System Features:</b> Synthesizes 18 core modules including RBAC, OCR plate verification, 2D slot compatibility, pessimistic concurrency control, HMAC-SHA256 QR validation, automated billing, and WebRTC/Chat coordination.</li>
    <li><b>3. Computer Program Component (Updated Stack):</b>
      <ul>
        <li><b>Client Tier:</b> Flutter 3.x / Dart (Android Mobile App &amp; PWA) + Laravel Blade, Tailwind CSS 3.x, &amp; Alpine.js 3.x (Web Portal).</li>
        <li><b>Application &amp; API Tier:</b> PHP 8.2 / Laravel 12 RESTful API containerized with <b>Docker &amp; Nginx on Render Cloud</b>.</li>
        <li><b>Data Tier:</b> <b>Supabase (Managed PostgreSQL 15+)</b> with Connection Pooler, Row-Level Security (RLS), and Realtime WebSockets.</li>
      </ul>
    </li>
  </ul>
  <h4>Modular Relational Database Architecture (Figures 13–15)</h4>
  <ul>
    <li><b>Core Booking Database (Figure 13 — 6 Tables):</b> <code>users</code>, <code>vehicles</code>, <code>parking_spaces</code>, <code>parking_slots</code>, <code>reservations</code>, <code>parking_space_feedback</code></li>
    <li><b>Communications &amp; Notification Database (Figure 14 — 5 Tables):</b> <code>reservation_messages</code>, <code>reservation_calls</code>, <code>reservation_call_signals</code>, <code>notifications</code>, <code>user_device_tokens</code> (FCM)</li>
    <li><b>Security Audit &amp; Telemetry Database (Figure 15 — 3 Tables):</b> <code>activity_logs</code>, <code>qr_transaction_logs</code>, <code>support_requests</code></li>
  </ul>
</div>

<!-- SLIDE 9 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 9</span>
    <span class="slide-title">Proposed Prototype (Mobile &amp; Web Interfaces)</span>
    <span class="fig-ref">Figures 19–23</span>
  </div>
  <table>
    <thead>
      <tr>
        <th style="width:26%;">Interface Module</th>
        <th style="width:74%;">Key Screens &amp; Functional Highlights</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>a. Driver Mobile UI<br>(Figure 19)</b></td>
        <td>• <b>Browse Parking:</b> Google Maps interactive pin discovery &amp; proximity/vehicle-compatibility filtering around Calamba City.<br>• <b>Space Details &amp; 2D Slot Map:</b> Operating schedules, hourly rates, and interactive <b>2D floor plan slot selection</b>.<br>• <b>My Reservations:</b> 6-stage real-time status bar (<i>Requested &rarr; Approved &rarr; Checked In &rarr; Checked Out &rarr; Payment Sent &rarr; Paid</i>), encrypted <b>Entry QR Code</b>, reschedule/cancel controls, and provider chat/call.<br>• <b>Driver Profile:</b> KYC verification badges &amp; OCR-assisted vehicle registration slots (up to 3 vehicles).</td>
      </tr>
      <tr>
        <td><b>b. Parking Owner Mobile UI<br>(Figure 20)</b></td>
        <td>• <b>Owner Dashboard:</b> Live counters for registered spaces, approved spaces, pending requests, and payments to verify.<br>• <b>My Parking Spaces:</b> Property editor, 2D slot layout configurator, and operating schedule manager.<br>• <b>Entry &amp; Exit Checkpoint Validator:</b> Hardware-accelerated camera QR scanner (<code>mobile_scanner</code>) with manual <code>RES-#</code> fallback and checkpoint mismatch detection.</td>
      </tr>
      <tr>
        <td><b>c. System Admin Mobile &amp; Web UI<br>(Figures 21 &amp; 22)</b></td>
        <td>• <b>Admin Reviews (KYC &amp; OCR Audit):</b> Side-by-side verification of user IDs, property proofs, and OCR-extracted license plates vs. vehicle photos.<br>• <b>Reservation &amp; Platform Operations Monitor:</b> Live transaction tracking, dispute resolution, QR scan telemetry logs, support desk, and 1-click <b>CSV audit report export</b>.</td>
      </tr>
    </tbody>
  </table>
</div>

<!-- SLIDE 10 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 10</span>
    <span class="slide-title">Hardware and Software Components</span>
    <span class="fig-ref">Tables 1 &amp; 2</span>
  </div>
  <h4>Table 1: Hardware Specification</h4>
  <table>
    <thead>
      <tr>
        <th style="width:22%;">Category</th>
        <th style="width:23%;">Component</th>
        <th style="width:28%;">Specification</th>
        <th style="width:27%;">Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>Development Device</b></td>
        <td>Laptop / Desktop PC</td>
        <td>Intel Core i3 / AMD Ryzen 3, 8 GB RAM, 256 GB SSD</td>
        <td>Used for coding, compiling Flutter builds, and managing backend/DB.</td>
      </tr>
      <tr>
        <td><b>Mobile Test Device</b></td>
        <td>Android Smartphone</td>
        <td>Android 8.0+, 4 GB RAM, Camera, GPS, Microphone</td>
        <td>Used for testing QR scanning, OCR plate capture, GPS, &amp; WebRTC calls.</td>
      </tr>
      <tr>
        <td><b>Network Connectivity</b></td>
        <td>Wi-Fi Router / Hotspot</td>
        <td>Stable broadband / 4G LTE connection</td>
        <td>Provides internet connectivity between mobile client and cloud backend.</td>
      </tr>
    </tbody>
  </table>

  <h4>Table 2: Updated Software Specification (E-Parada 16 Stack)</h4>
  <table>
    <thead>
      <tr>
        <th style="width:24%;">Category</th>
        <th style="width:26%;">Component</th>
        <th style="width:22%;">Specification</th>
        <th style="width:28%;">Architectural Role</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>Mobile Framework</b></td>
        <td>Flutter &amp; Dart SDK</td>
        <td>Flutter 3.x / Dart <code>^3.12.2</code></td>
        <td>Powers cross-platform Android mobile client &amp; PWA.</td>
      </tr>
      <tr>
        <td><b>Backend Framework</b></td>
        <td>PHP &amp; Laravel</td>
        <td>PHP 8.2 / Laravel 12.0</td>
        <td>RESTful API engine, Sanctum RBAC, HMAC signing, &amp; billing math.</td>
      </tr>
      <tr>
        <td><b>Database (DBMS)</b></td>
        <td>Supabase (PostgreSQL)</td>
        <td>Managed PostgreSQL 15+</td>
        <td>ACID transactions, <code>SELECT ... FOR UPDATE</code> locking, RLS, &amp; Realtime CDC.</td>
      </tr>
      <tr>
        <td><b>Cloud Hosting</b></td>
        <td>Docker &amp; Render Cloud</td>
        <td>Alpine Linux + Nginx + PHP-FPM</td>
        <td>Multi-stage containerized production deployment with SSL.</td>
      </tr>
      <tr>
        <td><b>2D Spatial Layout</b></td>
        <td>2D Floor Plan Slot Engine</td>
        <td>Custom Flutter Painter &amp; HTML5 Grid</td>
        <td>Renders interactive 2D parking lot lanes and angled slot layouts.</td>
      </tr>
      <tr>
        <td><b>Web Frontend</b></td>
        <td>Blade + Tailwind + Alpine</td>
        <td>Tailwind 3.x / Alpine 3.x</td>
        <td>Responsive administrative web portal and dashboard interface.</td>
      </tr>
      <tr>
        <td><b>Mapping &amp; OCR</b></td>
        <td>Google Maps API &amp; Tesseract</td>
        <td>Maps SDK / Tesseract PSM 11</td>
        <td>Geolocation routing &amp; automated LTO license plate character extraction.</td>
      </tr>
      <tr>
        <td><b>QR Scanner &amp; Comms</b></td>
        <td>ML Kit, CameraX, WebRTC, FCM</td>
        <td><code>mobile_scanner: ^7.4.0</code> / <code>flutter_webrtc</code></td>
        <td>Hardware-accelerated QR scanning, VoIP audio calling, &amp; push/Brevo alerts.</td>
      </tr>
      <tr>
        <td><b>Payment Gateway</b></td>
        <td>GCash via PayMongo API</td>
        <td>PayMongo API v1</td>
        <td>Authenticated cashless checkout sessions &amp; automated payment webhooks.</td>
      </tr>
    </tbody>
  </table>
</div>

<div class="page-break"></div>

<!-- SLIDE 11 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 11</span>
    <span class="slide-title">Data Flow and Control Logic (Activity Diagram, DFDs, &amp; Subroutines)</span>
    <span class="fig-ref">Figures 8, 16–18, 24, &amp; 25</span>
  </div>
  <h4>1. Activity Diagram (Figure 8) &amp; 12-Phase Cross-Functional System Flowchart (Figure 24)</h4>
  <ul>
    <li>Coordinates interactions across <b>Driver</b>, <b>Web &amp; Mobile Client</b>, <b>Laravel Backend &amp; Services</b>, <b>Parking Space Provider</b>, <b>System Administrator</b>, and <b>Supabase Database</b> swimlanes:
      <ul>
        <li><b>Phases 1–3 (Onboarding &amp; Auth):</b> Registration &rarr; Brevo email verification &rarr; Admin KYC/OCR approval &rarr; Role-based dashboard routing.</li>
        <li><b>Phases 4–6 (Discovery, Listing, &amp; Booking):</b> Provider listing creation &rarr; Driver proximity/dimension search &rarr; Pessimistic slot lock &rarr; Provider approval &rarr; HMAC-SHA256 QR pass issuance.</li>
        <li><b>Phases 7–9 (Checkpoint Scan &amp; Billing):</b> Gate Entry QR scan (<code>time_in</code>) &rarr; Active session monitoring &rarr; Gate Exit QR scan (<code>time_out</code>) &rarr; Automated duration + overstay billing &rarr; Cash or GCash (PayMongo) settlement &rarr; Provider earnings record updated &rarr; Driver feedback.</li>
        <li><b>Phases 10–12 (Governance &amp; Audit):</b> Admin listing/user reviews, dispute resolution, feedback moderation, &amp; CSV audit export.</li>
      </ul>
    </li>
  </ul>
  <h4>2. Partitioned Data Flow Diagrams (Figures 16–18)</h4>
  <ul>
    <li><b>Level-0 DFD (Figure 16):</b> 6 Core Processes (<i>1.0 Auth, 2.0 Listings, 3.0 Search &amp; Booking, 4.0 Check-In/Out, 5.0 Billing &amp; Settlement, 6.0 Feedback &amp; Audit</i>) across 6 Data Stores (<code>D1–D6</code>).</li>
    <li><b>Level-1 DFD (Figure 17):</b> Decomposes <b>Process 3.0</b> into 6 subprocesses (<i>3.1 Query &rarr; 3.2 Compatibility Filter &rarr; 3.3 Validate Request &rarr; 3.4 Conflict Check &rarr; 3.5 Generate HMAC QR &rarr; 3.6 Dispatch Pass</i>).</li>
    <li><b>Level-2 DFD (Figure 18):</b> Decomposes <b>Process 3.5</b> (<i>3.5.1 Extract Tuple &rarr; 3.5.2 Retrieve Secret Key &rarr; 3.5.3 Compute HMAC-SHA256 Hash &rarr; 3.5.4 Encode 2D Matrix &rarr; 3.5.5 Archive Token</i>).</li>
  </ul>
  <h4>3. Four Encapsulated Technical Subroutines (Figure 25)</h4>
  <ul>
    <li><b>Subroutine 1 (Tesseract OCR):</b> Grayscale + contrast boost + adaptive thresholding &rarr; PSM 11 extraction &rarr; LTO plate regex filter.</li>
    <li><b>Subroutine 2 (Pessimistic Concurrency Locking):</b> <code>BEGIN</code> &rarr; <code>SELECT ... FOR UPDATE</code> on <code>parking_slots</code> &rarr; overlap check &rarr; <code>COMMIT</code> or <code>ROLLBACK</code>.</li>
    <li><b>Subroutine 3 (Cryptographic QR Replay Guard):</b> Base64 decode &rarr; recompute <code>HMAC-SHA256</code> &rarr; verify single-use state &rarr; log to <code>qr_transaction_logs</code>.</li>
    <li><b>Subroutine 4 (Automated Duration &amp; Overstay Billing):</b> Compute <code>time_out - time_in</code> minus 15-min grace period &rarr; apply ceiling-rounded hourly &amp; overstay rates &rarr; Cash or PayMongo GCash webhook verification.</li>
  </ul>
</div>

<!-- SLIDE 12 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 12</span>
    <span class="slide-title">Testing Environment, Phases, and Test Case Coverage</span>
    <span class="fig-ref">Tables 3 &amp; 4</span>
  </div>
  <ul>
    <li><b>Testing Environment:</b> Physical Android smartphones (Android 8.0–14.0) + Android Studio Emulator + Desktop/Mobile Web Browsers connected to containerized PHP 8.2 / Laravel 12 &amp; <b>Supabase PostgreSQL 15+</b> across Wi-Fi, 4G/LTE, and throttled low-bandwidth networks.</li>
  </ul>
  <h4>Table 3: System Testing Phases and Acceptance Criteria</h4>
  <table>
    <thead>
      <tr>
        <th style="width:26%;">Testing Phase</th>
        <th style="width:38%;">Scope and Methodology</th>
        <th style="width:36%;">Pass/Fail Acceptance Criteria</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>1. Alpha Testing<br>(Unit &amp; Modular)</b></td>
        <td>Internal modular testing by the development team across all 5 increments (Auth, Listings, Maps, QR, Billing, GCash, WebRTC).</td>
        <td>• 100% pass rate on core auth, booking, and billing unit test suites.<br>• Zero critical DB integrity violations or unhandled exceptions.</td>
      </tr>
      <tr>
        <td><b>2. System &amp; Scenario Evaluation<br>(End-to-End Validation)</b></td>
        <td>End-to-end operational and technical evaluation conducted by purposively selected <b>IT Developers</b> executing complete Driver, Provider, and Admin workflows.</td>
        <td>• &ge; 95% successful completion rate across end-to-end role journeys.<br>• Zero occurrences of unresolved double bookings or unrecorded payments.</td>
      </tr>
      <tr>
        <td><b>3. Regression Testing</b></td>
        <td>Automated and manual re-testing of previously verified modules after bug fixes or increment integrations.</td>
        <td>• 100% pass on all 20 test cases; zero regression bugs in reservation states and billing math.</td>
      </tr>
    </tbody>
  </table>
  <h4>20-Item Test Case Coverage Matrix Summary (Table 4)</h4>
  <ul>
    <li><b>TC-01 to TC-02 (Auth &amp; RBAC):</b> Sanctum token issuance &amp; <code>HTTP 403</code> unauthorized route blocking.</li>
    <li><b>TC-03 to TC-04 (Vehicle &amp; OCR):</b> Tesseract OCR extraction (&ge; 90% precision) &amp; duplicate plate rejection.</li>
    <li><b>TC-05 to TC-06 (Listing &amp; 2D Layout):</b> Admin fee boundary enforcement &amp; responsive <b>2D floor plan slot grid</b> rendering.</li>
    <li><b>TC-07 to TC-08 (Search &amp; Maps):</b> Proximity/dimension filtering &amp; Google Maps route calculation.</li>
    <li><b>TC-09 to TC-10 (Booking &amp; Concurrency):</b> Standard booking &amp; <b>simultaneous race-condition stress test (<code>SELECT ... FOR UPDATE</code>)</b>.</li>
    <li><b>TC-11 to TC-14 (QR Security):</b> Valid entry/exit logging, <b>replay attack rejection</b>, unauthorized scanner blocking, &amp; manual <code>RES-#</code> fallback.</li>
    <li><b>TC-15 to TC-20 (Billing, Comms, &amp; Network):</b> 15-min grace period &amp; overstay math, Cash confirmation, <b>GCash PayMongo webhook</b>, reservation-bound chat, <b>WebRTC call (&lt; 250 ms)</b>, &amp; network drop recovery.</li>
  </ul>
</div>

<!-- SLIDE 13 -->
<div class="slide-card">
  <div class="slide-header">
    <span class="slide-num">Slide 13</span>
    <span class="slide-title">Evaluation and Statistical Treatment</span>
    <span class="fig-ref">Tables 5 &amp; 6</span>
  </div>
  <ul>
    <li><b>Evaluators &amp; Sampling Technique:</b> <b>Purposive Sampling</b> of qualified <b>IT Developers and Software Engineering Professionals</b> who execute full Driver, Provider, and Admin workflows and evaluate the system under the <b>ISO/IEC 25010:2011 Software Product Quality Model</b>:
      <ul>
        <li><b>A. Functional Suitability</b> (Items 1–3: <i>Completeness, Correctness, Appropriateness</i>)</li>
        <li><b>B. Performance Efficiency</b> (Items 4–6: <i>Time Behavior, Resource Utilization, Capacity</i>)</li>
        <li><b>C. Usability</b> (Items 7–12: <i>Recognizability, Learnability, Operability, User Error Protection, UI Aesthetics, Accessibility</i>)</li>
        <li><b>D. Reliability</b> (Items 13–16: <i>Maturity, Availability, Fault Tolerance, Recoverability</i>)</li>
      </ul>
    </li>
  </ul>
  <h4>Table 5: Objective Technical Performance Benchmarks</h4>
  <table>
    <thead>
      <tr>
        <th style="width:24%;">Performance Metric</th>
        <th style="width:26%;">Evaluation Target Threshold</th>
        <th style="width:25%;">Measurement Instrument</th>
        <th style="width:25%;">Evaluated Component</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><b>REST API Latency</b></td>
        <td>Mean Response &lt; 350 ms (at 50 req/s)</td>
        <td>Apache JMeter / Postman Runner</td>
        <td>Laravel 12 API &amp; Supabase Pooler</td>
      </tr>
      <tr>
        <td><b>QR Validation Speed</b></td>
        <td>Total latency &lt; 600 ms</td>
        <td>Physical Android Benchmark Timer</td>
        <td>Base64 Decode &amp; HMAC-SHA256</td>
      </tr>
      <tr>
        <td><b>Concurrency Resilience</b></td>
        <td>0 double-bookings (25 parallel reqs)</td>
        <td>Python Concurrency Stress Script</td>
        <td>PostgreSQL Row Lock (<code>FOR UPDATE</code>)</td>
      </tr>
      <tr>
        <td><b>OCR Extraction Latency</b></td>
        <td>Execution &lt; 1.8 s; Precision &ge; 90%</td>
        <td>50-Plate Automated Test Harness</td>
        <td>Tesseract OCR Engine (PSM 11)</td>
      </tr>
      <tr>
        <td><b>WebRTC Audio Latency</b></td>
        <td>Packet latency &lt; 200 ms</td>
        <td>Chrome WebRTC Internals Logger</td>
        <td>Flutter WebRTC P2P / Relayed Session</td>
      </tr>
      <tr>
        <td><b>Payment Webhook Latency</b></td>
        <td>Round-trip &lt; 1.2 s</td>
        <td>PayMongo Webhook Logger</td>
        <td>PayMongo API v1 Event Listener</td>
      </tr>
    </tbody>
  </table>

  <h4>Statistical Treatment Formulas &amp; Table 6: Likert Scale Interpretation Matrix</h4>
  <div class="formula-row">
    <div class="formula-pill">
      <b>1. Frequency &amp; Percentage</b><br>(Evaluator Technical Profile)
      <div class="formula-math">P = ( f / N ) &times; 100</div>
    </div>
    <div class="formula-pill">
      <b>2. Weighted Mean</b><br>(Central Quality Rating)
      <div class="formula-math">X&#772; = ( &sum; fx ) / N</div>
    </div>
    <div class="formula-pill">
      <b>3. Standard Deviation</b><br>(Evaluator Rating Consistency)
      <div class="formula-math">SD = &radic;[ &sum;(X - X&#772;)&sup2; / (N - 1) ]</div>
    </div>
  </div>
  <table>
    <thead>
      <tr>
        <th style="width:16%;">Scale</th>
        <th style="width:22%;">Weighted Mean Range</th>
        <th style="width:34%;">ISO/IEC 25010:2011 Quality Rating</th>
        <th style="width:28%;">Qualitative Level</th>
      </tr>
    </thead>
    <tbody>
      <tr><td><b>5</b></td><td>4.21 – 5.00</td><td>Excellent / Highly Compliant</td><td>Outstanding software quality</td></tr>
      <tr><td><b>4</b></td><td>3.41 – 4.20</td><td>Very Good / Compliant</td><td>High software quality</td></tr>
      <tr><td><b>3</b></td><td>2.61 – 3.40</td><td>Fair / Moderately Compliant</td><td>Moderate software quality</td></tr>
      <tr><td><b>2</b></td><td>1.81 – 2.60</td><td>Poor / Low Compliance</td><td>Substandard software quality</td></tr>
      <tr><td><b>1</b></td><td>1.00 – 1.80</td><td>Very Poor / Non-Compliant</td><td>Unacceptable software quality</td></tr>
    </tbody>
  </table>
</div>

</body>
</html>
"""
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"Wrote presentation print HTML: {html_path}")

    chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
    if not os.path.exists(chrome_path):
        chrome_path = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

    cmd = [
        chrome_path,
        '--headless=new',
        '--disable-gpu',
        '--no-pdf-header-footer',
        f'--print-to-pdf={pdf_path}',
        html_path
    ]
    subprocess.run(cmd, check=True)
    print(f"Generated Presentation Outline PDF: {pdf_path}")

    shutil.copy2(pdf_path, artifact_pdf)
    print(f"Copied PDF to artifacts: {artifact_pdf}")

    import pypdf
    reader = pypdf.PdfReader(pdf_path)
    print(f"Verified PDF! Total pages: {len(reader.pages)}")

if __name__ == '__main__':
    generate_presentation_outline_pdf()
