import 'dart:convert';
import 'dart:typed_data';

import 'package:e_parada_mobile/screens/vehicle_garage_screen.dart';
import 'package:e_parada_mobile/services/api_client.dart';
import 'package:e_parada_mobile/services/vehicle_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test-token-123',
      'user_id': 7,
      'user_name': 'Driver One',
      'user_email': 'driver@example.com',
      'user_role': 'driver',
    });
  });

  tearDown(() {
    ApiClient.resetClient();
  });

  test('VehicleService.scanPlateFromPhoto posts rear photo and parses plate', () async {
    String? requestedPath;
    String? requestedSide;
    String? requestedVehicleType;

    ApiClient.setClientForTesting(
      MockClient.streaming((request, bodyStream) async {
        requestedPath = request.url.path;
        final bodyBytes = await bodyStream.toBytes();
        final bodyText = utf8.decode(bodyBytes, allowMalformed: true);
        if (bodyText.contains('name="side"\r\n\r\nback')) {
          requestedSide = 'back';
        }
        if (bodyText.contains('name="vehicle_type"\r\n\r\nMotorcycle')) {
          requestedVehicleType = 'Motorcycle';
        }
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'success': true,
                'plate_number': 'A 123 BC',
                'side': 'back',
              }),
            ),
          ),
          200,
          headers: const {'content-type': 'application/json'},
        );
      }),
    );

    final plate = await VehicleService.scanPlateFromPhoto(
      photo: UploadFileData(
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
        filename: 'rear-moto.jpg',
      ),
      vehicleType: 'Motorcycle',
      side: 'back',
    );

    expect(requestedPath, endsWith('/ocr/scan-plate'));
    expect(requestedSide, 'back');
    expect(requestedVehicleType, 'Motorcycle');
    expect(plate, 'A 123 BC');
  });

  test('VehicleService.scanPlateFromPhoto returns null when server finds no plate', () async {
    ApiClient.setClientForTesting(
      MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'plate_number': null,
          }),
          200,
          headers: const {'content-type': 'application/json'},
        );
      }),
    );

    final plate = await VehicleService.scanPlateFromPhoto(
      photo: UploadFileData(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'front.jpg',
      ),
      vehicleType: 'Car',
      side: 'front',
    );

    expect(plate, isNull);
  });

  testWidgets('AddVehicleScreen highlights auto-scan on both front and rear photos', (tester) async {
    ApiClient.setClientForTesting(
      MockClient((request) async {
        return http.Response(
          jsonEncode({
            'catalog': {
              'Car': [
                {
                  'make': 'Toyota',
                  'models': [
                    {
                      'name': 'Vios',
                      'colors': ['White'],
                    },
                  ],
                },
              ],
              'Motorcycle': [
                {
                  'make': 'Honda',
                  'models': [
                    {
                      'name': 'Click 125i',
                      'colors': ['Black'],
                    },
                  ],
                },
              ],
            },
          }),
          200,
          headers: const {'content-type': 'application/json'},
        );
      }),
    );

    await tester.pumpWidget(const MaterialApp(home: AddVehicleScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('such as rear motorcycle plates'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('such as rear motorcycle plates'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Rear plate (auto-scans)'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Front view (auto-scans)'), findsOneWidget);
    expect(find.text('Rear plate (auto-scans)'), findsOneWidget);
  });
}

