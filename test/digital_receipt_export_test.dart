import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/widgets/digital_receipt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DigitalReceiptDialog renders Save PDF and Copy buttons', (tester) async {
    final reservation = DriverReservation.fromJson({
      'id': 105,
      'backup_reference': 'RES-10500001',
      'qr_code': 'EPARADA-10500001',
      'parking_space': {
        'id': 7,
        'name': 'Calamba Town Center Parking',
        'address': 'Calamba, Laguna',
        'owner_name': 'Pedro Reyes',
      },
      'slot': {'id': 3, 'label': 'Bay C-1'},
      'vehicle': {'id': 12, 'plate_number': 'NQR 7890', 'vehicle_type': 'Car'},
      'reservation_date': '2026-08-18',
      'end_date': '2026-08-18',
      'start_time': '10:00',
      'end_time': '13:00',
      'status': 'completed',
      'payment_status': 'paid',
      'payment_method': 'gcash',
      'total_hours': 3.0,
      'total_amount': 180.0,
      'time_in': '2026-08-18T10:00:00Z',
      'time_out': '2026-08-18T13:00:00Z',
      'overstay': {'status': 'normal', 'minutes': 0, 'amount': 0},
      'actions': {},
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DigitalReceiptDialog.showForDriver(context, reservation),
              child: const Text('View Receipt'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();

    expect(find.text('E-Parada Official Receipt'), findsOneWidget);
    expect(find.text('Copy Text'), findsOneWidget);
    expect(find.text('Save PDF'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Tap Save PDF button
    await tester.ensureVisible(find.text('Save PDF'));
    await tester.tap(find.text('Save PDF'));
    await tester.pumpAndSettle();
    expect(find.textContaining('PDF Tax Invoice for RES-10500001 prepared & saved!'), findsOneWidget);
  });
}
