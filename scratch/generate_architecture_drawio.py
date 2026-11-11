#!/usr/bin/env python3
"""
Generates the E-Parada System Architecture Diagram in Draw.io (.drawio) XML format
and an interactive Draw.io HTML viewer (.html).
- Orientation: Portrait (1100 x 1500)
- Color Palette: Academic Neutral (Slate / Charcoal / Warm Gray / Crisp White)
- Routing: 100% Straight Vertical Orthogonal Channels (Zero crossings, zero overlaps)
"""

import html
import json

PAGE_W = 1100
PAGE_H = 1500

cells = []
edges_audit = []
cell_id_counter = 2


def next_id():
    global cell_id_counter
    cid = f"cell_{cell_id_counter}"
    cell_id_counter += 1
    return cid


def add_box(x, y, w, h, label, style, parent="1"):
    cid = next_id()
    escaped = html.escape(label, quote=True).replace("\n", "&#xa;")
    cells.append(
        f'        <mxCell id="{cid}" value="{escaped}" style="{style}" vertex="1" parent="{parent}">\n'
        f'          <mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry" />\n'
        f'        </mxCell>'
    )
    return cid


def add_vertical_arrow(x, y1, y2, label="", bidirectional=False, dashed=False):
    cid = next_id()
    escaped = html.escape(label, quote=True)
    start_arrow = "block;startFill=1;" if bidirectional else "none;startFill=0;"
    dash_style = "dashed=1;dashPattern=4 4;" if dashed else ""
    style = (
        f"edgeStyle=none;orthogonalLoop=1;jettySize=auto;html=1;"
        f"endArrow=block;endFill=1;startArrow={start_arrow}{dash_style}"
        f"strokeColor=#334155;strokeWidth=1.5;fontFamily=Helvetica;fontSize=10;"
        f"fontColor=#1E293B;labelBackgroundColor=#FFFFFF;labelBorderColor=#CBD5E1;"
        f"jumpStyle=none;"
    )
    cells.append(
        f'        <mxCell id="{cid}" value="{escaped}" style="{style}" edge="1" parent="1">\n'
        f'          <mxGeometry relative="1" as="geometry">\n'
        f'            <mxPoint x="{x}" y="{y1}" as="sourcePoint" />\n'
        f'            <mxPoint x="{x}" y="{y2}" as="targetPoint" />\n'
        f'          </mxGeometry>\n'
        f'        </mxCell>'
    )
    edges_audit.append((cid, x, min(y1, y2), max(y1, y2), label))
    return cid


# -------------------------------------------------------------------------
# STYLES (Neutral Academic Palette)
# -------------------------------------------------------------------------
STYLE_TITLE_BOX = (
    "rounded=1;arcSize=4;whiteSpace=wrap;html=1;"
    "fillColor=#1E293B;strokeColor=#0F172A;strokeWidth=2;"
    "fontColor=#FFFFFF;fontFamily=Helvetica;fontSize=15;fontStyle=1;align=center;verticalAlign=middle;"
)

STYLE_ACTOR_BOX = (
    "rounded=1;arcSize=8;whiteSpace=wrap;html=1;"
    "fillColor=#F1F5F9;strokeColor=#475569;strokeWidth=1.5;"
    "fontColor=#0F172A;fontFamily=Helvetica;fontSize=11;align=center;verticalAlign=middle;"
)

STYLE_TIER_CONTAINER = (
    "rounded=1;arcSize=3;whiteSpace=wrap;html=1;"
    "fillColor=#F8FAFC;strokeColor=#64748B;strokeWidth=1.5;dashed=1;dashPattern=6 4;"
    "verticalAlign=top;align=left;"
)

STYLE_TIER_BANNER = (
    "rounded=1;arcSize=6;whiteSpace=wrap;html=1;"
    "fillColor=#334155;strokeColor=#1E293B;strokeWidth=1.5;"
    "fontColor=#FFFFFF;fontFamily=Helvetica;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;"
)

