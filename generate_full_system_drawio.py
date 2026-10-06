import xml.etree.ElementTree as ET
from xml.dom import minidom
import os
import subprocess

def create_full_system_drawio():
    mxfile = ET.Element('mxfile', host='Electron', agent='Mozilla/5.0', version='21.6.8', type='device')

    workspace_path = r'c:\Users\kimch\e_parada_mobile'

    # Helper styles
    title_style = "text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=top;whiteSpace=wrap;rounded=0;"
    
    # Draw.io Crow's Foot edge styles
    base_purple = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#432098;strokeWidth=1.5;fontSize=10;fontColor=#1E293B;fontFamily=Courier New;"
    edge_purple_1_n = base_purple + "startArrow=ERmandOne;endArrow=ERzeroToMany;"
    edge_purple_1_mand_n = base_purple + "startArrow=ERmandOne;endArrow=ERmany;"
    edge_purple_1_1 = base_purple + "startArrow=ERmandOne;endArrow=ERzeroToOne;"
    edge_purple_01_n = base_purple + "startArrow=ERzeroToOne;endArrow=ERzeroToMany;"

    base_blue = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#1D4ED8;strokeWidth=1.5;fontSize=10;fontColor=#1E293B;fontFamily=Courier New;"
    edge_blue_1_n = base_blue + "startArrow=ERmandOne;endArrow=ERzeroToMany;"
    edge_blue_1_mand_n = base_blue + "startArrow=ERmandOne;endArrow=ERmany;"

    base_teal = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#0D9488;strokeWidth=1.5;fontSize=10;fontColor=#1E293B;fontFamily=Courier New;"
    edge_teal_01_n = base_teal + "startArrow=ERzeroToOne;endArrow=ERzeroToMany;"

    table_container_style = "shape=rectangle;whiteSpace=wrap;html=1;overflow=hidden;fillColor=#FFFFFF;strokeColor=#432098;strokeWidth=1;shadow=1;align=left;verticalAlign=top;spacing=0;"

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

    def build_table_html(title, rows, header_color="#432098"):
        html = [
            f'<table style="width:100%; height:100%; border-collapse:collapse; background-color:#FFFFFF; font-family:Courier New, Courier, monospace; font-size:11px; border:1px solid {header_color};">',
            f'<tr style="background-color:{header_color}; height:30px;">',
            f'<td colspan="2" style="padding-left:10px; font-family:Arial, Helvetica, sans-serif; font-size:13px; font-weight:bold; color:#FFFFFF; text-align:left;">{title}</td>',
            '</tr>'
        ]
        for row in rows:
            col_name, col_type = row
            name_style = 'font-weight:bold; color:#000000;' if (col_name.startswith('PK') or col_name.startswith('FK')) else 'color:#000000;'
            type_style = 'color:#1E1B4B; font-weight:bold;' if col_type in ['boolean', 'timestamptz'] else 'color:#334155;'
            html.append(
                f'<tr style="border-bottom:1px solid #E2E8F0; height:23px;">'
                f'<td style="padding-left:8px; text-align:left; {name_style}">{col_name}</td>'
                f'<td style="padding-right:8px; text-align:left; {type_style}">: {col_type}</td>'
                f'</tr>'
            )
        html.append('</table>')
        return "".join(html)

    # =========================================================================
    # TAB 1: CORE BOOKING SUBSYSTEM (FIGURE 13)
    # =========================================================================
    diag1 = ET.SubElement(mxfile, 'diagram', id='fig13_core', name='1. Core Booking Subsystem (Fig 13)')
    graph1 = ET.SubElement(diag1, 'mxGraphModel', dx='2600', dy='2200', grid='1', gridSize='10', guides='1', tooltips='1', connect='1', arrows='1', fold='1', page='1', pageScale='1', pageWidth='1850', pageHeight='1650')
    root1 = ET.SubElement(graph1, 'root')
    ET.SubElement(root1, 'mxCell', id='0')
    ET.SubElement(root1, 'mxCell', id='1', parent='0')

    title1 = (
        '<div style="font-family: Arial, Helvetica, sans-serif;">'
        '<span style="font-size: 18px; font-weight: bold; color: #000000;">Figure 13. E-Parada Core Booking Database (Crow\'s Foot ERD)</span><br/>'
        '<span style="font-size: 11px; color: #475569;">Information Engineering (IE) Crow\'s Foot notation with PostgreSQL 15+ normalized datatypes.</span>'
        '</div>'
    )
    add_vertex(root1, 't1', title1, title_style, 40, 25, 750, 50)

    users_rows = [
        ("PK id", "INTEGER"), ("name", "varchar"), ("email", "varchar"), ("email_verified_at", "timestamptz"),
        ("password", "varchar"), ("remember_token", "varchar"), ("created_at", "timestamptz"), ("updated_at", "timestamptz"),
        ("role", "varchar"), ("verification_status", "varchar"), ("verification_notes", "TEXT"), ("id_type", "varchar"),
        ("id_image_path", "varchar"), ("gcash_name", "varchar"), ("gcash_number", "varchar"), ("gcash_qr_image", "varchar"),
        ("plate_number", "varchar"), ("contact_number", "varchar"), ("id_image_back_path", "varchar")
    ]
    add_vertex(root1, 't1_users', build_table_html('Users', users_rows), table_container_style, 40, 90, 310, 520)

    vehicles_rows = [
        ("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("plate_number", "varchar"), ("vehicle_type", "varchar"),
        ("color", "varchar"), ("model", "varchar"), ("photo_path", "varchar"), ("verification_status", "varchar"),
        ("verification_notes", "TEXT"), ("consented_at", "timestamptz"), ("FK reviewed_by", "INTEGER"),
        ("reviewed_at", "timestamptz"), ("created_at", "timestamptz"), ("updated_at", "timestamptz"),
        ("make", "varchar"), ("plate_scan_status", "varchar"), ("plate_scanned_at", "timestamptz"), ("photo_back_path", "varchar")
    ]
    add_vertex(root1, 't1_vehicles', build_table_html('Vehicles', vehicles_rows), table_container_style, 40, 700, 310, 490)

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
    add_vertex(root1, 't1_spaces', build_table_html('Parking Spaces', spaces_rows), table_container_style, 450, 150, 350, 780)

    slots_rows = [
        ("PK id", "INTEGER"), ("FK parking_space_id", "INTEGER"), ("slot_number", "INTEGER"), ("slot_label", "varchar"),
        ("vehicle_type", "varchar"), ("is_active", "boolean"), ("created_at", "timestamptz"), ("updated_at", "timestamptz"),
        ("supported_vehicle_types", "TEXT"), ("layout_x", "numeric"), ("layout_z", "numeric"), ("layout_rotation", "numeric")
    ]
    add_vertex(root1, 't1_slots', build_table_html('Parking Slots', slots_rows), table_container_style, 450, 1020, 350, 340)

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
    add_vertex(root1, 't1_reservations', build_table_html('Reservations', reservations_rows), table_container_style, 920, 200, 360, 1280)

    feedback_rows = [
        ("PK id", "INTEGER"), ("FK reservation_id", "INTEGER"), ("FK parking_space_id", "INTEGER"),
        ("FK user_id", "INTEGER"), ("rating", "INTEGER"), ("comment", "TEXT"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz"), ("moderation_status", "varchar"),
        ("admin_notes", "TEXT"), ("reviewed_at", "timestamptz")
    ]
    add_vertex(root1, 't1_feedback', build_table_html('Parking Space Feedback', feedback_rows), table_container_style, 1380, 90, 320, 340)

    # Fig 13 Edges with Cardinalities
    add_edge(root1, 'e1_1', 't1_users', 't1_spaces', edge_purple_1_n, 'user_id -&gt; id  [1 : 0..*]', 1, 0.15, 0, 0.12)
    add_edge(root1, 'e1_2', 't1_users', 't1_vehicles', edge_purple_1_n, 'user_id -&gt; id   reviewed_by -&gt; id  [1 : 0..*]', 0.5, 1, 0.5, 0)
    add_edge(root1, 'e1_3', 't1_spaces', 't1_slots', edge_purple_1_mand_n, 'parking_space_id -&gt; id  [1 : 1..*]', 0.5, 1, 0.5, 0)
    add_edge(root1, 'e1_4', 't1_spaces', 't1_reservations', edge_purple_1_n, 'parking_space_id -&gt; id  [1 : 0..*]', 1, 0.22, 0, 0.12)
    add_edge(root1, 'e1_5', 't1_slots', 't1_reservations', edge_purple_1_n, 'parking_slot_id -&gt; id  [1 : 0..*]', 1, 0.35, 0, 0.72)
    add_edge(root1, 'e1_6', 't1_vehicles', 't1_reservations', edge_purple_1_n, 'vehicle_id -&gt; id  [1 : 0..*]', 1, 0.85, 0, 0.88, points=[(400, 1115), (400, 1420), (870, 1420), (870, 1325)])
    add_edge(root1, 'e1_7', 't1_users', 't1_reservations', edge_purple_1_n, 'user_id -&gt; id  [1 : 0..*]', 0.5, 0, 0.5, 0, points=[(195, 65), (860, 65), (1100, 65)])
    add_edge(root1, 'e1_8', 't1_reservations', 't1_feedback', edge_purple_1_1, 'reservation_id -&gt; id  [1 : 0..1]', 1, 0.08, 0, 0.35)
    add_edge(root1, 'e1_9', 't1_spaces', 't1_feedback', edge_purple_1_n, 'parking_space_id -&gt; id  [1 : 0..*]', 0.7, 0, 0.5, 0, points=[(695, 80), (1330, 80), (1540, 80)])

    # =========================================================================
    # TAB 2: COMMUNICATIONS & NOTIFICATIONS SUBSYSTEM (FIGURE 14)
    # =========================================================================
    diag2 = ET.SubElement(mxfile, 'diagram', id='fig14_comm', name='2. Communications & Push (Fig 14)')
    graph2 = ET.SubElement(diag2, 'mxGraphModel', dx='2600', dy='2200', grid='1', gridSize='10', guides='1', tooltips='1', connect='1', arrows='1', fold='1', page='1', pageScale='1', pageWidth='1700', pageHeight='1200')
    root2 = ET.SubElement(graph2, 'root')
    ET.SubElement(root2, 'mxCell', id='0')
    ET.SubElement(root2, 'mxCell', id='1', parent='0')

    title2 = (
        '<div style="font-family: Arial, Helvetica, sans-serif;">'
        '<span style="font-size: 18px; font-weight: bold; color: #1E3A8A;">Figure 14. E-Parada Real-Time Communications & Notification Subsystem</span><br/>'
        '<span style="font-size: 11px; color: #475569;">In-app chat, WebRTC VoIP signaling, FCM background push tokens, and in-app notifications (Crow\'s Foot ERD).</span>'
        '</div>'
    )
    add_vertex(root2, 't2', title2, title_style, 40, 25, 850, 50)

    users_stub = [("PK id", "INTEGER"), ("name", "varchar"), ("email", "varchar"), ("role", "varchar")]
    add_vertex(root2, 't2_users', build_table_html('Users (Core Stub)', users_stub, '#475569'), table_container_style, 40, 100, 260, 150)

    res_stub = [("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("FK parking_space_id", "INTEGER"), ("status", "varchar")]
    add_vertex(root2, 't2_reservations', build_table_html('Reservations (Core Stub)', res_stub, '#475569'), table_container_style, 40, 360, 260, 150)

    messages_rows = [
        ("PK id", "INTEGER"), ("FK reservation_id", "INTEGER"), ("FK sender_id", "INTEGER"),
        ("body", "TEXT"), ("read_at", "timestamptz"), ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root2, 't2_messages', build_table_html('Reservation Messages (Chat)', messages_rows, '#1D4ED8'), table_container_style, 380, 340, 320, 210)

    calls_rows = [
        ("PK id", "INTEGER"), ("FK reservation_id", "INTEGER"), ("FK caller_id", "INTEGER"), ("FK callee_id", "INTEGER"),
        ("status", "varchar"), ("answered_at", "timestamptz"), ("ended_at", "timestamptz"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root2, 't2_calls', build_table_html('Reservation Calls (WebRTC)', calls_rows, '#1D4ED8'), table_container_style, 780, 340, 320, 260)

    signals_rows = [
        ("PK id", "INTEGER"), ("FK reservation_call_id", "INTEGER"), ("FK sender_id", "INTEGER"),
        ("type", "varchar(20)"), ("payload", "json"), ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root2, 't2_signals', build_table_html('Reservation Call Signals (SDP/ICE)', signals_rows, '#1D4ED8'), table_container_style, 1180, 340, 340, 210)

    tokens_rows = [
        ("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("token", "TEXT"), ("token_hash", "varchar(64)"),
        ("platform", "varchar(32)"), ("device_name", "varchar(128)"), ("last_used_at", "timestamptz"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root2, 't2_tokens', build_table_html('User Device Tokens (FCM Push)', tokens_rows, '#4338CA'), table_container_style, 380, 80, 320, 240)

    notifs_rows = [
        ("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("title", "varchar"), ("message", "TEXT"),
        ("type", "varchar"), ("link", "varchar"), ("read_at", "timestamptz"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root2, 't2_notifs', build_table_html('Notifications (In-App Tray)', notifs_rows, '#4338CA'), table_container_style, 780, 80, 320, 240)

    # Edges for Tab 2
    add_edge(root2, 'e2_1', 't2_users', 't2_tokens', edge_blue_1_n, 'user_id -&gt; id  [1 : 0..*]', 1, 0.4, 0, 0.3)
    add_edge(root2, 'e2_2', 't2_users', 't2_notifs', edge_blue_1_n, 'user_id -&gt; id  [1 : 0..*]', 1, 0.2, 0, 0.2, points=[(340, 130), (340, 60), (740, 60), (740, 128)])
    add_edge(root2, 'e2_3', 't2_reservations', 't2_messages', edge_blue_1_n, 'reservation_id -&gt; id  [1 : 0..*]', 1, 0.3, 0, 0.3)
    add_edge(root2, 'e2_4', 't2_reservations', 't2_calls', edge_blue_1_n, 'reservation_id -&gt; id  [1 : 0..*]', 1, 0.7, 0, 0.7, points=[(340, 465), (340, 580), (740, 580), (740, 520)])
    add_edge(root2, 'e2_5', 't2_calls', 't2_signals', edge_blue_1_mand_n, 'reservation_call_id -&gt; id  [1 : 1..*]', 1, 0.3, 0, 0.3)

    # =========================================================================
    # TAB 3: AUDIT, GATE TELEMETRY & SUPPORT SUBSYSTEM (FIGURE 15)
    # =========================================================================
    diag3 = ET.SubElement(mxfile, 'diagram', id='fig15_audit', name='3. Audit & Telemetry (Fig 15)')
    graph3 = ET.SubElement(diag3, 'mxGraphModel', dx='2600', dy='2200', grid='1', gridSize='10', guides='1', tooltips='1', connect='1', arrows='1', fold='1', page='1', pageScale='1', pageWidth='1700', pageHeight='1200')
    root3 = ET.SubElement(graph3, 'root')
    ET.SubElement(root3, 'mxCell', id='0')
    ET.SubElement(root3, 'mxCell', id='1', parent='0')

    title3 = (
        '<div style="font-family: Arial, Helvetica, sans-serif;">'
        '<span style="font-size: 18px; font-weight: bold; color: #0F766E;">Figure 15. E-Parada Security Audit, Scanner Telemetry & Support Subsystem</span><br/>'
        '<span style="font-size: 11px; color: #475569;">Admin audit trail, QR entrance/exit verification telemetry, and help desk support (Crow\'s Foot ERD).</span>'
        '</div>'
    )
    add_vertex(root3, 't3', title3, title_style, 40, 25, 850, 50)

    add_vertex(root3, 't3_users', build_table_html('Users (Core Stub)', users_stub, '#475569'), table_container_style, 40, 100, 250, 150)
    add_vertex(root3, 't3_reservations', build_table_html('Reservations (Core Stub)', res_stub, '#475569'), table_container_style, 40, 360, 250, 150)
    spaces_stub = [("PK id", "INTEGER"), ("space_name", "varchar"), ("address", "varchar")]
    add_vertex(root3, 't3_spaces', build_table_html('Parking Spaces (Core Stub)', spaces_stub, '#475569'), table_container_style, 40, 600, 250, 130)

    activity_rows = [
        ("PK id", "INTEGER"), ("FK actor_id", "INTEGER"), ("action", "varchar(30)"), ("subject_type", "varchar"),
        ("subject_id", "varchar(64)"), ("description", "varchar"), ("old_values", "json"), ("new_values", "json"),
        ("ip_address", "varchar(45)"), ("user_agent", "TEXT"), ("request_id", "uuid"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root3, 't3_activity', build_table_html('Activity Logs (Admin Audit Trail)', activity_rows, '#0F766E'), table_container_style, 380, 80, 350, 330)

    support_rows = [
        ("PK id", "INTEGER"), ("FK user_id", "INTEGER"), ("name", "varchar"), ("email", "varchar"),
        ("category", "varchar(50)"), ("subject", "varchar"), ("message", "TEXT"), ("status", "varchar(30)"),
        ("ip_address", "varchar(45)"), ("user_agent", "varchar(500)"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root3, 't3_support', build_table_html('Support Requests (Help Desk)', support_rows, '#0F766E'), table_container_style, 800, 80, 340, 310)

    qr_rows = [
        ("PK id", "INTEGER"), ("FK reservation_id", "INTEGER"), ("FK parking_space_id", "INTEGER"),
        ("FK actor_user_id", "INTEGER"), ("identifier_hash", "char(64)"), ("identifier_suffix", "varchar(8)"),
        ("lookup_method", "varchar(30)"), ("event_type", "varchar(50)"), ("was_successful", "boolean"),
        ("failure_reason", "varchar(255)"), ("reservation_status_before", "varchar(30)"),
        ("reservation_status_after", "varchar(30)"), ("time_in_before", "timestamptz"),
        ("time_in_after", "timestamptz"), ("time_out_before", "timestamptz"), ("time_out_after", "timestamptz"),
        ("ip_address", "varchar(45)"), ("user_agent", "varchar(500)"), ("metadata", "json"),
        ("created_at", "timestamptz"), ("updated_at", "timestamptz")
    ]
    add_vertex(root3, 't3_qr_logs', build_table_html('QR Transaction Logs (Scanner Telemetry)', qr_rows, '#0F766E'), table_container_style, 380, 460, 380, 520)

    # Edges for Tab 3
    add_edge(root3, 'e3_1', 't3_users', 't3_activity', edge_teal_01_n, 'actor_id -&gt; id  [0..1 : 0..*]', 1, 0.3, 0, 0.2)
    add_edge(root3, 'e3_2', 't3_users', 't3_support', edge_teal_01_n, 'user_id -&gt; id  [0..1 : 0..*]', 1, 0.1, 0, 0.1, points=[(320, 115), (320, 50), (760, 50), (760, 110)])
    add_edge(root3, 'e3_3', 't3_reservations', 't3_qr_logs', edge_teal_01_n, 'reservation_id -&gt; id  [0..1 : 0..*]', 1, 0.4, 0, 0.15)
    add_edge(root3, 'e3_4', 't3_spaces', 't3_qr_logs', edge_teal_01_n, 'parking_space_id -&gt; id  [0..1 : 0..*]', 1, 0.3, 0, 0.45)

    # =========================================================================
    # TAB 4: MASTER ENTERPRISE DATABASE ARCHITECTURE (ALL 14 TABLES)
    # =========================================================================
    diag4 = ET.SubElement(mxfile, 'diagram', id='fig_master', name='4. Master System Architecture (All 14 Tables)')
    graph4 = ET.SubElement(diag4, 'mxGraphModel', dx='3200', dy='2600', grid='1', gridSize='10', guides='1', tooltips='1', connect='1', arrows='1', fold='1', page='1', pageScale='1', pageWidth='2400', pageHeight='1800')
    root4 = ET.SubElement(graph4, 'root')
    ET.SubElement(root4, 'mxCell', id='0')
    ET.SubElement(root4, 'mxCell', id='1', parent='0')

    title4 = (
        '<div style="font-family: Arial, Helvetica, sans-serif;">'
        '<span style="font-size: 22px; font-weight: bold; color: #0F172A;">E-Parada Complete Multi-Subsystem Database Architecture (14 Domain Tables)</span><br/>'
        '<span style="font-size: 12px; color: #475569;">Comprehensive enterprise schema covering Core Booking, Communications & Push Notifications, and Security Audit & Telemetry (Crow\'s Foot ERD).</span>'
        '</div>'
    )
    add_vertex(root4, 't4', title4, title_style, 40, 25, 1200, 60)

    pkg_core = "shape=swimlane;whiteSpace=wrap;html=1;startSize=28;fillColor=#F5F3FF;strokeColor=#432098;fontColor=#432098;fontSize=13;fontStyle=1;rounded=1;shadow=0;"
    add_vertex(root4, 'pkg1', '1. Core Booking Subsystem (6 Tables)', pkg_core, 30, 90, 1260, 1420)

    pkg_comm = "shape=swimlane;whiteSpace=wrap;html=1;startSize=28;fillColor=#EFF6FF;strokeColor=#1D4ED8;fontColor=#1D4ED8;fontSize=13;fontStyle=1;rounded=1;shadow=0;"
    add_vertex(root4, 'pkg2', '2. Real-Time Communications & Push Subsystem (5 Tables)', pkg_comm, 1320, 90, 980, 650)

    pkg_audit = "shape=swimlane;whiteSpace=wrap;html=1;startSize=28;fillColor=#F0FDFA;strokeColor=#0D9488;fontColor=#0D9488;fontSize=13;fontStyle=1;rounded=1;shadow=0;"
    add_vertex(root4, 'pkg3', '3. Security Audit & Gate Telemetry Subsystem (3 Tables)', pkg_audit, 1320, 770, 980, 740)

    # Core Domain in Pkg 1:
    add_vertex(root4, 'm_users', build_table_html('Users', users_rows, '#432098'), table_container_style, 50, 140, 280, 500)
    add_vertex(root4, 'm_vehicles', build_table_html('Vehicles', vehicles_rows, '#432098'), table_container_style, 50, 690, 280, 480)
    add_vertex(root4, 'm_spaces', build_table_html('Parking Spaces', spaces_rows, '#432098'), table_container_style, 380, 140, 310, 750)
    add_vertex(root4, 'm_slots', build_table_html('Parking Slots', slots_rows, '#432098'), table_container_style, 380, 940, 310, 330)
    add_vertex(root4, 'm_reservations', build_table_html('Reservations', reservations_rows, '#432098'), table_container_style, 740, 140, 330, 1280)
    add_vertex(root4, 'm_feedback', build_table_html('Parking Space Feedback', feedback_rows, '#432098'), table_container_style, 1100, 140, 170, 340)

    # Comm Domain in Pkg 2:
    add_vertex(root4, 'm_tokens', build_table_html('User Device Tokens (FCM)', tokens_rows, '#1D4ED8'), table_container_style, 1340, 140, 300, 240)
    add_vertex(root4, 'm_notifs', build_table_html('Notifications', notifs_rows, '#1D4ED8'), table_container_style, 1680, 140, 290, 240)
    add_vertex(root4, 'm_messages', build_table_html('Reservation Messages', messages_rows, '#1D4ED8'), table_container_style, 1340, 430, 290, 210)
    add_vertex(root4, 'm_calls', build_table_html('Reservation Calls', calls_rows, '#1D4ED8'), table_container_style, 1660, 430, 290, 260)
    add_vertex(root4, 'm_signals', build_table_html('Reservation Call Signals', signals_rows, '#1D4ED8'), table_container_style, 1980, 430, 300, 210)

    # Audit Domain in Pkg 3:
    add_vertex(root4, 'm_activity', build_table_html('Activity Logs', activity_rows, '#0D9488'), table_container_style, 1340, 820, 310, 320)
    add_vertex(root4, 'm_support', build_table_html('Support Requests', support_rows, '#0D9488'), table_container_style, 1680, 820, 300, 300)
    add_vertex(root4, 'm_qr', build_table_html('QR Transaction Logs', qr_rows, '#0D9488'), table_container_style, 1340, 1180, 350, 310)

    # Cross-subsystem connectors with Crow's Foot
    add_edge(root4, 'em_u_spc', 'm_users', 'm_spaces', edge_purple_1_n, 'user_id -&gt; id  [1 : 0..*]', 1, 0.2, 0, 0.15)
    add_edge(root4, 'em_u_veh', 'm_users', 'm_vehicles', edge_purple_1_n, 'user_id -&gt; id  [1 : 0..*]', 0.5, 1, 0.5, 0)
    add_edge(root4, 'em_spc_slt', 'm_spaces', 'm_slots', edge_purple_1_mand_n, 'parking_space_id -&gt; id  [1 : 1..*]', 0.5, 1, 0.5, 0)
    add_edge(root4, 'em_spc_res', 'm_spaces', 'm_reservations', edge_purple_1_n, 'parking_space_id -&gt; id  [1 : 0..*]', 1, 0.2, 0, 0.12)
    add_edge(root4, 'em_slt_res', 'm_slots', 'm_reservations', edge_purple_1_n, 'parking_slot_id -&gt; id  [1 : 0..*]', 1, 0.35, 0, 0.72)
    add_edge(root4, 'em_res_fbk', 'm_reservations', 'm_feedback', edge_purple_1_1, 'reservation_id -&gt; id  [1 : 0..1]', 1, 0.08, 0, 0.3)

    add_edge(root4, 'em_u_tok', 'm_users', 'm_tokens', edge_blue_1_n, 'user_id -&gt; id  [1 : 0..*]', 0.5, 0, 0, 0.2, points=[(190, 75), (1310, 75), (1310, 188)])
    add_edge(root4, 'em_res_msg', 'm_reservations', 'm_messages', edge_blue_1_n, 'reservation_id -&gt; id  [1 : 0..*]', 1, 0.25, 0, 0.3)
    add_edge(root4, 'em_res_call', 'm_reservations', 'm_calls', edge_blue_1_n, 'reservation_id -&gt; id  [1 : 0..*]', 1, 0.28, 0, 0.7, points=[(1090, 500), (1310, 500), (1310, 610), (1630, 610), (1630, 580)])
    add_edge(root4, 'em_call_sig', 'm_calls', 'm_signals', edge_blue_1_mand_n, 'reservation_call_id -&gt; id  [1 : 1..*]', 1, 0.3, 0, 0.3)
    add_edge(root4, 'em_res_qr', 'm_reservations', 'm_qr', edge_teal_01_n, 'reservation_id -&gt; id  [0..1 : 0..*]', 1, 0.85, 0, 0.2, points=[(1090, 1230), (1310, 1230), (1310, 1240)])

    # Write Drawio
    rough_string = ET.tostring(mxfile, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    pretty_xml = reparsed.toprettyxml(indent="  ", encoding="utf-8").decode("utf-8")
    pretty_xml = "\n".join([line for line in pretty_xml.split("\n") if line.strip()])

    out_file = os.path.join(workspace_path, 'e_parada_complete_database_architecture.drawio')
    with open(out_file, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
    print(f"Generated Full System Drawio: {out_file}")

    render_fig14_and_fig15_pngs(workspace_path, users_stub, res_stub, spaces_stub, messages_rows, calls_rows, signals_rows, tokens_rows, notifs_rows, activity_rows, support_rows, qr_rows)

def render_fig14_and_fig15_pngs(workspace_path, users_stub, res_stub, spaces_stub, messages_rows, calls_rows, signals_rows, tokens_rows, notifs_rows, activity_rows, support_rows, qr_rows):
    chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
    if not os.path.exists(chrome_path):
        chrome_path = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

    def render_rows(rows):
        res = []
        for name, dtype in rows:
            name_cls = "bold" if (name.startswith("PK") or name.startswith("FK")) else ""
            type_cls = "fixed-type" if dtype in ["boolean", "timestamptz"] else "standard-type"
            res.append(f'<tr><td class="col-name {name_cls}">{name}</td><td class="col-type {type_cls}">: {dtype}</td></tr>')
        return "".join(res)

    base_css = """
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background-color: #FFFFFF; font-family: Arial, Helvetica, sans-serif; position: relative; }
  .table-card { position: absolute; background: #FFFFFF; border-radius: 2px; box-shadow: 2px 3px 8px rgba(0,0,0,0.08); overflow: hidden; }
  .table-title { color: #FFFFFF; font-weight: bold; font-size: 13px; padding: 6px 10px; }
  table { width: 100%; border-collapse: collapse; font-family: "Courier New", Courier, monospace; font-size: 11px; }
  tr { border-bottom: 1px solid #E2E8F0; height: 23px; }
  tr:last-child { border-bottom: none; }
  td { padding: 2px 8px; vertical-align: middle; }
  .col-name { color: #0f172a; width: 58%; }
  .col-type { width: 42%; }
  .bold { font-weight: bold; }
  .standard-type { color: #334155; }
  .fixed-type { color: #1E1B4B; font-weight: bold; background-color: #EEF2FF; border-radius: 3px; padding: 1px 4px; }
  svg.connectors { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 10; }
  .edge-line { stroke-width: 1.6; fill: none; }
  .edge-label { font-family: "Courier New", Courier, monospace; font-size: 10.5px; fill: #1E293B; }
  .cardinality-badge { font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }

  /* Legend */
  .legend-box {
    position: absolute;
    right: 40px;
    top: 90px;
    width: 280px;
    background: #F8FAFC;
    border: 1px solid #CBD5E1;
    border-radius: 4px;
    padding: 10px 14px;
    font-size: 11.5px;
    color: #1E293B;
  }
  .legend-title { font-weight: bold; margin-bottom: 6px; color: #0F172A; }
  .legend-item { display: flex; align-items: center; margin-bottom: 4px; font-family: "Courier New", Courier, monospace; }
  .legend-symbol { width: 45px; font-weight: bold; }
"""

    # 1. FIG 14: COMMUNICATIONS & NOTIFICATIONS
    html14 = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{base_css}
body {{ width: 1560px; height: 720px; padding: 25px; }}
.main-header h1 {{ font-size: 22px; color: #1E3A8A; }}
.main-header p {{ font-size: 12px; color: #475569; margin-top: 3px; }}
.edge-line {{ stroke: #1D4ED8; }}
.cardinality-badge {{ fill: #1D4ED8; }}
.legend-symbol {{ color: #1D4ED8; }}
</style></head>
<body>
<div class="main-header" style="position: absolute; top: 25px; left: 40px;">
  <h1>Figure 14. E-Parada Real-Time Communications & Notification Subsystem (Crow's Foot ERD)</h1>
  <p>In-app chat, WebRTC VoIP signaling, FCM background push tokens, and in-app notifications.</p>
</div>

<div class="table-card" style="left: 40px; top: 90px; width: 260px; border: 1px solid #475569;">
  <div class="table-title" style="background:#475569;">Users (Core Stub)</div><table>{render_rows(users_stub)}</table>
</div>
<div class="table-card" style="left: 40px; top: 320px; width: 260px; border: 1px solid #475569;">
  <div class="table-title" style="background:#475569;">Reservations (Core Stub)</div><table>{render_rows(res_stub)}</table>
</div>

<div class="table-card" style="left: 360px; top: 90px; width: 330px; border: 1px solid #4338CA;">
  <div class="table-title" style="background:#4338CA;">User Device Tokens (FCM Push)</div><table>{render_rows(tokens_rows)}</table>
</div>
<div class="table-card" style="left: 740px; top: 90px; width: 330px; border: 1px solid #4338CA;">
  <div class="table-title" style="background:#4338CA;">Notifications (In-App Tray)</div><table>{render_rows(notifs_rows)}</table>
</div>

<div class="table-card" style="left: 360px; top: 380px; width: 330px; border: 1px solid #1D4ED8;">
  <div class="table-title" style="background:#1D4ED8;">Reservation Messages (Chat)</div><table>{render_rows(messages_rows)}</table>
</div>
<div class="table-card" style="left: 740px; top: 380px; width: 330px; border: 1px solid #1D4ED8;">
  <div class="table-title" style="background:#1D4ED8;">Reservation Calls (WebRTC)</div><table>{render_rows(calls_rows)}</table>
</div>
<div class="table-card" style="left: 1120px; top: 380px; width: 350px; border: 1px solid #1D4ED8;">
  <div class="table-title" style="background:#1D4ED8;">Reservation Call Signals (SDP/ICE)</div><table>{render_rows(signals_rows)}</table>
</div>

<!-- Legend -->
<div class="legend-box">
  <div class="legend-title">Crow's Foot Cardinalities:</div>
  <div class="legend-item"><span class="legend-symbol">||</span> Mandatory One (1)</div>
  <div class="legend-item"><span class="legend-symbol">&gt;o</span> Optional Many (0..*)</div>
  <div class="legend-item"><span class="legend-symbol">&gt;|</span> Mandatory Many (1..*)</div>
</div>

<svg class="connectors">
  <defs>
    <marker id="crows-one-b" viewBox="0 0 16 16" refX="4" refY="8" markerWidth="12" markerHeight="12" orient="auto-start-reverse">
      <line x1="4" y1="1" x2="4" y2="15" stroke="#1D4ED8" stroke-width="1.8"/>
      <line x1="9" y1="1" x2="9" y2="15" stroke="#1D4ED8" stroke-width="1.8"/>
    </marker>
    <marker id="crows-zero-many-b" viewBox="0 0 24 16" refX="22" refY="8" markerWidth="16" markerHeight="12" orient="auto-start-reverse">
      <circle cx="5" cy="8" r="3.5" fill="#FFFFFF" stroke="#1D4ED8" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="8" stroke="#1D4ED8" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="2" stroke="#1D4ED8" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="14" stroke="#1D4ED8" stroke-width="1.8"/>
    </marker>
    <marker id="crows-one-many-b" viewBox="0 0 24 16" refX="22" refY="8" markerWidth="16" markerHeight="12" orient="auto-start-reverse">
      <line x1="5" y1="1" x2="5" y2="15" stroke="#1D4ED8" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="8" stroke="#1D4ED8" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="2" stroke="#1D4ED8" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="14" stroke="#1D4ED8" stroke-width="1.8"/>
    </marker>
  </defs>

  <!-- Users (1) -> Tokens (0..*) -->
  <path class="edge-line" d="M 300 140 L 360 140" marker-start="url(#crows-one-b)" marker-end="url(#crows-zero-many-b)"/>
  <rect x="305" y="128" width="50" height="13" fill="#FFF"/>
  <text class="edge-label" x="307" y="138">user_id</text>
  <text class="cardinality-badge" x="305" y="155">1</text>
  <text class="cardinality-badge" x="340" y="155">0..*</text>

  <!-- Users (1) -> Notifs (0..*) -->
  <path class="edge-line" d="M 300 115 L 330 115 L 330 65 L 710 65 L 710 130 L 740 130" marker-start="url(#crows-one-b)" marker-end="url(#crows-zero-many-b)"/>
  <rect x="490" y="58" width="80" height="13" fill="#FFF"/>
  <text class="edge-label" x="492" y="68">user_id -&gt; id</text>
  <text class="cardinality-badge" x="305" y="110">1</text>
  <text class="cardinality-badge" x="715" y="125">0..*</text>

  <!-- Res (1) -> Messages (0..*) -->
  <path class="edge-line" d="M 300 370 L 360 370 L 360 410" marker-start="url(#crows-one-b)" marker-end="url(#crows-zero-many-b)"/>
  <rect x="305" y="358" width="50" height="13" fill="#FFF"/>
  <text class="edge-label" x="307" y="368">res_id</text>
  <text class="cardinality-badge" x="305" y="385">1</text>
  <text class="cardinality-badge" x="345" y="405">0..*</text>

  <!-- Res (1) -> Calls (0..*) -->
  <path class="edge-line" d="M 300 420 L 330 420 L 330 610 L 710 610 L 710 460 L 740 460" marker-start="url(#crows-one-b)" marker-end="url(#crows-zero-many-b)"/>
  <rect x="490" y="603" width="95" height="13" fill="#FFF"/>
  <text class="edge-label" x="492" y="613">reservation_id</text>
  <text class="cardinality-badge" x="305" y="435">1</text>
  <text class="cardinality-badge" x="715" y="455">0..*</text>

  <!-- Calls (1) -> Signals (1..*) [IDENTIFYING STREAM] -->
  <path class="edge-line" d="M 1070 440 L 1120 440" marker-start="url(#crows-one-b)" marker-end="url(#crows-one-many-b)"/>
  <rect x="1072" y="428" width="45" height="13" fill="#FFF"/>
  <text class="edge-label" x="1074" y="438">call_id</text>
  <text class="cardinality-badge" x="1072" y="455">1</text>
  <text class="cardinality-badge" x="1102" y="455">1..*</text>
</svg>
</body></html>
"""
    f14_html = os.path.join(workspace_path, 'scratch', 'fig14_comm.html')
    f14_png = os.path.join(workspace_path, 'fig14_communications_notifications_database.png')
    with open(f14_html, 'w', encoding='utf-8') as f:
        f.write(html14)
    subprocess.run([chrome_path, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=2', '--window-size=1600,750', f'--screenshot={f14_png}', f14_html], check=True)
    crop_and_save_300dpi(f14_png)

    # 2. FIG 15: SECURITY AUDIT & SCANNER TELEMETRY
    html15 = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{base_css}
body {{ width: 1560px; height: 750px; padding: 25px; }}
.main-header h1 {{ font-size: 22px; color: #0F766E; }}
.main-header p {{ font-size: 12px; color: #475569; margin-top: 3px; }}
.edge-line {{ stroke: #0D9488; }}
.cardinality-badge {{ fill: #0D9488; }}
.legend-symbol {{ color: #0D9488; }}
</style></head>
<body>
<div class="main-header" style="position: absolute; top: 25px; left: 40px;">
  <h1>Figure 15. E-Parada Security Audit, Scanner Telemetry & Support Subsystem (Crow's Foot ERD)</h1>
  <p>Administrative audit trail, QR entrance/exit verification telemetry, and help desk support.</p>
</div>

<div class="table-card" style="left: 40px; top: 90px; width: 250px; border: 1px solid #475569;">
  <div class="table-title" style="background:#475569;">Users (Core Stub)</div><table>{render_rows(users_stub)}</table>
</div>
<div class="table-card" style="left: 40px; top: 270px; width: 250px; border: 1px solid #475569;">
  <div class="table-title" style="background:#475569;">Reservations (Core Stub)</div><table>{render_rows(res_stub)}</table>
</div>
<div class="table-card" style="left: 40px; top: 450px; width: 250px; border: 1px solid #475569;">
  <div class="table-title" style="background:#475569;">Parking Spaces (Stub)</div><table>{render_rows(spaces_stub)}</table>
</div>

<div class="table-card" style="left: 350px; top: 90px; width: 360px; border: 1px solid #0D9488;">
  <div class="table-title" style="background:#0D9488;">Activity Logs (Admin Audit Trail)</div><table>{render_rows(activity_rows)}</table>
</div>

<div class="table-card" style="left: 770px; top: 90px; width: 340px; border: 1px solid #0D9488;">
  <div class="table-title" style="background:#0D9488;">Support Requests (Help Desk)</div><table>{render_rows(support_rows)}</table>
</div>

<div class="table-card" style="left: 350px; top: 440px; width: 400px; border: 1px solid #0D9488;">
  <div class="table-title" style="background:#0D9488;">QR Transaction Logs (Scanner Telemetry)</div><table>{render_rows(qr_rows[:11] + [('...', '10 more fields')])}</table>
</div>

<!-- Legend -->
<div class="legend-box">
  <div class="legend-title">Crow's Foot Cardinalities:</div>
  <div class="legend-item"><span class="legend-symbol">||</span> Mandatory One (1)</div>
  <div class="legend-item"><span class="legend-symbol">o|</span> Optional One (0..1)</div>
  <div class="legend-item"><span class="legend-symbol">&gt;o</span> Optional Many (0..*)</div>
</div>

<svg class="connectors">
  <defs>
    <marker id="crows-one-t" viewBox="0 0 16 16" refX="4" refY="8" markerWidth="12" markerHeight="12" orient="auto-start-reverse">
      <line x1="4" y1="1" x2="4" y2="15" stroke="#0D9488" stroke-width="1.8"/>
      <line x1="9" y1="1" x2="9" y2="15" stroke="#0D9488" stroke-width="1.8"/>
    </marker>
    <marker id="crows-zero-one-t" viewBox="0 0 20 16" refX="16" refY="8" markerWidth="14" markerHeight="12" orient="auto-start-reverse">
      <circle cx="5" cy="8" r="3.5" fill="#FFFFFF" stroke="#0D9488" stroke-width="1.8"/>
      <line x1="13" y1="1" x2="13" y2="15" stroke="#0D9488" stroke-width="1.8"/>
    </marker>
    <marker id="crows-zero-many-t" viewBox="0 0 24 16" refX="22" refY="8" markerWidth="16" markerHeight="12" orient="auto-start-reverse">
      <circle cx="5" cy="8" r="3.5" fill="#FFFFFF" stroke="#0D9488" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="8" stroke="#0D9488" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="2" stroke="#0D9488" stroke-width="1.8"/>
      <line x1="10" y1="8" x2="22" y2="14" stroke="#0D9488" stroke-width="1.8"/>
    </marker>
  </defs>

  <!-- Users (0..1) -> Activity (0..*) [System actions have null actor] -->
  <path class="edge-line" d="M 290 140 L 350 140" marker-start="url(#crows-zero-one-t)" marker-end="url(#crows-zero-many-t)"/>
  <rect x="295" y="128" width="50" height="13" fill="#FFF"/>
  <text class="edge-label" x="297" y="138">actor_id</text>
  <text class="cardinality-badge" x="295" y="155">0..1</text>
  <text class="cardinality-badge" x="330" y="155">0..*</text>

  <!-- Users (0..1) -> Support (0..*) [Guest tickets have null user] -->
  <path class="edge-line" d="M 290 115 L 320 115 L 320 65 L 740 65 L 740 130 L 770 130" marker-start="url(#crows-zero-one-t)" marker-end="url(#crows-zero-many-t)"/>
  <rect x="500" y="58" width="60" height="13" fill="#FFF"/>
  <text class="edge-label" x="502" y="68">user_id -&gt; id</text>
  <text class="cardinality-badge" x="295" y="110">0..1</text>
  <text class="cardinality-badge" x="745" y="125">0..*</text>

  <!-- Res (0..1) -> QR (0..*) -->
  <path class="edge-line" d="M 290 320 L 320 320 L 320 480 L 350 480" marker-start="url(#crows-zero-one-t)" marker-end="url(#crows-zero-many-t)"/>
  <rect x="295" y="380" width="50" height="13" fill="#FFF"/>
  <text class="edge-label" x="297" y="390">res_id</text>
  <text class="cardinality-badge" x="295" y="315">0..1</text>
  <text class="cardinality-badge" x="330" y="475">0..*</text>

  <!-- Spaces (0..1) -> QR (0..*) -->
  <path class="edge-line" d="M 290 500 L 350 500" marker-start="url(#crows-zero-one-t)" marker-end="url(#crows-zero-many-t)"/>
  <rect x="295" y="488" width="50" height="13" fill="#FFF"/>
  <text class="edge-label" x="297" y="498">space_id</text>
  <text class="cardinality-badge" x="295" y="515">0..1</text>
  <text class="cardinality-badge" x="330" y="515">0..*</text>
</svg>
</body></html>
"""
    f15_html = os.path.join(workspace_path, 'scratch', 'fig15_audit.html')
    f15_png = os.path.join(workspace_path, 'fig15_security_telemetry_database.png')
    with open(f15_html, 'w', encoding='utf-8') as f:
        f.write(html15)
    subprocess.run([chrome_path, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=2', '--window-size=1600,800', f'--screenshot={f15_png}', f15_html], check=True)
    crop_and_save_300dpi(f15_png)

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
        shutil.copy2(png_path, f'{artifact_dir}/{os.path.basename(png_path)}')
        print(f'Updated artifact: {os.path.basename(png_path)}')

if __name__ == '__main__':
    create_full_system_drawio()
