import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import os

def generate_planar_zero_crossing_activity_diagram():
    # Root draw.io XML structure
    mxfile = ET.Element('mxfile', {
        'host': 'app.diagrams.net',
        'modified': '2026-09-04T04:20:00.000Z',
        'agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Antigravity/2.0 Planar Precision Engine',
        'etag': 'e-parada-planar-zero-cross-v12',
        'version': '21.0.0',
        'type': 'device'
    })

    # =========================================================================
    # PLANAR HIGH-PRECISION STYLES (Zero Line Crossings, Perfect Orthogonality)
    # =========================================================================
    title_style = "text;html=1;align=center;verticalAlign=middle;fontStyle=1;fontSize=15;fontColor=#000000;"
    
    # Swimlane Headers
    lane_style = (
        "swimlane;whiteSpace=wrap;html=1;startSize=45;"
        "fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.5;"
        "fontColor=#000000;fontStyle=1;fontSize=11;align=center;verticalAlign=top;"
        "swimlaneFillColor=#FFFFFF;collapsible=0;"
    )

    # Control Nodes
    start_style = "ellipse;html=1;shape=startState;fillColor=#000000;strokeColor=#000000;"
    end_style = "ellipse;html=1;shape=endState;fillColor=#000000;strokeColor=#000000;"
    flow_final_style = "ellipse;html=1;shape=mxgraph.sysml.flowFinal;fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.2;"

    # Action Nodes
    act_style = (
        "rounded=1;arcSize=22;whiteSpace=wrap;html=1;"
        "fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.2;"
        "fontColor=#000000;fontSize=9.5;align=center;verticalAlign=middle;spacing=2;"
    )
    act_sub_style = (
        "rounded=1;arcSize=22;whiteSpace=wrap;html=1;"
        "fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.2;"
        "fontColor=#000000;fontSize=9;align=center;verticalAlign=middle;spacing=1;"
    )

    # Decision Nodes
    dec_style = (
        "rhombus;whiteSpace=wrap;html=1;"
        "fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.2;"
        "fontColor=#000000;fontSize=8.5;fontStyle=0;align=center;verticalAlign=middle;"
    )

    # Joint Symbol (Fork & Join)
    joint_style = "rounded=0;whiteSpace=wrap;html=1;fillColor=#000000;strokeColor=#000000;strokeWidth=1;"

    # Signals
    send_signal_style = (
        "shape=mxgraph.sysml.sendSigAction;whiteSpace=wrap;html=1;"
        "fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.2;"
        "fontColor=#000000;fontSize=9;fontStyle=1;align=center;verticalAlign=middle;spacing=2;"
    )
    receive_signal_style = (
        "shape=mxgraph.sysml.accSigAction;whiteSpace=wrap;html=1;"
        "fillColor=#FFFFFF;strokeColor=#000000;strokeWidth=1.2;"
        "fontColor=#000000;fontSize=9;fontStyle=1;align=center;verticalAlign=middle;spacing=2;"
    )

    # Connectors
    edge_style = (
        "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
        "strokeColor=#000000;strokeWidth=1.2;fontSize=8.5;fontColor=#000000;"
        "endArrow=classic;endFill=1;"
    )
    edge_label_style = (
        "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
        "strokeColor=#000000;strokeWidth=1.2;fontSize=8;fontColor=#000000;fontStyle=2;"
        "endArrow=classic;endFill=1;"
    )

    # Helper function for adding diagram pages
    def create_page(diagram_id, diagram_name, width, height):
        diag = ET.SubElement(mxfile, 'diagram', {
            'id': diagram_id,
            'name': diagram_name
        })
        gm = ET.SubElement(diag, 'mxGraphModel', {
            'dx': '1600',
            'dy': '1200',
            'grid': '1',
            'gridSize': '10',
            'guides': '1',
            'tooltips': '1',
            'connect': '1',
            'arrows': '1',
            'fold': '1',
            'page': '1',
            'pageScale': '1',
            'pageWidth': str(width),
            'pageHeight': str(height),
            'math': '0',
            'shadow': '0'
        })
        r = ET.SubElement(gm, 'root')
        ET.SubElement(r, 'mxCell', {'id': '0'})
        ET.SubElement(r, 'mxCell', {'id': '1', 'parent': '0'})

        def add_v(cell_id, value, style, x, y, w, h, parent='1'):
            c = ET.SubElement(r, 'mxCell', {
                'id': str(cell_id),
                'value': value,
                'style': style,
                'vertex': '1',
                'parent': str(parent)
            })
            ET.SubElement(c, 'mxGeometry', {
                'x': str(x),
                'y': str(y),
                'width': str(w),
                'height': str(h),
                'as': 'geometry'
            })
            return c

        def add_e(edge_id, source_id, target_id, style, label='', exit_x=None, exit_y=None, entry_x=None, entry_y=None, points=None):
            attribs = {
                'id': str(edge_id),
                'value': label,
                'style': style,
                'edge': '1',
                'parent': '1',
                'source': str(source_id),
                'target': str(target_id)
            }
            c = ET.SubElement(r, 'mxCell', attribs)
            geom = ET.SubElement(c, 'mxGeometry', {
                'relative': '1',
                'as': 'geometry'
            })
            if exit_x is not None or exit_y is not None:
                c.set('style', c.get('style') + f';exitX={exit_x};exitY={exit_y};exitDx=0;exitDy=0;')
            if entry_x is not None or entry_y is not None:
                c.set('style', c.get('style') + f';entryX={entry_x};entryY={entry_y};entryDx=0;entryDy=0;')
            if points:
                pts_elem = ET.SubElement(geom, 'Array', {'as': 'points'})
                for px, py in points:
                    ET.SubElement(pts_elem, 'mxPoint', {'x': str(px), 'y': str(py)})
            return c

        return add_v, add_e

    # =========================================================================
    # BUILD PLANAR 5-LANE DIAGRAM WITH ZERO LINE CROSSINGS
    # =========================================================================
    add_v, add_e = create_page('page_planar_activity', 'E-Parada Planar Activity Diagram', 1480, 1860)

    # Top Header
    add_v('hdr_title', 'E-PARADA: PLANAR UML 2.0 ACTIVITY DIAGRAM (ZERO LINE CROSSINGS)', title_style, 0, 8, 1450, 25)

    lw = 285
    lh = 1780
    y_lane = 35

    x_l1 = 15
    x_l2 = x_l1 + lw    # 300
    x_l3 = x_l2 + lw    # 585
    x_l4 = x_l3 + lw    # 870
    x_l5 = x_l4 + lw    # 1155

    add_v('lane_1', 'DRIVER\n(Flutter Client)', lane_style, x_l1, y_lane, lw, lh)
    add_v('lane_2', 'SYSTEM\n(Backend API &amp; Controller)', lane_style, x_l2, y_lane, lw, lh)
    add_v('lane_3', 'PARKING SPACE PROVIDER\n(Host Hub)', lane_style, x_l3, y_lane, lw, lh)
    add_v('lane_4', 'SYSTEM (SERVICES)\n(Checkpoint &amp; GCash Gateway)', lane_style, x_l4, y_lane, lw, lh)
    add_v('lane_5', 'SYSTEM ADMINISTRATOR\n(Console &amp; Compliance)', lane_style, x_l5, y_lane, lw, lh)

    # -------------------------------------------------------------------------
    # RANK 1: INITIAL ONBOARDING & SUBMISSION (Y: 80 - 240)
    # -------------------------------------------------------------------------
    add_v('d_start', '', start_style, 147, 85, 22, 22)
    add_v('d_open', 'Open E-Parada App / Website', act_style, 45, 120, 225, 30)
    add_v('d_reg', 'Register Account', act_style, 45, 160, 225, 30)
    add_v('d_submit_acc', 'Submit Account for Verification', act_style, 45, 200, 225, 35)

    add_v('p_start', '', start_style, 717, 85, 22, 22)
    add_v('p_reg', 'Register Host Account', act_style, 615, 120, 225, 30)
    add_v('p_submit_acc', 'Submit Account for Verification', act_style, 615, 160, 225, 35)

    add_v('a_start', '', start_style, 1287, 85, 22, 22)
    add_v('a_login', 'Log In to Admin Console', act_style, 1185, 120, 225, 30)
    add_v('a_verify_acc', 'Audit KYC &amp; Verification Requests', act_style, 1185, 200, 225, 35)

    add_v('s_rx_acc', 'Receive Account Verification Request', act_style, 330, 200, 225, 35)

    add_e('e_d01', 'd_start', 'd_open', edge_style)
    add_e('e_d02', 'd_open', 'd_reg', edge_style)
    add_e('e_d03', 'd_reg', 'd_submit_acc', edge_style)
    add_e('e_d04', 'd_submit_acc', 's_rx_acc', edge_label_style, label='[Account Request]')

    add_e('e_p01', 'p_start', 'p_reg', edge_style)
    add_e('e_p02', 'p_reg', 'p_submit_acc', edge_style)
    add_e('e_p03', 'p_submit_acc', 's_rx_acc', edge_label_style, label='[Provider Request]', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)

    add_e('e_a01', 'a_start', 'a_login', edge_style)
    add_e('e_a02', 'a_login', 'a_verify_acc', edge_style)

    # -------------------------------------------------------------------------
    # RANK 2: ACCOUNT DECISION & APPROVAL NOTIFICATION (Y: 250 - 450)
    # -------------------------------------------------------------------------
    add_v('s_ver_acc', 'Verify Submitted Account Information', act_style, 330, 250, 225, 35)
    add_v('s_dec_acc', '', dec_style, 428, 295, 28, 28)
    add_v('s_rej_acc', 'Reject and<br/>Notify Applicant', act_style, 310, 335, 115, 35)
    add_v('s_app_acc', 'Approve<br/>Account', act_style, 460, 335, 115, 35)
    add_v('s_merge_acc', '', dec_style, 428, 385, 28, 28)
    add_v('s_notify_app', 'Notify Applicant &amp; Issue Token', act_style, 330, 425, 225, 32)

    add_e('e_s01', 's_rx_acc', 's_ver_acc', edge_style)
    add_e('e_s02', 's_ver_acc', 's_dec_acc', edge_style)
    add_e('e_s03', 's_dec_acc', 's_rej_acc', edge_label_style, label='[No]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_s04', 's_dec_acc', 's_app_acc', edge_label_style, label='[Yes]', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_s05', 's_rej_acc', 's_merge_acc', edge_style, exit_x=0.5, exit_y=1, entry_x=0, entry_y=0.5)
    add_e('e_s06', 's_app_acc', 's_merge_acc', edge_style, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_e('e_s07', 's_merge_acc', 's_notify_app', edge_style)

    add_v('d_login', 'Log In to Driver Account', act_style, 45, 475, 225, 30)
    add_v('p_login', 'Log In to Provider Hub', act_style, 615, 475, 225, 30)

    add_e('e_s08', 's_notify_app', 'd_login', edge_label_style, label='[Approved]', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5, points=[(290, 441), (290, 490)])
    add_e('e_s09', 's_notify_app', 'p_login', edge_label_style, label='[Approved]', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5, points=[(575, 441), (575, 490)])

    # -------------------------------------------------------------------------
    # RANK 3: VEHICLE OCR CONFIRMATION & SPACE PARALLEL FORK (Y: 520 - 860)
    # -------------------------------------------------------------------------
    add_v('d_manage_prof', 'Manage Profile and Vehicles', act_style, 45, 520, 225, 30)
    add_v('d_add_veh', 'Add Vehicle &amp; Capture Photos', act_style, 45, 560, 225, 30)
    add_v('d_ocr_extract', 'Extract Plate Number via OCR', act_style, 45, 600, 225, 30)
    add_v('d_ocr_disp', 'Display Extracted Plate Number', act_style, 45, 640, 225, 30)
    add_v('d_ocr_dec', '', dec_style, 144, 680, 28, 28)
    add_v('d_ocr_edit', 'Edit Plate Number<br/>Manually', act_sub_style, 35, 715, 95, 35)
    add_v('d_ocr_merge', '', dec_style, 144, 760, 28, 28)
    add_v('d_ocr_save', 'Save Vehicle Information', act_style, 45, 800, 225, 30)
    add_v('d_submit_veh', 'Submit Vehicle for Verification', act_style, 45, 840, 225, 35)

    add_e('e_d05', 'd_login', 'd_manage_prof', edge_style)
    add_e('e_d06', 'd_manage_prof', 'd_add_veh', edge_style)
    add_e('e_d07', 'd_add_veh', 'd_ocr_extract', edge_style)
    add_e('e_d08', 'd_ocr_extract', 'd_ocr_disp', edge_style)
    add_e('e_d09', 'd_ocr_disp', 'd_ocr_dec', edge_style)
    add_e('e_d10', 'd_ocr_dec', 'd_ocr_edit', edge_label_style, label='[No]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_d11', 'd_ocr_edit', 'd_ocr_merge', edge_label_style, label='[Corrected: Yes]', exit_x=0.5, exit_y=1, entry_x=0, entry_y=0.5)
    add_e('e_d12', 'd_ocr_dec', 'd_ocr_merge', edge_label_style, label='[Yes]', exit_x=0.5, exit_y=1, entry_x=0.5, entry_y=0)
    add_e('e_d13', 'd_ocr_merge', 'd_ocr_save', edge_style)
    add_e('e_d14', 'd_ocr_save', 'd_submit_veh', edge_style)

    # Provider Facility Setup (Parallel Fork/Join)
    add_v('p_manage_list', 'Create / Manage Parking Listings', act_style, 615, 520, 225, 30)
    add_v('p_fork', '', joint_style, 595, 565, 265, 6)
    add_v('p_sub_img', 'Upload Images &amp;<br/>Set Dimensions', act_sub_style, 590, 585, 125, 35)
    add_v('p_sub_sched', 'Set Availability<br/>Schedule', act_sub_style, 590, 628, 125, 30)
    add_v('p_sub_rates', 'Set Rates Within<br/>Admin Range', act_sub_style, 730, 585, 125, 35)
    add_v('p_sub_types', 'Specify Supported<br/>Vehicle Types', act_sub_style, 730, 628, 125, 30)
    add_v('p_join', '', joint_style, 595, 672, 265, 6)
    add_v('p_manage_res', 'Submit Space for Approval', act_style, 615, 690, 225, 32)
    add_v('p_view_earn', 'View Earnings &amp; Availability', act_style, 615, 735, 225, 32)

    add_e('e_p04', 'p_login', 'p_manage_list', edge_style)
    add_e('e_p05', 'p_manage_list', 'p_fork', edge_style)
    add_e('e_p06', 'p_fork', 'p_sub_img', edge_style, exit_x=0.25, exit_y=1, entry_x=0.5, entry_y=0)
    add_e('e_p07', 'p_fork', 'p_sub_sched', edge_style, exit_x=0.25, exit_y=1, entry_x=0.5, entry_y=0, points=[(655, 578), (575, 578), (575, 643), (590, 643)])
    add_e('e_p08', 'p_fork', 'p_sub_rates', edge_style, exit_x=0.75, exit_y=1, entry_x=0.5, entry_y=0)
    add_e('e_p09', 'p_fork', 'p_sub_types', edge_style, exit_x=0.75, exit_y=1, entry_x=0.5, entry_y=0, points=[(795, 578), (865, 578), (865, 643), (855, 643)])
    add_e('e_p10', 'p_sub_img', 'p_join', edge_style, exit_x=0.5, exit_y=1, entry_x=0.25, entry_y=0)
    add_e('e_p11', 'p_sub_sched', 'p_join', edge_style, exit_x=0.5, exit_y=1, entry_x=0.25, entry_y=0)
    add_e('e_p12', 'p_sub_rates', 'p_join', edge_style, exit_x=0.5, exit_y=1, entry_x=0.75, entry_y=0)
    add_e('e_p13', 'p_sub_types', 'p_join', edge_style, exit_x=0.5, exit_y=1, entry_x=0.75, entry_y=0)
    add_e('e_p14', 'p_join', 'p_manage_res', edge_style)
    add_e('e_p15', 'p_manage_res', 'p_view_earn', edge_style)

    add_v('a_rates', 'Approve Space Listings &amp; Tariffs', act_style, 1185, 690, 225, 35)
    add_e('e_a03', 'p_manage_res', 'a_rates', edge_label_style, label='[Listing Review]', exit_x=1, exit_y=0.5, entry_x=0, entry_y=0.5)

    # -------------------------------------------------------------------------
    # RANK 4: VEHICLE VERIFICATION & SEARCH (Y: 860 - 1050)
    # -------------------------------------------------------------------------
    add_v('s_rx_veh', 'Receive Vehicle Information', act_style, 330, 860, 225, 35)
    add_v('s_ver_veh', 'Verify Vehicle Information &amp; OCR', act_style, 330, 910, 225, 35)
    add_v('s_veh_dec', '', dec_style, 428, 955, 28, 28)
    add_v('s_app_veh', 'Approve<br/>Vehicle', act_style, 310, 995, 115, 35)
    add_v('s_rej_veh', 'Reject and<br/>Notify Driver', act_style, 460, 995, 115, 35)
    add_v('s_veh_merge', '', dec_style, 428, 1040, 28, 28)
    add_v('s_notify_drv', 'Notify Driver of Vehicle Status', act_style, 330, 1080, 225, 28)

    add_e('e_d15', 'd_submit_veh', 's_rx_veh', edge_label_style, label='[Vehicle Request]')
    add_e('e_s10', 's_rx_veh', 's_ver_veh', edge_style)
    add_e('e_s11', 's_ver_veh', 's_veh_dec', edge_style)
    add_e('e_s12', 's_veh_dec', 's_app_veh', edge_label_style, label='[Yes]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_s13', 's_veh_dec', 's_rej_veh', edge_label_style, label='[No]', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_s14', 's_app_veh', 's_veh_merge', edge_style, exit_x=0.5, exit_y=1, entry_x=0, entry_y=0.5)
    add_e('e_s15', 's_rej_veh', 's_veh_merge', edge_style, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_e('e_s16', 's_veh_merge', 's_notify_drv', edge_style)

    add_v('d_search', 'Search / Filter Parking Spaces', act_style, 45, 1080, 225, 30)
    add_e('e_s17', 's_notify_drv', 'd_search', edge_label_style, label='[Approved]', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5)

    # -------------------------------------------------------------------------
    # RANK 5: BOOKING RESERVATION & PAYMENT (Y: 1120 - 1360)
    # -------------------------------------------------------------------------
    add_v('d_details', 'View Parking Details &amp; Select Slot', act_style, 45, 1120, 225, 30)
    add_v('d_reserve', 'Reserve Slot &amp; Lock Schedule', act_style, 45, 1160, 225, 30)
    
    add_v('s_create_res', 'Create Reservation (Pending Lock)', act_style, 330, 1160, 225, 32)
    add_v('s_sig_prov', '<b>[SEND SIGNAL]</b>: Notify Provider', send_signal_style, 330, 1205, 225, 35)

    add_v('p_rx_signal', '<b>[ACCEPT SIGNAL]</b>: Receive Booking Alert', receive_signal_style, 615, 1205, 225, 35)

    add_e('e_d16', 'd_search', 'd_details', edge_style)
    add_e('e_d17', 'd_details', 'd_reserve', edge_style)
    add_e('e_d18', 'd_reserve', 's_create_res', edge_label_style, label='[Reservation Request]')
    add_e('e_s18', 's_create_res', 's_sig_prov', edge_style)
    add_e('e_s19', 's_sig_prov', 'p_rx_signal', edge_label_style, label='[FCM Alert]')

    # Payment Decision
    add_v('d_pay_dec', '', dec_style, 144, 1210, 28, 28)
    add_v('d_pay_cash', 'Cash Payment', act_style, 30, 1250, 110, 32)
    add_v('d_pay_gcash', 'GCash Payment Intent', act_style, 160, 1250, 110, 32)
    add_v('d_pay_merge', '', dec_style, 144, 1295, 28, 28)

    add_e('e_d19', 'd_reserve', 'd_pay_dec', edge_style)
    add_e('e_d20', 'd_pay_dec', 'd_pay_cash', edge_label_style, label='[Cash]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_d21', 'd_pay_dec', 'd_pay_gcash', edge_label_style, label='[GCash]', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_d22', 'd_pay_cash', 'd_pay_merge', edge_style, exit_x=0.5, exit_y=1, entry_x=0, entry_y=0.5)
    add_e('e_d23', 'd_pay_gcash', 'd_pay_merge', edge_style, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)

    add_v('s_rec_pay', 'Record Payment &amp; Issue QR Pass', act_style, 330, 1295, 225, 32)
    add_v('d_view_hist', 'View Confirmed Dynamic QR Pass', act_style, 45, 1340, 225, 32)

    add_e('e_d24', 'd_pay_merge', 's_rec_pay', edge_style)
    add_e('e_s20', 's_rec_pay', 'd_view_hist', edge_label_style, label='[Pass Issued]', exit_x=0, exit_y=0.5, entry_x=1, entry_y=0.5, points=[(310, 1311), (310, 1356)])

    # -------------------------------------------------------------------------
    # RANK 6: CHECKPOINT ENTRY & ACTIVE SESSION (Y: 1380 - 1530)
    # -------------------------------------------------------------------------
    add_v('p_scan_in', 'Scan Driver QR Code (Entry)', act_style, 615, 1380, 225, 35)
    add_v('srv_val_in', 'Validate Entry QR Credential', act_style, 900, 1380, 225, 35)
    add_v('srv_in_dec', '', dec_style, 998, 1425, 28, 28)
    add_v('srv_denied', 'Access Denied / Error Alert', act_style, 1040, 1460, 110, 32)
    add_v('srv_ff_in', '', flow_final_style, 1085, 1500, 18, 18)
    add_v('srv_rec_in', 'Record Time-In &amp; Occupy Slot', act_style, 885, 1460, 125, 32)

    add_e('e_p16', 'p_rx_signal', 'p_scan_in', edge_style)
    add_e('e_p17', 'p_scan_in', 'srv_val_in', edge_label_style, label='[Entry Scan]')
    add_e('e_srv01', 'srv_val_in', 'srv_in_dec', edge_style)
    add_e('e_srv02', 'srv_in_dec', 'srv_denied', edge_label_style, label='[No]', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_srv03', 'srv_denied', 'srv_ff_in', edge_style)
    add_e('e_srv04', 'srv_in_dec', 'srv_rec_in', edge_label_style, label='[Yes]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)

    # In-App Communication
    add_v('d_comm', 'Communicate for Approved Reservation', act_style, 45, 1385, 225, 32)
    add_v('d_comm_dec', '', dec_style, 144, 1430, 28, 28)
    add_v('d_comm_msg', 'In-app<br/>Messaging', act_style, 35, 1465, 100, 30)
    add_v('d_comm_call', 'In-app Audio<br/>Calling', act_style, 160, 1465, 100, 30)
    add_v('d_comm_merge', '', dec_style, 144, 1505, 28, 28)
    add_v('d_rx_notif', 'Receive Real-Time Status Alerts', act_style, 45, 1540, 225, 30)

    add_e('e_d25', 'd_view_hist', 'd_comm', edge_style)
    add_e('e_d26', 'd_comm', 'd_comm_dec', edge_style)
    add_e('e_d27', 'd_comm_dec', 'd_comm_msg', edge_label_style, label='[Message]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_d28', 'd_comm_dec', 'd_comm_call', edge_label_style, label='[Call]', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_d29', 'd_comm_msg', 'd_comm_merge', edge_style, exit_x=0.5, exit_y=1, entry_x=0, entry_y=0.5)
    add_e('e_d30', 'd_comm_call', 'd_comm_merge', edge_style, exit_x=0.5, exit_y=1, entry_x=1, entry_y=0.5)
    add_e('e_d31', 'd_comm_merge', 'd_rx_notif', edge_style)

    # -------------------------------------------------------------------------
    # RANK 7: CHECKPOINT EXIT, OVERSTAY BILLING & END (Y: 1580 - 1760)
    # -------------------------------------------------------------------------
    add_v('p_scan_out', 'Scan Driver QR Code (Exit)', act_style, 615, 1580, 225, 35)
    add_v('srv_val_out', 'Validate Exit QR Credential', act_style, 900, 1580, 225, 35)
    add_v('srv_out_dec', '', dec_style, 998, 1625, 28, 28)

    add_v('srv_rec_out', 'Record Time-Out &amp; Duration', act_style, 885, 1665, 115, 32)
    add_v('srv_slot_avail', 'Update Slot Status: Available', act_style, 900, 1710, 225, 30)
    add_v('srv_final', '', end_style, 1001, 1755, 22, 22)

    add_v('srv_manual_val', 'Manual RES-# Lookup', act_style, 1025, 1665, 110, 32)
    add_v('srv_man_dec', '', dec_style, 1066, 1710, 28, 28)
    add_v('srv_rej_out', 'Reject Exit', act_style, 1005, 1745, 65, 25)
    add_v('srv_ff_man', '', flow_final_style, 1030, 1780, 18, 18)

    add_e('e_p18', 'p_scan_in', 'p_scan_out', edge_style)
    add_e('e_p19', 'p_scan_out', 'srv_val_out', edge_label_style, label='[Exit Scan]')
    add_e('e_srv05', 'srv_val_out', 'srv_out_dec', edge_style)
    add_e('e_srv06', 'srv_out_dec', 'srv_rec_out', edge_label_style, label='[Valid]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_srv07', 'srv_rec_out', 'srv_slot_avail', edge_style)
    add_e('e_srv08', 'srv_slot_avail', 'srv_final', edge_style)

    add_e('e_srv09', 'srv_out_dec', 'srv_manual_val', edge_label_style, label='[Invalid]', exit_x=1, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_srv10', 'srv_manual_val', 'srv_man_dec', edge_style)
    add_e('e_srv11', 'srv_man_dec', 'srv_rej_out', edge_label_style, label='[No]', exit_x=0, exit_y=0.5, entry_x=0.5, entry_y=0)
    add_e('e_srv12', 'srv_rej_out', 'srv_ff_man', edge_style)
    add_e('e_srv13', 'srv_man_dec', 'srv_slot_avail', edge_label_style, label='[Yes]', exit_x=1, exit_y=0.5, entry_x=1, entry_y=0.5, points=[(1145, 1724), (1145, 1725)])

    # Driver & Provider Final Nodes
    add_v('d_final', '', end_style, 147, 1610, 22, 22)
    add_v('p_final', '', end_style, 717, 1640, 22, 22)
    add_e('e_d32', 'd_rx_notif', 'd_final', edge_style)
    add_e('e_p20', 'p_scan_out', 'p_final', edge_style)

    # Admin Final Actions
    add_v('a_monitor', 'Monitor Live Reservations &amp; QR', act_style, 1185, 1050, 225, 32)
    add_v('a_complaints', 'Manage Complaints &amp; Violations', act_style, 1185, 1092, 225, 32)
    add_v('a_reports', 'Generate System Financial Reports', act_style, 1185, 1132, 225, 30)
    add_v('a_logs', 'Audit Immutable Activity Logs', act_style, 1185, 1172, 225, 30)
    add_v('a_final', '', end_style, 1287, 1220, 22, 22)

    add_e('e_a04', 'a_rates', 'a_monitor', edge_style)
    add_e('e_a05', 'a_monitor', 'a_complaints', edge_style)
    add_e('e_a06', 'a_complaints', 'a_reports', edge_style)
    add_e('e_a07', 'a_reports', 'a_logs', edge_style)
    add_e('e_a08', 'a_logs', 'a_final', edge_style)

    # Format and write XML
    rough_string = ET.tostring(mxfile, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    pretty_xml = reparsed.toprettyxml(indent="  ", encoding="utf-8").decode("utf-8")
    pretty_xml = "\n".join([line for line in pretty_xml.split("\n") if line.strip()])

    workspace_path = r'c:\Users\kimch\e_parada_mobile'
    file_path_drawio = os.path.join(workspace_path, 'e_parada_activity_diagram.drawio')
    file_path_xml = os.path.join(workspace_path, 'e_parada_activity_diagram.drawio.xml')

    with open(file_path_drawio, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)

    with open(file_path_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)

    print(f"Successfully generated Planar Zero-Crossing Activity Diagram:\n  - {file_path_drawio}\n  - {file_path_xml}")

if __name__ == '__main__':
    generate_planar_zero_crossing_activity_diagram()