STYLE_MAIN_MODULE = (
    "rounded=1;arcSize=4;whiteSpace=wrap;html=1;"
    "fillColor=#FFFFFF;strokeColor=#475569;strokeWidth=1.5;"
    "verticalAlign=top;align=center;"
)

STYLE_MODULE_HEADER = (
    "rounded=1;arcSize=6;whiteSpace=wrap;html=1;"
    "fillColor=#E2E8F0;strokeColor=#475569;strokeWidth=1.2;"
    "fontColor=#0F172A;fontFamily=Helvetica;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;"
)

STYLE_SUB_CARD = (
    "rounded=1;arcSize=6;whiteSpace=wrap;html=1;"
    "fillColor=#F8FAFC;strokeColor=#94A3B8;strokeWidth=1;"
    "fontColor=#1E293B;fontFamily=Helvetica;fontSize=10;align=center;verticalAlign=middle;"
)

STYLE_MODEL_PILL = (
    "rounded=1;arcSize=12;whiteSpace=wrap;html=1;"
    "fillColor=#F1F5F9;strokeColor=#64748B;strokeWidth=1.2;"
    "fontColor=#0F172A;fontFamily=Helvetica;fontSize=10;fontStyle=1;align=center;verticalAlign=middle;"
)

# -------------------------------------------------------------------------
# 0. DIAGRAM HEADER BLOCK
# -------------------------------------------------------------------------
add_box(
    40, 20, 1020, 56,
    "<b>E-PARADA: SYSTEM ARCHITECTURE</b><br>"
    "<font style='font-size:11px;font-weight:normal;color:#CBD5E1;'>"
    "3-Tier Client-Server Architecture Utilizing an API-Centric Hybrid Model-View-Controller (MVC) Pattern"
    "</font>",
    STYLE_TITLE_BOX
)

# -------------------------------------------------------------------------
# 1. STAKEHOLDER / USER ACCESS LAYER
# -------------------------------------------------------------------------
add_box(
    70, 92, 450, 52,
    "<b>Mobile Stakeholders: Drivers, Space Providers &amp; Administrators</b><br>"
    "<font style='font-size:10px;color:#475569;'>Access via Android / iOS Smartphones (Navigation, Operations &amp; Mobile Admin)</font>",
    STYLE_ACTOR_BOX
)

add_box(
    580, 92, 450, 52,
    "<b>Web Stakeholders: Administrators, Space Providers &amp; Drivers</b><br>"
    "<font style='font-size:10px;color:#475569;'>Access via Desktop &amp; Mobile Web Browsers (Portal, Management &amp; Governance)</font>",
    STYLE_ACTOR_BOX
)

# Vertical Connectors: Stakeholders -> Tier 1
add_vertical_arrow(295, 144, 232, "Touch Gestures, GPS & Camera", bidirectional=True)
add_vertical_arrow(805, 144, 232, "Browser HTTPS Navigation", bidirectional=True)

# -------------------------------------------------------------------------
# 2. TIER 1: PRESENTATION TIER (CLIENT LAYER - DUAL VIEW)
# -------------------------------------------------------------------------
add_box(40, 188, 1020, 280, "", STYLE_TIER_CONTAINER)
add_box(
    40, 188, 1020, 30,
    "TIER 1: PRESENTATION TIER  —  CLIENT LAYER (HYBRID MVC DUAL VIEW INTERFACE)",
    STYLE_TIER_BANNER
)

# Left Module: Flutter Mobile App (Client-Side View)
add_box(70, 232, 450, 222, "", STYLE_MAIN_MODULE)
add_box(
    70, 232, 450, 32,
    "[VIEW: Client-Side]  Flutter Cross-Platform Mobile Client (Dart 3.x)",
    STYLE_MODULE_HEADER
)

