import 'package:e_parada_mobile/models/parking_space.dart';
import 'package:e_parada_mobile/utils/parking_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

ParkingSpace _space({
  required int id,
  required String name,
  required bool isOpen,
  required String price,
  required List<String> vehicles,
  double? latitude,
  double? longitude,
}) {
  return ParkingSpace(
    id: id,
    name: name,
    address: 'Calamba, Laguna',
    status: isOpen ? 'Open' : 'Closed',
    isOpenNow: isOpen,
    isOpen24Hours: false,
    operatingHours: '8:00 AM - 8:00 PM',
    price: price,
    description: '',
    supportedVehicles: vehicles,
    latitude: latitude,
    longitude: longitude,
    imageUrl: null,
  );
}

void main() {
  final nearCarPark = _space(
    id: 1,
    name: 'Near Car Park',
    isOpen: true,
    price: 'PHP 60.00/hr',
    vehicles: const ['Car'],
    latitude: 14.2127,
    longitude: 121.1653,
  );
  final farMotorcyclePark = _space(
    id: 2,
    name: 'Far Motorcycle Park',
    isOpen: true,
    price: 'PHP 30.00/hr',
    vehicles: const ['Motorcycle'],
    latitude: 14.2317,
    longitude: 121.1653,
  );
  final closedCarPark = _space(
    id: 3,
    name: 'Closed Car Park',
    isOpen: false,
    price: 'PHP 40.00/hr',
    vehicles: const ['Car'],
    latitude: null,
    longitude: null,
  );

  test('extracts hourly rates from API display strings', () {
    expect(parkingHourlyRate(nearCarPark), 60);
    expect(
      parkingHourlyRate(
        _space(
          id: 4,
          name: 'No rate',
          isOpen: true,
          price: 'Rate not set',
          vehicles: const ['Car'],
        ),
      ),
      isNull,
    );
  });

  test('filters by vehicle, open status, query, and maximum rate', () {
    final results = discoverParkingSpaces(
      spaces: [nearCarPark, farMotorcyclePark, closedCarPark],
      query: 'car park',
      vehicleType: 'Car',
      openNowOnly: true,
      maxHourlyRate: 100,
    );

    expect(results, [nearCarPark]);
  });

  test('sorts nearest spaces first and leaves missing coordinates last', () {
    final results = discoverParkingSpaces(
      spaces: [closedCarPark, farMotorcyclePark, nearCarPark],
      sort: ParkingSort.nearest,
      currentLatitude: 14.2117,
      currentLongitude: 121.1653,
    );

    expect(results, [nearCarPark, farMotorcyclePark, closedCarPark]);
    expect(
      parkingDistanceKm(
        nearCarPark,
        currentLatitude: 14.2117,
        currentLongitude: 121.1653,
      ),
      closeTo(0.111, 0.01),
    );
  });

  test('formats short and long distances for the UI', () {
    expect(formatParkingDistance(0.42), '420 m away');
    expect(formatParkingDistance(3.24), '3.2 km away');
    expect(formatParkingDistance(null), 'Distance unavailable');
  });
}
