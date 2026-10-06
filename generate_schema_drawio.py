import xml.etree.ElementTree as ET
from xml.dom import minidom
import os

def create_database_schema_drawio():
    # Root mxfile
    mxfile = ET.Element('mxfile', host='Electron', agent='Mozilla/5.0', version='21.6.8', type='device')
    diagram = ET.SubElement(mxfile, 'diagram', id='schema_diagram', name='E-Parada PostgreSQL Database Schema')
    mxGraphModel = ET.SubElement(diagram, 'mxGraphModel', 
                                 dx='2400', dy='1600', grid='1', gridSize='10', guides='1', 
                                 tooltips='1', connect='1', arrows='1', fold='1', page='1', 
                                 pageScale='1', pageWidth='2900', pageHeight='1900', math='0', shadow='1')
    root = ET.SubElement(mxGraphModel, 'root')
    
    # Base cells
    ET.SubElement(root, 'mxCell', id='0')
    ET.SubElement(root, 'mxCell', id='1', parent='0')

    # Helper function to add vertex
    def add_vertex(cell_id, value, style, x, y, w, h):
        cell = ET.SubElement(root, 'mxCell', id=cell_id, value=value, style=style, vertex='1', parent='1')
        geo = ET.SubElement(cell, 'mxGeometry', x=str(x), y=str(y), width=str(w), height=str(h))
        geo.set('as', 'geometry')
        return cell

    # Helper function to add edge
    def add_edge(edge_id, source_id, target_id, style, label='', exit_x=None, exit_y=None, entry_x=None, entry_y=None):
        cell = ET.SubElement(root, 'mxCell', id=edge_id, value=label, style=style, edge='1', parent='1', source=source_id, target=target_id)
        geo = ET.SubElement(cell, 'mxGeometry', relative='1')
        geo.set('as', 'geometry')
        if exit_x is not None and exit_y is not None:
            cell.set('style', f"{style}exitX={exit_x};exitY={exit_y};")
        if entry_x is not None and entry_y is not None:
            curr_style = cell.get('style', style)
            cell.set('style', f"{curr_style}entryX={entry_x};entryY={entry_y};")
        return cell

    # -------------------------------------------------------------------------
    # STYLES DEFINITION
    # -------------------------------------------------------------------------
    header_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#0F172A;strokeColor=#1E293B;fontColor=#FFFFFF;fontSize=18;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    legend_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#CBD5E1;fontColor=#1E293B;fontSize=11;align=left;verticalAlign=top;shadow=1;spacing=10;"
    
    # Entity Table Styles by Domain
    def table_style(header_color, border_color):
        return f"swimlane;fontStyle=1;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=32;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;whiteSpace=wrap;html=1;fillColor={header_color};strokeColor={border_color};strokeWidth=2;fontColor=#FFFFFF;fontSize=13;shadow=1;"

    body_style = "text;strokeColor=none;fillColor=#FFFFFF;align=left;verticalAlign=top;spacingLeft=8;spacingRight=8;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;whiteSpace=wrap;html=1;fontSize=11;fontColor=#1E293B;"
    body_alt_style = "text;strokeColor=none;fillColor=#F8FAFC;align=left;verticalAlign=top;spacingLeft=8;spacingRight=8;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;whiteSpace=wrap;html=1;fontSize=11;fontColor=#1E293B;"

    # Relationship Edges (Crow's foot / Relational line style)
    fk_edge_style = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#3B82F6;strokeWidth=2;fontSize=10;fontColor=#1D4ED8;endArrow=ERmany;endFill=0;startArrow=ERone;startFill=0;"
    fk_core_style = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#6366F1;strokeWidth=2.5;fontSize=10;fontColor=#4338CA;endArrow=ERmany;endFill=0;startArrow=ERone;startFill=0;"
    fk_audit_style = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;dashed=1;strokeColor=#64748B;strokeWidth=1.5;fontSize=10;fontColor=#475569;endArrow=ERmany;endFill=0;startArrow=ERone;startFill=0;"

    # -------------------------------------------------------------------------
    # 1. TOP HEADER & METADATA BANNER
    # -------------------------------------------------------------------------
    title_text = (
        '<b>E-PARADA: PRODUCTION RELATIONAL DATABASE SCHEMA &amp; ENTITY-RELATIONSHIP ARCHITECTURE</b><br/>'
        '<span style="font-size: 12px; font-weight: normal; color: #94A3B8;">'
        'Engine: Supabase Managed PostgreSQL 15+ (AWS Seoul ap-northeast-2) • Native BOOLEAN, JSONB &amp; TIMESTAMPTZ • Row-Level Security (RLS) Ready'
        '</span>'
    )
    add_vertex('hdr_title', title_text, header_style, 50, 40, 2760, 65)

    legend_text = (
        '<b>PostgreSQL Standards Legend &amp; Integrity Rules:</b><br/>'
        '• <b>PK:</b> Primary Key (BIGSERIAL / BIGINT IDENTITY)<br/>'
        '• <b>FK:</b> Foreign Key with Cascading Rules<br/>'
        '• <b>BOOLEAN:</b> Native PostgreSQL logical type (replaces legacy MySQL tinyint)<br/>'
        '• <b>JSONB:</b> Binary JSON for dynamic vehicle type arrays &amp; tariff matrices<br/>'
        '• <b>TIMESTAMPTZ:</b> Microsecond timestamp with timezone (Asia/Manila)<br/>'
        '• <b>layout_x / layout_z:</b> 2D Cartesian floor-plan grid coordinates (Aisle &amp; Lane)'
    )
    add_vertex('legend_box', legend_text, legend_style, 50, 120, 480, 130)

    # -------------------------------------------------------------------------
    # 2. ENTITY TABLES (TABLE DATA)
    # -------------------------------------------------------------------------

    # --- TABLE 1: USERS (Blue) ---
    t_users = (
        '<b>users</b> (Core Identity &amp; Auth)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>name</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>email</b> : VARCHAR(255) [UNIQUE]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>email_verified_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>password</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>role</b> : VARCHAR(20) [driver|owner|admin]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>contact_number</b> : VARCHAR(20)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>verification_status</b> : VARCHAR(20) [pending|approved|rejected]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>id_image_path</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>id_back_image_path</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>gcash_number</b> : VARCHAR(20)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>can_reserve</b> : <b>BOOLEAN</b> [DEFAULT true]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>can_manage_parking_spaces</b> : <b>BOOLEAN</b> [DEFAULT false]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_users', t_users, table_style('#1E40AF', '#1D4ED8'), 50, 280, 420, 320)

    # --- TABLE 2: VEHICLES (Blue/Sky) ---
    t_vehicles = (
        '<b>vehicles</b> (Driver Fleet &amp; OCR)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>make</b> : VARCHAR(100)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>model</b> : VARCHAR(100)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>color</b> : VARCHAR(50)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>plate_number</b> : VARCHAR(20) [UNIQUE]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>vehicle_type</b> : VARCHAR(20) [sedan|suv|van|motorcycle]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>vehicle_photo_path</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>plate_scan_status</b> : VARCHAR(20) [SUCCESS|FAILED|MANUAL]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>status</b> : VARCHAR(20) [pending|approved|rejected]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>rejection_reason</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_vehicles', t_vehicles, table_style('#0284C7', '#0369A1'), 520, 280, 400, 290)

    # --- TABLE 3: PARKING_SPACES (Emerald) ---
    t_spaces = (
        '<b>parking_spaces</b> (Facility Profile &amp; Policies)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id (Owner)]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>space_name</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>address</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>latitude</b> : NUMERIC(10,8)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>longitude</b> : NUMERIC(11,8)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>vehicle_types</b> : <b>JSONB</b> [Compatible Types Array]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>dimensions_sqm</b> : NUMERIC(8,2)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>description</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>is_open_24_hours</b> : <b>BOOLEAN</b> [DEFAULT true]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>opening_time</b> : TIME<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>closing_time</b> : TIME<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>is_available</b> : <b>BOOLEAN</b> [DEFAULT true]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>approval_status</b> : VARCHAR(20) [pending|approved|rejected]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>hourly_rate</b> : NUMERIC(10,2)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>vehicle_hourly_rates</b> : <b>JSONB</b> [Rate Matrix]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>total_slots</b> : INT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>overstay_grace_minutes</b> : INT [DEFAULT 15]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>overstay_rate</b> : NUMERIC(10,2)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>rating</b> : NUMERIC(3,2) [Cached Average]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_spaces', t_spaces, table_style('#059669', '#047857'), 980, 280, 420, 420)

    # --- TABLE 4: PARKING_SLOTS (Green/Teal) ---
    t_slots = (
        '<b>parking_slots</b> (2D Floor Plan Grid Entities)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  parking_space_id</b> : BIGINT [REF: parking_spaces.id]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>slot_number</b> : VARCHAR(50)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>supported_vehicle_types</b> : <b>JSONB</b><br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>is_available</b> : <b>BOOLEAN</b> [DEFAULT true]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>layout_x</b> : NUMERIC(8,2) [2D Aisle X-Offset]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>layout_z</b> : NUMERIC(8,2) [2D Lane Y-Offset]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>layout_rotation</b> : NUMERIC(5,2) [2D Slot Angle]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_slots', t_slots, table_style('#0D9488', '#0F766E'), 1460, 280, 390, 250)

    # --- TABLE 5: RESERVATIONS (Core Hub - Indigo) ---
    t_reservations = (
        '<b>reservations</b> (Central Transaction &amp; State Engine)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>reservation_code</b> : VARCHAR(20) [UNIQUE, RES-XXXX]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id (Driver)]<br/>'
        '<b>FK  vehicle_id</b> : BIGINT [REF: vehicles.id]<br/>'
        '<b>FK  parking_space_id</b> : BIGINT [REF: parking_spaces.id]<br/>'
        '<b>FK  parking_slot_id</b> : BIGINT [REF: parking_slots.id]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>reservation_date</b> : DATE<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>end_date</b> : DATE<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>start_time</b> : TIME<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>end_time</b> : TIME<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>status</b> : VARCHAR(20) [pending|approved|checked_in|completed|cancelled|rejected]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>payment_method</b> : VARCHAR(20) [cash|paymongo]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>payment_status</b> : VARCHAR(20) [pending|paid|refunded]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>total_fee</b> : NUMERIC(10,2)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>overstay_fee</b> : NUMERIC(10,2) [DEFAULT 0.00]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>time_in</b> : TIMESTAMPTZ [Checkpoint Scan In]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>time_out</b> : TIMESTAMPTZ [Checkpoint Scan Out]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>paid_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>dispute_status</b> : VARCHAR(20) [none|pending|resolved]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>cancellation_reason</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_reservations', t_reservations, table_style('#4338CA', '#3730A3'), 520, 680, 420, 480)

    # --- TABLE 6: QR_TRANSACTION_LOGS (Cyan/Blue) ---
    t_qr_logs = (
        '<b>qr_transaction_logs</b> (Checkpoint Gate Auditing)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  reservation_id</b> : BIGINT [REF: reservations.id]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id (Scanner/Guard)]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>event</b> : VARCHAR(20) [ENTRY|EXIT]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>hmac_hash</b> : VARCHAR(64) [SHA-256 Digest]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>was_successful</b> : <b>BOOLEAN</b><br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>reason</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>ip_address</b> : VARCHAR(45)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_qr_logs', t_qr_logs, table_style('#0891B2', '#0E7490'), 1020, 780, 400, 220)

    # --- TABLE 7: PARKING_SPACE_FEEDBACKS (Amber) ---
    t_feedbacks = (
        '<b>parking_space_feedbacks</b> (Ratings &amp; Reviews)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  reservation_id</b> : BIGINT [REF: reservations.id]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id (Driver)]<br/>'
        '<b>FK  parking_space_id</b> : BIGINT [REF: parking_spaces.id]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>rating</b> : INT [1 to 5 Stars]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>comment</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>is_moderated</b> : <b>BOOLEAN</b> [DEFAULT false]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_feedbacks', t_feedbacks, table_style('#D97706', '#B45309'), 1500, 680, 400, 220)

    # --- TABLE 8: SUPPORT_REQUESTS (Orange) ---
    t_support = (
        '<b>support_requests</b> (Dispute Resolution Tickets)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id]<br/>'
        '<b>FK  reservation_id</b> : BIGINT [REF: reservations.id, Nullable]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>subject</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>message</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>status</b> : VARCHAR(20) [open|in_progress|resolved]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>admin_notes</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_support', t_support, table_style('#EA580C', '#C2410C'), 520, 1260, 420, 220)

    # --- TABLE 9: NOTIFICATIONS (Violet) ---
    t_notifications = (
        '<b>notifications</b> (In-App &amp; Bell Alerts)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>title</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>message</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>type</b> : VARCHAR(50)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>link</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>dedupe_key</b> : VARCHAR(100)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>read_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_notifications', t_notifications, table_style('#7C3AED', '#6D28D9'), 50, 680, 420, 240)

    # --- TABLE 10: USER_DEVICE_TOKENS (Purple) ---
    t_tokens = (
        '<b>user_device_tokens</b> (FCM Push Registrations)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>token</b> : TEXT [Firebase FCM Token]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>device_type</b> : VARCHAR(20) [android|ios|web]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>updated_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_tokens', t_tokens, table_style('#9333EA', '#7E22CE'), 1960, 280, 380, 170)

    # --- TABLE 11: ACTIVITY_LOGS (Slate / Security) ---
    t_audit = (
        '<b>activity_logs</b> (Immutable Audit Trail)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  user_id</b> : BIGINT [REF: users.id, Nullable]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>action</b> : VARCHAR(255)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>ip_address</b> : VARCHAR(45)<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>user_agent</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>payload</b> : <b>JSONB</b><br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_audit', t_audit, table_style('#475569', '#334155'), 50, 1000, 420, 200)

    # --- TABLE 12: RESERVATION_MESSAGES (Pink/Rose) ---
    t_messages = (
        '<b>reservation_messages</b> (In-App Driver/Host Chat)<hr/>'
        '<b>PK  id</b> : BIGINT [IDENTITY]<br/>'
        '<b>FK  reservation_id</b> : BIGINT [REF: reservations.id]<br/>'
        '<b>FK  sender_id</b> : BIGINT [REF: users.id]<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>message</b> : TEXT<br/>'
        '&nbsp;&nbsp;&nbsp;&nbsp;<b>created_at</b> : TIMESTAMPTZ'
    )
    add_vertex('tbl_messages', t_messages, table_style('#E11D48', '#BE123C'), 1960, 680, 380, 170)

    # -------------------------------------------------------------------------
    # 3. FOREIGN KEY RELATIONSHIP EDGES
    # -------------------------------------------------------------------------
    # 1. users -> vehicles (1:N)
    add_edge('rel_usr_veh', 'tbl_users', 'tbl_vehicles', fk_edge_style, label='1 : N (Owns Fleet)', exit_x=1, exit_y=0.2, entry_x=0, entry_y=0.2)

    # 2. users -> parking_spaces (1:N Owner)
    add_edge('rel_usr_spc', 'tbl_users', 'tbl_spaces', fk_edge_style, label='1 : N (Hosts Facilities)', exit_x=1, exit_y=0.1, entry_x=0, entry_y=0.1)

    # 3. parking_spaces -> parking_slots (1:N)
    add_edge('rel_spc_slt', 'tbl_spaces', 'tbl_slots', fk_edge_style, label='1 : N (Contains Slots)', exit_x=1, exit_y=0.25, entry_x=0, entry_y=0.25)

    # 4. users -> reservations (1:N Driver)
    add_edge('rel_usr_res', 'tbl_users', 'tbl_reservations', fk_core_style, label='1 : N (Books)', exit_x=0.8, exit_y=1, entry_x=0, entry_y=0.2)

    # 5. vehicles -> reservations (1:N Vehicle)
    add_edge('rel_veh_res', 'tbl_vehicles', 'tbl_reservations', fk_core_style, label='1 : N (Staged Vehicle)', exit_x=0.5, exit_y=1, entry_x=0.3, entry_y=0)

    # 6. parking_spaces -> reservations (1:N Target Space)
    add_edge('rel_spc_res', 'tbl_spaces', 'tbl_reservations', fk_core_style, label='1 : N (Target Facility)', exit_x=0.2, exit_y=1, entry_x=0.7, entry_y=0)

    # 7. parking_slots -> reservations (1:N Assigned Slot)
    add_edge('rel_slt_res', 'tbl_slots', 'tbl_reservations', fk_core_style, label='1 : N (Assigned Slot)', exit_x=0.1, exit_y=1, entry_x=0.9, entry_y=0)

    # 8. reservations -> qr_transaction_logs (1:N Scans)
    add_edge('rel_res_qr', 'tbl_reservations', 'tbl_qr_logs', fk_core_style, label='1 : N (Scan Checkpoints)', exit_x=1, exit_y=0.4, entry_x=0, entry_y=0.3)

    # 9. reservations -> parking_space_feedbacks (1:1/1:N Review)
    add_edge('rel_res_rev', 'tbl_reservations', 'tbl_feedbacks', fk_core_style, label='1 : 1 (Rates &amp; Reviews)', exit_x=1, exit_y=0.2, entry_x=0, entry_y=0.4)

    # 10. reservations -> support_requests (1:N Dispute)
    add_edge('rel_res_sup', 'tbl_reservations', 'tbl_support', fk_edge_style, label='1 : N (Dispute Ticket)', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)

    # 11. reservations -> reservation_messages (1:N Chat)
    add_edge('rel_res_msg', 'tbl_reservations', 'tbl_messages', fk_edge_style, label='1 : N (Session Chat)', exit_x=1, exit_y=0.1, entry_x=0, entry_y=0.4)

    # 12. users -> notifications (1:N Alerts)
    add_edge('rel_usr_not', 'tbl_users', 'tbl_notifications', fk_audit_style, label='1 : N (Receives Alerts)', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)

    # 13. users -> user_device_tokens (1:N FCM Devices)
    add_edge('rel_usr_tok', 'tbl_users', 'tbl_tokens', fk_audit_style, label='1 : N (FCM Device Tokens)', exit_x=0.5, exit_y=0, entry_x=0.5, entry_y=0)

    # 14. users -> activity_logs (1:N Audit Logs)
    add_edge('rel_usr_aud', 'tbl_notifications', 'tbl_audit', fk_audit_style, label='1 : N (Audit Trail)', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)

    # -------------------------------------------------------------------------
    # 4. XML EXPORT & FILE CREATION
    # -------------------------------------------------------------------------
    rough_string = ET.tostring(mxfile, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    pretty_xml = reparsed.toprettyxml(indent="  ", encoding="utf-8").decode("utf-8")
    pretty_xml = "\n".join([line for line in pretty_xml.split("\n") if line.strip()])

    workspace_path = r'c:\Users\kimch\e_parada_mobile'
    file_path_drawio = os.path.join(workspace_path, 'e_parada_database_schema.drawio')
    file_path_xml = os.path.join(workspace_path, 'e_parada_database_schema.drawio.xml')

    with open(file_path_drawio, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
        
    with open(file_path_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)

    print(f"Successfully generated {file_path_drawio} and {file_path_xml}")

if __name__ == '__main__':
    create_database_schema_drawio()
