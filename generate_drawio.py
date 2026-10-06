import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import os

def create_drawio_flowchart():
    # Root draw.io XML structure
    mxfile = ET.Element('mxfile', {
        'host': 'app.diagrams.net',
        'modified': '2026-08-30T10:00:00.000Z',
        'agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Antigravity/2.0',
        'etag': 'e-parada-full-flow-v1',
        'version': '21.0.0',
        'type': 'device'
    })
    
    diagram = ET.SubElement(mxfile, 'diagram', {
        'id': 'e_parada_architecture_flowchart',
        'name': 'E-Parada System Architecture Flowchart'
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
        'pageHeight': '4480',
        'math': '0',
        'shadow': '0'
    })
    
    root = ET.SubElement(graph_model, 'root')
    
    # Base cells
    ET.SubElement(root, 'mxCell', {'id': '0'})
    ET.SubElement(root, 'mxCell', {'id': '1', 'parent': '0'})

    # Helper function to add vertices
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

    # Helper function to add edges
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
    lane_phase_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#1E293B;strokeColor=#334155;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F8FAFC;"
    lane_driver_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#1E3A8A;strokeColor=#3B82F6;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F0F7FF;"
    lane_api_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#312E81;strokeColor=#6366F1;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F5F3FF;"
    lane_owner_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#064E3B;strokeColor=#10B981;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#ECFDF5;"
    lane_admin_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#701A75;strokeColor=#D946EF;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#FDF4FF;"
    lane_db_style = "swimlane;whiteSpace=wrap;html=1;startSize=50;fillColor=#1F2937;strokeColor=#4B5563;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;swimlaneFillColor=#F9FAFB;"

    # Node Styles
    banner_p1_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#DBEAFE;strokeColor=#3B82F6;fontColor=#1E40AF;fontSize=13;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_p2_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#EDE9FE;strokeColor=#8B5CF6;fontColor=#5B21B6;fontSize=13;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_p3_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#D1FAE5;strokeColor=#10B981;fontColor=#065F46;fontSize=13;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_p4_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEF3C7;strokeColor=#F59E0B;fontColor=#92400E;fontSize=13;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    banner_p5_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FCE7F3;strokeColor=#EC4899;fontColor=#9D174D;fontSize=13;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    start_style = "ellipse;whiteSpace=wrap;html=1;fillColor=#22C55E;strokeColor=#16A34A;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;verticalAlign=middle;shadow=1;"
    end_style = "ellipse;whiteSpace=wrap;html=1;fillColor=#EF4444;strokeColor=#DC2626;fontColor=#FFFFFF;fontStyle=1;fontSize=13;align=center;verticalAlign=middle;shadow=1;"
    
    driver_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#3B82F6;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    driver_input_style = "shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;fixedSize=1;fillColor=#EFF6FF;strokeColor=#2563EB;strokeWidth=1.5;fontColor=#1E3A8A;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    
    api_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#6366F1;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    api_decision_style = "rhombus;whiteSpace=wrap;html=1;fillColor=#FEF08A;strokeColor=#EAB308;strokeWidth=1.5;fontColor=#713F12;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    
    owner_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#10B981;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    owner_input_style = "shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;fixedSize=1;fillColor=#ECFDF5;strokeColor=#059669;strokeWidth=1.5;fontColor=#064E3B;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    owner_decision_style = "rhombus;whiteSpace=wrap;html=1;fillColor=#A7F3D0;strokeColor=#10B981;strokeWidth=1.5;fontColor=#064E3B;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    admin_proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#D946EF;strokeWidth=1.5;fontColor=#1E293B;fontSize=11;align=center;verticalAlign=middle;shadow=1;"
    admin_decision_style = "rhombus;whiteSpace=wrap;html=1;fillColor=#F5D0FE;strokeColor=#C026D3;strokeWidth=1.5;fontColor=#701A75;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    db_style = "shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#F1F5F9;strokeColor=#475569;strokeWidth=1.5;fontColor=#0F172A;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"
    ext_service_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#E2E8F0;strokeColor=#64748B;strokeWidth=1.5;fontColor=#0F172A;fontSize=11;fontStyle=1;align=center;verticalAlign=middle;shadow=1;"

    # Edge Styles
    edge_flow = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#334155;strokeWidth=1.5;fontSize=11;fontColor=#1E293B;"
    edge_yes = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#16A34A;strokeWidth=2;fontSize=11;fontColor=#16A34A;fontStyle=1;"
    edge_no = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#DC2626;strokeWidth=2;fontSize=11;fontColor=#DC2626;fontStyle=1;"
    edge_sync = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;dashed=1;strokeColor=#6366F1;strokeWidth=1.5;fontSize=10;fontColor=#4338CA;"

    # 1. Canvas Top Header
    add_vertex('hdr_title', 
               '<b>E-PARADA: CROSS-FUNCTIONAL END-TO-END SYSTEM ARCHITECTURE FLOWCHART</b><br/><span style="font-size: 12px; font-weight: normal; color: #94A3B8;">Flutter Mobile Client (ph.eparada.mobile) • Laravel Backend REST API &amp; Sanctum • Space Provider • System Administrator • Supabase PostgreSQL, Brevo SMTP &amp; Cloud Integrations</span>', 
               title_style, 0, 0, 2660, 60)

    # 2. Main Swimlanes (6 Columns)
    lane_w_phase = 240
    lane_w_driver = 480
    lane_w_api = 520
    lane_w_owner = 460
    lane_w_admin = 460
    lane_w_db = 500
    lane_h = 4380

    x_phase = 0
    x_driver = x_phase + lane_w_phase      # 240
    x_api = x_driver + lane_w_driver       # 720
    x_owner = x_api + lane_w_api           # 1240
    x_admin = x_owner + lane_w_owner       # 1700
    x_db = x_admin + lane_w_admin          # 2160

    add_vertex('lane_phase', 'SYSTEM LIFECYCLE PHASES', lane_phase_style, x_phase, 60, lane_w_phase, lane_h)
    add_vertex('lane_driver', 'FLUTTER CLIENT: DRIVER / USER APP', lane_driver_style, x_driver, 60, lane_w_driver, lane_h)
    add_vertex('lane_api', 'LARAVEL REST API &amp; CONTROLLER ENGINE', lane_api_style, x_api, 60, lane_w_api, lane_h)
    add_vertex('lane_owner', 'PARKING SPACE PROVIDER (HOST)', lane_owner_style, x_owner, 60, lane_w_owner, lane_h)
    add_vertex('lane_admin', 'SYSTEM ADMINISTRATOR CONSOLE', lane_admin_style, x_admin, 60, lane_w_admin, lane_h)
    add_vertex('lane_db', 'DATABASE, HARDWARE &amp; EXTERNAL SERVICES', lane_db_style, x_db, 60, lane_w_db, lane_h)

    # =========================================================================
    # PHASE 1: AUTHENTICATION, ONBOARDING & VERIFICATION (Y: 100 - 900)
    # =========================================================================
    add_vertex('p1_banner', '<b>PHASE 1</b><br/><br/><b>AUTHENTICATION,<br/>ONBOARDING &amp;<br/>KYC VERIFICATION</b><br/><br/><span style="font-size:10px;color:#1E40AF;">• User &amp; Provider Sign Up<br/>• ID Document Upload<br/>• Vehicle Inspection KYC<br/>• Sanctum Token Issuance<br/>• Admin Approval Workflow</span>', banner_p1_style, 15, 110, 210, 780)

    add_vertex('p1_start', 'START', start_style, 420, 90, 120, 45)
    
    add_vertex('p1_drv_reg', '<b>Driver / User Registration</b><br/>Enters Name, Email, Password, Role (Driver),<br/>Plate Number, Vehicle Make/Color/Model,<br/>Consent &amp; Uploads ID + Vehicle Photos', driver_input_style, 290, 160, 380, 65)
    
    add_vertex('p1_own_reg', '<b>Provider Registration</b><br/>Enters Name, Email, Password, Role (Owner),<br/>Uploads Valid ID Front/Back &amp; Permits', owner_input_style, 1280, 160, 380, 65)

    add_vertex('p1_api_reg', '<b>[POST /api/register]</b><br/>Controller receives multipart payload.<br/>Validates fields, email uniqueness, file formats', api_proc_style, 780, 160, 400, 65)

    add_vertex('p1_dec_val', 'Payload &amp; Files<br/>Valid?', api_decision_style, 900, 255, 160, 70)

    add_vertex('p1_drv_err', '<b>[422 Unprocessable Entity]</b><br/>Display validation errors on Mobile UI', driver_proc_style, 310, 260, 340, 60)

    add_vertex('p1_db_store_user', '<b>Database: Insert Users &amp; Vehicles</b><br/>• INSERT INTO users (status: \'pending\')<br/>• INSERT INTO vehicles (status: \'pending\')<br/>• Store ID &amp; Vehicle photos to storage/app', db_style, 2220, 250, 380, 80)

    add_vertex('p1_api_token', '<b>Sanctum Token &amp; Brevo Email Verification</b><br/>Issue Bearer Token &amp; dispatch signed<br/>email verification link via Brevo SMTP relay', api_proc_style, 780, 355, 400, 60)

    add_vertex('p1_drv_store_session', '<b>Save Session Locally</b><br/>Store auth_token, user_id, role,<br/>can_reserve flag to SharedPreferences', driver_proc_style, 310, 355, 340, 60)

    add_vertex('p1_adm_fetch_kyc', '<b>Admin Fetches Pending Verifications</b><br/>[GET /api/admin/users?status=pending]<br/>[GET /api/admin/vehicles?status=pending]', admin_proc_style, 1740, 445, 380, 60)

    add_vertex('p1_adm_inspect', '<b>Inspect KYC Documents &amp; Photos</b><br/>Fetch private streams: [GET .../identity-document]<br/>[GET .../identity-document/back] &amp; [GET .../photo]', admin_proc_style, 1740, 530, 380, 65)

    add_vertex('p1_dec_adm_app', 'Admin Approve<br/>Account &amp; Vehicle?', admin_decision_style, 1850, 620, 160, 70)

    add_vertex('p1_api_reject', '<b>[PATCH /api/admin/users/{id}/reject]</b><br/><b>[PATCH /api/admin/vehicles/{id}/reject]</b><br/>Set verification_status=\'rejected\' with notes', api_proc_style, 780, 625, 400, 60)

    add_vertex('p1_api_approve', '<b>[PATCH /api/admin/users/{id}/approve]</b><br/><b>[PATCH /api/admin/vehicles/{id}/approve]</b><br/>Set verification_status=\'approved\',<br/>can_reserve=1, can_manage_parking_spaces=1', api_proc_style, 780, 715, 400, 70)

    add_vertex('p1_db_update_kyc', '<b>Database: Update KYC Status</b><br/>• UPDATE users SET verification_status=\'approved\'<br/>• UPDATE vehicles SET status=\'approved\'', db_style, 2220, 715, 380, 70)

    add_vertex('p1_drv_login', '<b>User / Driver Login Flow</b><br/>[POST /api/login] with Email &amp; Password<br/>Validate credentials &amp; fetch latest profile [GET /me]', driver_input_style, 310, 815, 340, 65)

    add_vertex('p1_drv_dash', '<b>Navigate to Main Navigation</b><br/>Load Dashboard (Driver Home / Owner Hub / Admin Panel)', driver_proc_style, 310, 905, 340, 50)

    # Phase 1 Edges
    add_edge('e1_01', 'p1_start', 'p1_drv_reg', edge_flow)
    add_edge('e1_02', 'p1_drv_reg', 'p1_api_reg', edge_flow)
    add_edge('e1_03', 'p1_own_reg', 'p1_api_reg', edge_flow)
    add_edge('e1_04', 'p1_api_reg', 'p1_dec_val', edge_flow)
    add_edge('e1_05', 'p1_dec_val', 'p1_drv_err', edge_no, label='No (Validation Error)', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e1_06', 'p1_dec_val', 'p1_db_store_user', edge_yes, label='Yes (Valid)', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e1_07', 'p1_db_store_user', 'p1_api_token', edge_flow, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('e1_08', 'p1_api_token', 'p1_drv_store_session', edge_flow)
    add_edge('e1_09', 'p1_db_store_user', 'p1_adm_fetch_kyc', edge_sync, label='Pending KYC Queue', exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('e1_10', 'p1_adm_fetch_kyc', 'p1_adm_inspect', edge_flow)
    add_edge('e1_11', 'p1_adm_inspect', 'p1_dec_adm_app', edge_flow)
    add_edge('e1_12', 'p1_dec_adm_app', 'p1_api_reject', edge_no, label='Reject', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e1_13', 'p1_dec_adm_app', 'p1_api_approve', edge_yes, label='Approve', exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('e1_14', 'p1_api_approve', 'p1_db_update_kyc', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e1_15', 'p1_drv_store_session', 'p1_drv_login', edge_flow)
    add_edge('e1_16', 'p1_drv_login', 'p1_drv_dash', edge_flow)

    # =========================================================================
    # PHASE 2: PARKING SPACE LISTING & MANAGEMENT (Y: 1000 - 1650)
    # =========================================================================
    add_vertex('p2_banner', '<b>PHASE 2</b><br/><br/><b>PARKING SPACE<br/>LISTING &amp;<br/>MANAGEMENT</b><br/><br/><span style="font-size:10px;color:#5B21B6;">• Space Geolocation Pinning<br/>• Slot Vehicle Compatibility<br/>• Operating Hours &amp; Rules<br/>• Admin Spatial Review<br/>• Dynamic Rate Tiering</span>', banner_p2_style, 15, 1000, 210, 650)

    add_vertex('p2_own_open', '<b>Host Opens Space Management</b><br/>Provider selects "Add New Parking Space"<br/>or loads existing listings [GET /api/owner/parking-spaces]', owner_proc_style, 1280, 1000, 380, 60)

    add_vertex('p2_own_form', '<b>Fill Parking Space Specifications</b><br/>• Space Name, Address, Lat/Long GPS Coordinates<br/>• Total Dimensions (sqm), Total Slots Count<br/>• 24/7 toggle or Opening &amp; Closing Times<br/>• Overstay Grace Period (mins), Abandoned Limit (hrs)', owner_input_style, 1260, 1085, 420, 80)

    add_vertex('p2_own_slots', '<b>Configure Slot Vehicle Matrix</b><br/>Define allowable vehicle types per individual slot:<br/>Motorcycle, E-Trike/E-Quad, Car, SUV/MPV, Van/Pickup', owner_input_style, 1260, 1190, 420, 65)

    add_vertex('p2_api_save', '<b>[POST /api/owner/parking-spaces]</b><br/>Controller receives multipart payload with images[].<br/>Validates spatial geometry, slot limits, operating hours', api_proc_style, 780, 1190, 400, 65)

    add_vertex('p2_dec_val', 'Space Data &amp;<br/>Slots Valid?', api_decision_style, 900, 1280, 160, 70)

    add_vertex('p2_own_err', '<b>Display Space Validation Errors</b><br/>Highlight invalid hours, missing images, or slot mismatch', owner_proc_style, 1280, 1285, 380, 60)

    add_vertex('p2_db_store_space', '<b>Database: Insert Parking Space</b><br/>• INSERT INTO parking_spaces (approval_status: \'pending\')<br/>• INSERT INTO parking_slots (vehicle_type_bitmask)<br/>• Store space gallery images to public storage disk', db_style, 2220, 1275, 380, 80)

    add_vertex('p2_adm_fetch_spaces', '<b>Admin Reviews Space Submission</b><br/>[GET /api/admin/parking-spaces?status=pending]<br/>Review dimensions, photos, geofence, and slots layout', admin_proc_style, 1740, 1385, 380, 65)

    add_vertex('p2_adm_set_rates', '<b>Admin Configures Hourly Rate Tiers</b><br/>Set vehicle_hourly_rates for Motorcycle, Car, SUV, Van.<br/>Add operational approval notes', admin_proc_style, 1740, 1475, 380, 65)

    add_vertex('p2_dec_adm_space', 'Admin Approve<br/>Parking Space?', admin_decision_style, 1850, 1565, 160, 70)

    add_vertex('p2_api_review_space', '<b>[PATCH /api/admin/parking-spaces/{id}/review]</b><br/>Set approval_status=\'approved\' (or \'rejected\'),<br/>attach hourly rates mapping &amp; admin_notes', api_proc_style, 780, 1570, 400, 65)

    add_vertex('p2_db_publish_space', '<b>Database: Activate &amp; Index Space</b><br/>UPDATE parking_spaces SET approval_status=\'approved\',<br/>is_active=1, hourly_rates=json_payload<br/>Spatial indexing active for Driver Discovery', db_style, 2220, 1560, 380, 80)

    # Phase 2 Edges
    add_edge('e2_01', 'p2_own_open', 'p2_own_form', edge_flow)
    add_edge('e2_02', 'p2_own_form', 'p2_own_slots', edge_flow)
    add_edge('e2_03', 'p2_own_slots', 'p2_api_save', edge_flow)
    add_edge('e2_04', 'p2_api_save', 'p2_dec_val', edge_flow)
    add_edge('e2_05', 'p2_dec_val', 'p2_own_err', edge_no, label='No (Errors)', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e2_06', 'p2_dec_val', 'p2_db_store_space', edge_yes, label='Yes (Valid)', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e2_07', 'p2_db_store_space', 'p2_adm_fetch_spaces', edge_sync, label='Pending Space Review', exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('e2_08', 'p2_adm_fetch_spaces', 'p2_adm_set_rates', edge_flow)
    add_edge('e2_09', 'p2_adm_set_rates', 'p2_dec_adm_space', edge_flow)
    add_edge('e2_10', 'p2_dec_adm_space', 'p2_api_review_space', edge_flow, exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e2_11', 'p2_api_review_space', 'p2_db_publish_space', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)

    # =========================================================================
    # PHASE 3: SEARCH, DISCOVERY & RESERVATION (Y: 1730 - 2470)
    # =========================================================================
    add_vertex('p3_banner', '<b>PHASE 3</b><br/><br/><b>SEARCH, DISCOVERY<br/>&amp; REAL-TIME<br/>RESERVATION</b><br/><br/><span style="font-size:10px;color:#065F46;">• Interactive Google Map<br/>• Spatial Search &amp; Filtering<br/>• Real-Time Slot Conflict Check<br/>• Reservation Lock &amp; QR Pass<br/>• Provider Booking Acceptance</span>', banner_p3_style, 15, 1730, 210, 740)

    add_vertex('p3_drv_map', '<b>Driver Opens Interactive Map Screen</b><br/>Enables GPS location, sets vehicle type filter,<br/>specifies intended reservation date/time window', driver_proc_style, 290, 1730, 380, 60)

    add_vertex('p3_ext_maps', '<b>Google Maps Platform</b><br/>• Places API &amp; Geocoding<br/>• Dynamic Vector Map SDK<br/>• Distance Matrix calculation', ext_service_style, 2220, 1730, 380, 60)

    add_vertex('p3_api_search', '<b>[GET /api/parking-spaces]</b><br/>Query active, approved spaces within bounding box / radius.<br/>Eager load slot capacities, hourly rates &amp; average ratings', api_proc_style, 780, 1730, 400, 60)

    add_vertex('p3_drv_render_pins', '<b>Interactive Map UI Rendering</b><br/>Displays custom parking pins, rate badges, clustering,<br/>and facility overview bottom sheets', driver_proc_style, 290, 1815, 380, 60)

    add_vertex('p3_drv_select_space', '<b>Select Space &amp; View Details</b><br/>Driver clicks space -> Inspects photos, amenities,<br/>allowed vehicle types, rules, and host ratings', driver_proc_style, 290, 1900, 380, 60)

    add_vertex('p3_drv_check_avail', '<b>Check Slot Real-Time Availability</b><br/>Driver selects Vehicle from Garage, Start/End Date &amp; Time<br/>[GET /api/driver/parking-spaces/{id}/availability]', driver_input_style, 290, 1985, 380, 65)

    add_vertex('p3_api_calc_avail', '<b>Availability Engine Conflict Check</b><br/>Check operating hours, existing overlapping reservations,<br/>matching slot vehicle compatibility, compute price quote', api_proc_style, 780, 1985, 400, 65)

    add_vertex('p3_drv_submit_res', '<b>Submit Slot Reservation</b><br/>[POST /api/driver/parking-spaces/{id}/reservations]<br/>Pass vehicle_id, parking_slot_id, schedule range', driver_input_style, 290, 2075, 380, 65)

    add_vertex('p3_dec_slot_ok', 'Slot Available &amp;<br/>No Schedule Conflict?', api_decision_style, 900, 2070, 160, 75)

    add_vertex('p3_drv_res_err', '<b>[422 Slot Unavailable / Conflict]</b><br/>Alert driver: Slot just booked or time window invalid.<br/>Prompt alternative slot or schedule', driver_proc_style, 290, 2165, 380, 60)

    add_vertex('p3_db_create_res', '<b>Database: Create Reservation Record</b><br/>• INSERT INTO reservations (status: \'pending\')<br/>• Generate unique secure QR Token &amp; Reference Code<br/>• Calculate estimated total parking fee', db_style, 2220, 2065, 380, 80)

    add_vertex('p3_db_notify_own', '<b>Database: Dispatch Notification</b><br/>• INSERT INTO mobile_notifications<br/>• Dispatch FCM / In-App push alert to Host', db_style, 2220, 2170, 380, 60)

    add_vertex('p3_own_review_res', '<b>Host Reviews Incoming Booking</b><br/>Provider opens Owner Reservations Screen<br/>[GET /api/owner/reservations?status=pending]', owner_proc_style, 1280, 2170, 380, 65)

    add_vertex('p3_dec_own_accept', 'Host Accept<br/>Reservation?', owner_decision_style, 1390, 2260, 160, 70)

    add_vertex('p3_api_reject_res', '<b>[PATCH /api/owner/reservations/{id}/reject]</b><br/>Set status=\'rejected\' with owner_response_notes.<br/>Release slot lock &amp; notify Driver', api_proc_style, 780, 2265, 400, 60)

    add_vertex('p3_api_approve_res', '<b>[PATCH /api/owner/reservations/{id}/approve]</b><br/>Set status=\'confirmed\', activate reservation QR token,<br/>notify Driver with confirmed schedule pass', api_proc_style, 780, 2355, 400, 65)

    add_vertex('p3_db_confirm_res', '<b>Database: Update Reservation Status</b><br/>UPDATE reservations SET status=\'confirmed\'', db_style, 2220, 2355, 380, 60)

    add_vertex('p3_drv_confirmed', '<b>Booking Confirmed &amp; QR Pass Issued</b><br/>Driver receives Confirmation Alert &amp; Dynamic QR Pass<br/>Reservation listed in Driver Active Schedule', driver_proc_style, 290, 2390, 380, 60)

    # Phase 3 Edges
    add_edge('e3_01', 'p3_drv_map', 'p3_api_search', edge_flow)
    add_edge('e3_02', 'p3_api_search', 'p3_ext_maps', edge_sync)
    add_edge('e3_03', 'p3_api_search', 'p3_drv_render_pins', edge_flow)
    add_edge('e3_04', 'p3_drv_render_pins', 'p3_drv_select_space', edge_flow)
    add_edge('e3_05', 'p3_drv_select_space', 'p3_drv_check_avail', edge_flow)
    add_edge('e3_06', 'p3_drv_check_avail', 'p3_api_calc_avail', edge_flow)
    add_edge('e3_07', 'p3_api_calc_avail', 'p3_drv_submit_res', edge_flow)
    add_edge('e3_08', 'p3_drv_submit_res', 'p3_dec_slot_ok', edge_flow)
    add_edge('e3_09', 'p3_dec_slot_ok', 'p3_drv_res_err', edge_no, label='Conflict', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e3_10', 'p3_dec_slot_ok', 'p3_db_create_res', edge_yes, label='Available', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e3_11', 'p3_db_create_res', 'p3_db_notify_own', edge_flow)
    add_edge('e3_12', 'p3_db_notify_own', 'p3_own_review_res', edge_flow, exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e3_13', 'p3_own_review_res', 'p3_dec_own_accept', edge_flow)
    add_edge('e3_14', 'p3_dec_own_accept', 'p3_api_reject_res', edge_no, label='Reject', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e3_15', 'p3_dec_own_accept', 'p3_api_approve_res', edge_yes, label='Approve', exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('e3_16', 'p3_api_approve_res', 'p3_db_confirm_res', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e3_17', 'p3_api_approve_res', 'p3_drv_confirmed', edge_flow, exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)

    # =========================================================================
    # PHASE 4: CHECK-IN, ACTIVE PARKING & CALL / CHAT (Y: 2540 - 3360)
    # =========================================================================
    add_vertex('p4_banner', '<b>PHASE 4</b><br/><br/><b>CHECK-IN, ACTIVE<br/>PARKING &amp;<br/>COMMUNICATION</b><br/><br/><span style="font-size:10px;color:#92400E;">• In-App Chat &amp; Voice Call<br/>• QR Scanner Checkpoint<br/>• Real-Time Entry/Exit Logs<br/>• Overstay Monitoring<br/>• Reservation Extensions</span>', banner_p4_style, 15, 2540, 210, 820)

    add_vertex('p4_comm_drv', '<b>In-App Communication (Driver)</b><br/>• Chat messaging [POST /conversation/messages]<br/>• Initiate Voice Call [POST /conversation/calls]', driver_proc_style, 290, 2540, 380, 60)

    add_vertex('p4_comm_api', '<b>Conversation &amp; WebRTC / Agora Signaling</b><br/>Exchange message polling / WebSocket events,<br/>relay RTC SDP tokens &amp; ICE signals', api_proc_style, 780, 2540, 400, 60)

    add_vertex('p4_comm_own', '<b>In-App Communication (Host)</b><br/>• Reply to Driver in-app messages<br/>• Accept / reject incoming voice calls', owner_proc_style, 1280, 2540, 380, 60)

    add_vertex('p4_drv_arrive', '<b>Driver Arrives at Parking Space</b><br/>Driver opens app and presents active QR Pass on screen', driver_proc_style, 290, 2635, 380, 55)

    add_vertex('p4_own_scan_in', '<b>Host / Guard Scans Driver QR Pass</b><br/>Host opens QR Scanner Screen (or manual code entry)<br/>[POST /api/owner/checkpoints/validate]', owner_input_style, 1280, 2630, 380, 65)

    add_vertex('p4_api_validate_chk', '<b>Validate Checkpoint Credential</b><br/>Verify QR token authenticity, parking_space_id match,<br/>vehicle plate number, and arrival grace time window', api_proc_style, 780, 2630, 400, 65)

    add_vertex('p4_dec_qr_val', 'QR Token &amp;<br/>Schedule Valid?', api_decision_style, 900, 2720, 160, 70)

    add_vertex('p4_own_chk_err', '<b>Checkpoint Rejection Alert</b><br/>Display error: Unmatched Space, Already Used, or Invalid Pass', owner_proc_style, 1280, 2725, 380, 60)

    add_vertex('p4_db_log_checkin', '<b>Database: Check-In Entry Transaction</b><br/>• UPDATE reservations SET status=\'checked_in\'<br/>• INSERT INTO checkpoint_transactions (type: \'check_in\', timestamp)', db_style, 2220, 2715, 380, 80)

    add_vertex('p4_drv_active_timer', '<b>Active Parking Session Monitor</b><br/>Driver UI displays live parking timer, space location,<br/>overstay countdown alert, and Request Extension button', driver_proc_style, 290, 2820, 380, 65)

    add_vertex('p4_drv_req_ext', '<b>Driver Requests Extension (Optional)</b><br/>[PATCH /api/driver/reservations/{id}/extension]<br/>Provide requested extension_end_time &amp; reason', driver_input_style, 290, 2915, 380, 65)

    add_vertex('p4_own_eval_ext', '<b>Host Evaluates Extension Request</b><br/>[PATCH /api/owner/reservations/{id}/extension/approve]<br/>or reject based on upcoming slot bookings', owner_proc_style, 1280, 2915, 380, 65)

    add_vertex('p4_api_monitor_overstay', '<b>Automated Overstay &amp; Abandoned Monitor</b><br/>Server checks overstay_grace_minutes threshold.<br/>Applies overtime multiplier rates if driver exceeds schedule', api_proc_style, 780, 3010, 400, 65)

    add_vertex('p4_drv_checkout_qr', '<b>Driver Prepares to Depart</b><br/>Driver presents Departure QR Pass to Host / Guard', driver_proc_style, 290, 3105, 380, 60)

    add_vertex('p4_own_scan_out', '<b>Host Scans Check-Out QR Pass</b><br/>[POST /api/owner/checkpoints/validate]<br/>Trigger Check-Out Exit event validation', owner_input_style, 1280, 3100, 380, 65)

    add_vertex('p4_api_calc_bill', '<b>Calculate Final Duration &amp; Billing</b><br/>Compute exact parked duration, overtime penalty hours,<br/>slot fee rate, and compile total payable breakdown', api_proc_style, 780, 3100, 400, 65)

    add_vertex('p4_db_log_checkout', '<b>Database: Check-Out Exit Transaction</b><br/>• UPDATE reservations SET status=\'completed\'<br/>• INSERT INTO checkpoint_transactions (type: \'check_out\')<br/>• INSERT INTO qr_transaction_logs (audit data)', db_style, 2220, 3090, 380, 85)

    add_vertex('p4_drv_bill_summary', '<b>Display Payable Balance &amp; Receipt</b><br/>Driver views total charges breakdown and payment options', driver_proc_style, 290, 3215, 380, 60)

    # Phase 4 Edges
    add_edge('e4_01', 'p4_comm_drv', 'p4_comm_api', edge_flow)
    add_edge('e4_02', 'p4_comm_api', 'p4_comm_own', edge_flow)
    add_edge('e4_03', 'p4_drv_arrive', 'p4_own_scan_in', edge_flow)
    add_edge('e4_04', 'p4_own_scan_in', 'p4_api_validate_chk', edge_flow)
    add_edge('e4_05', 'p4_api_validate_chk', 'p4_dec_qr_val', edge_flow)
    add_edge('e4_06', 'p4_dec_qr_val', 'p4_own_chk_err', edge_no, label='Invalid', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e4_07', 'p4_dec_qr_val', 'p4_db_log_checkin', edge_yes, label='Valid Pass', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e4_08', 'p4_db_log_checkin', 'p4_drv_active_timer', edge_flow, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('e4_09', 'p4_drv_active_timer', 'p4_drv_req_ext', edge_flow)
    add_edge('e4_10', 'p4_drv_req_ext', 'p4_own_eval_ext', edge_flow)
    add_edge('e4_11', 'p4_drv_active_timer', 'p4_api_monitor_overstay', edge_flow)
    add_edge('e4_12', 'p4_drv_active_timer', 'p4_drv_checkout_qr', edge_flow)
    add_edge('e4_13', 'p4_drv_checkout_qr', 'p4_own_scan_out', edge_flow)
    add_edge('e4_14', 'p4_own_scan_out', 'p4_api_calc_bill', edge_flow)
    add_edge('e4_15', 'p4_api_calc_bill', 'p4_db_log_checkout', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e4_16', 'p4_db_log_checkout', 'p4_drv_bill_summary', edge_flow, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)

    # =========================================================================
    # PHASE 5: PAYMENT, REVIEWS, DISPUTE & AUDIT TRAIL (Y: 3430 - 4350)
    # =========================================================================
    add_vertex('p5_banner', '<b>PHASE 5</b><br/><br/><b>PAYMENT, REVIEWS,<br/>DISPUTE &amp;<br/>AUDIT TRAIL</b><br/><br/><span style="font-size:10px;color:#9D174D;">• Cash &amp; E-Wallet Settlement<br/>• Payment Proof Verification<br/>• Star Rating &amp; Review System<br/>• Dispute Resolution Console<br/>• End-to-End Activity Logs</span>', banner_p5_style, 15, 3430, 210, 890)

    add_vertex('p5_dec_pay_method', 'Select Payment<br/>Method?', api_decision_style, 400, 3430, 160, 70)

    add_vertex('p5_drv_pay_cash', '<b>Pay Cash on Facility Check-out</b><br/>Driver hands cash payment directly to Host / Guard', driver_proc_style, 260, 3530, 200, 60)

    add_vertex('p5_own_mark_paid', '<b>Host Confirms Cash Received</b><br/>[PATCH /api/owner/reservations/{id}/mark-paid]<br/>Set payment_method=\'cash\', payment_status=\'paid\'', owner_proc_style, 1280, 3530, 380, 65)

    add_vertex('p5_drv_pay_online', '<b>PayMongo / E-Wallet Payment</b><br/>[POST /api/driver/reservations/{id}/payment]<br/>Driver completes checkout (GCash/Maya) or proof upload', driver_input_style, 490, 3530, 220, 65)

    add_vertex('p5_own_verify_proof', '<b>Host Inspects Payment Proof</b><br/>[GET /api/owner/reservations/{id}/payment-proof]<br/>View digital screenshot &amp; confirm transaction', owner_proc_style, 1280, 3625, 380, 65)

    add_vertex('p5_api_update_pay', '<b>[API Controller: Confirm Payment]</b><br/>Verify transaction balance, update payment flags', api_proc_style, 780, 3625, 400, 65)

    add_vertex('p5_db_update_pay', '<b>Database: Update Payment Status</b><br/>UPDATE reservations SET payment_status=\'paid\',<br/>paid_at=NOW()', db_style, 2220, 3620, 380, 75)

    add_vertex('p5_drv_submit_feedback', '<b>Driver Submits Star Rating &amp; Feedback</b><br/>[POST /api/driver/reservations/{id}/feedback]<br/>Rate 1 to 5 Stars with written review comments', driver_input_style, 290, 3730, 380, 65)

    add_vertex('p5_api_save_review', '<b>API Review Processor</b><br/>Insert feedback, compute parking space aggregate star average,<br/>and refresh public space score', api_proc_style, 780, 3730, 400, 65)

    add_vertex('p5_db_save_review', '<b>Database: Insert Feedback &amp; Recalculate Rating</b><br/>• INSERT INTO reviews (rating, comment)<br/>• UPDATE parking_spaces SET rating=AVG(rating)', db_style, 2220, 3725, 380, 75)

    add_vertex('p5_drv_file_dispute', '<b>Dispute or Support Ticket (Optional)</b><br/>Driver or Host files issue regarding overcharges,<br/>damages, or reservation discrepancies', driver_proc_style, 290, 3835, 380, 65)

    add_vertex('p5_adm_manage_disputes', '<b>Admin Reviews Disputes &amp; Support Requests</b><br/>[GET /api/admin/reservations?dispute_status=pending]<br/>[GET /api/admin/support-requests?status=open]', admin_proc_style, 1740, 3835, 380, 65)

    add_vertex('p5_adm_resolve_dispute', '<b>Admin Resolves Dispute Ticket</b><br/>[PATCH /api/admin/reservations/{id}]<br/>Set dispute_status=\'resolved\', add dispute_notes &amp; admin_internal_notes', admin_proc_style, 1740, 3930, 380, 70)

    add_vertex('p5_api_audit_trail', '<b>Automated System Activity &amp; Audit Engine</b><br/>Record all critical security, reservation status transitions,<br/>KYC decisions, checkpoint scans &amp; payments', api_proc_style, 780, 4030, 400, 65)

    add_vertex('p5_db_store_audit', '<b>Database: Store Audit Logs &amp; QR Logs</b><br/>• INSERT INTO audit_logs (user_id, action, ip, payload)<br/>• INSERT INTO qr_transaction_logs', db_style, 2220, 4025, 380, 75)

    add_vertex('p5_adm_view_analytics', '<b>Admin System Activity &amp; Audit Dashboard</b><br/>[GET /api/admin/activity]<br/>Monitor real-time system health, logs &amp; financial metrics', admin_proc_style, 1740, 4125, 380, 65)

    add_vertex('p5_drv_complete_receipt', '<b>Final Completed Summary &amp; Digital Receipt</b><br/>Driver views completed reservation history with receipt,<br/>vehicle slots updated, and session closed', driver_proc_style, 290, 4220, 380, 60)

    add_vertex('p5_end', 'END', end_style, 420, 4310, 120, 45)

    # Phase 5 Edges
    add_edge('e5_01', 'p5_dec_pay_method', 'p5_drv_pay_cash', edge_flow, label='Cash', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_edge('e5_02', 'p5_dec_pay_method', 'p5_drv_pay_online', edge_flow, label='PayMongo (GCash/Maya)', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_edge('e5_03', 'p5_drv_pay_cash', 'p5_own_mark_paid', edge_flow)
    add_edge('e5_04', 'p5_drv_pay_online', 'p5_own_verify_proof', edge_flow)
    add_edge('e5_05', 'p5_own_mark_paid', 'p5_api_update_pay', edge_flow)
    add_edge('e5_06', 'p5_own_verify_proof', 'p5_api_update_pay', edge_flow)
    add_edge('e5_07', 'p5_api_update_pay', 'p5_db_update_pay', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e5_08', 'p5_db_update_pay', 'p5_drv_submit_feedback', edge_flow, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_edge('e5_09', 'p5_drv_submit_feedback', 'p5_api_save_review', edge_flow)
    add_edge('e5_10', 'p5_api_save_review', 'p5_db_save_review', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e5_11', 'p5_drv_submit_feedback', 'p5_drv_file_dispute', edge_flow)
    add_edge('e5_12', 'p5_drv_file_dispute', 'p5_adm_manage_disputes', edge_flow)
    add_edge('e5_13', 'p5_adm_manage_disputes', 'p5_adm_resolve_dispute', edge_flow)
    add_edge('e5_14', 'p5_adm_resolve_dispute', 'p5_api_audit_trail', edge_flow, exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e5_15', 'p5_api_audit_trail', 'p5_db_store_audit', edge_flow, exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)
    add_edge('e5_16', 'p5_db_store_audit', 'p5_adm_view_analytics', edge_sync, label='Audit Stream')
    add_edge('e5_17', 'p5_api_audit_trail', 'p5_drv_complete_receipt', edge_flow, exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)
    add_edge('e5_18', 'p5_drv_complete_receipt', 'p5_end', edge_flow)

    # Convert to string and format
    rough_string = ET.tostring(mxfile, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    pretty_xml = reparsed.toprettyxml(indent="  ", encoding="utf-8").decode("utf-8")
    
    # Clean up empty lines from minidom
    pretty_xml = "\n".join([line for line in pretty_xml.split("\n") if line.strip()])
    
    # Save to both .drawio and .drawio.xml in the project workspace
    workspace_path = r'c:\Users\kimch\e_parada_mobile'
    file_path_drawio = os.path.join(workspace_path, 'e_parada_system_flowchart.drawio')
    file_path_xml = os.path.join(workspace_path, 'e_parada_system_flowchart.drawio.xml')
    
    with open(file_path_drawio, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
        
    with open(file_path_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
        
    print(f"Successfully generated formatted {file_path_drawio} and {file_path_xml}")

if __name__ == '__main__':
    create_drawio_flowchart()
