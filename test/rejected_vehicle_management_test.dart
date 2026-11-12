import 'dart:convert';
import 'dart:typed_data';

import 'package:e_parada_mobile/screens/vehicle_garage_screen.dart';
import 'package:e_parada_mobile/services/api_client.dart';
import 'package:e_parada_mobile/services/auth_service.dart';
import 'package:e_parada_mobile/services/vehicle_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test-token',
      'user_id': 7,
      'user_name': 'Allen Santiago',
      'user_email': 'allen@example.com',
      'user_role': 'driver',
      'user_subtype': 'owner_driver',
      'verification_status': 'approved',
      'email_verified': true,
      'terms_accepted': true,
      'has_approved_vehicle': true,
      'can_reserve': true,
      'can_add_vehicle': false,
      'remaining_vehicle_slots': 0,
    });
  });

  tearDown(() {
    ApiClient.resetClient();
  });

  test('deleteRejectedVehicle updates AuthService cached remaining slots from meta', () async {
    ApiClient.setClientForTesting(
      MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/api/vehicles/99');
        return http.Response(
          jsonEncode({
            'message': 'Rejected vehicle removed. Remaining slot updated.',
            'meta': {
              'maximum': 3,
              'remaining': 1,
              'can_add_vehicle': true,
              'has_approved_vehicle': true,
              'can_reserve': true,
              'account_verified': true,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final message = await VehicleService.deleteRejectedVehicle(99);
    expect(message, contains('Remaining slot updated'));

    final cachedUser = await AuthService.getCachedUser();
    expect(cachedUser, isNotNull);
    expect(cachedUser!.remainingVehicleSlots, 1);
    expect(cachedUser.canAddVehicle, isTrue);
  });

  test('updateRejectedVehicle posts multipart edit payload and syncs slots', () async {
    late http.BaseRequest capturedRequest;

    ApiClient.setClientForTesting(
      MockClient.streaming((request, bodyStream) async {
        capturedRequest = request;
        await bodyStream.drain<void>();
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'message': 'Vehicle updated and resubmitted for admin review.',
                'data': {
                  'id': 99,
                  'plate_number': 'N 5182 F',
                  'vehicle_type': 'Motorcycle',
                  'make': 'Honda',
                  'model': 'Click 160',
                  'color': 'Black',
                  'verification_status': 'pending',
                },
                'meta': {
                  'maximum': 3,
                  'remaining': 1,
                  'can_add_vehicle': true,
                  'has_approved_vehicle': false,
                  'can_reserve': false,
                  'account_verified': true,
                },
              }),
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final message = await VehicleService.updateRejectedVehicle(
      vehicleId: 99,
      plateNumber: 'N 5182 F',
      vehicleType: 'Motorcycle',
      vehicleMake: 'Honda',
      vehicleColor: 'Black',
      vehicleModel: 'Click 160',
      vehiclePhoto: UploadFileData(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'front.jpg',
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/vehicles/99');
    expect(message, contains('resubmitted'));

    final cachedUser = await AuthService.getCachedUser();
    expect(cachedUser!.remainingVehicleSlots, 1);
    expect(cachedUser.canAddVehicle, isTrue);
  });

  testWidgets('VehicleGarageScreen shows Edit & resubmit for rejected vehicle and updates remaining slots after deletion', (tester) async {
    var deleted = false;

    ApiClient.setClientForTesting(
      MockClient((request) async {
        if (request.method == 'DELETE' && request.url.path == '/api/vehicles/3') {
          deleted = true;
          return http.Response(
            jsonEncode({
              'message': 'Rejected vehicle removed. Remaining slot updated.',
              'meta': {
                'maximum': 3,
                'remaining': 1,
                'can_add_vehicle': true,
                'account_verified': true,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' && request.url.path == '/api/vehicles') {
          final vehicles = [
            {
              'id': 1,
              'plate_number': 'AAA 1001',
              'vehicle_type': 'Car',
              'make': 'Toyota',
              'model': 'Vios',
              'color': 'White',
              'verification_status': 'approved',
              'plate_scan_status': 'matched',
              'photo_url': '',
              'photo_back_url': '',
            },
            {
              'id': 2,
              'plate_number': 'BBB 2002',
              'vehicle_type': 'Car',
              'make': 'Honda',
              'model': 'City',
              'color': 'Black',
              'verification_status': 'pending',
              'plate_scan_status': 'pending',
              'photo_url': '',
              'photo_back_url': '',
            },
            if (!deleted)
              {
                'id': 3,
                'plate_number': 'N 5182 G',
                'vehicle_type': 'Motorcycle',
                'make': 'Honda',
                'model': 'Click 125i',
                'color': 'Red',
                'verification_status': 'rejected',
                'verification_notes': 'Plate typo.',
                'plate_scan_status': 'mismatch',
                'photo_url': '',
                'photo_back_url': '',
              },
          ];

          return http.Response(
            jsonEncode({
              'data': vehicles,
              'meta': {
                'maximum': 3,
                'remaining': deleted ? 1 : 0,
                'can_add_vehicle': deleted,
                'account_verified': true,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('{}', 404);
      }),
    );

    await tester.pumpWidget(const MaterialApp(home: VehicleGarageScreen()));
    await tester.pumpAndSettle();

    expect(find.text('3 of 3 vehicles registered'), findsOneWidget);
    expect(find.textContaining('Add vehicle'), findsNothing);

    await tester.scrollUntilVisible(find.text('Remove rejected vehicle'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Edit & resubmit'), findsOneWidget);
    expect(find.text('Remove rejected vehicle'), findsOneWidget);

    await tester.tap(find.text('Remove rejected vehicle'));
    await tester.pumpAndSettle();

    expect(find.text('Remove rejected vehicle?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('2 of 3 vehicles registered'), -300);
    expect(find.text('2 of 3 vehicles registered'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Add vehicle (1 remaining)'), 300);
    expect(find.text('Add vehicle (1 remaining)'), findsOneWidget);
    expect(find.text('N 5182 G'), findsNothing);
  });
}

