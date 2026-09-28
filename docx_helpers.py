import os
import zipfile
import xml.sax.saxutils as saxutils

def escape(text):
    return saxutils.escape(str(text))

def make_p(text="", bold=False, italic=False, size=21, color="222222", font="Calibri", align="left", space_before=60, space_after=100, line_spacing=260):
    jc_map = {"center": "center", "right": "right", "left": "left", "both": "both"}
    jc_val = jc_map.get(align, "left")
    b_tag = "<w:b/>" if bold else ""
    i_tag = "<w:i/>" if italic else ""
    
    return f"""<w:p>
  <w:pPr>
    <w:jc w:val="{jc_val}"/>
    <w:spacing w:before="{space_before}" w:after="{space_after}" w:line="{line_spacing}" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="{font}" w:hAnsi="{font}" w:cs="{font}"/>
      {b_tag}
      {i_tag}
      <w:sz w:val="{size}"/>
      <w:szCs w:val="{size}"/>
      <w:color w:val="{color}"/>
    </w:rPr>
    <w:t xml:space="preserve">{escape(text)}</w:t>
  </w:r>
</w:p>"""

def make_runs_p(runs, align="left", space_before=60, space_after=100, line_spacing=260):
    jc_map = {"center": "center", "right": "right", "left": "left", "both": "both"}
    jc_val = jc_map.get(align, "left")
    runs_xml = []
    for r in runs:
        text = r.get("text", "")
        bold = r.get("bold", False)
        italic = r.get("italic", False)
        size = r.get("size", 21)
        color = r.get("color", "222222")
        font = r.get("font", "Calibri")
        b_tag = "<w:b/>" if bold else ""
        i_tag = "<w:i/>" if italic else ""
        runs_xml.append(f"""<w:r>
  <w:rPr>
    <w:rFonts w:ascii="{font}" w:hAnsi="{font}" w:cs="{font}"/>
    {b_tag}{i_tag}
    <w:sz w:val="{size}"/>
    <w:szCs w:val="{size}"/>
    <w:color w:val="{color}"/>
  </w:rPr>
  <w:t xml:space="preserve">{escape(text)}</w:t>
</w:r>""")
    return f"""<w:p>
  <w:pPr>
    <w:jc w:val="{jc_val}"/>
    <w:spacing w:before="{space_before}" w:after="{space_after}" w:line="{line_spacing}" w:lineRule="auto"/>
  </w:pPr>
  {''.join(runs_xml)}
</w:p>"""

def make_code_block(code_text, label=""):
    lines = code_text.strip().split("\n")
    p_list = []
    if label:
        p_list.append(make_p(label, bold=True, size=18, color="1E5AA8", font="Calibri", space_before=40, space_after=40))
    for line in lines:
        p_list.append(f"""<w:p>
  <w:pPr>
    <w:spacing w:before="0" w:after="0" w:line="220" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Consolas" w:hAnsi="Consolas" w:cs="Consolas"/>
      <w:sz w:val="17"/>
      <w:szCs w:val="17"/>
      <w:color w:val="1A202C"/>
    </w:rPr>
    <w:t xml:space="preserve">{escape(line)}</w:t>
  </w:r>
</w:p>""")
    inner_xml = "".join(p_list)
    # wrap in a single-cell table for background & border
    return f"""<w:tbl>
  <w:tblPr>
    <w:tblW w:w="9360" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="6" w:space="0" w:color="CBD5E0"/>
      <w:bottom w:val="single" w:sz="6" w:space="0" w:color="CBD5E0"/>
      <w:left w:val="single" w:sz="18" w:space="0" w:color="2B6CB0"/>
      <w:right w:val="single" w:sz="6" w:space="0" w:color="CBD5E0"/>
    </w:tblBorders>
    <w:tblCellMar>
      <w:top w:w="120" w:type="dxa"/>
      <w:bottom w:w="120" w:type="dxa"/>
      <w:left w:w="180" w:type="dxa"/>
      <w:right w:w="180" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="9360" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="F7FAFC"/>
      </w:tcPr>
      {inner_xml}
    </w:tc>
  </w:tr>
</w:tbl>
<w:p><w:pPr><w:spacing w:before="60" w:after="80"/></w:pPr></w:p>"""

def make_callout(text, title=""):
    p_list = []
    if title:
        p_list.append(make_p(title, bold=True, size=20, color="1E3A8A", font="Calibri", space_before=40, space_after=40))
    p_list.append(make_p(text, bold=False, italic=False, size=19, color="1E293B", font="Calibri", space_before=20, space_after=40, line_spacing=240))
    inner_xml = "".join(p_list)
    return f"""<w:tbl>
  <w:tblPr>
    <w:tblW w:w="9360" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="4" w:space="0" w:color="BFDBFE"/>
      <w:bottom w:val="single" w:sz="4" w:space="0" w:color="BFDBFE"/>
      <w:left w:val="single" w:sz="24" w:space="0" w:color="1D4ED8"/>
      <w:right w:val="single" w:sz="4" w:space="0" w:color="BFDBFE"/>
    </w:tblBorders>
    <w:tblCellMar>
      <w:top w:w="140" w:type="dxa"/>
      <w:bottom w:w="140" w:type="dxa"/>
      <w:left w:w="200" w:type="dxa"/>
      <w:right w:w="200" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="9360" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="EFF6FF"/>
      </w:tcPr>
      {inner_xml}
    </w:tc>
  </w:tr>
</w:tbl>
<w:p><w:pPr><w:spacing w:before="60" w:after="80"/></w:pPr></w:p>"""

