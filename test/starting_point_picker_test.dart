import 'package:e_parada_mobile/models/parking_space.dart';
import 'package:e_parada_mobile/screens/interactive_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleSpace = ParkingSpace(
    id: 10,
    name: 'Canlubang Tech Hub',
    address: 'Canlubang IT Park, Calamba',
    status: 'Open',
    isOpenNow: true,
    isOpen24Hours: true,
    operatingHours: 'Open 24 hours',
    price: '₱30/hour',
    description: 'Covered and secure parking bays',
    supportedVehicles: ['Car', 'Motorcycle'],
    latitude: 14.2185,
    longitude: 121.1415,
    imageUrl: null,
  );

  testWidgets('MapScreen renders Route Planning Header with interactive origin box', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapScreen(
            loadParkingSpaces: () async => const [sampleSpace],
            initialSelectedSpace: sampleSpace,
            focusedParkingSpaceId: sampleSpace.id,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify origin box is present with tap-to-change prompt
    expect(find.textContaining('Your location'), findsWidgets);
    expect(find.textContaining('Tap to input custom starting point'), findsOneWidget);
    expect(find.byTooltip('Change or swap starting point'), findsOneWidget);

    // Tap on the origin box to open the starting point picker modal
    await tester.tap(find.textContaining('Tap to input custom starting point'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Starting Point modal appears
    expect(find.text('Set Starting Point'), findsOneWidget);
    expect(find.text('Your Location (Live GPS)'), findsOneWidget);
    expect(find.text('Choose on Map'), findsOneWidget);
    expect(find.text('Calamba Landmarks & Hubs'), findsOneWidget);
    expect(find.text('SM City Calamba'), findsOneWidget);

    // Select a Calamba landmark (e.g. SM City Calamba)
    await tester.tap(find.text('SM City Calamba'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Modal is dismissed, and origin header now reflects the custom starting point
    expect(find.text('Set Starting Point'), findsNothing);
    expect(find.text('SM City Calamba'), findsWidgets);
    expect(find.text('Custom'), findsWidgets);
    expect(find.textContaining('Custom origin • Tap to change'), findsOneWidget);

    // Verify 1-tap reset to GPS (close button on custom badge)
    expect(find.byTooltip('Reset to Live GPS'), findsOneWidget);
    await tester.tap(find.byTooltip('Reset to Live GPS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Reset back to GPS / starting point estimation
    expect(find.byTooltip('Reset to Live GPS'), findsNothing);
    expect(find.textContaining('Tap to input custom starting point'), findsOneWidget);
  });
}
