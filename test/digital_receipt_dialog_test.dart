import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/models/owner_reservation.dart';
import 'package:e_parada_mobile/widgets/digital_receipt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DigitalReceiptDialog renders driver receipt details with grace period and settlement', (tester) async {
    final reservation = DriverReservation.fromJson({
      'id': 101,
      'backup_reference': 'RES-10123456',
      'qr_code': 'EPARADA-10123456',
      'parking_space': {
        'id': 5,
        'name': 'Laguna Central Parking',
        'address': 'Calamba City, Laguna',
        'owner_name': 'Juan Dela Cruz',
      },
      'slot': {'id': 2, 'label': 'Bay B-2'},
      'vehicle': {'id': 10, 'plate_number': 'ABC 1234', 'vehicle_type': 'Car'},
      'reservation_date': '2026-08-16',
      'end_date': '2026-08-16',
      'start_time': '09:00',
      'end_time': '12:00',
      'status': 'completed',
      'payment_status': 'paid',
      'payment_method': 'gcash',
      'total_hours': 3.0,
      'total_amount': 150.0,
      'time_in': '2026-08-16T09:05:00Z',
      'time_out': '2026-08-16T12:00:00Z',
      'overstay': {'status': 'normal', 'minutes': 0, 'amount': 0},
      'actions': {},
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DigitalReceiptDialog.showForDriver(context, reservation),
              child: const Text('Open Receipt'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Receipt'));
    await tester.pumpAndSettle();

    expect(find.text('E-Parada Official Receipt'), findsOneWidget);
    expect(find.textContaining('RES-10123456'), findsWidgets);
    expect(find.text('Laguna Central Parking'), findsOneWidget);
    expect(find.text('ABC 1234'), findsOneWidget);
    expect(find.text('Bay B-2'), findsOneWidget);
    expect(find.text('15-min deduction applied'), findsOneWidget);
    expect(find.text('PHP 150.00'), findsOneWidget);
    expect(find.text('PAYMENT VERIFIED & SETTLED'), findsOneWidget);
    expect(find.text('GCASH'), findsOneWidget);
    expect(find.text('Copy Text'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('E-Parada Official Receipt'), findsNothing);
  });

  testWidgets('DigitalReceiptDialog renders owner receipt details correctly', (tester) async {
    final ownerReservation = OwnerReservation.fromJson({
      'id': 202,
      'backup_reference': 'RES-20234567',
      'driver': {'name': 'Maria Santos'},
      'vehicle': {
        'plate_number': 'XYZ 9876',
        'vehicle_type': 'Motorcycle',
      },
      'parking_space': {'space_name': 'SM Calamba Parking'},
      'slot_label': 'M-05',
      'reservation_date': '2026-08-16',
      'end_date': '2026-08-16',
      'start_time': '14:00',
      'end_time': '16:00',
      'status': 'completed',
      'payment_status': 'paid',
      'payment_method': 'cash',
      'total_amount': 80.0,
      'time_in': '2026-08-16T14:00:00Z',
      'time_out': '2026-08-16T16:00:00Z',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DigitalReceiptDialog.showForOwner(context, ownerReservation),
              child: const Text('Open Owner Receipt'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Owner Receipt'));
    await tester.pumpAndSettle();

    expect(find.text('E-Parada Official Receipt'), findsOneWidget);
    expect(find.textContaining('RES-20234567'), findsWidgets);
    expect(find.text('SM Calamba Parking'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('XYZ 9876'), findsOneWidget);
    expect(find.text('PHP 80.00'), findsOneWidget);
    expect(find.text('CASH'), findsOneWidget);
  });
}
