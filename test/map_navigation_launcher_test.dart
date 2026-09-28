import 'package:e_parada_mobile/utils/map_navigation_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapNavigationLauncher URI Builders', () {
    test('googleMapsUri creates valid destination URL with coordinates and address', () {
      final uri = MapNavigationLauncher.googleMapsUri(
        latitude: 14.2117,
        longitude: 121.1653,
        address: 'Calamba City, Laguna',
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['api'], '1');
      expect(uri.queryParameters['destination'], '14.2117,121.1653');
      expect(uri.queryParameters['destination_place_id'], 'Calamba City, Laguna');
    });

    test('wazeUri creates valid navigation URL with ll parameters', () {
      final uri = MapNavigationLauncher.wazeUri(
        latitude: 14.5995,
        longitude: 120.9842,
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'waze.com');
      expect(uri.path, '/ul');
      expect(uri.queryParameters['ll'], '14.5995,120.9842');
      expect(uri.queryParameters['navigate'], 'yes');
    });

    test('appleMapsUri creates valid destination URL with coordinates and query name', () {
      final uri = MapNavigationLauncher.appleMapsUri(
        latitude: 14.5995,
        longitude: 120.9842,
        name: 'SM City Calamba Parking',
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'maps.apple.com');
      expect(uri.queryParameters['daddr'], '14.5995,120.9842');
      expect(uri.queryParameters['q'], 'SM City Calamba Parking');
    });
  });

  group('MapNavigationLauncher Sheet UI', () {
    testWidgets('shows navigation modal sheet with Google Maps, Waze, Apple Maps, and Copy Coordinates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  MapNavigationLauncher.showNavigationSheet(
                    context,
                    latitude: 14.2117,
                    longitude: 121.1653,
                    spaceName: 'Central Plaza Parking',
                    address: 'Real St, Calamba, Laguna',
                  );
                },
                child: const Text('Launch Nav'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Launch Nav'));
      await tester.pumpAndSettle();

      expect(find.text('Navigate to Parking'), findsOneWidget);
      expect(find.text('Central Plaza Parking'), findsOneWidget);
      expect(find.text('Google Maps'), findsOneWidget);
      expect(find.text('Waze'), findsOneWidget);
      expect(find.text('Apple Maps / System Map'), findsOneWidget);
      expect(find.text('Copy Coordinates'), findsOneWidget);
      expect(find.text('14.2117, 121.1653'), findsOneWidget);
    });
  });
}
