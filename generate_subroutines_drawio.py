import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import os

def create_subroutines_drawio():
    mxfile = ET.Element('mxfile', {
        'host': 'app.diagrams.net',
        'modified': '2026-08-30T10:15:00.000Z',
        'agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Antigravity/2.0',
        'etag': 'e-parada-subroutines-v1',
        'version': '21.0.0',
        'type': 'device'
    })
    
    diagram = ET.SubElement(mxfile, 'diagram', {
        'id': 'e_parada_subroutines_flowchart',
        'name': 'E-Parada Core Subroutines Flowchart'
    })
    
    graph_model = ET.SubElement(diagram, 'mxGraphModel', {
        'dx': '2400',
        'dy': '2000',
        'grid': '1',
        'gridSize': '10',
        'guides': '1',
        'tooltips': '1',
        'connect': '1',
        'arrows': '1',
        'fold': '1',
        'page': '1',
        'pageScale': '1',
        'pageWidth': '2660',
        'pageHeight': '5200',
        'math': '0',
        'shadow': '0'
    })
    
    root = ET.SubElement(graph_model, 'root')
    
    # Base cells
    ET.SubElement(root, 'mxCell', {'id': '0'})
    ET.SubElement(root, 'mxCell', {'id': '1', 'parent': '0'})

    # Helper function for vertices
    def add_vertex(cell_id, value, style, x, y, width, height, parent='1'):
        cell = ET.SubElement(root, 'mxCell', {
            'id': str(cell_id),
            'value': value,
            'style': style,
            'vertex': '1',
            'parent': str(parent)
        })
        ET.SubElement(cell, 'mxGeometry', {
            'x': str(x),
            'y': str(y),
            'width': str(width),
            'height': str(height),
            'as': 'geometry'
        })
        return cell

    # Helper function for edges
    def add_edge(edge_id, source_id, target_id, style, label='', exit_x=None, exit_y=None, entry_x=None, entry_y=None):
        attribs = {
            'id': str(edge_id),
            'value': label,
            'style': style,
            'edge': '1',
            'parent': '1',
            'source': str(source_id),
            'target': str(target_id)
        }
        cell = ET.SubElement(root, 'mxCell', attribs)
        ET.SubElement(cell, 'mxGeometry', {
            'relative': '1',
            'as': 'geometry'
        })
        if exit_x is not None or exit_y is not None:
            cell.set('style', cell.get('style') + f';exitX={exit_x};exitY={exit_y};exitDx=0;exitDy=0;')
        if entry_x is not None or entry_y is not None:
            cell.set('style', cell.get('style') + f';entryX={entry_x};entryY={entry_y};entryDx=0;entryDy=0;')
        return cell

    # STYLES DEFINITION
    title_style = "rounded=0;whiteSpace=wrap;html=1;fillColor=#0F172A;strokeColor=#1E293B;fontColor=#FFFFFF;fontSize=18;fontStyle=1;align=center;verticalAlign=middle;spacing=5;"
    
    # Individual Swimlane Styles
    lane_sub_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#1E293B;strokeColor=#334155;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F8FAFC;"
    lane_driver_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#1E3A8A;strokeColor=#3B82F6;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F0F7FF;"
    lane_api_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#312E81;strokeColor=#6366F1;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F5F3FF;"
    lane_owner_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#064E3B;strokeColor=#10B981;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#ECFDF5;"
    lane_admin_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#701A75;strokeColor=#D946EF;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#FDF4FF;"
    lane_db_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#1F2937;strokeColor=#4B5563;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F9FAFB;"

    # Subroutine Banner Styles (Color coded per Subroutine)
    banner_s1 = "rounded=1;whiteSpace=wrap;html=1;fillColor=#DBEAFE;strokeColor=#3B82F6;fontColor=#1E40AF;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_s2 = "rounded=1;whiteSpace=wrap;html=1;fillColor=#D1FAE5;strokeColor=#10B981;fontColor=#065F46;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_s3 = "rounded=1;whiteSpace=wrap;html=1;fillColor=#EDE9FE;strokeColor=#8B5CF6;fontColor=#5B21B6;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_s4 = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEF3C7;strokeColor=#F59E0B;fontColor=#92400E;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_s5 = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FCE7F3;strokeColor=#EC4899;fontColor=#9D174D;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_s6 = "rounded=1;whiteSpace=wrap;html=1;fillColor=#CCFBF1;strokeColor=#14B8A6;fontColor=#115E59;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_s7 = "rounded=1;whiteSpace=wrap;html=1;fillColor=#E0E7FF;strokeColor=#6366F1;fontColor=#3730A3;fontSize=12;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    start_style = "ellipse;whiteSpace=wrap;html=1;fillColor=#22C55E;strokeColor=#16A34A;fontColor=#FFFFFF;fontStyle=1;fontSize=12;align=center;verticalAlign=middle;shadow=1;"
    end_style = "ellipse;whiteSpace=wrap;html=1;fillColor=#EF4444;strokeColor=#DC2626;fontColor=#FFFFFF;fontStyle=1;fontSize=12;align=center;verticalAlign=middle;shadow=1;"
    
    # Process / I/O / Decision Styles
    driver_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#3B82F6;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    driver_input_style = "shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;fixedSize=1;fillColor=#EFF6FF;strokeColor=#2563EB;strokeWidth=1.5;fontColor=#1E3A8A;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    driver_decision_style = "rhombus;whiteSpace=wrap;html=1;fillColor=#DBEAFE;strokeColor=#3B82F6;strokeWidth=1.5;fontColor=#1E40AF;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    api_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#6366F1;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    api_decision_style = "rhombus;whiteSpace=wrap;html=1;fillColor=#FEF08A;strokeColor=#EAB308;strokeWidth=1.5;fontColor=#713F12;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    
    owner_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#10B981;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    owner_input_style = "shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;fixedSize=1;fillColor=#ECFDF5;strokeColor=#059669;strokeWidth=1.5;fontColor=#064E3B;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    owner_decision_style = "rhombus;whiteSpace=wrap;html=1;fillColor=#A7F3D0;strokeColor=#10B981;strokeWidth=1.5;fontColor=#064E3B;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    admin_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#D946EF;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    admin_decision_style = "rhombus;whiteSpace=wrap;html=1;fillColor=#F5D0FE;strokeColor=#C026D3;strokeWidth=1.5;fontColor=#701A75;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    db_style = "shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#F1F5F9;strokeColor=#475569;strokeWidth=1.5;fontColor=#0F172A;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    ext_service_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#E2E8F0;strokeColor=#64748B;strokeWidth=1.5;fontColor=#0F172A;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    # Connectors
    edge_flow = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#334155;strokeWidth=1.5;fontSize=11;fontColor=#1E293B;"
    edge_yes = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#16A34A;strokeWidth=2;fontSize=11;fontColor=#16A34A;fontStyle=1;"
    edge_no = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#DC2626;strokeWidth=2;fontSize=11;fontColor=#DC2626;fontStyle=1;"
    edge_sync = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;dashed=1;strokeColor=#6366F1;strokeWidth=1.5;fontSize=10;fontColor=#4338CA;"

    # 1. Canvas Top Header
    add_vertex('hdr_title', 
               '<b>E-PARADA: CROSS-FUNCTIONAL SYSTEM SUBROUTINES &amp; MODULE WORKFLOWS</b><br/><span style="font-size: 12px; font-weight: normal; color: #94A3B8;">Detailed procedural logic for core platform subroutines: Auth, Availability Engine, QR Checkpoint, Overstay Billing, RTC &amp; Auditing</span>', 
               title_style, 0, 0, 2660, 60)

    # 2. Main Swimlanes (6 Columns)
    lane_w_sub = 240
    lane_w_driver = 480
    lane_w_api = 520
    lane_w_owner = 460
    lane_w_admin = 460
    lane_w_db = 500
    lane_h = 5100

    x_sub = 0
    x_driver = x_sub + lane_w_sub       # 240
    x_api = x_driver + lane_w_driver    # 720
    x_owner = x_api + lane_w_api        # 1240
    x_admin = x_owner + lane_w_owner    # 1700
    x_db = x_admin + lane_w_admin       # 2160

    add_vertex('lane_sub', 'CORE SUBROUTINES', lane_sub_style, x_sub, 60, lane_w_sub, lane_h)
    add_vertex('lane_driver', 'DRIVER MOBILE CLIENT (FLUTTER)', lane_driver_style, x_driver, 60, lane_w_driver, lane_h)
    add_vertex('lane_api', 'LARAVEL CONTROLLER &amp; API SUBROUTINE', lane_api_style, x_api, 60, lane_w_api, lane_h)
    add_vertex('lane_owner', 'SPACE PROVIDER (HOST)', lane_owner_style, x_owner, 60, lane_w_owner, lane_h)
    add_vertex('lane_admin', 'SYSTEM ADMIN CONSOLE', lane_admin_style, x_admin, 60, lane_w_admin, lane_h)
    add_vertex('lane_db', 'DATABASE &amp; EXTERNAL SERVICES', lane_db_style, x_db, 60, lane_w_db, lane_h)

    # =========================================================================
    # SUBROUTINE 1: AUTHENTICATION, SESSION & KYC PIPELINE
    # =========================================================================
    add_vertex('s1_banner', '<b>SUBROUTINE 1</b><br/><br/><b>AUTH &amp; KYC<br/>PIPELINE</b><br/><br/><span style="font-size:10px;color:#1E40AF;">• Multipart Payload Parsing<br/>• Bcrypt Password Hashing<br/>• Sanctum Token Issuance<br/>• Secure KYC Storage<br/>• Admin Approval Action</span>', banner_s1, 15, 100, 210, 680)

    add_vertex('s1_start', 'SUB_AUTH_KYC (Start)', start_style, 400, 90, 160, 45)
    
    add_vertex('s1_drv_input', '<b>Driver/Host Register Input</b><br/>Provide Credentials + Multipart Uploads<br/>(id_image, vehicle_photo, plate_number)', driver_input_style, 290, 160, 380, 60)

    add_vertex('s1_api_validate', '<b>Subroutine: validatePayload()</b><br/>• Check email uniqueness, regex, required files<br/>• Verify MIME types (jpeg, png, pdf) &lt; 5MB', api_proc_style, 780, 160, 400, 60)

    add_vertex('s1_dec_valid', 'Validation<br/>Passed?', api_decision_style, 900, 245, 160, 70)

    add_vertex('s1_api_err', '<b>Return 422 JSON Errors</b><br/>Send field-specific error messages to client', driver_proc_style, 290, 250, 380, 60)

    add_vertex('s1_api_hash', '<b>Subroutine: persistUserAndFiles()</b><br/>• Hash password via bcrypt(rounds=12)<br/>• Store encrypted private files to storage/app/kyc<br/>• Insert users (verification_status: \'pending\')', api_proc_style, 780, 340, 400, 70)

    add_vertex('s1_db_insert', '<b>Database: users &amp; vehicles</b><br/>INSERT INTO users &amp; INSERT INTO vehicles<br/>with initial quotas &amp; remaining_vehicle_slots=3', db_style, 2220, 335, 380, 75)

    add_vertex('s1_api_token', '<b>Subroutine: issueSanctumToken()</b><br/>$user-&gt;createToken(\'auth_token\')-&gt;plainTextToken<br/>Return 201 JSON { token, user: {...} }', api_proc_style, 780, 435, 400, 65)

    add_vertex('s1_drv_save', '<b>Subroutine: saveSession()</b><br/>Store token &amp; permissions to SharedPreferences', driver_proc_style, 290, 435, 380, 60)

    add_vertex('s1_adm_review', '<b>Admin Subroutine: reviewKYC()</b><br/>Fetch private images &amp; compare ID to vehicle plate', admin_proc_style, 1740, 525, 380, 65)

    add_vertex('s1_dec_adm', 'Approve KYC<br/>Account?', admin_decision_style, 1850, 615, 160, 70)

    add_vertex('s1_api_reject', '<b>[PATCH /admin/users/{id}/reject]</b><br/>Set verification_status=\'rejected\' &amp; dispatch Brevo email', api_proc_style, 780, 620, 400, 60)

    add_vertex('s1_api_approve', '<b>[PATCH /admin/users/{id}/approve]</b><br/>Set verification_status=\'approved\' &amp; dispatch Brevo email', api_proc_style, 780, 705, 400, 60)

    add_vertex('s1_db_update', '<b>Database: Update Permissions</b><br/>UPDATE users SET verification_status=\'approved\'', db_style, 2220, 705, 380, 60)

    add_edge('es1_01', 's1_start', 's1_drv_input', edge_flow)
    add_edge('es1_02', 's1_drv_input', 's1_api_validate', edge_flow)
    add_edge('es1_03', 's1_api_validate', 's1_dec_valid', edge_flow)
    add_edge('es1_04', 's1_dec_valid', 's1_api_err', edge_no, label='No', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('es1_05', 's1_dec_valid', 's1_api_hash', edge_yes, label='Yes', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_edge('es1_06', 's1_api_hash', 's1_db_insert', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es1_07', 's1_api_hash', 's1_api_token', edge_flow)
    add_edge('es1_08', 's1_api_token', 's1_drv_save', edge_flow)
    add_edge('es1_09', 's1_db_insert', 's1_adm_review', edge_sync, label='KYC Queue', exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('es1_10', 's1_adm_review', 's1_dec_adm', edge_flow)
    add_edge('es1_11', 's1_dec_adm', 's1_api_reject', edge_no, label='Reject', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('es1_12', 's1_dec_adm', 's1_api_approve', edge_yes, label='Approve', exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('es1_13', 's1_api_approve', 's1_db_update', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)

    # =========================================================================
    # SUBROUTINE 2: REAL-TIME AVAILABILITY & CONFLICT RESOLUTION ENGINE
    # =========================================================================
    add_vertex('s2_banner', '<b>SUBROUTINE 2</b><br/><br/><b>REAL-TIME<br/>AVAILABILITY &amp;<br/>CONFLICT ENGINE</b><br/><br/><span style="font-size:10px;color:#065F46;">• Operating Hours Verification<br/>• Slot Vehicle Matrix Match<br/>• Overlap Reservation Filter<br/>• Real-Time Slot Locking<br/>• Estimated Fare Calculator</span>', banner_s2, 15, 810, 210, 680)

    add_vertex('s2_start', 'SUB_AVAILABILITY_CHECK (Start)', start_style, 400, 800, 180, 45)

    add_vertex('s2_drv_query', '<b>Driver Request Availability</b><br/>Input: space_id, vehicle_id, start/end date &amp; time<br/>[GET /driver/parking-spaces/{id}/availability]', driver_input_style, 290, 865, 380, 65)

    add_vertex('s2_api_hours', '<b>Subroutine: checkOperatingHours()</b><br/>Verify if target window is within opening/closing hours<br/>(or if space is_open_24_hours=true)', api_proc_style, 780, 865, 400, 65)

    add_vertex('s2_dec_hours', 'Operating<br/>Hours OK?', api_decision_style, 900, 955, 160, 70)

    add_vertex('s2_api_hours_err', '<b>Return Closed Alert</b><br/>Facility is closed during the requested time window', driver_proc_style, 290, 960, 380, 60)

    add_vertex('s2_api_compat', '<b>Subroutine: filterCompatibleSlots()</b><br/>Match vehicle_type against parking_slots.vehicle_types<br/>Extract candidate slot IDs', api_proc_style, 780, 1050, 400, 65)

    add_vertex('s2_db_query_overlap', '<b>Database: Overlapping Reservations</b><br/>SELECT slot_id FROM reservations WHERE space_id=?<br/>AND status IN (\'pending\',\'confirmed\',\'checked_in\')<br/>AND NOT (end_time &lt;= :req_start OR start_time &gt;= :req_end)', db_style, 2220, 1040, 380, 85)

    add_vertex('s2_dec_slot_avail', 'Available<br/>Slot Found?', api_decision_style, 900, 1145, 160, 70)

    add_vertex('s2_api_no_slots', '<b>Return 422 Slot Conflict</b><br/>All compatible slots are booked. Return alternative times', driver_proc_style, 290, 1150, 380, 60)

    add_vertex('s2_api_calc_quote', '<b>Subroutine: calculateEstimatedFee()</b><br/>duration_hours = ceil(end_time - start_time)<br/>total_cost = duration_hours * vehicle_hourly_rate', api_proc_style, 780, 1240, 400, 65)

    add_vertex('s2_drv_display_quote', '<b>Display Available Slots &amp; Cost Quote</b><br/>Driver views available slot list, pricing, and Book CTA', driver_proc_style, 290, 1240, 380, 65)

    add_vertex('s2_api_lock', '<b>Subroutine: createReservationLock()</b><br/>Insert reservation (status: \'pending\') with unique token<br/>Trigger DB row lock / transaction to prevent race conditions', api_proc_style, 780, 1330, 400, 70)

    add_vertex('s2_db_lock', '<b>Database: Insert Reservation Lock</b><br/>INSERT INTO reservations (status:\'pending\')', db_style, 2220, 1330, 380, 65)

    add_vertex('s2_end', 'SUB_AVAILABILITY_CHECK (End)', end_style, 400, 1425, 180, 45)

    add_edge('es2_01', 's2_start', 's2_drv_query', edge_flow)
    add_edge('es2_02', 's2_drv_query', 's2_api_hours', edge_flow)
    add_edge('es2_03', 's2_api_hours', 's2_dec_hours', edge_flow)
    add_edge('es2_04', 's2_dec_hours', 's2_api_hours_err', edge_no, label='No', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('es2_05', 's2_dec_hours', 's2_api_compat', edge_yes, label='Yes', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_edge('es2_06', 's2_api_compat', 's2_db_query_overlap', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es2_07', 's2_db_query_overlap', 's2_dec_slot_avail', edge_flow, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('es2_08', 's2_dec_slot_avail', 's2_api_no_slots', edge_no, label='None', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('es2_09', 's2_dec_slot_avail', 's2_api_calc_quote', edge_yes, label='Available', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_edge('es2_10', 's2_api_calc_quote', 's2_drv_display_quote', edge_flow)
    add_edge('es2_11', 's2_api_calc_quote', 's2_api_lock', edge_flow)
    add_edge('es2_12', 's2_api_lock', 's2_db_lock', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es2_13', 's2_drv_display_quote', 's2_end', edge_flow)

    # =========================================================================
    # SUBROUTINE 3: QR PASS GENERATION & CHECKPOINT SCANNER SUBROUTINE
    # =========================================================================
    add_vertex('s3_banner', '<b>SUBROUTINE 3</b><br/><br/><b>QR PASS &amp;<br/>CHECKPOINT<br/>VALIDATION</b><br/><br/><span style="font-size:10px;color:#5B21B6;">• HMAC / Token Generation<br/>• Mobile QR Code Rendering<br/>• Host Checkpoint Scanner<br/>• Time Window Verification<br/>• Check-in Transaction Log</span>', banner_s3, 15, 1510, 210, 680)

    add_vertex('s3_start', 'SUB_QR_CHECKPOINT (Start)', start_style, 400, 1500, 180, 45)

    add_vertex('s3_api_gen_qr', '<b>Subroutine: generateQrCredential()</b><br/>Create unique reservation_token &amp; QR signature<br/>Bind token with reservation_id, plate_number, space_id', api_proc_style, 780, 1565, 400, 65)

    add_vertex('s3_drv_render_qr', '<b>Render Dynamic In-App QR Pass</b><br/>Driver displays secure QR barcode on mobile screen', driver_proc_style, 290, 1565, 380, 60)

    add_vertex('s3_own_scan', '<b>Host Checkpoint Scanner Capture</b><br/>Host scans QR token (or inputs reservation code)<br/>[POST /api/owner/checkpoints/validate]', owner_input_style, 1280, 1650, 380, 65)

    add_vertex('s3_api_verify_chk', '<b>Subroutine: validateCheckpointToken()</b><br/>• Decrypt/Lookup reservation by credential token<br/>• Verify space_id matches authenticated host space<br/>• Verify arrival time &lt;= end_time', api_proc_style, 780, 1650, 400, 70)

    add_vertex('s3_dec_qr_ok', 'Token &amp; Space<br/>Match?', api_decision_style, 900, 1745, 160, 70)

    add_vertex('s3_own_err', '<b>Checkpoint Error Feedback</b><br/>Alert: Invalid Token, Wrong Facility, or Out of Schedule', owner_proc_style, 1280, 1750, 380, 60)

    add_vertex('s3_dec_event_type', 'Scan Event<br/>Type?', api_decision_style, 900, 1845, 160, 70)

    add_vertex('s3_api_do_checkin', '<b>Subroutine: executeCheckIn()</b><br/>• UPDATE reservations SET status=\'checked_in\'<br/>• INSERT INTO checkpoint_transactions (type:\'check_in\')', api_proc_style, 780, 1940, 400, 65)

    add_vertex('s3_db_log_entry', '<b>Database: Log Entry Checkpoint</b><br/>Insert timestamped entry log to DB', db_style, 2220, 1940, 380, 60)

    add_vertex('s3_drv_live_timer', '<b>Start Live Parking Session Timer</b><br/>Driver screen transitions to Active Parking with live countdown', driver_proc_style, 290, 1940, 380, 65)

    add_vertex('s3_end', 'SUB_QR_CHECKPOINT (End)', end_style, 400, 2030, 180, 45)

    add_edge('es3_01', 's3_start', 's3_api_gen_qr', edge_flow)
    add_edge('es3_02', 's3_api_gen_qr', 's3_drv_render_qr', edge_flow)
    add_edge('es3_03', 's3_drv_render_qr', 's3_own_scan', edge_flow)
    add_edge('es3_04', 's3_own_scan', 's3_api_verify_chk', edge_flow)
    add_edge('es3_05', 's3_api_verify_chk', 's3_dec_qr_ok', edge_flow)
    add_edge('es3_06', 's3_dec_qr_ok', 's3_own_err', edge_no, label='Invalid', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es3_07', 's3_dec_qr_ok', 's3_dec_event_type', edge_yes, label='Valid', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_edge('es3_08', 's3_dec_event_type', 's3_api_do_checkin', edge_flow, label='Entry Scan', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_edge('es3_09', 's3_api_do_checkin', 's3_db_log_entry', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es3_10', 's3_api_do_checkin', 's3_drv_live_timer', edge_flow)
    add_edge('es3_11', 's3_drv_live_timer', 's3_end', edge_flow)

    # =========================================================================
    # SUBROUTINE 4: OVERSTAY DETECTION & PENALTY BILLING ENGINE
    # =========================================================================
    add_vertex('s4_banner', '<b>SUBROUTINE 4</b><br/><br/><b>OVERSTAY &amp;<br/>PENALTY BILLING<br/>ENGINE</b><br/><br/><span style="font-size:10px;color:#92400E;">• Actual Duration Computation<br/>• Grace Period Verification<br/>• Multiplier Penalty Rates<br/>• Abandoned Vehicle Flagging<br/>• Consolidated Bill Synthesis</span>', banner_s4, 15, 2210, 210, 700)

    add_vertex('s4_start', 'SUB_OVERSTAY_BILLING (Start)', start_style, 400, 2200, 190, 45)

    add_vertex('s4_own_checkout_scan', '<b>Host Triggers Check-out Scan</b><br/>Driver presents QR pass upon facility departure<br/>[POST /api/owner/checkpoints/validate]', owner_input_style, 1280, 2265, 380, 65)

    add_vertex('s4_api_calc_dur', '<b>Subroutine: calculateActualDuration()</b><br/>actual_minutes = diffInMinutes(checked_in_at, now())<br/>reserved_minutes = diffInMinutes(start_time, end_time)', api_proc_style, 780, 2265, 400, 65)

    add_vertex('s4_dec_overstay', 'Exceeded<br/>Grace Period?', api_decision_style, 900, 2355, 160, 70)

    add_vertex('s4_api_no_penalty', '<b>Subroutine: applyStandardRate()</b><br/>overstay_penalty = 0<br/>final_amount = base_calculated_fee', api_proc_style, 780, 2450, 400, 60)

    add_vertex('s4_api_penalty', '<b>Subroutine: calculateOverstayPenalty()</b><br/>overstay_hours = ceil((now - end_time - grace_mins) / 60)<br/>penalty_amount = overstay_hours * hourly_rate * 1.5', api_proc_style, 780, 2530, 400, 70)

    add_vertex('s4_dec_abandoned', 'Overstay &gt;<br/>Abandoned Limit?', api_decision_style, 900, 2625, 160, 70)

    add_vertex('s4_api_flag_abandon', '<b>Subroutine: flagAbandonedVehicle()</b><br/>Mark is_abandoned=true, notify Admin &amp; Space Owner', api_proc_style, 780, 2715, 400, 60)

    add_vertex('s4_db_checkout_update', '<b>Database: Complete Reservation &amp; Bill</b><br/>• UPDATE reservations SET status=\'completed\',<br/>total_amount=final_amount, overstay_fee=penalty_amount<br/>• INSERT INTO checkpoint_transactions (type:\'check_out\')', db_style, 2220, 2705, 380, 85)

    add_vertex('s4_drv_bill_summary', '<b>Display Consolidated Statement</b><br/>Driver &amp; Host receive itemized invoice (Base + Penalty)', driver_proc_style, 290, 2715, 380, 65)

    add_vertex('s4_end', 'SUB_OVERSTAY_BILLING (End)', end_style, 400, 2815, 190, 45)

    add_edge('es4_01', 's4_start', 's4_own_checkout_scan', edge_flow)
    add_edge('es4_02', 's4_own_checkout_scan', 's4_api_calc_dur', edge_flow)
    add_edge('es4_03', 's4_api_calc_dur', 's4_dec_overstay', edge_flow)
    add_edge('es4_04', 's4_dec_overstay', 's4_api_no_penalty', edge_no, label='No (On Time)', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_edge('es4_05', 's4_dec_overstay', 's4_api_penalty', edge_yes, label='Yes (Overstayed)', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_edge('es4_06', 's4_api_penalty', 's4_dec_abandoned', edge_flow)
    add_edge('es4_07', 's4_dec_abandoned', 's4_api_flag_abandon', edge_yes, label='Yes (&gt; Limit)', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_edge('es4_08', 's4_dec_abandoned', 's4_db_checkout_update', edge_no, label='No', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es4_09', 's4_api_flag_abandon', 's4_db_checkout_update', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es4_10', 's4_api_no_penalty', 's4_db_checkout_update', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es4_11', 's4_db_checkout_update', 's4_drv_bill_summary', edge_flow, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('es4_12', 's4_drv_bill_summary', 's4_end', edge_flow)

    # =========================================================================
    # SUBROUTINE 5: PAYMENT VERIFICATION & RATING AGGREGATION
    # =========================================================================
    add_vertex('s5_banner', '<b>SUBROUTINE 5</b><br/><br/><b>PAYMENT &amp;<br/>RATING<br/>AGGREGATION</b><br/><br/><span style="font-size:10px;color:#9D174D;">• Multi-Method Payment<br/>• Payment Proof Upload &amp; Audit<br/>• Host Proof Inspection Stream<br/>• Star Rating Submission<br/>• Dynamic Space Rating Recalc</span>', banner_s5, 15, 2910, 210, 700)

    add_vertex('s5_start', 'SUB_PAYMENT_RATING (Start)', start_style, 400, 2900, 190, 45)

    add_vertex('s5_dec_method', 'Payment<br/>Method?', driver_decision_style, 400, 2965, 160, 70)

    add_vertex('s5_drv_cash', '<b>Driver Hands Cash Payment</b><br/>Cash settled on-site at checkpoint', driver_proc_style, 270, 3055, 200, 60)

    add_vertex('s5_own_cash_confirm', '<b>Subroutine: markCashPaid()</b><br/>Host confirms physical receipt<br/>[PATCH /owner/reservations/{id}/mark-paid]', owner_proc_style, 1280, 3055, 380, 65)

    add_vertex('s5_drv_online', '<b>Subroutine: processEWalletPayment()</b><br/>PayMongo Checkout / payment proof upload<br/>[POST /driver/reservations/{id}/payment]', driver_input_style, 500, 3055, 210, 65)

    add_vertex('s5_own_view_proof', '<b>Subroutine: fetchPaymentProof()</b><br/>Host streams image [GET .../payment-proof]<br/>Validates reference &amp; marks verified', owner_proc_style, 1280, 3145, 380, 65)

    add_vertex('s5_api_set_paid', '<b>Subroutine: finalizePaymentState()</b><br/>UPDATE reservations SET payment_status=\'paid\'<br/>Generate digital tax &amp; transaction receipt', api_proc_style, 780, 3145, 400, 65)

    add_vertex('s5_db_update_pay', '<b>Database: Payment Settled</b><br/>UPDATE reservations SET payment_status=\'paid\'', db_style, 2220, 3140, 380, 60)

    add_vertex('s5_drv_rate', '<b>Subroutine: submitFeedback()</b><br/>Driver rates 1-5 stars and writes review<br/>[POST /driver/reservations/{id}/feedback]', driver_input_style, 290, 3240, 380, 65)

    add_vertex('s5_api_recalc_rating', '<b>Subroutine: recalculateSpaceRating()</b><br/>• INSERT INTO reviews (reservation_id, rating, comment)<br/>• UPDATE parking_spaces SET rating = (SELECT AVG(rating) FROM reviews)', api_proc_style, 780, 3240, 400, 70)

    add_vertex('s5_db_reviews', '<b>Database: Store Review &amp; Aggregate</b><br/>Insert review row &amp; update parking_spaces.rating', db_style, 2220, 3240, 380, 70)

    add_vertex('s5_end', 'SUB_PAYMENT_RATING (End)', end_style, 400, 3345, 190, 45)

    add_edge('es5_01', 's5_start', 's5_dec_method', edge_flow)
    add_edge('es5_02', 's5_dec_method', 's5_drv_cash', edge_flow, label='Cash', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_edge('es5_03', 's5_dec_method', 's5_drv_online', edge_flow, label='PayMongo (GCash/Maya)', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_edge('es5_04', 's5_drv_cash', 's5_own_cash_confirm', edge_flow)
    add_edge('es5_05', 's5_drv_online', 's5_own_view_proof', edge_flow)
    add_edge('es5_06', 's5_own_cash_confirm', 's5_api_set_paid', edge_flow)
    add_edge('es5_07', 's5_own_view_proof', 's5_api_set_paid', edge_flow)
    add_edge('es5_08', 's5_api_set_paid', 's5_db_update_pay', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es5_09', 's5_db_update_pay', 's5_drv_rate', edge_flow, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('es5_10', 's5_drv_rate', 's5_api_recalc_rating', edge_flow)
    add_edge('es5_11', 's5_api_recalc_rating', 's5_db_reviews', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es5_12', 's5_drv_rate', 's5_end', edge_flow)

    # =========================================================================
    # SUBROUTINE 6: REAL-TIME IN-APP RTC SIGNALING & AUDIO CALL ENGINE
    # =========================================================================
    add_vertex('s6_banner', '<b>SUBROUTINE 6</b><br/><br/><b>REAL-TIME RTC<br/>SIGNALING &amp;<br/>VOICE ENGINE</b><br/><br/><span style="font-size:10px;color:#115E59;">• Call Session Creation<br/>• Active Call Polling / Events<br/>• SDP Offer/Answer Relay<br/>• ICE Candidate Signal Batch<br/>• Agora / WebRTC Audio Session</span>', banner_s6, 15, 3630, 210, 680)

    add_vertex('s6_start', 'SUB_RTC_SIGNALING (Start)', start_style, 400, 3620, 190, 45)

    add_vertex('s6_drv_call', '<b>Driver Initiates Voice Call</b><br/>Click Call Icon [POST /conversation/calls]', driver_proc_style, 290, 3685, 380, 60)

    add_vertex('s6_api_create_call', '<b>Subroutine: createCallSession()</b><br/>INSERT INTO reservation_calls (status: \'calling\')<br/>Generate call channel token &amp; notify host', api_proc_style, 780, 3685, 400, 65)

    add_vertex('s6_own_poll_call', '<b>Host Receives Incoming Call Alert</b><br/>Screen shows incoming caller info &amp; Accept / Reject CTA<br/>[GET /conversation/calls/active]', owner_proc_style, 1280, 3770, 380, 65)

    add_vertex('s6_dec_host_ans', 'Host Accept<br/>Call?', owner_decision_style, 1390, 3860, 160, 70)

    add_vertex('s6_api_reject_call', '<b>Subroutine: rejectCall()</b><br/>[PATCH .../calls/{id}/reject] (status=\'rejected\')', api_proc_style, 780, 3865, 400, 60)

    add_vertex('s6_api_accept_call', '<b>Subroutine: acceptCall()</b><br/>[PATCH .../calls/{id}/accept] (status=\'in_progress\')', api_proc_style, 780, 3950, 400, 60)

    add_vertex('s6_api_signals', '<b>Subroutine: relaySignalBatch()</b><br/>• [POST .../signals] exchange SDP offer / answer<br/>• [GET .../signals?after_id=?] poll ICE candidates', api_proc_style, 780, 4035, 400, 65)

    add_vertex('s6_ext_agora', '<b>WebRTC / Agora RTC Audio Engine</b><br/>Bidirectional low-latency audio stream active', ext_service_style, 2220, 4030, 380, 65)

    add_vertex('s6_drv_end_call', '<b>Terminate Audio Call</b><br/>Either party taps End Call [PATCH .../calls/{id}/end]', driver_proc_style, 290, 4125, 380, 60)

    add_vertex('s6_api_end_call', '<b>Subroutine: terminateCallSession()</b><br/>UPDATE reservation_calls SET status=\'ended\'', api_proc_style, 780, 4125, 400, 60)

    add_vertex('s6_end', 'SUB_RTC_SIGNALING (End)', end_style, 400, 4215, 190, 45)

    add_edge('es6_01', 's6_start', 's6_drv_call', edge_flow)
    add_edge('es6_02', 's6_drv_call', 's6_api_create_call', edge_flow)
    add_edge('es6_03', 's6_api_create_call', 's6_own_poll_call', edge_flow)
    add_edge('es6_04', 's6_own_poll_call', 's6_dec_host_ans', edge_flow)
    add_edge('es6_05', 's6_dec_host_ans', 's6_api_reject_call', edge_no, label='Reject', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('es6_06', 's6_dec_host_ans', 's6_api_accept_call', edge_yes, label='Accept', exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('es6_07', 's6_api_accept_call', 's6_api_signals', edge_flow)
    add_edge('es6_08', 's6_api_signals', 's6_ext_agora', edge_sync, label='RTC Audio Stream')
    add_edge('es6_09', 's6_api_signals', 's6_drv_end_call', edge_flow)
    add_edge('es6_10', 's6_drv_end_call', 's6_api_end_call', edge_flow)
    add_edge('es6_11', 's6_api_end_call', 's6_end', edge_flow)

    # =========================================================================
    # SUBROUTINE 7: SYSTEM AUDIT LOGGING & DISPUTE GOVERNANCE
    # =========================================================================
    add_vertex('s7_banner', '<b>SUBROUTINE 7</b><br/><br/><b>AUDIT LOGGING &amp;<br/>DISPUTE<br/>GOVERNANCE</b><br/><br/><span style="font-size:10px;color:#3730A3;">• Event Interceptor Middleware<br/>• Non-repudiation Audit Records<br/>• Dispute Ticket Lifecycle<br/>• Admin Internal Investigation<br/>• System Health Analytics</span>', banner_s7, 15, 4340, 210, 680)

    add_vertex('s7_start', 'SUB_AUDIT_LOGGING (Start)', start_style, 400, 4330, 190, 45)

    add_vertex('s7_drv_dispute', '<b>Driver / Host Submits Dispute Ticket</b><br/>File ticket for billing discrepancy or parking conflict<br/>[POST /admin/support-requests]', driver_input_style, 290, 4395, 380, 65)

    add_vertex('s7_api_interceptor', '<b>Subroutine: logSystemAuditEvent()</b><br/>Intercept action, serialize actor_id, ip_address, route,<br/>and state payload diff into audit buffer', api_proc_style, 780, 4395, 400, 70)

    add_vertex('s7_db_audit_insert', '<b>Database: audit_logs &amp; qr_logs</b><br/>• INSERT INTO audit_logs (user_id, action, payload)<br/>• INSERT INTO qr_transaction_logs', db_style, 2220, 4390, 380, 75)

    add_vertex('s7_adm_fetch_audit', '<b>Admin Monitor Subroutine: fetchActivity()</b><br/>Admin streams real-time audit logs &amp; pending disputes<br/>[GET /api/admin/activity] &amp; [GET /api/admin/reservations]', admin_proc_style, 1740, 4485, 380, 70)

    add_vertex('s7_adm_resolve', '<b>Admin Resolves Dispute</b><br/>[PATCH /api/admin/reservations/{id}]<br/>Set dispute_status=\'resolved\', add dispute_notes', admin_proc_style, 1740, 4580, 380, 65)

    add_vertex('s7_api_update_dispute', '<b>Subroutine: applyDisputeResolution()</b><br/>Update reservation balance, adjust refund/penalty, notify parties', api_proc_style, 780, 4580, 400, 65)

    add_vertex('s7_db_update_dispute', '<b>Database: Settle Dispute Status</b><br/>UPDATE reservations SET dispute_status=\'resolved\'', db_style, 2220, 4580, 380, 60)

    add_vertex('s7_adm_analytics', '<b>Subroutine: renderSystemAnalytics()</b><br/>Compute occupancy rates, revenue totals &amp; audit statistics', admin_proc_style, 1740, 4670, 380, 65)

    add_vertex('s7_end', 'SUB_AUDIT_LOGGING (End)', end_style, 400, 4760, 190, 45)

    add_edge('es7_01', 's7_start', 's7_drv_dispute', edge_flow)
    add_edge('es7_02', 's7_drv_dispute', 's7_api_interceptor', edge_flow)
    add_edge('es7_03', 's7_api_interceptor', 's7_db_audit_insert', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es7_04', 's7_db_audit_insert', 's7_adm_fetch_audit', edge_sync, label='Audit Stream')
    add_edge('es7_05', 's7_adm_fetch_audit', 's7_adm_resolve', edge_flow)
    add_edge('es7_06', 's7_adm_resolve', 's7_api_update_dispute', edge_flow, exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('es7_07', 's7_api_update_dispute', 's7_db_update_dispute', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('es7_08', 's7_adm_resolve', 's7_adm_analytics', edge_flow)
    add_edge('es7_09', 's7_api_update_dispute', 's7_end', edge_flow, exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)

    # Format XML nicely
    rough_string = ET.tostring(mxfile, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    pretty_xml = reparsed.toprettyxml(indent="  ", encoding="utf-8").decode("utf-8")
    pretty_xml = "\n".join([line for line in pretty_xml.split("\n") if line.strip()])
    
    workspace_path = r'c:\Users\kimch\e_parada_mobile'
    file_path_drawio = os.path.join(workspace_path, 'e_parada_subroutines_flowchart.drawio')
    file_path_xml = os.path.join(workspace_path, 'e_parada_subroutines_flowchart.drawio.xml')
    
    with open(file_path_drawio, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
        
    with open(file_path_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
        
    print(f"Successfully generated {file_path_drawio} and {file_path_xml}")

if __name__ == '__main__':
    create_subroutines_drawio()
