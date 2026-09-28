import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/widgets/security_gate_pass_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleReservation = DriverReservation.fromJson({
    'id': 202,
    'backup_reference': 'RES-GATE202',
    'parking_space_id': 8,
    'parking_space_name': 'Serendra B2 Parking',
    'parking_space_address': 'BGC, Taguig City',
    'owner_name': 'Security Master',
    'driver_name': 'Kim Driver',
    'plate_number': 'NBI 9999',
    'vehicle_type': 'suv',
    'slot_number': 12,
    'slot_label': 'Slot #12',
    'schedule_label': '2026-09-10 08:00 - 18:00',
    'reservation_date': '2026-09-10',
    'end_date': '2026-09-10',
    'start_time': '08:00',
    'end_time': '18:00',
    'status': 'approved',
    'total_amount': 250.0,
    'qr_code': 'EPARADA-GATE-202',
  });

  testWidgets('SecurityGatePassDialog renders pass details and buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecurityGatePassDialog(
            reservation: sampleReservation,
            vehicleMakeModel: 'Toyota Fortuner',
            vehicleColor: 'Silver Metallic',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Security Gate Pass'), findsOneWidget);
    expect(find.text('SECURITY VERIFIED'), findsOneWidget);
    expect(find.text(sampleReservation.backupReference), findsWidgets);
    expect(find.text('NBI 9999'), findsOneWidget);
    expect(find.text('Slot #12'), findsOneWidget);
    expect(find.textContaining('Toyota Fortuner'), findsOneWidget);
    expect(find.text('Download Pass (PDF)'), findsOneWidget);
  });
}
