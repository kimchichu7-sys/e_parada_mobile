import 'dart:math' as math;

import '../models/parking_space.dart';

enum ParkingSort { recommended, nearest, lowestPrice }

List<String> parkingVehicleTypes(Iterable<ParkingSpace> spaces) {
  final values = <String>{};
  for (final space in spaces) {
    for (final vehicle in space.supportedVehicles) {
      final value = vehicle.trim();
      if (value.isNotEmpty) values.add(value);
    }
  }
  final result = values.toList()..sort();
  return result;
}

double? parkingHourlyRate(ParkingSpace space) {
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(space.price);
  return match == null ? null : double.tryParse(match.group(1)!);
}

double? parkingDistanceKm(
  ParkingSpace space, {
  required double? currentLatitude,
  required double? currentLongitude,
}) {
  final latitude = space.latitude;
  final longitude = space.longitude;
  if (latitude == null ||
      longitude == null ||
      currentLatitude == null ||
      currentLongitude == null) {
    return null;
  }

  const earthRadiusKm = 6371.0;
  final latitudeDelta = _radians(latitude - currentLatitude);
  final longitudeDelta = _radians(longitude - currentLongitude);
  final startLatitude = _radians(currentLatitude);
  final endLatitude = _radians(latitude);

  final a =
      math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
      math.cos(startLatitude) *
          math.cos(endLatitude) *
          math.sin(longitudeDelta / 2) *
          math.sin(longitudeDelta / 2);
  final angularDistance = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * angularDistance;
}

String formatParkingDistance(double? distanceKm) {
  if (distanceKm == null) return 'Distance unavailable';
  if (distanceKm < 1) {
    return '${(distanceKm * 1000).round()} m away';
  }
  return '${distanceKm.toStringAsFixed(distanceKm < 10 ? 1 : 0)} km away';
}

List<ParkingSpace> discoverParkingSpaces({
  required List<ParkingSpace> spaces,
  String query = '',
  String? vehicleType,
  bool openNowOnly = false,
  double? maxHourlyRate,
  ParkingSort sort = ParkingSort.recommended,
  double? currentLatitude,
  double? currentLongitude,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final normalizedVehicle = vehicleType?.trim().toLowerCase();

  final result = spaces
      .where((space) {
        final matchesQuery =
            normalizedQuery.isEmpty ||
            space.name.toLowerCase().contains(normalizedQuery) ||
            space.address.toLowerCase().contains(normalizedQuery);
        final matchesVehicle =
            normalizedVehicle == null ||
            normalizedVehicle.isEmpty ||
            space.supportedVehicles.any(
              (vehicle) => vehicle.trim().toLowerCase() == normalizedVehicle,
            );
        final matchesAvailability = !openNowOnly || space.isOpenNow;
        final rate = parkingHourlyRate(space);
        final matchesRate =
            maxHourlyRate == null || (rate != null && rate <= maxHourlyRate);

        return matchesQuery &&
            matchesVehicle &&
            matchesAvailability &&
            matchesRate;
      })
      .toList(growable: true);

  switch (sort) {
    case ParkingSort.recommended:
      break;
    case ParkingSort.nearest:
      result.sort((left, right) {
        final leftDistance = parkingDistanceKm(
          left,
          currentLatitude: currentLatitude,
          currentLongitude: currentLongitude,
        );
        final rightDistance = parkingDistanceKm(
          right,
          currentLatitude: currentLatitude,
          currentLongitude: currentLongitude,
        );
        if (leftDistance == null && rightDistance == null) return 0;
        if (leftDistance == null) return 1;
        if (rightDistance == null) return -1;
        return leftDistance.compareTo(rightDistance);
      });
      break;
    case ParkingSort.lowestPrice:
      result.sort((left, right) {
        final leftRate = parkingHourlyRate(left);
        final rightRate = parkingHourlyRate(right);
        if (leftRate == null && rightRate == null) return 0;
        if (leftRate == null) return 1;
        if (rightRate == null) return -1;
        return leftRate.compareTo(rightRate);
      });
      break;
  }

  return result;
}

double _radians(double degrees) => degrees * math.pi / 180;