add_box(
    85, 276, 202, 78,
    "<b>2D Floor Plan &amp; Slot Grid</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Interactive Stall Selection<br>• Real-Time Vacancy Colors<br>• Provider Slot &amp; Rate Control</font>",
    STYLE_SUB_CARD
)
add_box(
    303, 276, 202, 78,
    "<b>GPS &amp; Route Navigation</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Google Maps Platform SDK<br>• Turn-by-Turn Polyline Route<br>• Proximity Radius Search</font>",
    STYLE_SUB_CARD
)
add_box(
    85, 364, 202, 78,
    "<b>QR Pass &amp; Offline Resilience</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Optical Gate QR Scanner<br>• OfflineParkingPassService<br>• Manual Code (RES-XXXX)</font>",
    STYLE_SUB_CARD
)
add_box(
    303, 364, 202, 78,
    "<b>Mobile Admin, Comms &amp; OCR</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Admin KYC &amp; Space Reviews<br>• Reservation Chat &amp; WebRTC<br>• Plate OCR Camera Capture</font>",
    STYLE_SUB_CARD
)

# Right Module: Web Management Portal (Server-Side View)
add_box(580, 232, 450, 222, "", STYLE_MAIN_MODULE)
add_box(
    580, 232, 450, 32,
    "[VIEW: Server-Side]  Responsive Web Portal (Laravel Blade / Tailwind CSS)",
    STYLE_MODULE_HEADER
)

add_box(
    595, 276, 202, 78,
    "<b>Admin Governance &amp; KYC</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Driver &amp; Owner KYC Review<br>• Space Listing Approval<br>• System Audit &amp; Ban Controls</font>",
    STYLE_SUB_CARD
)
add_box(
    813, 276, 202, 78,
    "<b>Provider Space Management</b><br>"
    "<font style='font-size:9px;color:#475569;'>• 2D Floor Plan Slot Builder<br>• Pricing &amp; Overstay Policy<br>• Reservation Approval Queue</font>",
    STYLE_SUB_CARD
)
add_box(
    595, 364, 202, 78,
    "<b>Gate Checkpoint Terminal</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Web QR Scanner Interface<br>• Manual Code (RES-XXXX)<br>• Cash Settlement Confirmation</font>",
    STYLE_SUB_CARD
)
add_box(
    813, 364, 202, 78,
    "<b>Analytics &amp; Driver Web View</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Smart Occupancy Heatmaps<br>• Revenue &amp; Settlement Logs<br>• Web Booking &amp; Digital Receipts</font>",
    STYLE_SUB_CARD
)

# -------------------------------------------------------------------------
# NETWORK CHANNEL 1: TIER 1 <-> TIER 2 (y = 454 to 596)
# -------------------------------------------------------------------------
add_vertical_arrow(190, 454, 596, "HTTPS REST API (JSON / Sanctum Token)")
add_vertical_arrow(400, 596, 454, "JSON Responses & Status Codes")

add_vertical_arrow(700, 454, 596, "HTTPS Web Request (Session / CSRF)")
add_vertical_arrow(910, 596, 454, "Rendered HTML5 / Blade Views")

# -------------------------------------------------------------------------
# 3. TIER 2: APPLICATION & BUSINESS LOGIC TIER (LARAVEL 11 HYBRID MVC)
# -------------------------------------------------------------------------
add_box(40, 552, 1020, 516, "", STYLE_TIER_CONTAINER)
add_box(
    40, 552, 1020, 30,
    "TIER 2: APPLICATION & BUSINESS LOGIC TIER  —  CENTRALIZED SERVER (LARAVEL 11 / PHP 8.2)",
    STYLE_TIER_BANNER
)

# Sub-Layer 2A: Dual Controller Layer
add_box(70, 596, 450, 134, "", STYLE_MAIN_MODULE)
add_box(
    70, 596, 450, 30,
    "[CONTROLLER: API]  RESTful API Controllers (routes/api.php)",
    STYLE_MODULE_HEADER
)
add_box(
    85, 636, 420, 82,
    "<b>Stateless Token Middleware &amp; API Endpoints</b><br>"
    "<font style='font-size:9.5px;color:#334155;'>"
    "• <b>Auth &amp; 3-Role RBAC:</b> Sanctum Bearer Token &amp; RoleMiddleware (Driver / Owner / Admin)<br>"
    "• <b>Core &amp; Admin APIs:</b> Auth, Vehicle, Space, Reservation, Admin KYC (/api/admin/*)<br>"
    "• <b>Operations:</b> QR Check-In/Out, PayMongo Webhook, Chat &amp; WebRTC Signaling"
    "</font>",
    STYLE_SUB_CARD
)

