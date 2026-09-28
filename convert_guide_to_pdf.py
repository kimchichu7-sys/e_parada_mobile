import os
import sys
import re
import subprocess

md_path = r'c:\Users\kimch\e_parada_mobile\DEFENSE_READINESS_REVISION_GUIDE.md'
html_path = r'c:\Users\kimch\e_parada_mobile\DEFENSE_READINESS_REVISION_GUIDE.html'
pdf_path = r'c:\Users\kimch\e_parada_mobile\DEFENSE_READINESS_REVISION_GUIDE.pdf'

with open(md_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

html_lines = []
in_code = False
in_table = False
table_has_header = False

def escape_html(t):
    return t.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

def inline_format(t):
    t = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', t)
    t = re.sub(r'\*(.+?)\*', r'<em>\1</em>', t)
    t = re.sub(r'`([^`]+)`', r'<code>\1</code>', t)
    t = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', t)
    return t

for line in lines:
    raw = line.rstrip('\r\n')
    
    if raw.startswith('```'):
        if in_code:
            html_lines.append('</code></pre>')
            in_code = False
        else:
            lang = raw[3:].strip()
            html_lines.append(f'<pre><code class="{lang}">')
            in_code = True
        continue
        
    if in_code:
        html_lines.append(escape_html(raw))
        continue
        
    # Tables
    if raw.startswith('|') and raw.endswith('|'):
        cells = [c.strip() for c in raw.strip('|').split('|')]
        if not in_table:
            in_table = True
            table_has_header = True
            html_lines.append('<div class="table-container"><table><thead><tr>')
            for c in cells:
                html_lines.append(f'<th>{inline_format(escape_html(c))}</th>')
            html_lines.append('</tr></thead><tbody>')
            continue
        elif table_has_header and all(re.match(r'^:?-+:?$', c) for c in cells):
            table_has_header = False
            continue
        else:
            html_lines.append('<tr>')
            for c in cells:
                html_lines.append(f'<td>{inline_format(escape_html(c))}</td>')
            html_lines.append('</tr>')
            continue
    else:
        if in_table:
            html_lines.append('</tbody></table></div>')
            in_table = False
            
    # Headers
    if raw.startswith('# '):
        html_lines.append(f'<h1>{inline_format(escape_html(raw[2:]))}</h1>')
    elif raw.startswith('## '):
        html_lines.append(f'<h2>{inline_format(escape_html(raw[3:]))}</h2>')
    elif raw.startswith('### '):
        html_lines.append(f'<h3>{inline_format(escape_html(raw[4:]))}</h3>')
    elif raw.startswith('#### '):
        html_lines.append(f'<h4>{inline_format(escape_html(raw[5:]))}</h4>')
    elif raw.startswith('---'):
        html_lines.append('<hr/>')
    elif raw.startswith('> [!CAUTION]'):
        html_lines.append('<div class="alert alert-caution"><strong>CAUTION:</strong>')
    elif raw.startswith('> '):
        content = raw[2:].strip()
        html_lines.append(f'<blockquote>{inline_format(escape_html(content))}</blockquote>')
    elif raw.startswith('- [ ] ') or raw.startswith('- [x] '):
        box = '☑ ' if raw.startswith('- [x] ') else '☐ '
        html_lines.append(f'<div class="checkbox-item">{box}{inline_format(escape_html(raw[6:]))}</div>')
    elif raw.startswith('- ') or raw.startswith('* '):
        html_lines.append(f'<li>{inline_format(escape_html(raw[2:]))}</li>')
    elif re.match(r'^\d+\.\s', raw):
        match = re.match(r'^\d+\.\s(.*)$', raw)
        html_lines.append(f'<li class="ol-item">{inline_format(escape_html(match.group(1)))}</li>')
    elif raw.strip() == '':
        html_lines.append('<div class="spacer"></div>')
    else:
        html_lines.append(f'<p>{inline_format(escape_html(raw))}</p>')

if in_table:
    html_lines.append('</tbody></table></div>')

body_content = '\n'.join(html_lines)

full_html = f'''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>E-Parada Thesis Defense Revision Guide</title>
<style>
@page {{
    size: A4;
    margin: 18mm 14mm 18mm 14mm;
}}
body {{
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    color: #1e293b;
    line-height: 1.55;
    font-size: 10pt;
    background: #fff;
    padding: 0;
    margin: 0;
}}
h1 {{
    color: #0f172a;
    font-size: 18pt;
    border-bottom: 2.5px solid #2563eb;
    padding-bottom: 6px;
    margin-top: 10px;
    margin-bottom: 12px;
    page-break-after: avoid;
}}
h2 {{
    color: #1e3a8a;
    font-size: 13.5pt;
    border-bottom: 1px solid #cbd5e1;
    padding-bottom: 4px;
    margin-top: 20px;
    margin-bottom: 8px;
    page-break-after: avoid;
}}
h3 {{
    color: #1d4ed8;
    font-size: 11.5pt;
    margin-top: 14px;
    margin-bottom: 6px;
    page-break-after: avoid;
}}
h4 {{
    color: #334155;
    font-size: 10.5pt;
    margin-top: 12px;
    margin-bottom: 4px;
    page-break-after: avoid;
}}
p {{
    margin: 4px 0 8px 0;
}}
hr {{
    border: none;
    border-top: 1px solid #e2e8f0;
    margin: 16px 0;
}}
pre {{
    background: #0f172a;
    color: #f8fafc;
    padding: 10px 14px;
    border-radius: 6px;
    font-size: 8.5pt;
    font-family: 'Consolas', 'Courier New', monospace;
    overflow-x: auto;
    white-space: pre-wrap;
    word-break: break-word;
    margin: 8px 0 10px 0;
    page-break-inside: avoid;
}}
code {{
    background: #f1f5f9;
    color: #0f172a;
    padding: 1px 4px;
    border-radius: 4px;
    font-family: 'Consolas', 'Courier New', monospace;
    font-size: 9pt;
}}
pre code {{
    background: transparent;
    color: inherit;
    padding: 0;
}}
blockquote {{
    border-left: 4px solid #3b82f6;
    margin: 8px 0;
    padding: 6px 14px;
    background: #eff6ff;
    color: #1e3a8a;
    font-style: italic;
    page-break-inside: avoid;
}}
.table-container {{
    margin: 10px 0;
    overflow-x: auto;
    page-break-inside: avoid;
}}
table {{
    width: 100%;
    border-collapse: collapse;
    font-size: 8.5pt;
    page-break-inside: avoid;
}}
th, td {{
    border: 1px solid #cbd5e1;
    padding: 5px 8px;
    text-align: left;
    vertical-align: top;
}}
th {{
    background: #1e3a8a;
    color: #ffffff;
    font-weight: 600;
}}
tr:nth-child(even) {{
    background: #f8fafc;
}}
li {{
    margin-bottom: 3px;
}}
.checkbox-item {{
    padding: 2px 0;
    font-size: 9.5pt;
}}
.spacer {{
    height: 4px;
}}
.alert {{
    padding: 8px 12px;
    border-radius: 6px;
    margin: 8px 0;
    page-break-inside: avoid;
}}
.alert-caution {{
    background: #fef2f2;
    border-left: 4px solid #ef4444;
    color: #991b1b;
}}
strong {{
    font-weight: 600;
}}
</style>
</head>
<body>
{body_content}
</body>
</html>'''

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(full_html)

chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
cmd = [
    chrome_path,
    '--headless',
    '--disable-gpu',
    '--run-all-compositor-stages-before-draw',
    f'--print-to-pdf={pdf_path}',
    '--no-pdf-header-footer',
    html_path
]

res = subprocess.run(cmd, capture_output=True, text=True)
if os.path.exists(pdf_path) and os.path.getsize(pdf_path) > 1000:
    print(f'SUCCESS: PDF created at {pdf_path} (Size: {os.path.getsize(pdf_path)} bytes)')
else:
    print('FAILED to generate PDF')
    print('STDOUT:', res.stdout)
    print('STDERR:', res.stderr)
