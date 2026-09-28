import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/models/parking_space.dart';
import 'package:e_parada_mobile/screens/map_screen.dart';
import 'package:e_parada_mobile/services/route_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('RouteNavigationService Math & Bearing Algorithms', () {
    test('computeBearing correctly identifies cardinal compass directions', () {
      // Heading Due North (increasing latitude)
      final northBearing = RouteNavigationService.computeBearing(
        const LatLng(14.0, 121.0),
        const LatLng(14.1, 121.0),
      );
      expect(northBearing, closeTo(0.0, 1.0));

      // Heading Due East (increasing longitude)
      final eastBearing = RouteNavigationService.computeBearing(
        const LatLng(14.0, 121.0),
        const LatLng(14.0, 121.1),
      );
      expect(eastBearing, closeTo(90.0, 1.0));

      // Heading Due South (decreasing latitude)
      final southBearing = RouteNavigationService.computeBearing(
        const LatLng(14.1, 121.0),
        const LatLng(14.0, 121.0),
      );
      expect(southBearing, closeTo(180.0, 1.0));

      // Heading Due West (decreasing longitude)
      final westBearing = RouteNavigationService.computeBearing(
        const LatLng(14.0, 121.1),
        const LatLng(14.0, 121.0),
      );
      expect(westBearing, closeTo(270.0, 1.0));
    });

    test('interpolatePosition samples path accurately across polyline segments', () {
      final polyline = [
        const LatLng(14.2000, 121.1500),
        const LatLng(14.2050, 121.1500),
        const LatLng(14.2050, 121.1550),
      ];

      // At start
      final startPos = RouteNavigationService.interpolatePosition(polyline, 0.0);
      expect(startPos.latitude, 14.2000);
      expect(startPos.longitude, 121.1500);

      // At end
      final endPos = RouteNavigationService.interpolatePosition(polyline, 1.0);
      expect(endPos.latitude, 14.2050);
      expect(endPos.longitude, 121.1550);

      // In middle
      final midPos = RouteNavigationService.interpolatePosition(polyline, 0.5);
      expect(midPos.latitude, closeTo(14.2050, 0.003));
      expect(midPos.longitude, closeTo(121.1500, 0.003));
    });

    test('computeProgress produces progressive live navigation state', () {
      final routeData = RouteNavigationService.generateFallbackRoute(
        origin: const LatLng(14.2000, 121.1500),
        destination: const LatLng(14.2100, 121.1600),
        mode: NavigationTransportMode.car,
        destinationSpace: const ParkingSpace(
          id: 1,
          name: 'Central Bay Park',
          address: 'Calamba, Laguna',
          status: 'Open',
          isOpenNow: true,
          isOpen24Hours: true,
          operatingHours: 'Open 24 hours',
          price: '₱30/hour',
          description: 'Bay parking',
          supportedVehicles: ['Car'],
          latitude: 14.2100,
          longitude: 121.1600,
          imageUrl: null,
        ),
      );

      // Progress at 25%
      final p25 = RouteNavigationService.computeProgress(
        routeData: routeData,
        progressFraction: 0.25,
      );

      expect(p25.isArrived, isFalse);
      expect(p25.progressFraction, 0.25);
      expect(p25.currentSpeedKmh, greaterThan(0));
      expect(p25.bearing, inInclusiveRange(0.0, 360.0));
      expect(p25.remainingDistanceKm, greaterThan(0));
      expect(p25.currentStep, isNotNull);

      // Progress at 100% (Arrival)
      final p100 = RouteNavigationService.computeProgress(
        routeData: routeData,
        progressFraction: 1.0,
      );

      expect(p100.isArrived, isTrue);
      expect(p100.remainingDistanceKm, 0.0);
      expect(p100.remainingEtaText, 'Arrived');
      expect(p100.currentStep.instruction, contains('Arrive at Central Bay Park'));
    });

    test('simulateNavigationStream emits incremental steps and completes', () async {
      final routeData = RouteNavigationService.generateFallbackRoute(
        origin: const LatLng(14.2000, 121.1500),
        destination: const LatLng(14.2050, 121.1550),
        mode: NavigationTransportMode.motorcycle,
      );

      final stream = RouteNavigationService.simulateNavigationStream(
        routeData: routeData,
        tickInterval: const Duration(milliseconds: 10),
        totalDurationSeconds: 0.1,
      );

      final emissions = await stream.toList();
      expect(emissions.length, greaterThanOrEqualTo(3));
      expect(emissions.first.progressFraction, 0.0);
      expect(emissions.last.isArrived, isTrue);
      expect(emissions.last.progressFraction, 1.0);
    });
  });

  group('MapScreen Live Driving Navigation HUD Widget Tests', () {
    const space = ParkingSpace(
      id: 55,
      name: 'Vista Mall Laguna Parking',
      address: 'Santa Rosa, Laguna',
      status: 'Open',
      isOpenNow: true,
      isOpen24Hours: true,
      operatingHours: 'Open 24 hours',
      price: '₱35/hour',
      description: 'Spacious guarded parking',
      supportedVehicles: ['Car', 'Motorcycle'],
      latitude: 14.2300,
      longitude: 121.1200,
      imageUrl: null,
    );

    testWidgets('MapScreen starts live driving HUD when Start Driving button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            loadParkingSpaces: () async => const [space],
            initialLatitude: 14.2200,
            initialLongitude: 121.1200,
            focusedParkingSpaceId: 55,
            initialSelectedSpace: space,
            startNavigationMode: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Start Driving'), findsWidgets);

      // Tap "Start Driving" to launch full-screen HUD
      await tester.tap(find.text('Start Driving').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Driving HUD components are visible
      expect(find.text('km/h'), findsOneWidget);
      expect(find.byTooltip('Stop Navigation'), findsOneWidget);
      expect(find.byTooltip('Center on vehicle'), findsOneWidget);
      expect(find.byTooltip('Camera Following'), findsOneWidget);
      expect(find.textContaining('left'), findsOneWidget);

      // Tap Stop Navigation button in the driving HUD
      await tester.tap(find.byTooltip('Stop Navigation'));
      await tester.pumpAndSettle();

      // Returns to Route planning mode
      expect(find.byTooltip('Stop Navigation'), findsNothing);
      expect(find.text('IN-APP ROUTE'), findsWidgets);
      expect(find.text('Start Driving'), findsWidgets);
    });

    test('Driver reservation model parses parkingSpaceId and backupReference', () {
      final jsonMap = {
        'id': 12,
        'parking_space_id': 55,
        'user_id': 1,
        'slot_id': 3,
        'vehicle_id': 4,
        'backup_reference': 'EP-2026-0910-1234',
        'plate_number': 'NDX 9283',
        'status': 'approved',
        'start_time': '2026-09-10T08:00:00.000Z',
        'end_time': '2026-09-10T12:00:00.000Z',
        'total_amount': '140.00',
        'is_paid': true,
        'payment_status': 'paid',
        'created_at': '2026-09-10T07:30:00.000Z',
      };

      final parsed = DriverReservation.fromJson(jsonMap);
      expect(parsed.parkingSpaceId, 55);
      expect(parsed.backupReference, 'EP-2026-0910-1234');
    });
  });
}