add_box(580, 596, 450, 134, "", STYLE_MAIN_MODULE)
add_box(
    580, 596, 450, 30,
    "[CONTROLLER: Web]  Web MVC Controllers (routes/web.php)",
    STYLE_MODULE_HEADER
)
add_box(
    595, 636, 420, 82,
    "<b>Stateful Session Middleware &amp; Web Controllers</b><br>"
    "<font style='font-size:9.5px;color:#334155;'>"
    "• <b>Auth &amp; Security:</b> Session Guard, CSRF Token Verification &amp; RoleMiddleware<br>"
    "• <b>Portal Controllers:</b> AdminDashboard, KYC Review, Owner Space/Slot CRUD<br>"
    "• <b>Web Workflows:</b> Driver Web Booking, Receipt Export &amp; Analytics Reporting"
    "</font>",
    STYLE_SUB_CARD
)

# Vertical Connectors: Controllers -> Core Domain Services
add_vertical_arrow(295, 730, 774, "Dispatches Service Calls", bidirectional=False)
add_vertical_arrow(805, 730, 774, "Dispatches Service Calls", bidirectional=False)

# Sub-Layer 2B: Core Domain Services Layer
add_box(70, 774, 960, 136, "", STYLE_MAIN_MODULE)
add_box(
    70, 774, 960, 30,
    "CORE DOMAIN SERVICES &amp; BUSINESS LOGIC ENGINE (app/Services &amp; app/Support)",
    STYLE_MODULE_HEADER
)

add_box(
    85, 814, 222, 84,
    "<b>Reservation &amp; Concurrency</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Time-Window Overlap Check<br>• Row-Level Locking (FOR UPDATE)<br>• Zero Double-Booking Guard</font>",
    STYLE_SUB_CARD
)
add_box(
    321, 814, 222, 84,
    "<b>Cryptographic QR Gate Engine</b><br>"
    "<font style='font-size:9px;color:#475569;'>• HMAC-SHA256 Token Signing<br>• Single-Use Replay Protection<br>• Cross-Facility Scan Guard</font>",
    STYLE_SUB_CARD
)
add_box(
    557, 814, 222, 84,
    "<b>Billing &amp; Overstay Service</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Automated Duration Tracking<br>• 15-Minute Grace Period Rule<br>• Overstay Penalty Multipliers</font>",
    STYLE_SUB_CARD
)
add_box(
    793, 814, 222, 84,
    "<b>OCR &amp; Real-Time Signaling</b><br>"
    "<font style='font-size:9px;color:#475569;'>• LTO Plate Regex Normalizer<br>• Reservation-Bound Messaging<br>• WebRTC SDP/ICE Relay</font>",
    STYLE_SUB_CARD
)

# Vertical Connectors: Services -> Unified Model Layer
add_vertical_arrow(196, 910, 950, "", bidirectional=True)
add_vertical_arrow(432, 910, 950, "", bidirectional=True)
add_vertical_arrow(668, 910, 950, "", bidirectional=True)
add_vertical_arrow(904, 910, 950, "", bidirectional=True)

# Sub-Layer 2C: Unified Eloquent ORM Model Layer
add_box(70, 950, 960, 102, "", STYLE_MAIN_MODULE)
add_box(
    70, 950, 960, 30,
    "[MODEL: Unified Data Layer]  Eloquent ORM Models &amp; Database Abstraction (app/Models)",
    STYLE_MODULE_HEADER
)

models = [
    "User\n(RBAC & KYC)",
    "Vehicle\n(LTO Plate)",
    "ParkingSpace\n(Geofence & Rate)",
    "ParkingSlot\n(2D Grid State)",
    "Reservation\n(Lifecycle & QR)",
    "Payment\n(Cash & GCash)",
    "Conversation\n(Chat & Calls)",
    "AuditLog\n(Security Trail)"
]
pill_w = 108
pill_gap = 10
start_x = 85
for idx, m_text in enumerate(models):
    px = start_x + idx * (pill_w + pill_gap)
    add_box(px, 992, pill_w, 48, m_text, STYLE_MODEL_PILL)

