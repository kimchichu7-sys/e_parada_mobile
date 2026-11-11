import os
import re
import html
import shutil
import subprocess

WORKSPACE = r'c:\Users\kimch\e_parada_mobile'
ARTIFACT_DIR = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185'
MD_PATH = os.path.join(WORKSPACE, 'E_PARADA_PRESENTATION_SCRIPT.md')
HTML_PATH = os.path.join(WORKSPACE, 'scratch', 'presentation_script_print.html')
PDF_PATH = os.path.join(WORKSPACE, 'E_PARADA_PRESENTATION_SCRIPT.pdf')
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'

CSS = """
@page { size: letter; margin: 0.6in; }
body { font-family: "Segoe UI", Arial, sans-serif; font-size: 10.5pt; line-height: 1.55; color: #0F172A; }
h1 { background: linear-gradient(135deg,#1E1B4B,#432098); color:#fff; padding:16px 20px; border-radius:8px; font-size:16pt; margin:0 0 10px; }
h1.chapter { background:#1E1B4B; font-size:12.5pt; padding:8px 16px; margin-top:22px; page-break-after: avoid; }
h2 { color:#1E1B4B; font-size:12pt; border-bottom:2px solid #432098; padding-bottom:4px; margin:18px 0 8px; page-break-after: avoid; }
p { margin: 4px 0 8px; }
.speaker { font-weight:700; color:#432098; margin-top:6px; }
blockquote { background:#F8FAFC; border-left:4px solid #6366F1; margin:6px 0 12px; padding:8px 14px; border-radius:0 6px 6px 0; page-break-inside: auto; }
blockquote p { margin: 4px 0; }
ul, ol { margin: 4px 0 6px; padding-left: 22px; }
li { margin-bottom: 3px; }
code { background:#EEF2FF; padding:0 4px; border-radius:3px; font-size:9.5pt; }
.meta { color:#334155; font-size:9.5pt; margin: 2px 0; }
hr { display:none; }
"""


def inline(text):
    text = html.escape(text, quote=False)
    text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
    text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'(?<!\*)\*(?!\s)(.+?)(?<!\s)\*(?!\*)', r'<i>\1</i>', text)
    text = text.replace(r'$\text{time\_out} - \text{time\_in}$', 'time_out &minus; time_in')
    return text


def render_block(lines):
    """Render a list of markdown lines (lists + paragraphs) into HTML."""
    out, stack = [], []  # stack of (tag, indent)

    def close_to(indent):
        while stack and stack[-1][1] >= indent:
            out.append(f'</li></{stack.pop()[0]}>')

    for raw in lines:
        if not raw.strip():
            continue
        indent = len(raw) - len(raw.lstrip(' '))
        s = raw.strip()
        m_ul = re.match(r'^[*-]\s+(.*)', s)
        m_ol = re.match(r'^\d+\.\s+(.*)', s)
        if m_ul or m_ol:
            tag = 'ul' if m_ul else 'ol'
            content = (m_ul or m_ol).group(1)
            if stack and stack[-1][1] == indent and stack[-1][0] == tag:
                out.append('</li>')
            elif stack and stack[-1][1] >= indent:
                close_to(indent)
                if stack and stack[-1][1] == indent:
                    out.append('</li>')
                else:
                    out.append(f'<{tag}>')
                    stack.append((tag, indent))
            else:
                out.append(f'<{tag}>')
                stack.append((tag, indent))
            out.append('<li>' + inline(content))
        else:
            close_to(0)
            out.append('<p>' + inline(s) + '</p>')
    close_to(0)
    return '\n'.join(out)


def md_to_html(md):
    lines = md.splitlines()
    body, i, first_h1 = [], 0, True
    while i < len(lines):
        line = lines[i]
        s = line.strip()
        if s.startswith('> '):
            quote = []
            while i < len(lines) and lines[i].strip().startswith('>'):
                quote.append(re.sub(r'^\s*>\s?', '', lines[i]))
                i += 1
            body.append('<blockquote>' + render_block(quote) + '</blockquote>')
            continue
        if s.startswith('# '):
            cls = '' if first_h1 else ' class="chapter"'
            first_h1 = False
            body.append(f'<h1{cls}>{inline(s[2:])}</h1>')
        elif s.startswith('## '):
            body.append(f'<h2>{inline(s[3:])}</h2>')
        elif s.startswith('**🎙️ Speaker:**'):
            body.append('<div class="speaker">🎙️ Speaker:</div>')
        elif s == '---' or not s:
            pass
        elif s.startswith('**') and ':**' in s[:20]:
            body.append(f'<p class="meta">{inline(s)}</p>')
        else:
            body.append(f'<p>{inline(s)}</p>')
        i += 1
    return '\n'.join(body)


def main():
    with open(MD_PATH, encoding='utf-8') as f:
        md = f.read()
    os.makedirs(os.path.dirname(HTML_PATH), exist_ok=True)
    doc = f'<!DOCTYPE html><html><head><meta charset="utf-8"><title>E-Parada Presentation Script</title><style>{CSS}</style></head><body>{md_to_html(md)}</body></html>'
    with open(HTML_PATH, 'w', encoding='utf-8') as f:
        f.write(doc)
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--no-pdf-header-footer',
                    f'--print-to-pdf={PDF_PATH}', 'file:///' + HTML_PATH.replace('\\', '/')],
                   check=True, timeout=120)
    shutil.copy(MD_PATH, os.path.join(ARTIFACT_DIR, 'E_PARADA_PRESENTATION_SCRIPT.md'))
    shutil.copy(PDF_PATH, os.path.join(ARTIFACT_DIR, 'E_PARADA_PRESENTATION_SCRIPT.pdf'))
    from pypdf import PdfReader
    print('Script PDF pages:', len(PdfReader(PDF_PATH).pages))


if __name__ == '__main__':
    main()
