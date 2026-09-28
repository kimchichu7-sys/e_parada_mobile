import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/widgets/digital_receipt_dialog.dart';

void main() {
  testWidgets('DigitalReceiptDialog renders BIR-compliant tax breakdown and QR stamp', (tester) async {
    final reservation = DriverReservation(
      id: 202,
      backupReference: 'EPARADA-GATE-202',
      qrCode: 'EPARADA-GATE-202',
      parkingSpaceName: 'Crossing Central Terminal Parking Bay',
      parkingSpaceAddress: 'Crossing, Calamba City',
      ownerName: 'Maria Santos',
      slotLabel: 'Bay C-2',
      vehicleId: 2,
      plateNumber: 'NCR 5678',
      vehicleType: 'Car',
      reservationDate: '2026-09-10',
      endDate: '2026-09-10',
      startTime: '10:00',
      endTime: '14:00',
      status: 'completed',
      ownerNotes: '',
      totalHours: 4.0,
      totalAmount: 112.0, // 100 net + 12 VAT
      paymentStatus: 'paid',
      paymentMethod: 'gcash',
      timeIn: DateTime(2026, 9, 10, 10, 2),
      timeOut: DateTime(2026, 9, 10, 14, 0),
      feedbackRating: 5,
      feedbackComment: 'Great parking!',
      extensionStatus: '',
      extensionEndDate: '',
      extensionEndTime: '',
      extensionReason: '',
      extensionOwnerNotes: '',
      overstayStatus: 'normal',
      overstayMinutes: 0,
      overstayAmount: 0.0,
      canCancel: false,
      canReschedule: false,
      canExtend: false,
      canSubmitPayment: false,
      canSubmitFeedback: false,
    );

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
    expect(find.text('PAYMENT VERIFIED & SETTLED'), findsOneWidget);
    expect(find.text('DIGITAL AUTHENTICITY SEAL'), findsOneWidget);
    expect(find.text('Crossing Central Terminal Parking Bay'), findsOneWidget);
    expect(find.text('NCR 5678'), findsOneWidget);
    expect(find.text('PHP 100.00'), findsOneWidget); // Net VAT
    expect(find.text('PHP 12.00'), findsOneWidget); // 12% EVAT
    expect(find.text('PHP 112.00'), findsOneWidget); // Total
    expect(find.text('Save PDF'), findsOneWidget);
    expect(find.text('Copy Text'), findsOneWidget);
  });
}
