import 'package:e_parada_mobile/widgets/reservation_credential_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('shows a scannable QR code and permanent backup reference', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showReservationCredentialDialog(
                context: context,
                qrCode: 'EPARADA-TEST-CREDENTIAL',
                backupReference: 'RES-125',
                parkingSpaceName: 'Calamba Test Parking',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('RES-125'), findsOneWidget);
    expect(find.text('Calamba Test Parking'), findsOneWidget);
    expect(find.byTooltip('Copy backup reference'), findsOneWidget);
  });

  testWidgets(
    'keeps backup entry available when QR generation is unavailable',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showReservationCredentialDialog(
                  context: context,
                  qrCode: '',
                  backupReference: 'RES-9',
                  parkingSpaceName: 'Backup Parking',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsNothing);
      expect(find.text('RES-9'), findsOneWidget);
      expect(
        find.text(
          'The QR image is unavailable. Use the backup reference below.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('reservation progress reflects entry, exit, and payment', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReservationProgressTracker(
            status: 'completed',
            paymentStatus: 'pending_verification',
            timeIn: DateTime(2026, 8, 20, 9),
            timeOut: DateTime(2026, 8, 20, 11),
          ),
        ),
      ),
    );

    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('Checked in'), findsOneWidget);
    expect(find.text('Checked out'), findsOneWidget);
    expect(find.text('Payment sent'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
  });
}
