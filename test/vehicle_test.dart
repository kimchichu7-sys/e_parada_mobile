import 'package:e_parada_mobile/models/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an approved vehicle from the API', () {
    final vehicle = Vehicle.fromJson({
      'id': 4,
      'plate_number': 'ABC 1234',
      'vehicle_type': 'Car',
      'make': 'Toyota',
      'color': 'White',
      'model': 'Vios',
      'verification_status': 'approved',
      'verification_notes': null,
      'photo_url': 'http://127.0.0.1:8000/api/vehicles/4/photo',
    });

    expect(vehicle.plateNumber, 'ABC 1234');
    expect(vehicle.make, 'Toyota');
    expect(vehicle.isApproved, true);
    expect(vehicle.isPending, false);
    expect(vehicle.isRejected, false);
  });

  test('keeps rejection notes for the driver', () {
    final vehicle = Vehicle.fromJson({
      'id': 5,
      'plate_number': 'XYZ 9876',
      'vehicle_type': 'SUV/MPV',
      'make': 'Toyota',
      'color': 'Black',
      'model': 'Fortuner',
      'verification_status': 'rejected',
      'verification_notes': 'The plate is not visible.',
      'photo_url': 'http://127.0.0.1:8000/api/vehicles/5/photo',
    });

    expect(vehicle.isRejected, true);
    expect(vehicle.verificationNotes, 'The plate is not visible.');
  });
}