# -------------------------------------------------------------------------
# NETWORK CHANNEL 2: TIER 2 <-> TIER 3 (y = 1052 to 1196)
# -------------------------------------------------------------------------
add_vertical_arrow(220, 1052, 1196, "SQL Queries & Row Locks (Persistent TLS)", bidirectional=True)
add_vertical_arrow(550, 1052, 1196, "Multipart File & Document Streams", bidirectional=True)
add_vertical_arrow(880, 1052, 1196, "HTTPS REST / Webhooks / STUN-TURN", bidirectional=True)

# -------------------------------------------------------------------------
# 4. TIER 3: DATA PERSISTENCE & EXTERNAL CLOUD INTEGRATION TIER
# -------------------------------------------------------------------------
add_box(40, 1152, 1020, 318, "", STYLE_TIER_CONTAINER)
add_box(
    40, 1152, 1020, 30,
    "TIER 3: DATA PERSISTENCE &amp; EXTERNAL CLOUD INTEGRATION TIER",
    STYLE_TIER_BANNER
)

# Left Box: Supabase PostgreSQL Database
add_box(70, 1196, 300, 256, "", STYLE_MAIN_MODULE)
add_box(
    70, 1196, 300, 32,
    "Cloud Relational Database (Supabase)",
    STYLE_MODULE_HEADER
)
add_box(
    85, 1240, 270, 62,
    "<b>PostgreSQL Engine (ACID Compliant)</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Connection Pooling (Port 5432 / 6543)<br>• Pessimistic Row-Level Concurrency Locks</font>",
    STYLE_SUB_CARD
)
add_box(
    85, 1310, 270, 62,
    "<b>Core &amp; Spatial Schema</b><br>"
    "<font style='font-size:9px;color:#475569;'>• users, vehicles, parking_spaces, parking_slots<br>• Coordinate Bounding &amp; 2D Stall Metadata</font>",
    STYLE_SUB_CARD
)
add_box(
    85, 1380, 270, 58,
    "<b>Transactional &amp; Security Schema</b><br>"
    "<font style='font-size:9px;color:#475569;'>• reservations, payments, messages, audit_logs</font>",
    STYLE_SUB_CARD
)

# Center Box: Cloud File & Media Storage
add_box(400, 1196, 300, 256, "", STYLE_MAIN_MODULE)
add_box(
    400, 1196, 300, 32,
    "Object &amp; Document Storage Layer",
    STYLE_MODULE_HEADER
)
add_box(
    415, 1240, 270, 62,
    "<b>KYC &amp; Compliance Document Vault</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Government IDs &amp; Driver's Licenses<br>• LTO OR/CR &amp; Property Ownership Proofs</font>",
    STYLE_SUB_CARD
)
add_box(
    415, 1310, 270, 62,
    "<b>Facility &amp; Transaction Media</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Parking Space Photos &amp; Reference Maps<br>• GCash Payment Proofs &amp; Digital Receipts</font>",
    STYLE_SUB_CARD
)
add_box(
    415, 1380, 270, 58,
    "<b>Local Client Storage (Mobile)</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Encrypted Offline QR Pass &amp; Session Cache</font>",
    STYLE_SUB_CARD
)

# Right Box: External Third-Party APIs & Gateways
add_box(730, 1196, 300, 256, "", STYLE_MAIN_MODULE)
add_box(
    730, 1196, 300, 32,
    "External Cloud APIs &amp; Gateways",
    STYLE_MODULE_HEADER
)
add_box(
    745, 1240, 270, 62,
    "<b>Google Maps Platform &amp; OSRM API</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Interactive Map Tiles &amp; Pin Projection<br>• Turn-by-Turn Route Polyline &amp; ETA Calculation</font>",
    STYLE_SUB_CARD
)
add_box(
    745, 1310, 270, 62,
    "<b>PayMongo / GCash Payment Gateway</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Digital E-Wallet Checkout Sessions<br>• Asynchronous Payment Webhook Verification</font>",
    STYLE_SUB_CARD
)
add_box(
    745, 1380, 270, 58,
    "<b>OCR, WebRTC STUN/TURN &amp; FCM</b><br>"
    "<font style='font-size:9px;color:#475569;'>• Tesseract/ML Kit OCR, Voice Relay &amp; Push Alerts</font>",
    STYLE_SUB_CARD
)

