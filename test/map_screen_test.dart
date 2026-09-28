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

  testWidgets('MapScreen activates in-app route mode and renders PolylineLayer with ETA banner', (
    tester,
  ) async {
    const space = ParkingSpace(
      id: 99,
      name: 'Laguna Technopark Gate 1 Parking',
      address: 'Technopark Ave, Biñan, Laguna',
      status: 'Open',
      isOpenNow: true,
      isOpen24Hours: true,
      operatingHours: 'Open 24 hours',
      price: '₱40/hour',
      description: 'Secure open & covered bays',
      supportedVehicles: ['Car', 'Motorcycle'],
      latitude: 14.2500,
      longitude: 121.1000,
      imageUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          loadParkingSpaces: () async => const [space],
          initialLatitude: 14.2400,
          initialLongitude: 121.1000,
          focusedParkingSpaceId: 99,
          initialSelectedSpace: space,
          startNavigationMode: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.text('IN-APP ROUTE'), findsWidgets);
    expect(find.text('Laguna Technopark Gate 1 Parking'), findsWidgets);
    expect(find.textContaining('Your location'), findsOneWidget);
    expect(find.byTooltip('Drive'), findsOneWidget);
    expect(find.byTooltip('Motor'), findsOneWidget);
    expect(find.text('Reserve'), findsOneWidget);

    // Switch transport mode to Motor
    await tester.tap(find.byTooltip('Motor'));
    await tester.pumpAndSettle();

    // Toggle turn-by-turn directions accordion
    expect(find.text('View turn-by-turn directions'), findsOneWidget);
    await tester.tap(find.text('View turn-by-turn directions'));
    await tester.pumpAndSettle();

    expect(find.text('Hide directions'), findsOneWidget);
    expect(find.textContaining('Depart from your current position'), findsOneWidget);
    expect(find.textContaining('Arrive at Laguna Technopark Gate 1 Parking'), findsOneWidget);

    // Tap "Close route" (top header close button)
    await tester.tap(find.byTooltip('Close route').first);
    await tester.pumpAndSettle();

    expect(find.text('IN-APP ROUTE'), findsNothing);
  });

  testWidgets('MapScreen generates route polyline even when GPS coordinates are initially null', (
    tester,
  ) async {
    const space = ParkingSpace(
      id: 101,
      name: 'Nuvali Lakeside Parking',
      address: 'Santa Rosa, Laguna',
      status: 'Open',
      isOpenNow: true,
      isOpen24Hours: true,
      operatingHours: 'Open 24 hours',
      price: '₱50/hour',
      description: 'Open air parking near mall',
      supportedVehicles: ['Car'],
      latitude: 14.2420,
      longitude: 121.0600,
      imageUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          loadParkingSpaces: () async => const [space],
          // No initialLatitude / initialLongitude
          focusedParkingSpaceId: 101,
          startNavigationMode: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.text('IN-APP ROUTE'), findsWidgets);
    expect(find.text('Nuvali Lakeside Parking'), findsWidgets);
    expect(find.textContaining('Your location'), findsOneWidget);
  });

  testWidgets('selective marker filtering: only the selected parking space is marked in route mode, while all markers appear in browse mode', (
    tester,
  ) async {
    const space1 = ParkingSpace(
      id: 1,
      name: 'Alpha Bay Plaza',
      address: 'Calamba, Laguna',
      status: 'Open',
      isOpenNow: true,
      isOpen24Hours: true,
      operatingHours: 'Open 24 hours',
      price: '₱30/hour',
      description: 'Alpha Bay Parking',
      supportedVehicles: ['Car'],
      latitude: 14.2120,
      longitude: 121.1650,
      imageUrl: null,
    );

    const space2 = ParkingSpace(
      id: 2,
      name: 'Beta Tower Parking',
      address: 'Calamba, Laguna',
      status: 'Open',
      isOpenNow: true,
      isOpen24Hours: true,
      operatingHours: 'Open 24 hours',
      price: '₱35/hour',
      description: 'Beta Tower Parking',
      supportedVehicles: ['Car'],
      latitude: 14.2125,
      longitude: 121.1655,
      imageUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          loadParkingSpaces: () async => const [space1, space2],
          initialLatitude: 14.2100,
          initialLongitude: 121.1600,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // In Browse Mode: both spaces have markers on the map
    expect(find.bySemanticsLabel('Alpha Bay Plaza, Open'), findsOneWidget);
    expect(find.bySemanticsLabel('Beta Tower Parking, Open'), findsOneWidget);
    expect(find.byType(PolylineLayer), findsNothing);

    // Select Space 1 via the card action
    await tester.ensureVisible(find.byTooltip('Show on map').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show on map').first);
    await tester.pumpAndSettle();

    // In Route Mode: ONLY Alpha Bay Plaza destination marker is shown; Beta Tower is hidden!
    expect(find.bySemanticsLabel('Destination: Alpha Bay Plaza'), findsOneWidget);
    expect(find.bySemanticsLabel('Beta Tower Parking, Open'), findsNothing);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.text('IN-APP ROUTE'), findsWidgets);
    expect(find.textContaining('Your location'), findsOneWidget);

    // Close Route: Returns to Browse Mode and restores all parking space markers
    await tester.tap(find.byTooltip('Close route').first);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Alpha Bay Plaza, Open'), findsOneWidget);
    expect(find.bySemanticsLabel('Beta Tower Parking, Open'), findsOneWidget);
    expect(find.byType(PolylineLayer), findsNothing);
  });
}


