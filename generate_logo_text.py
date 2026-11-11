import os
import subprocess
import shutil
import base64
from PIL import Image

WORKSPACE = r'c:\Users\kimch\e_parada_mobile'
BRANDING_DIR = os.path.join(WORKSPACE, 'assets', 'branding')
ARTIFACT_DIR = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185'
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
SCRATCH = os.path.join(WORKSPACE, 'scratch')
os.makedirs(SCRATCH, exist_ok=True)
os.makedirs(BRANDING_DIR, exist_ok=True)

# Read the logo image and encode as base64 so Chrome can render it standalone with 0 security/cors restrictions
logo_path = os.path.join(BRANDING_DIR, 'eparada_general.png')
with open(logo_path, 'rb') as f:
    logo_b64 = base64.b64encode(f.read()).decode('utf-8')
logo_data_uri = f'data:image/png;base64,{logo_b64}'

def build_svg_and_pngs():
    # 1. Pure SVG Wordmarks and Lockups
    # SVG 1: Horizontal Lockup
    svg_horizontal = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1100 320" width="1100" height="320">
  <defs>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#E8BC2E" />
      <stop offset="100%" stop-color="#C59608" />
    </linearGradient>
    <filter id="shadow" x="-10%" y="-10%" width="130%" height="130%">
      <feDropShadow dx="0" dy="6" stdDeviation="8" flood-color="#0F172A" flood-opacity="0.16" />
    </filter>
  </defs>
  <!-- Logo Icon -->
  <g transform="translate(30, 20) scale(0.27)" filter="url(#shadow)">
    <image href="{logo_data_uri}" width="1024" height="1024" />
  </g>
  <!-- Text Brand -->
  <g transform="translate(340, 150)">
    <text font-family="'Segoe UI', 'Montserrat', system-ui, -apple-system, sans-serif" font-weight="900" font-size="82" letter-spacing="-1">
      <tspan fill="url(#goldGrad)">E</tspan><tspan fill="#7BAAD6">-</tspan><tspan fill="#1A3054">PARADA</tspan>
    </text>
    <text y="42" font-family="'Segoe UI', 'Plus Jakarta Sans', system-ui, sans-serif" font-weight="700" font-size="17" fill="#4B6A96" letter-spacing="4.5">
      DIGITAL MARKETPLACE FOR PARKING SPACES
    </text>
    <g transform="translate(0, 78)">
      <text font-family="'Segoe UI', system-ui, sans-serif" font-weight="600" font-size="14.5" fill="#7E93A8" letter-spacing="1.2">
        SMART PARKING WITHIN REACH
      </text>
      <circle cx="270" cy="-5" r="3.5" fill="#E8BC2E" />
      <text x="286" font-family="'Segoe UI', system-ui, sans-serif" font-weight="600" font-size="14.5" fill="#7E93A8" letter-spacing="1.2">
        CALAMBA CITY
      </text>
    </g>
  </g>
</svg>'''

    # SVG 2: Horizontal Dark Lockup
    svg_horizontal_dark = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1100 320" width="1100" height="320">
  <defs>
    <linearGradient id="goldGradDark" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#F3CA3E" />
      <stop offset="100%" stop-color="#D4A017" />
    </linearGradient>
  </defs>
  <rect width="1100" height="320" rx="20" fill="#0A1128" />
  <!-- Logo Icon -->
  <g transform="translate(40, 20) scale(0.27)">
    <image href="{logo_data_uri}" width="1024" height="1024" />
  </g>
  <!-- Text Brand -->
  <g transform="translate(350, 150)">
    <text font-family="'Segoe UI', 'Montserrat', system-ui, -apple-system, sans-serif" font-weight="900" font-size="82" letter-spacing="-1">
      <tspan fill="url(#goldGradDark)">E</tspan><tspan fill="#93C5FD">-</tspan><tspan fill="#FFFFFF">PARADA</tspan>
    </text>
    <text y="42" font-family="'Segoe UI', 'Plus Jakarta Sans', system-ui, sans-serif" font-weight="700" font-size="17" fill="#94A3B8" letter-spacing="4.5">
      DIGITAL MARKETPLACE FOR PARKING SPACES
    </text>
    <g transform="translate(0, 78)">
      <text font-family="'Segoe UI', system-ui, sans-serif" font-weight="600" font-size="14.5" fill="#64748B" letter-spacing="1.2">
        SMART PARKING WITHIN REACH
      </text>
      <circle cx="270" cy="-5" r="3.5" fill="#F3CA3E" />
      <text x="286" font-family="'Segoe UI', system-ui, sans-serif" font-weight="600" font-size="14.5" fill="#64748B" letter-spacing="1.2">
        CALAMBA CITY
      </text>
    </g>
  </g>
</svg>'''

    # SVG 3: Stacked / Centered Lockup
    svg_stacked = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 680 560" width="680" height="560">
  <defs>
    <linearGradient id="goldGradStack" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#E8BC2E" />
      <stop offset="100%" stop-color="#C59608" />
    </linearGradient>
    <filter id="shadowStack" x="-10%" y="-10%" width="130%" height="130%">
      <feDropShadow dx="0" dy="6" stdDeviation="8" flood-color="#0F172A" flood-opacity="0.14" />
    </filter>
  </defs>
  <!-- Logo Icon -->
  <g transform="translate(225, 30) scale(0.225)" filter="url(#shadowStack)">
    <image href="{logo_data_uri}" width="1024" height="1024" />
  </g>
  <!-- Text Brand -->
  <g transform="translate(340, 350)" text-anchor="middle">
    <text font-family="'Segoe UI', 'Montserrat', system-ui, -apple-system, sans-serif" font-weight="900" font-size="76" letter-spacing="-1">
      <tspan fill="url(#goldGradStack)">E</tspan><tspan fill="#7BAAD6">-</tspan><tspan fill="#1A3054">PARADA</tspan>
    </text>
    <text y="44" font-family="'Segoe UI', 'Plus Jakarta Sans', system-ui, sans-serif" font-weight="700" font-size="16" fill="#4B6A96" letter-spacing="4">
      DIGITAL MARKETPLACE FOR PARKING SPACES
    </text>
    <text y="82" font-family="'Segoe UI', system-ui, sans-serif" font-weight="600" font-size="14" fill="#7E93A8" letter-spacing="1.2">
      SMART PARKING WITHIN REACH &bull; CALAMBA CITY
    </text>
  </g>
