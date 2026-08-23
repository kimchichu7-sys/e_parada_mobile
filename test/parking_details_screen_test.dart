import 'package:e_parada_mobile/screens/parking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('open parking space can start a reservation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: ParkingDetailsScreen(
          parkingSpaceId: 3,
          parkingName: 'Sample Parking',
          address: 'Calamba, Laguna',
          status: 'Open',
          price: 'PHP 50 /hr',
          description: 'A test parking space.',
          supportedVehicles: ['Car'],
          operatingHours: '6:00 AM - 10:00 PM',
          latitude: 14.2117,
          longitude: 121.1653,
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Reserve This Space'),
    );

    expect(button.onPressed, isNotNull);
    expect(find.textContaining('6:00 AM - 10:00 PM'), findsOneWidget);
    expect(find.text('Open Directions'), findsOneWidget);
  });

  testWidgets('closed-now parking still allows a future schedule', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: ParkingDetailsScreen(
          parkingSpaceId: 3,
          parkingName: 'Sample Parking',
          address: 'Calamba, Laguna',
          status: 'Closed',
          price: 'PHP 50 /hr',
          description: 'A test parking space.',
          supportedVehicles: ['Car'],
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Reserve This Space'),
    );

    expect(button.onPressed, isNotNull);
  });
}