# -------------------------------------------------------------------------
# AUDIT EDGES FOR INTERSECTIONS
# -------------------------------------------------------------------------
intersections = 0
for i in range(len(edges_audit)):
    for j in range(i + 1, len(edges_audit)):
        id1, x1, y1_min, y1_max, _ = edges_audit[i]
        id2, x2, y2_min, y2_max, _ = edges_audit[j]
        if x1 == x2 and max(y1_min, y2_min) < min(y1_max, y2_max):
            intersections += 1
            print(f"COLLISION between {id1} and {id2} at x={x1}")

print(f"Geometric Audit: {len(edges_audit)} vertical connectors verified | {intersections} intersections.")

# -------------------------------------------------------------------------
# BUILD XML & HTML
# -------------------------------------------------------------------------
drawio_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2026-11-08T09:00:00.000Z" agent="E-Parada Architecture Generator" version="24.0.0" type="device">
  <diagram id="eparada_arch_portrait" name="Figure 6 - System Architecture (Portrait)">
    <mxGraphModel dx="1200" dy="1600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="{PAGE_W}" pageHeight="{PAGE_H}" background="#FFFFFF" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
{chr(10).join(cells)}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
"""

out_drawio_paths = [
    r"c:\Users\kimch\e_parada_mobile\e_parada_system_architecture.drawio",
    r"C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\e_parada_system_architecture.drawio",
]

for p in out_drawio_paths:
    with open(p, "w", encoding="utf-8") as f:
        f.write(drawio_xml)
    print(f"Saved Draw.io XML to: {p}")

mxgraph_config = {
    "highlight": "#334155",
    "nav": True,
    "resize": True,
    "toolbar": "zoom layers tags lightbox",
    "edit": "_blank",
    "xml": drawio_xml,
}
escaped_config = html.escape(json.dumps(mxgraph_config), quote=True)

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>E-Parada System Architecture - Portrait Neutral Edition</title>
  <style>
    body {{
      margin: 0;
      padding: 20px;
      background: #f1f5f9;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }}
    .header {{
      max-width: 1140px;
      margin: 0 auto 16px auto;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 12px;
      border-bottom: 1px solid #cbd5e1;
    }}
    h1 {{
      margin: 0 0 4px 0;
      font-size: 20px;
      font-weight: 700;
      color: #0f172a;
    }}
    p {{
      margin: 0;
      color: #475569;
      font-size: 13px;
    }}
    .badge {{
      background: #e2e8f0;
      color: #1e293b;
      border: 1px solid #94a3b8;
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }}
    .viewer-container {{
      max-width: 1140px;
      margin: 0 auto;
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
      padding: 20px;
      overflow: auto;
    }}
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>Figure 6: E-Parada System Architecture (Portrait Orientation)</h1>
      <p>3-Tier Client-Server Architecture Utilizing an API-Centric Hybrid Model-View-Controller (MVC) Pattern</p>
    </div>
    <span class="badge">Portrait (1100x1500) &bull; Neutral Palette &bull; Zero Intersecting Lines</span>
  </div>
  <div class="viewer-container">
    <div class="mxgraph" style="max-width:100%;border:1px solid transparent;" data-mxgraph="{escaped_config}"></div>
  </div>
  <script type="text/javascript" src="https://viewer.diagrams.net/js/viewer-static.min.js"></script>
</body>
</html>
"""

out_html_paths = [
    r"c:\Users\kimch\e_parada_mobile\e_parada_system_architecture.html",
    r"C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185\e_parada_system_architecture.html",
]

for p in out_html_paths:
    with open(p, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Saved HTML Viewer to: {p}")