</svg>'''

    # Write SVGs
    svg_h_path = os.path.join(BRANDING_DIR, 'eparada_logo_horizontal.svg')
    svg_hd_path = os.path.join(BRANDING_DIR, 'eparada_logo_horizontal_dark.svg')
    svg_s_path = os.path.join(BRANDING_DIR, 'eparada_logo_stacked.svg')

    with open(svg_h_path, 'w', encoding='utf-8') as f: f.write(svg_horizontal)
    with open(svg_hd_path, 'w', encoding='utf-8') as f: f.write(svg_horizontal_dark)
    with open(svg_s_path, 'w', encoding='utf-8') as f: f.write(svg_stacked)
    print("Saved vector SVGs to assets/branding/")

    # Also render high-res PNGs using Chrome headless screenshot
    render_html = f'''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  body {{ margin: 0; padding: 0; background: transparent; overflow: hidden; }}
  .box {{ display: inline-block; }}
</style>
</head>
<body>
<div class="box">{svg_horizontal}</div>
</body>
</html>'''
    
    html_temp = os.path.join(SCRATCH, 'render_h.html')
    with open(html_temp, 'w', encoding='utf-8') as f: f.write(render_html)
    
    png_h_path = os.path.join(BRANDING_DIR, 'eparada_logo_horizontal.png')
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--default-background-color=00000000',
                    '--window-size=1150,380', f'--screenshot={png_h_path}', 'file:///' + html_temp.replace('\\', '/')],
                   check=True)

    # Render dark horizontal
    render_hd = f'''<!DOCTYPE html><html><body style="margin:0;background:transparent;overflow:hidden;">{svg_horizontal_dark}</body></html>'''
    html_hd_temp = os.path.join(SCRATCH, 'render_hd.html')
    with open(html_hd_temp, 'w', encoding='utf-8') as f: f.write(render_hd)
    png_hd_path = os.path.join(BRANDING_DIR, 'eparada_logo_horizontal_dark.png')
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--default-background-color=00000000',
                    '--window-size=1150,380', f'--screenshot={png_hd_path}', 'file:///' + html_hd_temp.replace('\\', '/')],
                   check=True)

    # Render stacked
    render_s = f'''<!DOCTYPE html><html><body style="margin:0;background:transparent;overflow:hidden;">{svg_stacked}</body></html>'''
    html_s_temp = os.path.join(SCRATCH, 'render_s.html')
    with open(html_s_temp, 'w', encoding='utf-8') as f: f.write(render_s)
    png_s_path = os.path.join(BRANDING_DIR, 'eparada_logo_stacked.png')
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--default-background-color=00000000',
                    '--window-size=720,600', f'--screenshot={png_s_path}', 'file:///' + html_s_temp.replace('\\', '/')],
                   check=True)

    # Copy to artifacts directory as well
    for filename in ['eparada_logo_horizontal.png', 'eparada_logo_horizontal.svg', 
                     'eparada_logo_horizontal_dark.png', 'eparada_logo_horizontal_dark.svg',
                     'eparada_logo_stacked.png', 'eparada_logo_stacked.svg']:
        shutil.copy(os.path.join(BRANDING_DIR, filename), os.path.join(ARTIFACT_DIR, filename))
    
    print("Successfully generated all logo lockups (PNG + SVG) in assets/branding and artifacts!")

if __name__ == '__main__':
    build_svg_and_pngs()