def make_header_box(title, subtitle="", metadata=""):
    p_list = []
    p_list.append(make_p("<<Final Laboratory Interim>>", bold=True, italic=True, size=24, color="1E3A8A", align="center", space_before=100, space_after=40))
    p_list.append(make_p(title, bold=True, size=34, color="0F172A", align="center", space_before=40, space_after=60))
    if subtitle:
        p_list.append(make_p(subtitle, bold=False, italic=True, size=21, color="334155", align="center", space_before=20, space_after=60))
    if metadata:
        p_list.append(make_p(metadata, bold=False, italic=False, size=18, color="64748B", align="center", space_before=20, space_after=100))
    
    inner_xml = "".join(p_list)
    return f"""<w:tbl>
  <w:tblPr>
    <w:tblW w:w="9360" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="12" w:space="0" w:color="1E3A8A"/>
      <w:bottom w:val="single" w:sz="12" w:space="0" w:color="1E3A8A"/>
      <w:left w:val="none"/>
      <w:right w:val="none"/>
    </w:tblBorders>
    <w:tblCellMar>
      <w:top w:w="160" w:type="dxa"/>
      <w:bottom w:w="160" w:type="dxa"/>
      <w:left w:w="200" w:type="dxa"/>
      <w:right w:w="200" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="9360" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="F1F5F9"/>
      </w:tcPr>
      {inner_xml}
    </w:tc>
  </w:tr>
</w:tbl>
<w:p><w:pPr><w:spacing w:before="120" w:after="160"/></w:pPr></w:p>"""

def make_section_title(number_str, title_str):
    return f"""<w:p>
  <w:pPr>
    <w:spacing w:before="240" w:after="100"/>
    <w:pBdr>
      <w:bottom w:val="single" w:sz="8" w:space="4" w:color="1E3A8A"/>
    </w:pBdr>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
      <w:b/>
      <w:sz w:val="28"/>
      <w:color w:val="1E3A8A"/>
    </w:rPr>
    <w:t xml:space="preserve">{escape(number_str)} {escape(title_str)}</w:t>
  </w:r>
</w:p>"""

def make_table_2col(rows, col1_w=2800, col2_w=6560):
    tr_list = []
    for i, (col1, col2) in enumerate(rows):
        shd_val = "F8FAFC" if i % 2 == 1 else "FFFFFF"
        if isinstance(col1, str):
            p1 = make_p(col1, bold=True, size=19, color="1E3A8A", space_before=40, space_after=40)
        else:
            p1 = col1
            
        if isinstance(col2, str):
            p2 = make_p(col2, bold=False, size=19, color="1E293B", space_before=40, space_after=40)
        else:
            p2 = col2
            
        tr_list.append(f"""<w:tr>
  <w:tc>
    <w:tcPr>
      <w:tcW w:w="{col1_w}" w:type="dxa"/>
      <w:shd w:val="clear" w:color="auto" w:fill="{shd_val}"/>
    </w:tcPr>
    {p1}
  </w:tc>
  <w:tc>
    <w:tcPr>
      <w:tcW w:w="{col2_w}" w:type="dxa"/>
      <w:shd w:val="clear" w:color="auto" w:fill="{shd_val}"/>
    </w:tcPr>
    {p2}
  </w:tc>
</w:tr>""")

    return f"""<w:tbl>
  <w:tblPr>
    <w:tblW w:w="9360" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
      <w:bottom w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
      <w:left w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
      <w:right w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
      <w:insideH w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/>
      <w:insideV w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/>
    </w:tblBorders>
    <w:tblCellMar>
      <w:top w:w="120" w:type="dxa"/>
      <w:bottom w:w="120" w:type="dxa"/>
      <w:left w:w="160" w:type="dxa"/>
      <w:right w:w="160" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  {''.join(tr_list)}
</w:tbl>
<w:p><w:pPr><w:spacing w:before="60" w:after="100"/></w:pPr></w:p>"""

def make_table_header(header_cols, col_widths, bg="1E3A8A"):
    tc_list = []
    for col, width in zip(header_cols, col_widths):
        p = make_p(col, bold=True, size=20, color="FFFFFF", space_before=40, space_after=40)
        tc_list.append(f"""<w:tc>
  <w:tcPr>
    <w:tcW w:w="{width}" w:type="dxa"/>
    <w:shd w:val="clear" w:color="auto" w:fill="{bg}"/>
  </w:tcPr>
  {p}
</w:tc>""")
    return f"""<w:tr>{''.join(tc_list)}</w:tr>"""

print("Helper functions ready")
