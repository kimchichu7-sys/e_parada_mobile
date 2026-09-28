import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/models/parking_space.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vehicle filter criteria accurately filters parking spaces', () {
    final spaces = [
      ParkingSpace(
        id: 1,
        name: 'Sedan Garage',
        address: 'Calamba',
        status: 'Available',
        isOpenNow: true,
        isOpen24Hours: false,
        operatingHours: '8AM-8PM',
        price: '₱40/hr',
        description: 'Cars only',
        supportedVehicles: const ['Car', 'Sedan'],
        latitude: 14.2,
        longitude: 121.1,
        imageUrl: null,
      ),
      ParkingSpace(
        id: 2,
        name: 'Moto Hub',
        address: 'Sta Rosa',
        status: 'Available',
        isOpenNow: true,
        isOpen24Hours: false,
        operatingHours: '8AM-8PM',
        price: '₱20/hr',
        description: 'Bikes only',
        supportedVehicles: const ['Motorcycle', 'Scooter'],
        latitude: 14.3,
        longitude: 121.2,
        imageUrl: null,
      ),
    ];

    final carSpaces = spaces.where((s) => s.supportedVehicles.any((v) => v.toLowerCase().contains('car'))).toList();
    expect(carSpaces.length, 1);
    expect(carSpaces.first.name, 'Sedan Garage');

    final motoSpaces = spaces.where((s) => s.supportedVehicles.any((v) => v.toLowerCase().contains('motorcycle'))).toList();
    expect(motoSpaces.length, 1);
    expect(motoSpaces.first.name, 'Moto Hub');
  });

  test('active reservation identifies currently parked and upcoming sessions', () {
    final activeReservation = DriverReservation.fromJson({
      'id': 77,
      'backup_reference': 'RES-77',
      'qr_code': 'EPARADA-77',
      'parking_space': {'name': 'SM Calamba Parking'},
      'slot': {'label': 'Slot A1'},
      'vehicle': {'plate_number': 'NCD 5566', 'vehicle_type': 'Car'},
      'reservation_date': '2026-08-16',
      'end_date': '2026-08-16',
      'start_time': '09:00',
      'end_time': '11:00',
      'status': 'approved',
      'payment_status': 'unpaid',
      'time_in': '2026-08-16T09:02:00Z',
      'time_out': null,
      'actions': {},
    });

    expect(activeReservation.hasCredential, true);
    expect(activeReservation.timeIn != null && activeReservation.timeOut == null, true);
    expect(activeReservation.parkingSpaceName, 'SM Calamba Parking');
  });
}
