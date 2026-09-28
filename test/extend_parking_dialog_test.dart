import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/widgets/extend_parking_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleReservation = DriverReservation.fromJson({
    'id': 101,
    'backup_reference': 'RES-EXT101',
    'parking_space_id': 5,
    'parking_space_name': 'Ayala Malls Parking Slot A-1',
    'parking_space_address': 'Makati City, Metro Manila',
    'owner_name': 'Juan Dela Cruz',
    'driver_name': 'Kim Driver',
    'plate_number': 'ABC 1234',
    'vehicle_type': 'sedan',
    'slot_number': 1,
    'slot_label': 'Slot #1',
    'schedule_label': '2026-09-10 10:00 - 12:00',
    'reservation_date': '2026-09-10',
    'end_date': '2026-09-10',
    'start_time': '10:00',
    'end_time': '12:00',
    'status': 'approved',
    'total_amount': 100.0,
    'qr_code': 'EPARADA-EXT-101',
  });

  testWidgets('ExtendParkingDialog renders presets and computes new schedule', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExtendParkingDialog(reservation: sampleReservation),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Extend Parking Time'), findsOneWidget);
    expect(find.textContaining('Ayala Malls'), findsWidgets);
    expect(find.text('+30 mins'), findsOneWidget);
    expect(find.text('+1 hr'), findsOneWidget);
    expect(find.text('+2 hrs'), findsOneWidget);
    expect(find.text('+3 hrs'), findsOneWidget);
    expect(find.text('Custom Picker'), findsOneWidget);
    expect(find.text('Request Extension'), findsOneWidget);

    // Tap +2 hrs
    await tester.tap(find.text('+2 hrs'));
    await tester.pumpAndSettle();

    expect(find.textContaining('14:00'), findsOneWidget);
    expect(find.textContaining('Estimated additional cost'), findsOneWidget);
  });
}
