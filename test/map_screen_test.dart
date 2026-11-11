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

    // Filter via search
    await tester.enterText(find.byType(TextField).first, 'Unknown Location');
    await tester.pump();
    expect(find.text('0 found'), findsOneWidget);

    // Clear search
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('1 found'), findsOneWidget);
  });

  testWidgets('MapScreen activates in-app route mode and renders Polyline with ETA banner', (
    tester,
  ) async {
    const space = ParkingSpace(
      id: 99,
      name: 'Laguna Technopark Gate 1 Parking',
      address: 'Biñan / Santa Rosa, Laguna',
      status: 'Open',
      isOpenNow: true,
      isOpen24Hours: true,
      operatingHours: 'Open 24 hours',
      price: '₱40/hour',
      description: 'Technopark secure parking',
      supportedVehicles: ['Car', 'Motorcycle'],
      latitude: 14.2800,
      longitude: 121.1000,
      imageUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          loadParkingSpaces: () async => const [space],
          initialLatitude: 14.2200,
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
    final polylineLayer = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
    expect(polylineLayer.polylines, isNotEmpty);
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

    expect(find.textContaining('Depart from'), findsOneWidget);
    expect(find.text('Hide directions'), findsOneWidget);

    // Switch starting point via interactive origin picker
    expect(find.byTooltip('Change or swap starting point'), findsOneWidget);
    await tester.tap(find.byTooltip('Change or swap starting point'));
    await tester.pumpAndSettle();

    expect(find.text('Set Starting Point'), findsOneWidget);
    await tester.tap(find.byTooltip('Close').first);
    await tester.pumpAndSettle();
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
      description: 'Lakeside open-air parking',
      supportedVehicles: ['Car'],
      latitude: 14.2380,
      longitude: 121.0580,
      imageUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          loadParkingSpaces: () async => const [space],
          focusedParkingSpaceId: 101,
          startNavigationMode: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(FlutterMap), findsOneWidget);
    final polylineLayer = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
    expect(polylineLayer.polylines, isNotEmpty);
    expect(find.text('IN-APP ROUTE'), findsWidgets);
    expect(find.text('Nuvali Lakeside Parking'), findsWidgets);
    expect(find.textContaining('Your location'), findsOneWidget);
  });

  testWidgets('selective marker filtering: route mode renders polyline, close route restores browse mode', (
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

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          loadParkingSpaces: () async => const [space1],
          initialLatitude: 14.2100,
          initialLongitude: 121.1600,
          focusedParkingSpaceId: 1,
          initialSelectedSpace: space1,
          startNavigationMode: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // In Route Mode: polyline is active
    var polylineLayer = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
    expect(polylineLayer.polylines, isNotEmpty);
    expect(find.text('IN-APP ROUTE'), findsWidgets);
    expect(find.textContaining('Your location'), findsOneWidget);

    // Close Route: Returns to Browse Mode
    await tester.tap(find.byTooltip('Close route').first);
    await tester.pumpAndSettle();

    polylineLayer = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
    expect(polylineLayer.polylines, isEmpty);
  });
}
