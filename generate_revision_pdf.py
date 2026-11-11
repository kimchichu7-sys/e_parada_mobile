import os
import subprocess
import shutil

def generate_pdf_guide():
    workspace = r'c:\Users\kimch\e_parada_mobile'
    html_path = os.path.join(workspace, 'scratch', 'revision_guide_print.html')
    pdf_path = os.path.join(workspace, 'E_PARADA_IT_DEVELOPER_AND_BUSINESS_MODEL_REVISION_GUIDE.pdf')
    artifact_pdf = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\E_PARADA_IT_DEVELOPER_AND_BUSINESS_MODEL_REVISION_GUIDE.pdf'

    os.makedirs(os.path.dirname(html_path), exist_ok=True)

    html_content = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>E-Parada Manuscript Revision Guide: IT Developer Evaluation &amp; Business Model Removal</title>
<style>
  @page {
    size: letter;
    margin: 0.65in 0.65in 0.7in 0.65in;
  }
  * {
    box-sizing: border-box;
  }
  body {
    font-family: "Segoe UI", -apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, sans-serif;
    font-size: 10.5pt;
    line-height: 1.5;
    color: #1E293B;
    margin: 0;
    padding: 0;
  }
  /* Header Banner */
  .cover-banner {
    background: linear-gradient(135deg, #1E1B4B 0%, #432098 100%);
    color: #FFFFFF;
    padding: 24px 28px;
    border-radius: 8px;
    margin-bottom: 20px;
  }
  .cover-banner h1 {
    margin: 0 0 6px 0;
    font-size: 18pt;
    font-weight: 700;
    letter-spacing: -0.3px;
  }
  .cover-banner p {
    margin: 0;
    font-size: 10.5pt;
    color: #E0E7FF;
  }
  .badge-row {
    margin-top: 12px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
  }
  .badge {
    background: rgba(255, 255, 255, 0.16);
    border: 1px solid rgba(255, 255, 255, 0.3);
    color: #FFFFFF;
    padding: 3px 10px;
    border-radius: 999px;
    font-size: 8.5pt;
    font-weight: 600;
  }

  /* Section Headings */
  h2.section-header {
    background-color: #F1F5F9;
    border-left: 5px solid #432098;
    color: #0F172A;
    padding: 8px 14px;
    font-size: 13.5pt;
    margin-top: 22px;
    margin-bottom: 12px;
    border-radius: 0 6px 6px 0;
    page-break-after: avoid;
  }
  h3.sub-header {
    color: #1E1B4B;
    font-size: 11.5pt;
    margin-top: 16px;
    margin-bottom: 6px;
    border-bottom: 1.5px solid #E2E8F0;
    padding-bottom: 4px;
    page-break-after: avoid;
  }
  h4 {
    color: #334155;
    font-size: 10.5pt;
    margin-top: 10px;
    margin-bottom: 4px;
    page-break-after: avoid;
  }

  /* Callout Boxes */
  .card {
    border: 1px solid #CBD5E1;
    border-radius: 6px;
    padding: 12px 16px;
    margin-bottom: 14px;
    background: #FFFFFF;
    page-break-inside: avoid;
  }
  .page-tag {
    display: inline-block;
    background: #432098;
    color: #FFFFFF;
    font-weight: 700;
    font-size: 8.5pt;
    padding: 2px 8px;
    border-radius: 4px;
    margin-bottom: 6px;
    text-transform: uppercase;
  }
  .page-tag.critical {
    background: #DC2626;
  }
  .page-tag.warning {
    background: #D97706;
  }
  .page-tag.teal {
    background: #0F766E;
  }

  .old-box {
    background-color: #FEF2F2;
    border-left: 4px solid #EF4444;
    padding: 8px 12px;
    margin: 6px 0;
    border-radius: 0 4px 4px 0;
    font-size: 9.8pt;
    color: #7F1D1D;
  }
  .new-box {
    background-color: #F0FDF4;
    border-left: 4px solid #16A34A;
    padding: 8px 12px;
    margin: 6px 0;
    border-radius: 0 4px 4px 0;
    font-size: 9.8pt;
    color: #14532D;
  }
  .label-title {
    font-weight: 700;
    font-size: 9pt;
    text-transform: uppercase;
    display: block;
    margin-bottom: 3px;
  }

  /* Tables */
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0 16px 0;
    font-size: 9.5pt;
  }
  th, td {
    border: 1px solid #CBD5E1;
    padding: 6px 8px;
    text-align: left;
    vertical-align: top;
  }
  th {
    background-color: #F8FAFC;
    color: #0F172A;
    font-weight: 700;
  }
  tr {
    page-break-inside: avoid;
  }

  /* Continuous Manuscript Block */
  .manuscript-container {
    font-family: "Times New Roman", Times, serif;
    font-size: 11.5pt;
    line-height: 1.65;
    color: #000000;
    border: 1.5px solid #432098;
    border-radius: 6px;
    padding: 20px 24px;
    background: #FFFFFF;
  }
  .manuscript-container p {
    text-align: justify;
    margin: 0 0 10px 0;
  }
  .manuscript-container h3 {
    font-family: "Times New Roman", Times, serif;
    font-size: 12pt;
    font-weight: bold;
    margin: 16px 0 6px 0;
    color: #000000;
  }
  .manuscript-container h4 {
    font-family: "Times New Roman", Times, serif;
    font-size: 11.5pt;
    font-weight: bold;
    margin: 12px 0 4px 0;
    color: #000000;
  }
  .manuscript-container table.apa {
    font-family: "Times New Roman", Times, serif;
    font-size: 10pt;
    border-top: 1.5pt solid #000;
    border-bottom: 1.5pt solid #000;
    border-left: none;
    border-right: none;
  }
  .manuscript-container table.apa th {
    background: none;
    border-top: none;
    border-left: none;
    border-right: none;
    border-bottom: 1pt solid #000;
  }
  .manuscript-container table.apa td {
    border: none;
  }
  .manuscript-container table.grid th,
  .manuscript-container table.grid td {
    border: 1px solid #000000;
    font-family: "Times New Roman", Times, serif;
    font-size: 10pt;
  }
  .formula-box {
    text-align: center;
    font-weight: bold;
    font-size: 12pt;
    margin: 10px 0;
    font-family: "Cambria Math", "Times New Roman", serif;
  }
  .page-break {
    page-break-before: always;
  }
  ul, ol {
    margin: 4px 0 10px 0;
    padding-left: 22px;
  }
  li {
    margin-bottom: 4px;
  }
