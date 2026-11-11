#!/usr/bin/env python3
"""
Synchronizes the Draw.io XML into the interactive standalone HTML viewer files
for Level 0, Level 1, and Level 2 DFDs in both workspace and artifact directories.
"""

import html
import json
import os

ARTIFACT_DIR = r"C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185"
WORKSPACE_DIR = r"c:\Users\kimch\e_parada_mobile"

def generate_html(title, subtitle, badge, drawio_xml):
    # JSON-encode config
    config = {
        "highlight": "#0000ff",
        "nav": True,
        "resize": True,
        "toolbar": "zoom layers tags lightbox pages",
        "edit": "_blank",
        "xml": drawio_xml
    }
    config_json = json.dumps(config)
    escaped_config = html.escape(config_json, quote=True)
    
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>{title}</title>
  <style>
    body {{
      margin: 0;
      padding: 20px;
      background: #f8fafc;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      padding-bottom: 12px;
      border-bottom: 1px solid #e2e8f0;
    }}
    h1 {{
      margin: 0 0 4px 0;
      font-size: 20px;
      font-weight: 700;
      color: #111827;
    }}
    p {{
      margin: 0;
      color: #6b7280;
      font-size: 13px;
    }}
    .badge {{
      background: #dcfce7;
      color: #166534;
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      white-space: nowrap;
    }}
    .viewer-container {{
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.08);
      padding: 20px;
      overflow: auto;
    }}
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>{title}</h1>
      <p>{subtitle}</p>
    </div>
    <span class="badge">{badge}</span>
  </div>
  <div class="viewer-container">
    <div class="mxgraph" style="max-width:100%;border:1px solid transparent;" data-mxgraph="{escaped_config}"></div>
  </div>
  <script type="text/javascript" src="https://viewer.diagrams.net/js/viewer-static.min.js"></script>
</body>
</html>
"""
    return html_content

def sync_dfd(base_name, title, subtitle, badge):
    src_drawio = os.path.join(WORKSPACE_DIR, f"{base_name}.drawio")
    with open(src_drawio, "r", encoding="utf-8") as f:
        drawio_xml = f.read()
    
    html_str = generate_html(title, subtitle, badge, drawio_xml)
    
    # Save workspace files
    with open(os.path.join(WORKSPACE_DIR, f"{base_name}.html"), "w", encoding="utf-8") as f:
        f.write(html_str)
    
    # Save artifact files
    with open(os.path.join(ARTIFACT_DIR, f"{base_name}.drawio"), "w", encoding="utf-8") as f:
        f.write(drawio_xml)
        
    with open(os.path.join(ARTIFACT_DIR, f"{base_name}.html"), "w", encoding="utf-8") as f:
        f.write(html_str)
        
    print(f"Synchronized {base_name} (drawio + html) to workspace and artifacts.")

sync_dfd(
    "e_parada_dfd_level_0",
    "E-Parada: Level 0 Data Flow Diagram (Portrait - Gane & Sarson / IEEE Standard)",
    "7 Core Processes (1.0 to 7.0) - 4 External Entities - 6 Data Stores (D1-D6) - 33 High-Level Composite Flows",
    "Portrait Orientation (1180x1310) - Zero Intersections (0 Crossings)"
)

sync_dfd(
    "e_parada_dfd_level_1",
    "E-Parada: Level 1 Data Flow Diagram (Single-Tab Portrait - 15 Subprocesses)",
    "12 Elementary Modules + 3 Compound Processes (1.1, 2.3, 4.1) - 4 Entities - 6 Data Stores - 51 Zero-Intersection Flows",
    "Single-Page Portrait (1240x1540) - Zero Intersections (0 Crossings)"
)

sync_dfd(
    "e_parada_dfd_level_2",
    "E-Parada: Level 2 Data Flow Diagram (Single-Tab Portrait - 6 Elementary Subprocesses)",
    "Decomposes Compound Processes 1.1, 2.3 & 4.1 into 6 Elementary Modules (12 L1 + 6 L2 = 18 Total System Modules)",
    "Single-Page Portrait (1180x1160) - Fewest Processes (6) - 0 Crossings"
)
