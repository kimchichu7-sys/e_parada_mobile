import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/services/offline_parking_pass_service.dart';
import 'package:e_parada_mobile/widgets/offline_parking_pass_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflinePassData Model', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final pass = OfflinePassData(
        id: 42,
        backupReference: 'RES-42-9988',
        qrCode: 'EPARADA:42:SECURE_TOKEN_ABC',
        parkingSpaceName: 'Grand Central Hub',
        parkingSpaceAddress: 'Poblacion, Calamba',
        ownerName: 'Juan Dela Cruz',
        plateNumber: 'NBD-1234',
        vehicleType: 'Car',
        slotLabel: 'Bay A-1',
        scheduleLabel: 'Today, 2:00 PM - 5:00 PM',
        status: 'approved',
        cachedAt: now,
      );

      final json = pass.toJson();
      final reconstructed = OfflinePassData.fromJson(json);

      expect(reconstructed.id, 42);
      expect(reconstructed.backupReference, 'RES-42-9988');
      expect(reconstructed.qrCode, 'EPARADA:42:SECURE_TOKEN_ABC');
      expect(reconstructed.parkingSpaceName, 'Grand Central Hub');
      expect(reconstructed.plateNumber, 'NBD-1234');
      expect(reconstructed.slotLabel, 'Bay A-1');
      expect(reconstructed.status, 'approved');
    });

    test('creates valid OfflinePassData from DriverReservation', () {
      final reservation = DriverReservation.fromJson({
        'id': 101,
        'user_id': 10,
        'parking_space_id': 5,
        'parking_space_name': 'Ayala Malls Calamba',
        'parking_space_address': 'National Highway, Calamba',
        'owner_name': 'Ayala Admin',
        'vehicle_id': 2,
        'plate_number': 'XYZ-9090',
        'vehicle_type': 'Car',
        'slot_label': 'Bay B-4',
        'start_time': '2026-09-05T14:00:00.000Z',
        'end_time': '2026-09-05T17:00:00.000Z',
        'status': 'approved',
        'qr_code': 'EPARADA:101:XYZ',
        'backup_reference': 'RES-101-ABCDEF',
      });

      final pass = OfflinePassData.fromDriverReservation(reservation);
      expect(pass.id, 101);
      expect(pass.backupReference, 'RES-101-ABCDEF');
      expect(pass.qrCode, 'EPARADA:101:XYZ');
      expect(pass.parkingSpaceName, 'Ayala Malls Calamba');
      expect(pass.plateNumber, 'XYZ-9090');
      expect(pass.slotLabel, 'Bay B-4');
    });
  });

  group('OfflineParkingPassService Storage', () {
    test('caches and retrieves reservations from local storage', () async {
      final reservations = [
        DriverReservation.fromJson({
          'id': 1,
          'parking_space_name': 'Space 1',
          'plate_number': 'AAA-111',
          'status': 'approved',
          'qr_code': 'QR-1',
          'backup_reference': 'REF-1',
        }),
        DriverReservation.fromJson({
          'id': 2,
          'parking_space_name': 'Space 2',
          'plate_number': 'BBB-222',
          'status': 'completed', // Not active/credential
        }),
      ];

      await OfflineParkingPassService.cacheReservations(reservations);
      final stored = await OfflineParkingPassService.getOfflinePasses();

      expect(stored.length, 1);
      expect(stored.first.id, 1);
      expect(stored.first.parkingSpaceName, 'Space 1');

      final latest = await OfflineParkingPassService.getLatestActivePass();
      expect(latest?.id, 1);

      await OfflineParkingPassService.clearPasses();
      final afterClear = await OfflineParkingPassService.getOfflinePasses();
      expect(afterClear.isEmpty, true);
    });
  });

  group('OfflineParkingPassDialog Widget', () {
    testWidgets('renders high-contrast offline pass banner, QR code, and backup reference', (tester) async {
      final pass = OfflinePassData(
        id: 77,
        backupReference: 'RES-77-991122',
        qrCode: 'EPARADA:77:SAMPLE_QR',
        parkingSpaceName: 'Underground Level 2 Bay C-3',
        parkingSpaceAddress: 'Basement Parking, City Center',
        ownerName: 'Security Gate',
        plateNumber: 'CAR-888',
        vehicleType: 'Car',
        slotLabel: 'Bay C-3',
        scheduleLabel: 'Today, 1:00 PM - 4:00 PM',
        status: 'approved',
        cachedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => OfflineParkingPassDialog.show(context, pass),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('OFFLINE PASS (Basement Access Mode)'), findsOneWidget);
      expect(find.text('Underground Level 2 Bay C-3'), findsOneWidget);
      expect(find.text('Slot: Bay C-3 • CAR-888 (Car)'), findsOneWidget);
      expect(find.text('PERMANENT BACKUP REFERENCE CODE'), findsOneWidget);
      expect(find.text('RES-77-991122'), findsOneWidget);
      expect(find.text('Copy Code'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
