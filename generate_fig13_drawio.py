import xml.etree.ElementTree as ET
from xml.dom import minidom
import os
import subprocess

def generate_core_booking_database():
    mxfile = ET.Element('mxfile', host='Electron', agent='Mozilla/5.0', version='21.6.8', type='device')
    
    # -------------------------------------------------------------------------
    # PAGE 1: CROW'S FOOT ERD DIAGRAM (FIGURE 13)
    # -------------------------------------------------------------------------
    diagram1 = ET.SubElement(mxfile, 'diagram', id='fig13_core_db_table', name='Figure 13 - E-Parada Core Booking Database')
    mxGraphModel1 = ET.SubElement(diagram1, 'mxGraphModel', 
                                  dx='2600', dy='2200', grid='1', gridSize='10', guides='1', 
                                  tooltips='1', connect='1', arrows='1', fold='1', page='1', 
                                  pageScale='1', pageWidth='1850', pageHeight='1650', math='0', shadow='0')
    root1 = ET.SubElement(mxGraphModel1, 'root')
    ET.SubElement(root1, 'mxCell', id='0')
    ET.SubElement(root1, 'mxCell', id='1', parent='0')

    def add_vertex(root_node, cell_id, value, style, x, y, w, h):
        cell = ET.SubElement(root_node, 'mxCell', id=cell_id, value=value, style=style, vertex='1', parent='1')
        geo = ET.SubElement(cell, 'mxGeometry', x=str(x), y=str(y), width=str(w), height=str(h))
        geo.set('as', 'geometry')
        return cell

    def add_edge(root_node, edge_id, source_id, target_id, style, label='', exit_x=None, exit_y=None, entry_x=None, entry_y=None, points=None):
        cell = ET.SubElement(root_node, 'mxCell', id=edge_id, value=label, style=style, edge='1', parent='1', source=source_id, target=target_id)
        geo = ET.SubElement(cell, 'mxGeometry', relative='1')
        geo.set('as', 'geometry')
        
        curr_style = style
        if exit_x is not None and exit_y is not None:
            curr_style += f"exitX={exit_x};exitY={exit_y};"
        if entry_x is not None and entry_y is not None:
            curr_style += f"entryX={entry_x};entryY={entry_y};"
        cell.set('style', curr_style)

        if points:
            arr = ET.SubElement(geo, 'Array')
            arr.set('as', 'points')
            for px, py in points:
                ET.SubElement(arr, 'mxPoint', x=str(px), y=str(py))
        return cell

    # Styles
    title_style = "text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=top;whiteSpace=wrap;rounded=0;"
    
    # Specific Crow's Foot Styles in Draw.io:
    base_edge = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#432098;strokeWidth=1.5;fontSize=10;fontColor=#1E293B;fontFamily=Courier New;"
    edge_1_to_many_opt = base_edge + "startArrow=ERmandOne;endArrow=ERzeroToMany;"
    edge_1_to_many_mand = base_edge + "startArrow=ERmandOne;endArrow=ERmany;"
    edge_1_to_1_opt = base_edge + "startArrow=ERmandOne;endArrow=ERzeroToOne;"
    edge_01_to_many_opt = base_edge + "startArrow=ERzeroToOne;endArrow=ERzeroToMany;"

    table_container_style = "shape=rectangle;whiteSpace=wrap;html=1;overflow=hidden;fillColor=#FFFFFF;strokeColor=#432098;strokeWidth=1;shadow=1;align=left;verticalAlign=top;spacing=0;"

    # 1. Main Document Title
    title_html = (
        '<div style="font-family: Arial, Helvetica, sans-serif;">'
        '<span style="font-size: 18px; font-weight: bold; color: #000000;">Figure 13. E-Parada Core Booking Database (Crow\'s Foot ERD)</span><br/>'
        '<span style="font-size: 11px; color: #475569;">Information Engineering (IE) Crow\'s Foot notation with PostgreSQL 15+ normalized datatypes.</span>'
        '</div>'
    )
    add_vertex(root1, 'title_node', title_html, title_style, 40, 25, 750, 50)

    # Legend Box in Drawio
    legend_html = (
        '<div style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; color: #1E293B; padding: 6px;">'
        '<b>Crow\'s Foot Notation Legend:</b><br/>'
        '<span style="font-family: monospace;">|| &nbsp;Mandatory One (1)</span><br/>'
        '<span style="font-family: monospace;">o&lt; Optional Many (0..*)</span><br/>'
        '<span style="font-family: monospace;">|&lt; Mandatory Many (1..*)</span><br/>'
        '<span style="font-family: monospace;">o| &nbsp;Optional One (0..1)</span>'
        '</div>'
    )
    add_vertex(root1, 'legend_node', legend_html, "shape=rectangle;rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#94A3B8;strokeWidth=1;", 1400, 480, 280, 95)

    def build_table_html(title, rows):
        html = [
            '<table style="width:100%; height:100%; border-collapse:collapse; background-color:#FFFFFF; font-family:Courier New, Courier, monospace; font-size:11px; border:1px solid #432098;">',
            f'<tr style="background-color:#432098; height:32px;">',
            f'<td colspan="2" style="padding-left:10px; font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:bold; color:#FFFFFF; text-align:left; border-bottom:2px solid #432098;">{title}</td>',
            '</tr>'
        ]
        for row in rows:
            col_name, col_type = row
            name_style = 'font-weight:bold; color:#000000;' if (col_name.startswith('PK') or col_name.startswith('FK')) else 'color:#000000;'
            type_style = 'color:#1E1B4B; font-weight:bold;' if col_type in ['boolean', 'timestamptz'] else 'color:#334155;'
            html.append(
                f'<tr style="border-bottom:1px solid #E2E8F0; height:24px;">'
                f'<td style="padding-left:8px; text-align:left; {name_style}">{col_name}</td>'
                f'<td style="padding-right:8px; text-align:left; {type_style}">: {col_type}</td>'
                f'</tr>'
            )
        html.append('</table>')
        return "".join(html)

    # 1. Users
    users_rows = [
        ("PK id", "INTEGER"), ("name", "varchar"), ("email", "varchar"), ("email_verified_at", "timestamptz"),
        ("password", "varchar"), ("remember_token", "varchar"), ("created_at", "timestamptz"), ("updated_at", "timestamptz"),
        ("role", "varchar"), ("verification_status", "varchar"), ("verification_notes", "TEXT"), ("id_type", "varchar"),
        ("id_image_path", "varchar"), ("gcash_name", "varchar"), ("gcash_number", "varchar"), ("gcash_qr_image", "varchar"),
        ("plate_number", "varchar"), ("contact_number", "varchar"), ("id_image_back_path", "varchar")
    ]
    add_vertex(root1, 'tbl_users', build_table_html('Users', users_rows), table_container_style, 40, 90, 310, 520)

    # 2. Vehicles
    vehicles_rows = [
        ("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("plate_number", "varchar"), ("vehicle_type", "varchar"),
        ("color", "varchar"), ("model", "varchar"), ("photo_path", "varchar"), ("verification_status", "varchar"),
        ("verification_notes", "TEXT"), ("consented_at", "timestamptz"), ("FK reviewed_by", "INTEGER"),
        ("reviewed_at", "timestamptz"), ("created_at", "timestamptz"), ("updated_at", "timestamptz"),
        ("make", "varchar"), ("plate_scan_status", "varchar"), ("plate_scanned_at", "timestamptz"), ("photo_back_path", "varchar")
    ]
    add_vertex(root1, 'tbl_vehicles', build_table_html('Vehicles', vehicles_rows), table_container_style, 40, 700, 310, 490)

    # 3. Parking Spaces
    spaces_rows = [
        ("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("space_name", "varchar"), ("address", "varchar"),
        ("vehicle_types", "TEXT"), ("dimensions_sqm", "numeric"), ("description", "TEXT"), ("image_paths", "TEXT"),
        ("is_available", "boolean"), ("created_at", "timestamptz"), ("updated_at", "timestamptz"),
        ("approval_status", "varchar"), ("hourly_rate", "numeric"), ("admin_notes", "TEXT"),
        ("latitude", "numeric"), ("longitude", "numeric"), ("vehicle_hourly_rates", "TEXT"), ("total_slots", "INTEGER"),
        ("is_open_24_hours", "boolean"), ("opening_time", "time"), ("closing_time", "time"),
        ("overstay_grace_minutes", "INTEGER"), ("abandoned_after_hours", "INTEGER"),
        ("entrance_latitude", "numeric"), ("entrance_longitude", "numeric"),
        ("layout_entrance_x", "numeric"), ("layout_entrance_z", "numeric"),
        ("layout_north_rotation", "numeric"), ("entrance_instructions", "varchar")
    ]
    add_vertex(root1, 'tbl_spaces', build_table_html('Parking Spaces', spaces_rows), table_container_style, 450, 150, 350, 780)

    # 4. Parking Slots
    slots_rows = [
        ("PK id", "INTEGER"), ("FK parking_space_id", "INTEGER"), ("slot_number", "INTEGER"), ("slot_label", "varchar"),
        ("vehicle_type", "varchar"), ("is_active", "boolean"), ("created_at", "timestamptz"), ("updated_at", "timestamptz"),
        ("supported_vehicle_types", "TEXT"), ("layout_x", "numeric"), ("layout_z", "numeric"), ("layout_rotation", "numeric")
    ]
    add_vertex(root1, 'tbl_slots', build_table_html('Parking Slots', slots_rows), table_container_style, 450, 1020, 350, 340)

    # 5. Reservations
    reservations_rows = [
        ("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("FK parking_space_id", "INTEGER"),
        ("reservation_date", "date"), ("start_time", "time"), ("end_time", "time"), ("status", "varchar"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz"), ("vehicle_type", "varchar"),
        ("qr_code", "varchar"), ("time_in", "timestamptz"), ("time_out", "timestamptz"),
        ("total_hours", "numeric"), ("total_amount", "numeric"), ("payment_status", "varchar"),
        ("payment_method", "varchar"), ("dispute_status", "varchar"), ("dispute_notes", "TEXT"),
        ("payment_proof_path", "varchar"), ("payment_submitted_at", "timestamptz"), ("payment_verified_at", "timestamptz"),
        ("cancellation_reason", "TEXT"), ("cancelled_at", "timestamptz"), ("cancelled_by", "varchar"),
        ("original_reservation_date", "date"), ("original_start_time", "time"), ("original_end_time", "time"),
        ("reschedule_reason", "TEXT"), ("rescheduled_at", "timestamptz"), ("owner_response_notes", "TEXT"),
        ("admin_internal_notes", "TEXT"), ("end_date", "date"), ("FK parking_slot_id", "INTEGER"),
        ("FK vehicle_id", "INTEGER"), ("extension_status", "varchar"), ("extension_end_date", "date"),
        ("extension_end_time", "time"), ("extension_reason", "TEXT"), ("extension_owner_notes", "TEXT"),
        ("extension_requested_at", "timestamptz"), ("extension_responded_at", "timestamptz"),
        ("overstay_status", "varchar"), ("overstay_started_at", "timestamptz"), ("overstay_last_notified_at", "timestamptz"),
        ("overstay_minutes", "INTEGER"), ("overstay_amount", "numeric"), ("abandoned_flagged_at", "timestamptz")
    ]
    add_vertex(root1, 'tbl_reservations', build_table_html('Reservations', reservations_rows), table_container_style, 920, 200, 360, 1280)

    # 6. Parking Space Feedback
    feedback_rows = [
        ("PK id", "INTEGER"), ("FK reservation_id", "INTEGER"), ("FK parking_space_id", "INTEGER"),
        ("FK user_id", "INTEGER"), ("rating", "INTEGER"), ("comment", "TEXT"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz"), ("moderation_status", "varchar"),
        ("admin_notes", "TEXT"), ("reviewed_at", "timestamptz")
    ]
    add_vertex(root1, 'tbl_feedback', build_table_html('Parking Space Feedback', feedback_rows), table_container_style, 1380, 90, 320, 340)

    # -------------------------------------------------------------------------
    # CROW'S FOOT EDGES WITH CARDINALITIES
    # -------------------------------------------------------------------------
    # 1. Users (1) -> Parking Spaces (0..N) [user_id -> id]
    add_edge(root1, 'e_usr_spc', 'tbl_users', 'tbl_spaces', edge_1_to_many_opt, 
             label='user_id -&gt; id  [1 : 0..*]', exit_x=1, exit_y=0.15, entry_x=0, entry_y=0.12)

    # 2. Users (1) -> Vehicles (0..N) [user_id -> id]
    add_edge(root1, 'e_usr_veh', 'tbl_users', 'tbl_vehicles', edge_1_to_many_opt, 
             label='user_id -&gt; id   reviewed_by -&gt; id  [1 : 0..*]', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)

    # 3. Parking Spaces (1) -> Parking Slots (1..N) [IDENTIFYING COMPOSITION: parking_space_id -> id]
    add_edge(root1, 'e_spc_slt', 'tbl_spaces', 'tbl_slots', edge_1_to_many_mand, 
             label='parking_space_id -&gt; id  [1 : 1..*]', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)

    # 4. Parking Spaces (1) -> Reservations (0..N) [parking_space_id -> id]
    add_edge(root1, 'e_spc_res', 'tbl_spaces', 'tbl_reservations', edge_1_to_many_opt, 
             label='parking_space_id -&gt; id  [1 : 0..*]', exit_x=1, exit_y=0.22, entry_x=0, entry_y=0.12)

    # 5. Parking Slots (1) -> Reservations (0..N) [parking_slot_id -> id]
    add_edge(root1, 'e_slt_res', 'tbl_slots', 'tbl_reservations', edge_1_to_many_opt, 
             label='parking_slot_id -&gt; id  [1 : 0..*]', exit_x=1, exit_y=0.35, entry_x=0, entry_y=0.72)

    # 6. Vehicles (1) -> Reservations (0..N) [vehicle_id -> id] (Bottom route)
    add_edge(root1, 'e_veh_res', 'tbl_vehicles', 'tbl_reservations', edge_1_to_many_opt, 
             label='vehicle_id -&gt; id  [1 : 0..*]', exit_x=1, exit_y=0.85, entry_x=0, entry_y=0.88,
             points=[(400, 1115), (400, 1420), (870, 1420), (870, 1325)])

    # 7. Users (1) -> Reservations (0..N) [user_id -> id] (Top route)
    add_edge(root1, 'e_usr_res', 'tbl_users', 'tbl_reservations', edge_1_to_many_opt, 
             label='user_id -&gt; id  [1 : 0..*]', exit_x=0.5, exit_y=0, entry_x=0.5, entry_y=0,
             points=[(195, 65), (860, 65), (1100, 65)])

    # 8. Reservations (1) -> Parking Space Feedback (0..1) [ONE-TO-ONE: reservation_id -> id]
    add_edge(root1, 'e_res_fbk', 'tbl_reservations', 'tbl_feedback', edge_1_to_1_opt, 
             label='reservation_id -&gt; id  [1 : 0..1]', exit_x=1, exit_y=0.08, entry_x=0, entry_y=0.35)

    # 9. Parking Spaces (1) -> Parking Space Feedback (0..N) [parking_space_id -> id]
    add_edge(root1, 'e_spc_fbk', 'tbl_spaces', 'tbl_feedback', edge_1_to_many_opt, 
             label='parking_space_id -&gt; id  [1 : 0..*]', exit_x=0.7, exit_y=0, entry_x=0.5, entry_y=0,
             points=[(695, 80), (1330, 80), (1540, 80)])

    # -------------------------------------------------------------------------
    # WRITE DRAWIO XML
    # -------------------------------------------------------------------------
    rough_string = ET.tostring(mxfile, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    pretty_xml = reparsed.toprettyxml(indent="  ", encoding="utf-8").decode("utf-8")
    pretty_xml = "\n".join([line for line in pretty_xml.split("\n") if line.strip()])

    workspace_path = r'c:\Users\kimch\e_parada_mobile'
    paths = [
        os.path.join(workspace_path, 'e_parada_core_booking_database.drawio'),
        os.path.join(workspace_path, 'e_parada_core_booking_database.drawio.xml'),
        os.path.join(workspace_path, 'e_parada_database_schema.drawio'),
        os.path.join(workspace_path, 'e_parada_database_schema.drawio.xml')
    ]

    for p in paths:
        with open(p, 'w', encoding='utf-8') as f:
            f.write(pretty_xml)
        print(f"Generated: {p}")

    # -------------------------------------------------------------------------
    # GENERATE HIGH-RES 300 DPI PNG WITH AUTHENTIC CROW'S FOOT SVG SYMBOLS
    # -------------------------------------------------------------------------
    render_crows_foot_png(workspace_path, users_rows, vehicles_rows, spaces_rows, slots_rows, reservations_rows, feedback_rows)

def render_crows_foot_png(workspace_path, users_rows, vehicles_rows, spaces_rows, slots_rows, reservations_rows, feedback_rows):
    html_file = os.path.join(workspace_path, 'scratch', 'fig13_crows_preview.html')
    png_file = os.path.join(workspace_path, 'fig13_core_booking_database_postgres.png')

    def render_rows(rows):
        res = []
        for name, dtype in rows:
            name_cls = "bold" if (name.startswith("PK") or name.startswith("FK")) else ""
            type_cls = "fixed-type" if dtype in ["boolean", "timestamptz"] else "standard-type"
            res.append(f'<tr><td class="col-name {name_cls}">{name}</td><td class="col-type {type_cls}">: {dtype}</td></tr>')
        return "".join(res)

    html_content = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    background-color: #FFFFFF;
    font-family: Arial, Helvetica, sans-serif;
    padding: 30px;
    width: 1780px;
    height: 1540px;
    position: relative;
  }}
  .main-header {{ position: absolute; top: 25px; left: 40px; }}
  .main-header h1 {{ font-size: 24px; font-weight: bold; color: #000000; }}
  .main-header p {{ font-size: 13px; color: #475569; margin-top: 4px; }}

  .table-card {{
    position: absolute;
    background: #FFFFFF;
    border: 1px solid #432098;
    box-shadow: 2px 3px 8px rgba(0,0,0,0.08);
    border-radius: 2px;
    overflow: hidden;
  }}
  .table-title {{
    background-color: #432098;
    color: #FFFFFF;
    font-weight: bold;
    font-size: 14px;
    padding: 7px 12px;
    letter-spacing: 0.2px;
  }}
  table {{
    width: 100%;
    border-collapse: collapse;
    font-family: "Courier New", Courier, monospace;
    font-size: 11.5px;
  }}
  tr {{ border-bottom: 1px solid #E2E8F0; height: 23px; }}
  tr:last-child {{ border-bottom: none; }}
  td {{ padding: 2px 8px; vertical-align: middle; }}
  .col-name {{ color: #0f172a; width: 58%; }}
  .col-type {{ width: 42%; }}
  .bold {{ font-weight: bold; }}
  .standard-type {{ color: #334155; }}
  .fixed-type {{
    color: #1E1B4B;
    font-weight: bold;
    background-color: #EEF2FF;
    border-radius: 3px;
    padding: 1px 4px;
  }}

  /* Legend */
  .legend-box {{
    position: absolute;
    right: 40px;
    top: 470px;
    width: 320px;
    background: #F8FAFC;
    border: 1px solid #CBD5E1;
    border-radius: 4px;
    padding: 12px 16px;
    font-size: 12px;
    color: #1E293B;
    box-shadow: 1px 2px 6px rgba(0,0,0,0.04);
  }}
  .legend-title {{ font-weight: bold; margin-bottom: 8px; color: #0F172A; font-size: 12.5px; }}
  .legend-item {{ display: flex; align-items: center; margin-bottom: 5px; font-family: "Courier New", Courier, monospace; }}
  .legend-symbol {{ width: 55px; font-weight: bold; color: #432098; }}

  /* SVG Connectors */
  svg.connectors {{
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
    z-index: 10;
  }}
  .edge-line {{ stroke: #432098; stroke-width: 1.6; fill: none; }}
  .edge-label {{
    font-family: "Courier New", Courier, monospace;
    font-size: 10.5px;
    fill: #1E293B;
  }}
  .cardinality-badge {{
    font-family: Arial, Helvetica, sans-serif;
    font-size: 11px;
    font-weight: bold;
    fill: #432098;
  }}
</style>
</head>
<body>

<div class="main-header">
  <h1>Figure 13. E-Parada Core Booking Database (Crow's Foot ERD)</h1>
  <p>Information Engineering (IE) notation depicting entity cardinalities and PostgreSQL 15+ normalized datatypes.</p>
</div>

<!-- USERS (40, 90, 310) -->
<div class="table-card" style="left: 40px; top: 90px; width: 310px;">
  <div class="table-title">Users</div>
  <table>{render_rows(users_rows)}</table>
</div>

<!-- VEHICLES (40, 680, 310) -->
<div class="table-card" style="left: 40px; top: 680px; width: 310px;">
  <div class="table-title">Vehicles</div>
  <table>{render_rows(vehicles_rows)}</table>
</div>

<!-- PARKING SPACES (450, 150, 360) -->
<div class="table-card" style="left: 450px; top: 150px; width: 360px;">
  <div class="table-title">Parking Spaces</div>
  <table>{render_rows(spaces_rows)}</table>
</div>

<!-- PARKING SLOTS (450, 1000, 360) -->
<div class="table-card" style="left: 450px; top: 1000px; width: 360px;">
  <div class="table-title">Parking Slots</div>
  <table>{render_rows(slots_rows)}</table>
</div>

<!-- RESERVATIONS (930, 180, 365) -->
<div class="table-card" style="left: 930px; top: 180px; width: 365px;">
  <div class="table-title">Reservations</div>
  <table>{render_rows(reservations_rows)}</table>
</div>

<!-- FEEDBACK (1400, 90, 320) -->
<div class="table-card" style="left: 1400px; top: 90px; width: 320px;">
  <div class="table-title">Parking Space Feedback</div>
  <table>{render_rows(feedback_rows)}</table>
</div>

<!-- NOTATION LEGEND -->
<div class="legend-box">
  <div class="legend-title">Crow's Foot Relationship Notation:</div>
  <div class="legend-item"><span class="legend-symbol">||</span> Mandatory One (Exactly 1)</div>
  <div class="legend-item"><span class="legend-symbol">&gt;o</span> Optional Many (0 to Many)</div>
  <div class="legend-item"><span class="legend-symbol">&gt;|</span> Mandatory Many (1 to Many)</div>
  <div class="legend-item"><span class="legend-symbol">o|</span> Optional One (0 or 1)</div>
</div>

<svg class="connectors">
  <defs>
    <!-- 1. MANDATORY ONE (Double Bar) -->
    <marker id="crows-one" viewBox="0 0 16 16" refX="4" refY="8" markerWidth="12" markerHeight="12" orient="auto-start-reverse">
      <line x1="4" y1="1" x2="4" y2="15" stroke="#432098" stroke-width="1.8"/>
      <line x1="9" y1="1" x2="9" y2="15" stroke="#432098" stroke-width="1.8"/>
    </marker>

    <!-- 2. OPTIONAL MANY (Circle + Crow's Foot) -->
    <marker id="crows-zero-many" viewBox="0 0 24 16" refX="22" refY="8" markerWidth="16" markerHeight="12" orient="auto-start-reverse">
      <circle cx="5" cy="8" r="3.5" fill="#FFFFFF" stroke="#432098" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="8" stroke="#432098" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="2" stroke="#432098" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="14" stroke="#432098" stroke-width="1.8"/>
    </marker>

    <!-- 3. MANDATORY MANY (Bar + Crow's Foot) -->
    <marker id="crows-one-many" viewBox="0 0 24 16" refX="22" refY="8" markerWidth="16" markerHeight="12" orient="auto-start-reverse">
      <line x1="5" y1="1" x2="5" y2="15" stroke="#432098" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="8" stroke="#432098" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="2" stroke="#432098" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="14" stroke="#432098" stroke-width="1.8"/>
    </marker>

    <!-- 4. OPTIONAL ONE (Circle + Bar) -->
    <marker id="crows-zero-one" viewBox="0 0 20 16" refX="16" refY="8" markerWidth="14" markerHeight="12" orient="auto-start-reverse">
      <circle cx="5" cy="8" r="3.5" fill="#FFFFFF" stroke="#432098" stroke-width="1.8"/>
      <line x1="13" y1="1" x2="13" y2="15" stroke="#432098" stroke-width="1.8"/>
    </marker>
  </defs>

  <!-- 1. Users (1) -> Parking Spaces (0..*) [user_id -> id] -->
  <path class="edge-line" d="M 350 170 L 400 170 L 400 230 L 450 230" marker-start="url(#crows-one)" marker-end="url(#crows-zero-many)"/>
  <rect x="360" y="157" width="85" height="14" fill="#FFFFFF"/>
  <text class="edge-label" x="362" y="168">user_id -&gt; id</text>
  <text class="cardinality-badge" x="355" y="163">1</text>
  <text class="cardinality-badge" x="428" y="223">0..*</text>

  <!-- 2. Users (1) -> Vehicles (0..*) [user_id -> id] -->
  <path class="edge-line" d="M 195 625 L 195 680" marker-start="url(#crows-one)" marker-end="url(#crows-zero-many)"/>
  <rect x="70" y="645" width="250" height="15" fill="#FFFFFF"/>
  <text class="edge-label" x="72" y="656">user_id-&gt; id   reviewed_by -&gt; id</text>
  <text class="cardinality-badge" x="202" y="638">1</text>
  <text class="cardinality-badge" x="202" y="674">0..*</text>

  <!-- 3. Parking Spaces (1) -> Parking Slots (1..*) [IDENTIFYING COMPOSITION] -->
  <path class="edge-line" d="M 630 945 L 630 1000" marker-start="url(#crows-one)" marker-end="url(#crows-one-many)"/>
  <rect x="555" y="965" width="150" height="15" fill="#FFFFFF"/>
  <text class="edge-label" x="558" y="976">parking_space_id -&gt; id</text>
  <text class="cardinality-badge" x="637" y="958">1</text>
  <text class="cardinality-badge" x="637" y="995">1..*</text>

  <!-- 4. Parking Spaces (1) -> Reservations (0..*) [parking_space_id -> id] -->
  <path class="edge-line" d="M 810 320 L 870 320 L 870 250 L 930 250" marker-start="url(#crows-one)" marker-end="url(#crows-zero-many)"/>
  <rect x="815" y="307" width="140" height="14" fill="#FFFFFF"/>
  <text class="edge-label" x="818" y="318">parking_space_id -&gt; id</text>
  <text class="cardinality-badge" x="815" y="313">1</text>
  <text class="cardinality-badge" x="908" y="243">0..*</text>

  <!-- 5. Parking Slots (1) -> Reservations (0..*) [parking_slot_id -> id] -->
  <path class="edge-line" d="M 810 1080 L 870 1080 L 870 1060 L 930 1060" marker-start="url(#crows-one)" marker-end="url(#crows-zero-many)"/>
  <rect x="815" y="1068" width="130" height="14" fill="#FFFFFF"/>
  <text class="edge-label" x="818" y="1079">parking_slot_id -&gt; id</text>
  <text class="cardinality-badge" x="815" y="1073">1</text>
  <text class="cardinality-badge" x="908" y="1053">0..*</text>

  <!-- 6. Vehicles (1) -> Reservations (0..*) [vehicle_id -> id] -->
  <path class="edge-line" d="M 350 1120 L 400 1120 L 400 1370 L 870 1370 L 870 1100 L 930 1100" marker-start="url(#crows-one)" marker-end="url(#crows-zero-many)"/>
  <rect x="580" y="1357" width="105" height="14" fill="#FFFFFF"/>
  <text class="edge-label" x="585" y="1368">vehicle_id -&gt; id</text>
  <text class="cardinality-badge" x="355" y="1113">1</text>
  <text class="cardinality-badge" x="908" y="1093">0..*</text>

  <!-- 7. Users (1) -> Reservations (0..*) [user_id -> id] -->
  <path class="edge-line" d="M 195 90 L 195 65 L 860 65 L 860 225 L 930 225" marker-start="url(#crows-one)" marker-end="url(#crows-zero-many)"/>
  <rect x="520" y="57" width="90" height="14" fill="#FFFFFF"/>
  <text class="edge-label" x="525" y="68">user_id -&gt; id</text>
  <text class="cardinality-badge" x="198" y="85">1</text>
  <text class="cardinality-badge" x="908" y="218">0..*</text>

  <!-- 8. Reservations (1) -> Parking Space Feedback (0..1) [ONE-TO-ONE / ZERO-OR-ONE] -->
  <path class="edge-line" d="M 1295 240 L 1345 240 L 1345 150 L 1400 150" marker-start="url(#crows-one)" marker-end="url(#crows-zero-one)"/>
  <rect x="1295" y="227" width="145" height="14" fill="#FFFFFF"/>
  <text class="edge-label" x="1298" y="238">reservation_id -&gt; id (1:1)</text>
  <text class="cardinality-badge" x="1298" y="253">1</text>
  <text class="cardinality-badge" x="1378" y="143">0..1</text>

  <!-- 9. Parking Spaces (1) -> Parking Space Feedback (0..*) [parking_space_id -> id] -->
  <path class="edge-line" d="M 680 150 L 680 80 L 1350 80 L 1350 180 L 1400 180" marker-start="url(#crows-one)" marker-end="url(#crows-zero-many)"/>
  <rect x="1000" y="72" width="140" height="14" fill="#FFFFFF"/>
  <text class="edge-label" x="1005" y="83">parking_space_id -&gt; id</text>
  <text class="cardinality-badge" x="685" y="145">1</text>
  <text class="cardinality-badge" x="1378" y="173">0..*</text>
</svg>

</body>
</html>
"""
    os.makedirs(os.path.dirname(html_file), exist_ok=True)
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(html_content)

    chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
    if not os.path.exists(chrome_path):
        chrome_path = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

    cmd = [
        chrome_path,
        '--headless=new',
        '--disable-gpu',
        '--hide-scrollbars',
        '--force-device-scale-factor=2',
        '--window-size=1880,1580',
        f'--screenshot={png_file}',
        html_file
    ]
    subprocess.run(cmd, capture_output=True, check=True)
    crop_and_save_300dpi(png_file)

def crop_and_save_300dpi(png_path):
    from PIL import Image, ImageChops
    im = Image.open(png_path).convert('RGB')
    bg = Image.new('RGB', im.size, (255, 255, 255))
    diff = ImageChops.difference(im, bg)
    bbox = diff.getbbox()
    if bbox:
        margin = 40
        box = (
            max(0, bbox[0] - margin),
            max(0, bbox[1] - margin),
            min(im.size[0], bbox[2] + margin),
            min(im.size[1], bbox[3] + margin)
        )
        cropped = im.crop(box)
        cropped.save(png_path, dpi=(300, 300))
        print(f"Saved cropped 300 DPI: {png_path} ({cropped.size})")

        # Copy to artifacts
        artifact_dir = r'C:\Users\kimch\.gemini\antigravity\brain\1b4fe125-c1ab-4d87-bfc1-efbfedf06185'
        import shutil
        shutil.copy2(png_path, f'{artifact_dir}/fig13_core_booking_database_postgres.png')
        print('Updated artifact PNG.')

if __name__ == '__main__':
    generate_core_booking_database()
