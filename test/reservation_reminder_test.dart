import 'package:e_parada_mobile/services/reservation_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ReservationReminderService generates arrival reminder, checkpoint confirmation, and overstay alert', () async {
    final arrivalAlert = ReservationReminderService.createArrivalReminder(
      spaceName: 'Laguna Central Parking',
      reservationRef: 'RES-101',
      scheduledStart: DateTime(2026, 8, 16, 9, 0),
    );

    expect(arrivalAlert.type, equals(AlertType.arrivalReminder));
    expect(arrivalAlert.title, contains('Arrival Reminder'));
    expect(arrivalAlert.message, contains('Laguna Central Parking'));
    expect(arrivalAlert.message, contains('RES-101'));

    final checkpointAlert = ReservationReminderService.createCheckpointConfirmation(
      spaceName: 'Laguna Central Parking',
      reservationRef: 'RES-101',
      isEntry: true,
      time: DateTime(2026, 8, 16, 9, 5),
    );

    expect(checkpointAlert.type, equals(AlertType.checkpointScan));
    expect(checkpointAlert.title, contains('Check-In Verified'));
    expect(checkpointAlert.message, contains('15-minute billing grace period'));

    final overstayAlert = ReservationReminderService.createOverstayWarning(
      spaceName: 'Laguna Central Parking',
      reservationRef: 'RES-101',
      overstayMinutes: 30,
      overstayFee: 50.0,
    );

    expect(overstayAlert.type, equals(AlertType.overstayWarning));
    expect(overstayAlert.title, contains('Overstay Grace Window Alert'));
    expect(overstayAlert.message, contains('30 mins overstay'));
    expect(overstayAlert.message, contains('₱50.00'));

    // Test saving and fetching
    await ReservationReminderService.saveAlert(arrivalAlert);
    final alerts = await ReservationReminderService.fetchAlerts();
    expect(alerts.length, equals(1));
    expect(alerts.first.reservationRef, equals('RES-101'));
  });
}
