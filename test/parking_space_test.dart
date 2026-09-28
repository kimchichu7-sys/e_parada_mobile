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
}
