import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/widgets/live_overstay_tracker_card.dart';

void main() {
  DriverReservation buildReservation({
    String reservationDate = '2026-09-10',
    String endDate = '2026-09-10',
    String startTime = '10:00',
    String endTime = '14:00',
    String status = 'approved',
    String extensionStatus = '',
    double totalAmount = 100.0,
    double totalHours = 4.0,
    bool canExtend = true,
  }) {
    return DriverReservation(
      id: 101,
      backupReference: 'EPARADA-GATE-1001',
      qrCode: 'EPARADA-GATE-1001',
      parkingSpaceName: 'SM City Calamba Multi-Level Carpark',
      parkingSpaceAddress: 'National Highway, Calamba',
      ownerName: 'Juan Dela Cruz',
      slotLabel: 'Bay A-1',
      vehicleId: 1,
      plateNumber: 'NBI 9999',
      vehicleType: 'SUV/MPV',
      reservationDate: reservationDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      status: status,
      ownerNotes: '',
      totalHours: totalHours,
      totalAmount: totalAmount,
      paymentStatus: 'unpaid',
      paymentMethod: '',
      timeIn: null,
      timeOut: null,
      feedbackRating: null,
      feedbackComment: '',
      extensionStatus: extensionStatus,
      extensionEndDate: '',
      extensionEndTime: '',
      extensionReason: '',
      extensionOwnerNotes: '',
      overstayStatus: 'normal',
      overstayMinutes: 0,
      overstayAmount: 0.0,
      canCancel: false,
      canReschedule: false,
      canExtend: canExtend,
      canSubmitPayment: false,
      canSubmitFeedback: false,
    );
  }

  testWidgets('LiveOverstayTrackerCard renders active normal countdown state', (tester) async {
    final res = buildReservation(
      reservationDate: '2026-09-10',
      endDate: '2026-09-10',
      startTime: '10:00',
      endTime: '14:00',
    );
    // Mock current time at 11:30:00 (2h 30m remaining)
    final mockNow = DateTime(2026, 9, 10, 11, 30, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveOverstayTrackerCard(
            reservation: res,
            mockNow: mockNow,
          ),
        ),
      ),
    );

    expect(find.text('PARKING SESSION ACTIVE'), findsOneWidget);
    expect(find.textContaining('02h 30m 00s remaining'), findsOneWidget);
    expect(find.textContaining('Expires at 14:00'), findsOneWidget);
    expect(find.text('+30m'), findsOneWidget);
    expect(find.text('+1h'), findsOneWidget);
    expect(find.text('+2h'), findsOneWidget);
    expect(find.text('Custom...'), findsOneWidget);
  });

  testWidgets('LiveOverstayTrackerCard renders expiring soon warning state (< 15 mins)', (tester) async {
    final res = buildReservation(
      reservationDate: '2026-09-10',
      endDate: '2026-09-10',
      startTime: '10:00',
      endTime: '14:00',
    );
    // Mock current time at 13:50:00 (10 mins remaining)
    final mockNow = DateTime(2026, 9, 10, 13, 50, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveOverstayTrackerCard(
            reservation: res,
            mockNow: mockNow,
          ),
        ),
      ),
    );

    expect(find.text('SESSION EXPIRING SOON'), findsOneWidget);
    expect(find.textContaining('10m 00s remaining'), findsOneWidget);
    expect(find.text('Extend now to prevent grace period transition'), findsOneWidget);
  });

  testWidgets('LiveOverstayTrackerCard renders grace period active state', (tester) async {
    final res = buildReservation(
      reservationDate: '2026-09-10',
      endDate: '2026-09-10',
      startTime: '10:00',
      endTime: '14:00',
    );
    // Mock current time at 14:05:00 (5 mins past end, 10 mins grace remaining)
    final mockNow = DateTime(2026, 9, 10, 14, 5, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveOverstayTrackerCard(
            reservation: res,
            mockNow: mockNow,
            graceMinutes: 15,
          ),
        ),
      ),
    );

    expect(find.text('GRACE PERIOD ACTIVE (15 MINS)'), findsOneWidget);
    expect(find.textContaining('10m 00s grace remaining'), findsOneWidget);
    expect(find.text('No fee yet. Overstay charges start after grace ends.'), findsOneWidget);
  });

  testWidgets('LiveOverstayTrackerCard renders overstay penalty state', (tester) async {
    final res = buildReservation(
      reservationDate: '2026-09-10',
      endDate: '2026-09-10',
      startTime: '10:00',
      endTime: '14:00',
      totalAmount: 100.0, // PHP 25/hr
      totalHours: 4.0,
    );
    // Mock current time at 14:45:00 (30 mins past 15m grace end = 1 billable hour = PHP 25)
    final mockNow = DateTime(2026, 9, 10, 14, 45, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveOverstayTrackerCard(
            reservation: res,
            mockNow: mockNow,
            graceMinutes: 15,
          ),
        ),
      ),
    );

    expect(find.textContaining('OVERSTAY ACTIVE'), findsOneWidget);
    expect(find.textContaining('overstay'), findsWidgets);
    expect(find.textContaining('+PHP 25'), findsOneWidget);
    expect(find.textContaining('Est. overstay fee: PHP 25.00'), findsOneWidget);
  });

  testWidgets('LiveOverstayTrackerCard displays pending extension review banner', (tester) async {
    final res = buildReservation(
      extensionStatus: 'pending',
      canExtend: true,
    );
    final mockNow = DateTime(2026, 9, 10, 11, 0, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveOverstayTrackerCard(
            reservation: res,
            mockNow: mockNow,
          ),
        ),
      ),
    );

    expect(find.text('Extension request under owner review...'), findsOneWidget);
    expect(find.text('+30m'), findsNothing);
  });

  testWidgets('LiveOverstayTrackerCard renders compact mode for gate pass dialog', (tester) async {
    final res = buildReservation(
      reservationDate: '2026-09-10',
      endDate: '2026-09-10',
      startTime: '10:00',
      endTime: '14:00',
    );
    final mockNow = DateTime(2026, 9, 10, 11, 0, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveOverstayTrackerCard(
            reservation: res,
            mockNow: mockNow,
            isCompact: true,
          ),
        ),
      ),
    );

    expect(find.text('PARKING SESSION ACTIVE'), findsOneWidget);
    expect(find.text('Extend'), findsOneWidget);
  });
}