</style>
</head>
<body>

<div class="cover-banner">
  <h1>E-PARADA MANUSCRIPT ALIGNMENT &amp; REVISION GUIDE</h1>
  <p>Complete Page-by-Page Audit (Pages 1–149): Aligning to <b>IT Developer Evaluation Only</b> &amp; Removing <b>Business Model / Commission Remnants</b></p>
  <div class="badge-row">
    <span class="badge">✔ Zero End-User Respondents</span>
    <span class="badge">✔ Purposive Sampling (IT Developers)</span>
    <span class="badge">✔ Zero Business Model / Service Fees</span>
    <span class="badge">✔ Complete Pages 126–149 Replacement Included</span>
  </div>
</div>

<!-- ===================================================================== -->
<!-- PART 1: SUMMARY OF ALL REQUIRED CHANGES (BY PAGE NUMBER)              -->
<!-- ===================================================================== -->
<h2 class="section-header">PART 1: Master Checklist of Pages to Change (Pages 1–149)</h2>

<p>Your 149-page PDF currently contains internal contradictions regarding respondents—claiming <b>89 respondents</b> (84 end-users + 5 IT experts via Slovin’s &amp; Bowley’s formulas) on <b>Pages 127 &amp; 140–141</b>, while claiming <b>50 respondents</b> (30 drivers, 15 providers, 5 IT experts) on <b>Pages 136 &amp; 147</b>. Transitioning to <b>IT Developers only</b> resolves all statistical contradictions.</p>

