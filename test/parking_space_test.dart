import 'package:e_parada_mobile/models/parking_space.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the Laravel parking-space response', () {
    final space = ParkingSpace.fromJson({
      'id': 7,
      'space_name': 'Milagrosa Parking',
      'address': 'Calamba, Laguna',
      'status': 'Open',
      'is_open_now': true,
      'is_open_24_hours': false,
      'operating_hours': '8:00 AM - 9:00 PM',
      'price': 'PHP 50.00/hr',
      'description': 'Covered parking',
      'supported_vehicles': ['Car', 'SUV/MPV'],
      'latitude': 14.2,
      'longitude': 121.1,
      'image_url': 'http://127.0.0.1:8000/storage/parking-spaces/a.jpg',
    });

    expect(space.id, 7);
    expect(space.name, 'Milagrosa Parking');
    expect(space.isAvailable, true);
    expect(space.supportedVehicles, ['Car', 'SUV/MPV']);
    expect(space.operatingHours, '8:00 AM - 9:00 PM');
    expect(space.imageUrl, isNotNull);
    expect(space.imageUrl, contains('storage/parking-spaces/a.jpg'));
  });

  test('resolves relative, local, and nested image paths from backend', () {
    final space = ParkingSpace.fromJson({
      'id': 8,
      'space_name': 'Tung Tung Sahur',
      'address': 'KM 53 Pan-Philippine Hwy',
      'images': [
        {'url': 'storage/parking_spaces/tung_tung.jpg'},
        {'path': '/storage/parking_spaces/side_view.jpg'},
      ],
      'photo_url': 'public/storage/parking_spaces/cover.jpg',
    });

    expect(space.imageUrls.length, greaterThanOrEqualTo(2));
    expect(space.imageUrl, isNotNull);
    expect(space.imageUrl, contains('storage/parking_spaces/tung_tung.jpg'));
  });

  test('returns specific vehicle rate if chosen or lowest price if All vehicle types', () {
    final space = ParkingSpace.fromJson({
      'id': 10,
      'space_name': 'Calamba Doctors Parking',
      'address': 'Calamba Doctors Hospital',
      'status': 'Open',
      'is_open_now': true,
      'price': 'PHP 15.00/hr',
      'lowest_hourly_rate': 15.0,
      'hourly_rate': 15.0,
      'vehicle_hourly_rates': {
        'Motorcycle': 15.0,
        'Car': 30.0,
        'SUV/MPV': 45.0,
        'Van': 50.0,
      },
    });

    // Specific vehicle chosen
    expect(space.getEffectiveRate(vehicleType: 'Car'), 30.0);
    expect(space.getEffectiveRate(vehicleType: 'Motorcycle'), 15.0);
    expect(space.getEffectiveRate(vehicleType: 'SUV/MPV'), 45.0);
    expect(space.getEffectiveRate(vehicleType: 'SUV'), 45.0);

    // All vehicle types -> Lowest price in that parking space
    expect(space.getEffectiveRate(vehicleType: 'All'), 15.0);
    expect(space.getEffectiveRate(vehicleType: 'All Vehicle Types'), 15.0);
    expect(space.getEffectiveRate(vehicleType: ''), 15.0);
    expect(space.getEffectiveRate(vehicleType: null), 15.0);
  });
}

