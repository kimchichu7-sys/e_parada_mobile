import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_parada_mobile/models/auth_user.dart';
import 'package:e_parada_mobile/models/parking_space.dart';
import 'package:e_parada_mobile/screens/find_screen.dart';
import 'package:e_parada_mobile/screens/main_navigation_screen.dart';

final testDriverUser = AuthUser.fromJson({
  'id': 1,
  'name': 'Test Driver',
  'email': 'driver@eparada.ph',
  'role': 'driver',
  'verification_status': 'verified',
  'email_verified': true,
  'has_approved_vehicle': true,
  'can_reserve': true,
  'can_manage_parking_spaces': false,
  'remaining_vehicle_slots': 3,
});

final List<ParkingSpace> sampleSpaces = [
  ParkingSpace.fromJson({
    'id': 1,
    'space_name': 'SM Calamba Parking',
    'name': 'SM Calamba Parking',
    'address': 'National Highway, Calamba City, Laguna',
    'status': 'available',
    'is_open_now': true,
    'is_open_24_hours': false,
    'operating_hours': '9:00 AM - 10:00 PM',
    'price': '₱20.00 / hour',
    'description': 'Multi-level secure mall parking facility with CCTV.',
    'supported_vehicles': ['Car', 'SUV/MPV', 'Motorcycle'],
    'available_slots_count': 42,
    'latitude': 14.2050,
    'longitude': 121.1600,
  }),
  ParkingSpace.fromJson({
    'id': 2,
    'space_name': 'VOGMES Parking Space',
    'name': 'VOGMES Parking Space',
    'address': '085 Candelaria, Balian, Pangil',
    'status': 'available',
    'is_open_now': true,
    'is_open_24_hours': false,
    'operating_hours': '8:00 AM - 8:00 PM',
    'price': '₱10.00 / hour',
    'description': 'Spacious open-air parking with dedicated slots.',
    'supported_vehicles': ['Car', 'Motorcycle'],
    'available_slots_count': 6,
    'latitude': 14.4000,
    'longitude': 121.4800,
  }),
];

void main() {
  group('Driver Navigation and FindScreen Tests', () {
    testWidgets('MainNavigationScreen has 4 Driver tabs: Find, Booking, Garage, Profile', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: MainNavigationScreen(user: testDriverUser),
        ),
      );
      await tester.pump();

      // Navigation bar exists
      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);

      // Verify the 4 tabs requested by user
      expect(find.text('Find'), findsOneWidget);
      expect(find.text('Booking'), findsOneWidget);
      expect(find.text('Garage'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify 'Home' and 'Map' are REMOVED
      expect(find.text('Home'), findsNothing);
      expect(find.text('Map'), findsNothing);
    });

    testWidgets('FindScreen renders top filter header with search bar, arrive after, exit before, vehicle type, apply', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FindScreen(
            loadParkingSpaces: () async => sampleSpaces,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Search Bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Address, Place or Event...'), findsOneWidget);

      // 2. Arrive After & Exit Before
      expect(find.text('ARRIVE AFTER'), findsOneWidget);
      expect(find.text('EXIT BEFORE'), findsOneWidget);

      // 3. Vehicle Type dropdown
      expect(find.text('VEHICLE TYPE'), findsOneWidget);
      expect(find.text('All Vehicle Types'), findsOneWidget);

      // 4. Apply Button
      expect(find.text('APPLY'), findsOneWidget);

      // 5. View Mode switcher (MAP & GRID)
      expect(find.text('MAP'), findsOneWidget);
      expect(find.text('GRID'), findsOneWidget);

      // 6. Location Services Banner
      expect(find.textContaining('Tap here to enable location services'), findsOneWidget);
    });

    testWidgets('FindScreen switches to GRID view and displays parking space cards with actions', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FindScreen(
            loadParkingSpaces: () async => sampleSpaces,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap GRID toggle
      await tester.tap(find.text('GRID'));
      await tester.pumpAndSettle();

      // Verify cards appear
      expect(find.text('SM Calamba Parking'), findsOneWidget);
      expect(find.text('VOGMES Parking Space'), findsOneWidget);
      expect(find.text('BOOK NOW'), findsNWidgets(2));
      expect(find.text('Directions'), findsNWidgets(2));
      expect(find.text('DETAILS'), findsNWidgets(2));
    });

    testWidgets('Search bar uses dark text style and preserves spaces when searching a general place', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FindScreen(
            loadParkingSpaces: () async => sampleSpaces,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.color, const Color(0xFF0F172A)); // Dark slate text, visible on white!

      // Type general place
      await tester.enterText(find.byType(TextField), 'Calamba Laguna');
      await tester.pumpAndSettle();

      // Tap GRID to check that spaces remain visible
      await tester.tap(find.text('GRID'));
      await tester.pumpAndSettle();

      expect(find.text('SM Calamba Parking'), findsOneWidget);
    });
  });
}