<table>
  <thead>
    <tr>
      <th style="width:12%;">Page(s)</th>
      <th style="width:24%;">Section / Figure</th>
      <th style="width:32%;">Issue Found in Uploaded PDF</th>
      <th style="width:32%;">Required Action</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Page 2</b></td>
      <td>Background of the Study (Para 2)</td>
      <td>Mentions property owners can <i>"monetize their available slots"</i>.</td>
      <td>Change <i>"monetize"</i> to <b>"rent out and manage"</b>.</td>
    </tr>
    <tr>
      <td><b>Page 6</b></td>
      <td>Figure 1 (Conceptual Framework IPO Diagram)</td>
      <td>1. Mentions <i>"Beta testing in selected private/residential parking areas"</i>.<br>2. Lists <i>"SQLite / MySQL"</i> under tools.</td>
      <td>1. Change to <b>"End-to-end scenario validation by IT developers"</b>.<br>2. Change DB to <b>"Supabase (PostgreSQL 15+)"</b>.</td>
    </tr>
    <tr>
      <td><b>Pages 7–9</b></td>
      <td>Conceptual Framework Narrative</td>
      <td>Mentions <i>"field testing scenarios"</i>, <i>"two distinct frameworks"</i>, and <i>"user-accepted"</i>.</td>
      <td>Align to <b>IT developer evaluation</b> using the single <b>ISO/IEC 25010:2011</b> framework.</td>
    </tr>
    <tr>
      <td><b>Page 13</b></td>
      <td>Limitations of the Study (Item #10)</td>
      <td>Mentions <i>"user testing are conducted within selected private and residential parking sites..."</i></td>
      <td>Change to <b>controlled technical testing and software quality evaluation by IT developers</b>.</td>
    </tr>
    <tr>
      <td><b>Page 14</b></td>
      <td>Significance of the Study (Paras 1 &amp; 3)</td>
      <td>Mentions <i>"e-commerce principles"</i> and <i>"digital commerce"</i>.</td>
      <td>Change to <b>"digital resource-sharing principles"</b> and <b>"smart mobility systems"</b>.</td>
    </tr>
    <tr>
      <td><b>Pages 50–52</b></td>
      <td>Chapter 2 RRL (GCash &amp; Chan, 2026)</td>
      <td><b>CRITICAL BUSINESS MODEL REMNANT (Page 52):</b> Proposes exploring <i>"additional revenue streams, such as premium reservation services or subscription-based features"</i>.</td>
      <td><b>Delete the revenue stream / subscription sentence on Page 52</b> and replace with technical payment webhook reliability text.</td>
    </tr>
    <tr>
      <td><b>Page 55</b></td>
      <td>Chapter 2 Design Synthesis</td>
      <td>Line 13 says <i>"3D visualization of the parking spot"</i>.</td>
      <td>Change to <b>"interactive 2D floor plan visualization of the parking spot"</b>.</td>
    </tr>
    <tr>
      <td><b>Pages 61–65</b></td>
      <td>References (Duplicate List)</td>
      <td>Pages 56–60 are APA References; Pages 61–65 repeat the exact same list in IEEE <code>[1]</code> format.</td>
      <td><b>Delete Pages 61–65</b> (keep APA list on Pages 56–60).</td>
    </tr>
    <tr>
      <td><b>Pages 66–67</b></td>
      <td>Chapter 3: Software Development Model</td>
      <td>Page 66 says <i>"3D layout visualization"</i>. Page 67 says <i>"User evaluation will be conducted among selected respondents... licensed drivers, residential and commercial parking space providers..."</i></td>
      <td>Change to <b>2D floor plan slot mapping</b> and <b>structured expert evaluation by purposively selected IT developers</b>.</td>
    </tr>
    <tr>
      <td><b>Pages 68, 70, 106</b></td>
      <td>Figure 6 &amp; Table 2 (Software Spec)</td>
      <td>Lists <i>"Three.js / 3D Spatial Layout Library"</i> and <i>"SQLite Database"</i>.</td>
      <td>Replace Three.js with <b>2D Floor Plan Slot Engine</b> and SQLite with <b>Supabase PostgreSQL 15+</b>.</td>
    </tr>
    <tr>
      <td><b>Page 116</b></td>
      <td>System Flowchart Narrative (Paras 2 &amp; 3)</td>
      <td><b>CRITICAL BUSINESS MODEL REMNANT:</b> Claims <i>"the provider's earnings are credited minus the platform's service fee"</i> and admin views <i>"platform fees"</i>.</td>
      <td>Remove <i>"minus the platform's service fee"</i> and <i>"platform fees"</i> (your system does not charge platform commissions).</td>
    </tr>
    <tr>
      <td><b>Pages 120 &amp; 124</b></td>
      <td>Figure 25 (Subroutine 2) &amp; Figure 26</td>
      <td>Fig 25 header says <code>MYSQL DATABASE</code>. Fig 26 says <code>3D parking slot layout</code>, <code>MySQL database</code>, and <code>User acceptance testing</code>.</td>
      <td>Update diagram labels to <b>Supabase PostgreSQL</b>, <b>2D parking slot layout</b>, and <b>IT developer technical evaluation</b>.</td>
    </tr>
    <tr>
      <td><b>Pages 126–128</b></td>
      <td>Data Collection, Sampling &amp; Procedures</td>
      <td><b>Page 127</b> uses N=500, Slovin's Formula (n=84), and Bowley's Allocation (59 drivers, 25 providers). <b>Page 128</b> claims interviews/field surveys were conducted.</td>
      <td><b>Replace completely</b> with <b>Evaluators and Sampling Technique (Purposive Sampling of IT Developers)</b>.</td>
    </tr>
    <tr>
      <td><b>Pages 135–137</b></td>
      <td>Table 3 (Testing Phases) &amp; Beta Testing</td>
      <td>Table 3 &amp; Page 136 claim <b>50 respondents (30 drivers, 15 providers, 5 IT experts)</b> in Beta Field Testing.</td>
      <td>Rename to <b>System &amp; Scenario Evaluation</b> conducted by IT developers executing Driver, Provider, and Admin roles.</td>
    </tr>
    <tr>
      <td><b>Pages 140–149</b></td>
      <td>Evaluation Criteria, Instrument &amp; Statistics</td>
      <td>1. Mentions 84 stratified respondents + 5 experts (N=89).<br>2. Claims a 10-person pilot test &amp; Cronbach's Alpha.<br>3. Part I asks for Driver/Vehicle/OS.<br>4. <b>OMITS D. Reliability from the questionnaire table!</b></td>
      <td>1. Align to IT Developer evaluators.<br>2. Remove pilot test &amp; Cronbach's Alpha.<br>3. Change Part I to IT Evaluator Profile.<br>4. <b>Add D. Reliability (Items 13–16)</b>.</td>
    </tr>
  </tbody>
</table>

<div class="page-break"></div>

<!-- ===================================================================== -->
<!-- PART 2: EXACT BEFORE & AFTER REPLACEMENTS (PAGES 2–125)               -->
<!-- ===================================================================== -->
<h2 class="section-header">PART 2: Exact Before &amp; After Replacements for Pages 2–125</h2>

<div class="card">
  <span class="page-tag warning">Page 2 — Background of the Study (Paragraph 2, Line 4)</span>
  <div class="old-box">
    <span class="label-title">❌ Current Text (Has Monetization Wording):</span>
    "...By applying digital marketplace principles to parking management, property owners with surplus space can list and <b>monetize</b> their available slots, while motorists obtain affordable, pre-arranged, and accessible parking options in close proximity to their destinations."
  </div>
  <div class="new-box">
    <span class="label-title">✅ Replace With:</span>
    "...By applying digital marketplace principles to parking management, property owners with surplus space can list and <b>manage</b> their available slots for short-term use, while motorists obtain affordable, pre-arranged, and accessible parking options in close proximity to their destinations."
  </div>
</div>

<div class="card">
  <span class="page-tag">Pages 7, 8, &amp; 9 — Conceptual Framework Narrative</span>
  <div class="old-box">
    <span class="label-title">❌ Current Text (Pages 7–9):</span>
    • <b>Page 7 (Bottom):</b> "...Finally, Testing Inputs consist of functional and security test cases, simulated and field testing scenarios in Calamba City, the ISO/IEC 25010 Software Product Quality evaluation questionnaire."<br>
    • <b>Page 8 (Bottom):</b> "Finally, The completed system will be assessed in the System Evaluation using two distinct frameworks: the ISO/IEC 25010 Software Product Quality Model to evaluate technical software product quality in terms of Functional Suitability, Performance Efficiency, Usability, and Reliability, with survey responses analyzed using the weighted mean."<br>
    • <b>Page 9 (Para 1, Last Line):</b> "...Ultimately, the output delivers a quality-tested and user-accepted cross-platform marketplace platform evaluated and verified under ISO/IEC 25010 software quality standards."
  </div>
  <div class="new-box">
    <span class="label-title">✅ Replace With:</span>
    • <b>Page 7 (Bottom):</b> "...Finally, Testing Inputs consist of functional and security test cases, simulated operational scenarios modeled on Calamba City parking workflows, and the ISO/IEC 25010:2011 Software Product Quality evaluation instrument administered to IT developers."<br>
    • <b>Page 8 (Bottom):</b> "Finally, the completed system will be assessed in the System Evaluation phase by purposively selected IT developers using the ISO/IEC 25010:2011 Software Product Quality Model in terms of Functional Suitability, Performance Efficiency, Usability, and Reliability, with evaluation ratings analyzed using the weighted mean."<br>
    • <b>Page 9 (Para 1, Last Line):</b> "...Ultimately, the output delivers a quality-tested and technically validated cross-platform marketplace platform evaluated and verified by IT developers under ISO/IEC 25010:2011 software quality standards."
  </div>
</div>

<div class="card">
  <span class="page-tag">Page 13 — Limitations of the Study (Item #10)</span>
  <div class="old-box">
    <span class="label-title">❌ Current Text:</span>
    "10. Prototype evaluation and user testing are conducted within selected private and residential parking sites in Calamba City, Laguna, and may not fully capture the operational dynamics of large multi-level commercial transit terminals."
  </div>
  <div class="new-box">
    <span class="label-title">✅ Replace With:</span>
    "10. System evaluation is conducted through controlled technical benchmarking and end-to-end software quality assessment by IT developers simulating private and residential parking scenarios in Calamba City, Laguna, rather than large-scale public end-user deployment or multi-level commercial transit terminal operations."
  </div>
</div>

<div class="card">
  <span class="page-tag warning">Page 14 — Significance of the Study (Paragraphs 1 &amp; 3)</span>
  <div class="old-box">
    <span class="label-title">❌ Current Text:</span>
    • <b>Para 1, Line 7:</b> "...through the application of mobile and web technologies, QR code validation, and <b>e-commerce principles</b>."<br>
    • <b>Para 3 (Industry Practitioners), Line 2:</b> "...assist professionals in software development, urban planning, and <b>digital commerce</b> by improving efficiency..."
  </div>
  <div class="new-box">
    <span class="label-title">✅ Replace With:</span>
    • <b>Para 1, Line 7:</b> "...through the application of mobile and web technologies, QR code validation, and <b>digital resource-sharing principles</b>."<br>
    • <b>Para 3 (Industry Practitioners), Line 2:</b> "...assist professionals in software development, urban planning, and <b>smart mobility systems</b> by improving efficiency..."
  </div>
</div>

<div class="card">
  <span class="page-tag critical">Pages 50 &amp; 51–52 — Chapter 2 RRL: Business Model / Revenue Stream Removal</span>
  <div class="old-box">
    <span class="label-title">❌ Current Text (Page 50 Para 2 &amp; Page 52 Top Paragraph):</span>
    • <b>Page 50 (Para 2, Last Line):</b> "...enhancing efficiency, reliability, and accessibility in parking management through modern <b>digital commerce solutions</b>."<br>
    • <b>Page 52 (Top Paragraph, Lines 3–6):</b> "At the same time, Chan’s analysis suggests that future scalability of E-Parada could <b>explore additional revenue streams, such as premium reservation services or subscription-based features, to strengthen its viability as a digital marketplace</b>."
  </div>
  <div class="new-box">
    <span class="label-title">✅ Replace With:</span>
    • <b>Page 50 (Para 2, Last Line):</b> "...enhancing efficiency, reliability, and accessibility in parking management through modern <b>digital payment solutions</b>."<br>
    • <b>Page 51–52 (Replace entire bottom paragraph of Page 51 / top of Page 52):</b> "This strategic perspective is relevant to E-Parada, as it highlights the importance of aligning digital payment integration with user convenience and transactional reliability. By adopting GCash as its primary cashless payment option via automated webhook verification, E-Parada benefits from the platform’s established security and local accessibility, ensuring seamless, verifiable settlements between drivers and parking space providers."
  </div>
</div>

<div class="card">
  <span class="page-tag">Pages 66–67 — Chapter 3: Software Development Model</span>
  <div class="old-box">
    <span class="label-title">❌ Current Text (Page 66 Bottom &amp; Page 67 Middle Paragraph):</span>
    • <b>Page 66 (Last Line):</b> "...dimension configuration, rate management, and <b>3D layout visualization</b>;"<br>
    • <b>Page 67 (Paragraph 2):</b> "Furthermore, the effectiveness and performance of the completed system will be evaluated through objective technical testing and structured user evaluation... User evaluation will be conducted among selected respondents representing the primary stakeholders—namely licensed drivers, residential and commercial parking space providers, and IT/software engineering experts—to assess the platform’s usability, quality, and user acceptance under realistic deployment conditions in Calamba City, Laguna."
  </div>
  <div class="new-box">
    <span class="label-title">✅ Replace With:</span>
    • <b>Page 66 (Last Line):</b> "...dimension configuration, rate management, and <b>interactive 2D floor plan slot mapping</b>;"<br>
    • <b>Page 67 (Paragraph 2):</b> "Furthermore, the effectiveness and performance of the completed system will be evaluated through objective technical benchmarking and structured expert evaluation. Objective performance testing will measure system metrics including API response latency, OCR extraction speed, QR code decoding time, and database concurrency resilience. Software product quality evaluation will be conducted among purposively selected IT developers and software engineering professionals—who will execute complete role workflows across the driver, parking space provider, and administrator modules—to assess the platform’s Functional Suitability, Performance Efficiency, Usability, and Reliability under the ISO/IEC 25010:2011 standard."
  </div>
</div>

<div class="card">
  <span class="page-tag critical">Page 116 — System Flowchart Narrative (Platform Service Fee Removal)</span>
  <div class="old-box">
    <span class="label-title">❌ Current Text (Page 116, Paragraphs 2 &amp; 3):</span>
    • <b>Paragraph 2, Lines 8–10:</b> "Once payment is confirmed, the transaction receipt is saved in the database, <b>the provider's earnings are credited minus the platform's service fee</b>, and the driver is given the option to rate and review the parking facility."<br>
    • <b>Paragraph 3, Lines 6–8:</b> "In addition, the backend compiles system reports from the database, giving the administrator an overview of total bookings, <b>revenue, platform fees</b>, and active users."
  </div>
  <div class="new-box">
    <span class="label-title">✅ Replace With:</span>
    • <b>Paragraph 2, Lines 8–10:</b> "Once payment is confirmed, the transaction receipt is saved in the database, <b>the provider's cumulative earnings record is updated</b>, and the driver is given the option to rate and review the parking facility."<br>
    • <b>Paragraph 3, Lines 6–8:</b> "In addition, the backend compiles system reports from the database, giving the administrator an overview of total bookings, <b>settled transaction summaries</b>, and active users."
  </div>
</div>

<div class="page-break"></div>

<!-- ===================================================================== -->
<!-- PART 3: COMPLETE CONTINUOUS REPLACEMENT FOR PAGES 126–149             -->
<!-- ===================================================================== -->
<h2 class="section-header">PART 3: Complete Copy-Paste Replacement for Pages 126–149</h2>
<p><i>Highlight everything from the top of <b>Page 126</b> through the end of <b>Page 149</b> in your manuscript and replace it with the complete text below. Note that this also adds the missing <b>D. Reliability</b> table to your questionnaire and fixes the duplicate Table 4 numbering.</i></p>

<div class="manuscript-container">

<p>Following development, Phase 3 (System Integration and Testing) connects the Android mobile application and administrative web portal to the centralized Laravel REST API and Supabase PostgreSQL database, where complete functional, security, and performance stress tests are conducted. Integration testing validates the end-to-end reservation and payment pipeline, verifying that slot state transitions, PayMongo webhook callbacks, and Supabase WebSocket broadcasts execute deterministically across both native Android devices and web viewports. In Phase 4 (System Evaluation), the integrated platform is evaluated by purposively selected IT developers using the ISO/IEC 25010:2011 Software Product Quality Model (assessing Functional Suitability, Performance Efficiency, Usability, and Reliability), with gathered evaluation ratings analyzed using the weighted mean. Finally, Phase 5 (Output) delivers the complete, evaluated E-Parada system, comprising the Android mobile application for drivers and parking space providers and the centralized administrative web portal.</p>

<h3>Data Collection</h3>

<p>This section outlines the operational test locale, evaluator selection, sampling technique, data gathering procedures, evaluation instrument, and ethical considerations utilized in validating the E-Parada system. The study performs functional scenario validation, objective technical benchmarking, and ISO/IEC 25010:2011 software product quality evaluation conducted by IT developers.</p>

<h3>Research Locale</h3>

<p>Calamba City, Laguna, Philippines serves as the operational context and spatial simulation locale for the study. Due to its rapid urban growth, high concentration of educational institutions (including National University Laguna), major transport terminals, and bustling commercial districts, the area experiences acute parking shortages and roadside congestion. All geospatial coordinates, Google Maps routing tests, and residential/commercial parking space listings modeled and tested within the E-Parada platform are anchored within Calamba City.</p>

<h3>Evaluators and Sampling Technique</h3>

<p>To ensure a rigorous and technically grounded assessment of the platform’s software architecture, database integrity, and functional execution, the study utilizes Purposive Sampling to select qualified IT Developers and Software Engineering Professionals as system evaluators. Rather than relying on general end-user surveys, evaluators are purposively selected based on their technical expertise in mobile and web application engineering, relational database management, RESTful API integration, and software quality assurance.</p>

<p>During the evaluation phase, the participating IT developers perform comprehensive, role-based scenario walkthroughs across both the Flutter Android mobile application and the Laravel administrative web portal—simulating the complete operational workflows of Drivers, Parking Space Providers, and System Administrators. Following hands-on technical inspection, code and security review, and execution of predefined test cases, the evaluators rate the platform using the standardized ISO/IEC 25010:2011 Software Product Quality Model across four core dimensions: Functional Suitability, Performance Efficiency, Usability, and Reliability.</p>

<h3>Data Gathering Procedures</h3>

<p>Data collection and technical validation were executed in two primary phases:</p>

<ol>
  <li><b>Requirements Analysis Phase:</b> Conducted through domain analysis of urban parking workflows in Calamba City, environmental inspection of residential and commercial parking constraints, and a comprehensive review of existing smart parking literature. These technical insights established the functional specifications, vehicle dimension filtering rules, fee boundary parameters, and relational database schema of E-Parada.</li>
  <li><b>System Validation and Technical Evaluation Phase:</b> Following end-to-end system integration, the selected IT developers interacted directly with the working Android mobile application and administrative web portal across predefined operational scenarios (account registration, Tesseract OCR plate extraction, 2D floor plan slot mapping, Google Maps routing, HMAC-SHA256 QR check-in/check-out validation, automated duration billing, GCash payment gateway settlement, and WebRTC communication). After executing all test cases and auditing objective performance benchmarks, the IT developers accomplished the structured ISO/IEC 25010:2011 evaluation instrument.</li>
</ol>

<h3>Ethical Considerations and Data Privacy</h3>

<p>The Philippine Data Privacy Act of 2012 (Republic Act No. 10173) is strictly complied with throughout all system testing and evaluation procedures. Prior to conducting the evaluation, informed consent is obtained from all participating IT developers, outlining the research objectives, voluntary nature of participation, and confidentiality terms. During scenario testing, synthetic user profiles and consent-authorized developer test vehicles are utilized to ensure no unauthorized personally identifiable information (PII) is exposed. Within the platform, all uploaded identification documents, vehicle photographs, and transaction logs are protected via role-based access control (RBAC) and encrypted storage accessible exclusively to authorized administrators. All evaluation scores and feedback submitted by the IT evaluators are anonymized during statistical tabulation.</p>

<h3>OPERATION AND TESTING PROCEDURE</h3>

<h4>System Operation Procedure</h4>
<p>This section outlines the operational workflows of the E-Parada platform, categorized according to the distinct roles of Drivers, Parking Space Providers, and System Administrators, alongside the automated QR validation and payment gateway procedures.</p>

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
<p>The testing environment for E-Parada is configured as a software-driven ecosystem operating across consumer mobile devices, web browsers, and cloud server infrastructure without reliance on dedicated physical IoT sensor hardware or automated gate barriers. Testing is conducted using both simulated environments (for automated unit, concurrency, and cross-version regression testing) and physical Android hardware (for validating camera QR scanning, OCR plate extraction, GPS navigation, and WebRTC voice communication).</p>

<h4>Device Testing</h4>
<p>The Android Studio built-in emulator and physical Android smartphones running Android 8.0 or higher are used for testing. Physical devices ensure accurate validation of hardware-dependent modules—including GPS/geolocation, Google Maps routing, camera-based QR scanning, vehicle plate OCR capture, microphone access, and in-app WebRTC audio calling—while the emulator supports rapid UI testing across multiple screen resolutions. The web portal is tested across modern desktop and mobile web browsers to verify cross-platform consistency and real-time synchronization with the mobile application.</p>

<h4>Backend and Database Configuration</h4>
<p>For the E-Parada backend, PHP 8.2 and Laravel 12 are employed, while Supabase (managed PostgreSQL 15+) serves as the relational database for system integration testing, performance benchmarking, and end-to-end scenario evaluation. Supabase provides the ACID-compliant transactional environment and row-level locking needed to handle multi-user concurrency. Laravel manages the administrative web portal, RESTful API endpoints, authentication, validation, and application logic, while the Flutter mobile client communicates with the backend over HTTPS using JSON payloads.</p>

<h4>Network Conditions</h4>
<p>Testing is conducted under varying network conditions, including high-speed broadband Wi-Fi, cellular mobile data (4G/LTE), and simulated low-bandwidth or throttled connections. High-speed Wi-Fi establishes baseline system performance, while 4G/LTE represents typical real-world mobile connectivity for drivers and parking providers. Low-bandwidth conditions are simulated to assess the system’s timeout handling, error notifications, and graceful degradation across reservation synchronization, API connectivity, Google Maps services, in-app messaging, and WebRTC audio communication.</p>

<h3>Testing Phases</h3>
<p>System testing is conducted across three sequential phases aligned with the Incremental Development Model:</p>

<p><b>Table 3</b><br><i>System Testing Phases and Acceptance Criteria</i></p>
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

<p>Alpha Testing is conducted internally by the development team during each of the five development increments. Unit and module-level tests are performed to verify core functions, database consistency, and RESTful API operations. Critical functions must achieve a 100% passing rate before proceeding to integration with subsequent modules.</p>

<p>System and Scenario Evaluation is carried out with purposively selected IT developers and software professionals. Evaluators execute complete end-to-end workflows across all user roles (Driver, Parking Space Provider, and System Administrator) under realistic operating conditions to evaluate the platform’s functional completeness, performance efficiency, usability, and reliability. A minimum scenario completion rate of 95% with zero concurrency double-bookings is enforced as the acceptance criterion.</p>

<p>Regression Testing is performed whenever modifications are introduced to the system, including code optimizations, bug fixes, and dependency updates, confirming that new changes do not negatively affect previously verified reservation workflows, billing computations, or database operations.</p>

<h3>Test Case Coverage</h3>
<p><b>Table 4</b><br><i>Test Case Coverage Matrix</i></p>
<table class="apa">
  <thead>
    <tr>
      <th style="width:25%;">Test Category</th>
      <th style="width:35%;">Test Case Identifier &amp; Scope</th>
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

<p>The test coverage matrix defines specific validation requirements for both normal system operations and critical edge-case scenarios. Aside from core functions such as user authentication, vehicle OCR processing, interactive 2D parking slot mapping, and Google Maps navigation, the matrix gives particular attention to system security and concurrent transactions. TC-10 assesses the system’s ability to prevent double-booking when multiple requests attempt to reserve the same parking slot simultaneously by applying database row-level locking through SELECT ... FOR UPDATE. Security-related test cases, including TC-02, TC-12, and TC-13, verify that unauthorized API access is denied, reused QR codes are rejected through single-use token invalidation, and scanning attempts made by unauthorized parking providers are blocked. In addition, TC-15 to TC-20 examine the accuracy of parking duration and overstay billing computations, real-time processing of GCash payment webhooks, WebRTC audio communication performance, and the system’s ability to handle network interruptions without causing operational failures.</p>

<h3>EVALUATION</h3>

<h4>Evaluation Criteria</h4>
<p>The <b>ISO/IEC 25010:2011 Software Product Quality Model</b> is utilized to evaluate E-Parada. To assess the technical quality of the developed mobile application and administrative web portal, the system is evaluated by purposively selected IT developers across four core software quality characteristics: Functional Suitability, Performance Efficiency, Usability, and Reliability.</p>

<p>To ensure a rigorous engineering assessment, the evaluation combines objective technical performance benchmarking (measuring API response latencies, execution speeds, and concurrency resilience) with structured expert software quality evaluation conducted by IT developers.</p>

<h4>ISO/IEC 25010:2011 Software Product Quality Framework</h4>
<p><b>Functional Suitability.</b> This criterion determines the degree to which E-Parada provides functions that meet stated and implied needs when used under specified conditions. Features including authentication, OCR vehicle registration, space/slot listing, interactive 2D slot mapping, Google Maps routing, QR entry/exit validation, automated duration billing, cash and GCash payment gateway settlement, and WebRTC voice communication are assessed under this criterion.</p>
<p><b>Performance Efficiency.</b> This criterion determines the performance of E-Parada relative to the amount of resources used under stated conditions. It assesses the time behavior (response and processing times), resource utilization, and capacity of the mobile application, web portal, and backend RESTful API under standard and concurrent workloads.</p>
<p><b>Usability.</b> This criterion determines the degree to which E-Parada can be understood, learned, operated, and attractive to users across the driver, parking space provider, and administrator interfaces, including built-in user error protection and accessibility.</p>
<p><b>Reliability.</b> This criterion determines the degree to which E-Parada performs specified functions under specified conditions for a specified period of time. It assesses operational maturity, availability, fault tolerance against network drops or invalid inputs, and data recoverability across reservation records, slot states, QR logs, and payment transactions.</p>

<h4>Objective Technical Performance Benchmarks</h4>
<p>Alongside the ISO/IEC 25010:2011 evaluation, objective technical benchmarking is conducted across six critical system operations. The benchmark metrics, target thresholds, measurement instruments, and evaluated components are summarized in Table 5:</p>

<p><b>Table 5</b><br><i>Objective System Performance Benchmarks</i></p>
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
<p>The primary evaluation instrument is a structured, five-point Likert scale software quality assessment questionnaire adapted directly from the ISO/IEC 25010:2011 Software Product Quality Model and administered to IT developers. Because the instrument utilizes internationally standardized ISO/IEC 25010:2011 quality sub-characteristics, construct validity is established by standard definition.</p>

<p>The following five-point Likert Scale will be used in interpreting the responses:</p>
<table class="apa" style="width:65%;">
  <thead>
    <tr><th style="width:30%;">Scale</th><th style="width:70%;">Verbal Interpretation</th></tr>
  </thead>
  <tbody>
    <tr><td>5</td><td>Strongly Agree</td></tr>
    <tr><td>4</td><td>Agree</td></tr>
    <tr><td>3</td><td>Neutral</td></tr>
    <tr><td>2</td><td>Disagree</td></tr>
    <tr><td>1</td><td>Strongly Disagree</td></tr>
  </tbody>
</table>

<p>The evaluation questionnaire will contain the following:</p>

<h4>Part I. Evaluator Information</h4>
<p>Name (Optional): ____________________________<br>
Current Position / Title: _______________________</p>

<p><b>Technical Specialization:</b><br>
☐ Software / Full-Stack Developer<br>
☐ Mobile / Frontend Developer<br>
☐ Backend / Database Engineer<br>
☐ QA Engineer / Systems &amp; IT Specialist</p>

<p><b>Years of Software / IT Experience:</b><br>
☐ 1 – 2 Years &nbsp;&nbsp;&nbsp;&nbsp; ☐ 3 – 5 Years &nbsp;&nbsp;&nbsp;&nbsp; ☐ More than 5 Years</p>

<h4>Part II. System Evaluation</h4>
<p><b>Direction:</b> After testing the E-Parada mobile application and administrative web portal across the Driver, Parking Space Provider, and Administrator workflows, please evaluate the system by placing a check (✔) on the number that best describes your assessment of the system.</p>

<h4>A. Functional Suitability</h4>
<table class="grid">
  <thead>
    <tr>
      <th style="width:75%;">Statements</th>
      <th style="width:5%; text-align:center;">5</th>
      <th style="width:5%; text-align:center;">4</th>
      <th style="width:5%; text-align:center;">3</th>
      <th style="width:5%; text-align:center;">2</th>
      <th style="width:5%; text-align:center;">1</th>
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
      <th style="width:75%;">Statements</th>
      <th style="width:5%; text-align:center;">5</th>
      <th style="width:5%; text-align:center;">4</th>
      <th style="width:5%; text-align:center;">3</th>
      <th style="width:5%; text-align:center;">2</th>
      <th style="width:5%; text-align:center;">1</th>
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
      <th style="width:75%;">Statements</th>
      <th style="width:5%; text-align:center;">5</th>
      <th style="width:5%; text-align:center;">4</th>
      <th style="width:5%; text-align:center;">3</th>
      <th style="width:5%; text-align:center;">2</th>
      <th style="width:5%; text-align:center;">1</th>
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
      <th style="width:75%;">Statements</th>
      <th style="width:5%; text-align:center;">5</th>
      <th style="width:5%; text-align:center;">4</th>
      <th style="width:5%; text-align:center;">3</th>
      <th style="width:5%; text-align:center;">2</th>
      <th style="width:5%; text-align:center;">1</th>
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

<p>The evaluation instrument will be administered to the purposively selected IT developers after they inspect and test the appropriate features of the mobile application and administrative web portal across all user roles. The responses gathered from the selected ISO/IEC 25010:2011 characteristics will be used to assess the quality of the developed system using the weighted mean.</p>

<h3>Statistical Treatment and Interpretation of Data</h3>
<p>This section presents the statistical methods and computation formulas used to evaluate the performance and quality of the proposed system, “E-Parada: A Digital Marketplace for Parking Spaces.” The data gathered from the IT developer evaluation questionnaire will be analyzed using descriptive statistical measures to determine the evaluators' assessment of the E-Parada system based on the selected ISO/IEC 25010:2011 software quality characteristics: Functional Suitability, Performance Efficiency, Usability, and Reliability.</p>

<ol>
  <li><b>Frequency and Percentage Distribution:</b> Used to tabulate and profile the professional background of the IT developer evaluators (technical specialization and years of experience). The formula is expressed as:</li>
</ol>
<div class="formula-box">P = ( f / N ) × 100</div>
<p>Where:<br>
<b>P</b> = Percentage distribution (%)<br>
<b><i>f</i></b> = Frequency of evaluators in a specific category<br>
<b>N</b> = Total number of IT developer evaluators</p>

<ol start="2">
  <li><b>Weighted Mean:</b> Used to calculate the central tendency and overall average rating for each individual indicator and software quality characteristic. The formula is expressed as:</li>
</ol>
<div class="formula-box">X̄ = ( ∑ fx ) / N</div>
<p>Where:<br>
<b>X̄</b> = Weighted Mean<br>
<b><i>f</i></b> = Frequency of responses<br>
<b>x</b> = Weight assigned to each response (1–5)<br>
<b>N</b> = Total number of IT developer evaluators</p>

<ol start="3">
  <li><b>Standard Deviation (SD):</b> Used to determine the degree of dispersion or variability of IT developer ratings around the weighted mean, assessing the consistency of responses. The formula is expressed as:</li>
</ol>
<div class="formula-box">SD = √[ ∑(X - X̄)² / (N - 1) ]</div>
<p>Where:<br>
<b>SD</b> = Sample Standard Deviation<br>
<b>X</b> = Each value from the sample<br>
<b>X̄</b> = The sample mean<br>
<b>N</b> = Total number of IT developer evaluators</p>

<ol start="4">
  <li><b>Scale and Verbal Interpretation Matrix:</b> To interpret the computed weighted means systematically, a five-point Likert scale with corresponding weighted mean intervals is established. Table 6 outlines the scale ranges alongside their respective ISO/IEC 25010:2011 software quality ratings:</li>
</ol>

<p><b>Table 6</b><br><i>Likert Scale Range and Verbal Interpretation Matrix</i></p>
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
    <tr><td>5</td><td>4.21 – 5.00</td><td>Excellent / Highly Compliant</td><td>Outstanding software quality.</td></tr>
    <tr><td>4</td><td>3.41 – 4.20</td><td>Very Good / Compliant</td><td>High software quality.</td></tr>
    <tr><td>3</td><td>2.61 – 3.40</td><td>Fair / Moderately Compliant</td><td>Moderate software quality.</td></tr>
    <tr><td>2</td><td>1.81 – 2.60</td><td>Poor / Low Compliance</td><td>Substandard software quality.</td></tr>
    <tr><td>1</td><td>1.00 – 1.80</td><td>Very Poor / Non-Compliant</td><td>Unacceptable software quality.</td></tr>
  </tbody>
</table>

</div>

</body>
</html>
"""
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"Wrote print HTML: {html_path}")

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
    print(f"Generated PDF: {pdf_path}")

    shutil.copy2(pdf_path, artifact_pdf)
    print(f"Copied PDF to artifacts: {artifact_pdf}")

    # Verify page count with pypdf
    import pypdf
    reader = pypdf.PdfReader(pdf_path)
    print(f"PDF verified successfully! Total pages: {len(reader.pages)}")

if __name__ == '__main__':
    generate_pdf_guide()
