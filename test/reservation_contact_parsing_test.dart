import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/models/owner_reservation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('driver reservation reads assigned parking provider identity', () {
    final reservation = DriverReservation.fromJson({
      'id': 12,
      'backup_reference': 'RES-12',
      'parking_space': {
        'name': 'Sample Space',
        'owner': {'name': 'Owner Name'},
      },
    });

    expect(reservation.ownerName, 'Owner Name');
  });

  test('owner reservation reads the reserved driver identity', () {
    final reservation = OwnerReservation.fromJson({
      'id': 18,
      'backup_reference': 'RES-18',
      'driver': {'name': 'Driver Name'},
    });

    expect(reservation.driverName, 'Driver Name');
  });
}
