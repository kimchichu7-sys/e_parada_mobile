import 'package:e_parada_mobile/models/parking_space.dart';
import 'package:e_parada_mobile/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('parking map renders markers and filters search results', (
    tester,
  ) async {
    const parkingSpace = ParkingSpace(
      id: 7,
      name: 'Calamba Central Parking',
      address: 'Calamba, Laguna',
      status: 'Open',
      isOpenNow: true,
      isOpen24Hours: true,
      operatingHours: 'Open 24 hours',
      price: '₱30/hour',
      description: 'Covered parking',
      supportedVehicles: ['Car'],
      latitude: 14.2117,
      longitude: 121.1653,
      imageUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          loadParkingSpaces: () async => const [parkingSpace],
          initialLatitude: 14.211,
          initialLongitude: 121.1653,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Real mobile map will go here next phase'), findsNothing);
    expect(find.text('Available Nearby'), findsOneWidget);
    expect(find.text('1 found'), findsOneWidget);
    expect(find.text('Calamba Central Parking'), findsOneWidget);
    expect(find.textContaining('m away'), findsWidgets);
    expect(find.byTooltip('Navigate'), findsWidgets);
    expect(find.byTooltip('Filters'), findsOneWidget);

    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Find the right parking'), findsOneWidget);

    await tester.tap(find.text('Car'));
    await tester.tap(find.text('Nearest'));
    await tester.ensureVisible(find.text('Apply filters'));
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();

    expect(find.text('Nearest Parking'), findsOneWidget);
    expect(find.text('1 found'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'a location that does not exist',
    );
    await tester.pump();

    expect(find.text('0 found'), findsOneWidget);
    expect(find.text('No parking spaces found'), findsOneWidget);
  });
}
