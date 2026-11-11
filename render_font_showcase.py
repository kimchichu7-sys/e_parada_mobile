import os
import subprocess
import shutil
import base64

WORKSPACE = r'c:\Users\kimch\e_parada_mobile'
BRANDING_DIR = os.path.join(WORKSPACE, 'assets', 'branding')
ARTIFACT_DIR = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185'
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
SCRATCH = os.path.join(WORKSPACE, 'scratch')
os.makedirs(SCRATCH, exist_ok=True)

logo_path = os.path.join(BRANDING_DIR, 'eparada_general.png')
with open(logo_path, 'rb') as f:
    logo_b64 = base64.b64encode(f.read()).decode('utf-8')
logo_data_uri = f'data:image/png;base64,{logo_b64}'

# HTML Showcase template with 5 curated font pairings that complement the curving "eP" emblem
HTML_SHOWCASE = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Comfortaa:wght@700&family=Exo+2:ital,wght@0,700;0,800;0,900;1,800&family=Nunito:wght@800;900&family=Outfit:wght@600;700;800;900&family=Plus+Jakarta+Sans:wght@700;800&family=Sora:wght@700;800&family=Urbanist:wght@700;800;900&display=swap" rel="stylesheet">
<style>
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    background: #F8FAFC;
    font-family: 'Plus Jakarta Sans', sans-serif;
    padding: 30px;
    color: #0F172A;
  }}
  .header {{
    text-align: center;
    margin-bottom: 25px;
  }}
  .header h1 {{
    font-size: 26px;
    font-weight: 800;
    color: #1A3054;
  }}
  .header p {{
    font-size: 14px;
    color: #64748B;
    margin-top: 4px;
  }}
  .grid {{
    display: flex;
    flex-direction: column;
    gap: 20px;
    max-width: 1050px;
    margin: 0 auto;
  }}
  .option-card {{
    background: #FFFFFF;
    border: 2px solid #E2E8F0;
    border-radius: 16px;
    padding: 20px 28px;
    display: flex;
    align-items: center;
    gap: 28px;
    box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04);
  }}
  .badge {{
    background: #1A3054;
    color: #FFFFFF;
    font-size: 11px;
    font-weight: 700;
    padding: 4px 10px;
    border-radius: 6px;
    letter-spacing: 0.5px;
    display: inline-block;
    margin-bottom: 6px;
  }}
  .badge-tag {{
    font-size: 12px;
    color: #64748B;
    font-weight: 600;
  }}
  .logo-img {{
    height: 105px;
    width: 105px;
    object-fit: contain;
    flex-shrink: 0;
  }}
  .lockup-content {{
    flex: 1;
  }}
  
  /* Font 1: Urbanist (Curved Modern Tech, Title Case) */
  .font-1 .brand-title {{
    font-family: 'Urbanist', sans-serif;
    font-size: 52px;
    font-weight: 900;
    letter-spacing: -0.5px;
    line-height: 1;
  }}
  .font-1 .brand-sub {{
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 3.5px;
    color: #557297;
    margin-top: 6px;
  }}

  /* Font 2: Exo 2 (Aerodynamic Mobility & Transit, Forward-Leaning) */
  .font-2 .brand-title {{
    font-family: 'Exo 2', sans-serif;
    font-size: 50px;
    font-weight: 800;
    font-style: italic;
    letter-spacing: 0px;
    line-height: 1;
  }}
  .font-2 .brand-sub {{
    font-family: 'Exo 2', sans-serif;
    font-size: 12.5px;
    font-weight: 700;
    letter-spacing: 3px;
    color: #557297;
    margin-top: 6px;
  }}

  /* Font 3: Sora (Geometric Tech with Rounded Elegance) */
  .font-3 .brand-title {{
    font-family: 'Sora', sans-serif;
    font-size: 48px;
    font-weight: 800;
    letter-spacing: -0.5px;
    line-height: 1;
  }}
  .font-3 .brand-sub {{
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 12.5px;
    font-weight: 700;
    letter-spacing: 3.5px;
    color: #557297;
    margin-top: 6px;
  }}

  /* Font 4: Comfortaa / Soft Organic (Harmonizes with flowing logo curves) */
  .font-4 .brand-title {{
    font-family: 'Comfortaa', cursive;
    font-size: 46px;
    font-weight: 700;
    letter-spacing: -1px;
    line-height: 1;
  }}
  .font-4 .brand-sub {{
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 12.5px;
    font-weight: 700;
    letter-spacing: 3px;
    color: #557297;
    margin-top: 6px;
  }}

  /* Font 5: Outfit (Clean Modern Startup - Title Case e-Parada) */
  .font-5 .brand-title {{
    font-family: 'Outfit', sans-serif;
    font-size: 52px;
    font-weight: 800;
    letter-spacing: -0.8px;
    line-height: 1;
  }}
  .font-5 .brand-sub {{
    font-family: 'Outfit', sans-serif;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 3px;
    color: #557297;
    margin-top: 6px;
  }}

  .gold {{ color: #DDA818; }}
  .blue {{ color: #6EA1D4; }}
  .navy {{ color: #1A3054; }}
</style>
</head>
<body>

<div class="header">
  <h1>E-Parada Typography Pairing Options</h1>
  <p>Exploring distinct font personalities to match the fluid curves of the "eP" emblem</p>
</div>

<div class="grid">

  <!-- OPTION 1 -->
  <div class="option-card font-1">
    <img class="logo-img" src="{logo_data_uri}" alt="Logo">
    <div class="lockup-content">
      <span class="badge">OPTION 1: MODERN MOBILITY TECH</span>
      <span class="badge-tag">Font: <b>Urbanist</b> (Title Case: <i>e-Parada</i>) &bull; Clean, contemporary app aesthetic</span>
      <div class="brand-title"><span class="blue">e</span><span class="gold">-</span><span class="navy">Parada</span></div>
      <div class="brand-sub">DIGITAL MARKETPLACE FOR PARKING SPACES</div>
    </div>
  </div>

  <!-- OPTION 2 -->
  <div class="option-card font-2">
    <img class="logo-img" src="{logo_data_uri}" alt="Logo">
    <div class="lockup-content">
      <span class="badge">OPTION 2: DYNAMIC TRANSIT & SPEED</span>
      <span class="badge-tag">Font: <b>Exo 2</b> (Italic Bold) &bull; Aerodynamic, transportation & smart-city feel</span>
      <div class="brand-title"><span class="gold">E</span><span class="blue">-</span><span class="navy">PARADA</span></div>
      <div class="brand-sub">DIGITAL MARKETPLACE FOR PARKING SPACES</div>
    </div>
  </div>

  <!-- OPTION 3 -->
  <div class="option-card font-3">
    <img class="logo-img" src="{logo_data_uri}" alt="Logo">
    <div class="lockup-content">
      <span class="badge">OPTION 3: GEOMETRIC TECH & CURVES</span>
      <span class="badge-tag">Font: <b>Sora</b> (Wide Bold) &bull; Premium fintech/smart-system look</span>
      <div class="brand-title"><span class="gold">E</span><span class="blue">-</span><span class="navy">PARADA</span></div>
      <div class="brand-sub">DIGITAL MARKETPLACE FOR PARKING SPACES</div>
    </div>
  </div>

  <!-- OPTION 4 -->
  <div class="option-card font-4">
    <img class="logo-img" src="{logo_data_uri}" alt="Logo">
    <div class="lockup-content">
      <span class="badge">OPTION 4: ORGANIC CURVILINEAR MATCH</span>
      <span class="badge-tag">Font: <b>Comfortaa</b> (Rounded) &bull; Mirrors the exact fluid, rounded curves of the emblem</span>
      <div class="brand-title"><span class="gold">e</span><span class="blue">-</span><span class="navy">Parada</span></div>
      <div class="brand-sub">DIGITAL MARKETPLACE FOR PARKING SPACES</div>
    </div>
  </div>

  <!-- OPTION 5 -->
  <div class="option-card font-5">
    <img class="logo-img" src="{logo_data_uri}" alt="Logo">
    <div class="lockup-content">
      <span class="badge">OPTION 5: MODERN SILICON-VALLEY STARTUP</span>
      <span class="badge-tag">Font: <b>Outfit</b> (Bold All-Caps) &bull; Sleek, ultra-clean commercial marketplace feel</span>
      <div class="brand-title"><span class="gold">E</span><span class="blue">-</span><span class="navy">PARADA</span></div>
      <div class="brand-sub">DIGITAL MARKETPLACE FOR PARKING SPACES</div>
    </div>
  </div>

</div>

</body>
</html>
"""

html_showcase_path = os.path.join(SCRATCH, 'font_showcase.html')
with open(html_showcase_path, 'w', encoding='utf-8') as f:
    f.write(HTML_SHOWCASE)

preview_png = os.path.join(BRANDING_DIR, 'eparada_font_options_showcase.png')
subprocess.run([
    CHROME, '--headless=new', '--disable-gpu',
    '--window-size=1150,1180',
    f'--screenshot={preview_png}',
    'file:///' + html_showcase_path.replace('\\', '/')
], check=True)

shutil.copy(preview_png, os.path.join(ARTIFACT_DIR, 'eparada_font_options_showcase.png'))
print(f"Generated comparison sheet at {preview_png}")
