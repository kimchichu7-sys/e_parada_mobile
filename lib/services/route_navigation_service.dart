import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/parking_space.dart';

enum NavigationTransportMode {
  car,
  motorcycle,
  walking,
  bicycle,
}

class RouteStepItem {
  const RouteStepItem({
    required this.instruction,
    this.streetName,
    this.distanceMeters,
    this.icon = Icons.directions_car_rounded,
  });

  final String instruction;
  final String? streetName;
  final double? distanceMeters;
  final IconData icon;
}

class NavigationRouteData {
  const NavigationRouteData({
    required this.primaryCoordinates,
    this.alternativeCoordinates,
    required this.distanceKm,
    required this.durationMinutes,
    required this.etaText,
    required this.steps,
    required this.primaryMidpoint,
    this.alternativeMidpoint,
    this.alternativeEtaText,
    this.alternativeDistanceKm,
    this.mode = NavigationTransportMode.car,
    this.carEta = '',
    this.motorcycleEta = '',
    this.walkingEta = '',
    this.bicycleEta = '',
  });

  final List<LatLng> primaryCoordinates;
  final List<LatLng>? alternativeCoordinates;
  final double distanceKm;
  final int durationMinutes;
  final String etaText;
  final List<RouteStepItem> steps;
  final LatLng primaryMidpoint;
  final LatLng? alternativeMidpoint;
  final String? alternativeEtaText;
  final double? alternativeDistanceKm;
  final NavigationTransportMode mode;
  final String carEta;
  final String motorcycleEta;
  final String walkingEta;
  final String bicycleEta;
}

class LiveNavigationProgress {
  const LiveNavigationProgress({
    required this.currentPosition,
    required this.bearing,
    required this.currentStepIndex,
    required this.currentStep,
    this.nextStep,
    required this.remainingDistanceKm,
    required this.remainingDurationMinutes,
    required this.remainingEtaText,
    required this.currentSpeedKmh,
    required this.isArrived,
    required this.progressFraction,
  });

  final LatLng currentPosition;
  final double bearing;
  final int currentStepIndex;
  final RouteStepItem currentStep;
  final RouteStepItem? nextStep;
  final double remainingDistanceKm;
  final int remainingDurationMinutes;
  final String remainingEtaText;
  final double currentSpeedKmh;
  final bool isArrived;
  final double progressFraction;
}

class RouteNavigationService {
  static const _timeout = Duration(seconds: 4);

  static Future<NavigationRouteData> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    ParkingSpace? destinationSpace,
    NavigationTransportMode mode = NavigationTransportMode.car,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final profile = mode == NavigationTransportMode.walking
        ? 'foot'
        : mode == NavigationTransportMode.bicycle
            ? 'bicycle'
            : 'driving';
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=true&alternatives=true',
    );

    try {
      final response = await httpClient.get(
        url,
        headers: {'User-Agent': 'EParadaMobile/1.0'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok' && data['routes'] is List && (data['routes'] as List).isNotEmpty) {
          final routes = data['routes'] as List;
          final primaryJson = routes[0] as Map<String, dynamic>;
          final primaryCoords = _parseCoordinates(primaryJson['geometry']);

          if (primaryCoords.length >= 2) {
            final distanceMeters = (primaryJson['distance'] as num?)?.toDouble() ?? 0.0;
            final durationSeconds = (primaryJson['duration'] as num?)?.toDouble() ?? 0.0;
            final distanceKm = distanceMeters / 1000.0;
            final durationMinutes = math.max(1, (durationSeconds / 60.0).round());
            final etaText = _formatEta(durationMinutes, mode: mode);

            final steps = _parseSteps(primaryJson, destinationSpace);
            final primaryMidpoint = primaryCoords[primaryCoords.length ~/ 2];

            List<LatLng>? altCoords;
            LatLng? altMidpoint;
            String? altEtaText;
            double? altDistanceKm;

            if (routes.length > 1) {
              final altJson = routes[1] as Map<String, dynamic>;
              altCoords = _parseCoordinates(altJson['geometry']);
              if (altCoords.length >= 2) {
                altMidpoint = altCoords[altCoords.length ~/ 2];
                final altDistMeters = (altJson['distance'] as num?)?.toDouble() ?? 0.0;
                final altDurSecs = (altJson['duration'] as num?)?.toDouble() ?? 0.0;
                altDistanceKm = altDistMeters / 1000.0;
                final altMins = math.max(1, (altDurSecs / 60.0).round());
                altEtaText = _formatEta(altMins, mode: mode);
              }
            }

            return NavigationRouteData(
              primaryCoordinates: primaryCoords,
              alternativeCoordinates: altCoords,
              distanceKm: distanceKm,
              durationMinutes: durationMinutes,
              etaText: etaText,
              steps: steps,
              primaryMidpoint: primaryMidpoint,
              alternativeMidpoint: altMidpoint,
              alternativeEtaText: altEtaText,
              alternativeDistanceKm: altDistanceKm,
              mode: mode,
              carEta: formatModeEta(distanceKm, NavigationTransportMode.car),
              motorcycleEta: formatModeEta(distanceKm, NavigationTransportMode.motorcycle),
              walkingEta: formatModeEta(distanceKm, NavigationTransportMode.walking),
              bicycleEta: formatModeEta(distanceKm, NavigationTransportMode.bicycle),
            );
          }
        }
      }
    } catch (_) {
      // Network failure or timeout: gracefully fall back to local road geometry generator
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }

    return generateFallbackRoute(
      origin: origin,
      destination: destination,
      destinationSpace: destinationSpace,
      mode: mode,
    );
  }

  static List<LatLng> _parseCoordinates(dynamic geometry) {
    if (geometry is! Map<String, dynamic>) return [];
    final coordinates = geometry['coordinates'];
    if (coordinates is! List) return [];

    final list = <LatLng>[];
    for (final item in coordinates) {
      if (item is List && item.length >= 2) {
        final lng = (item[0] as num).toDouble();
        final lat = (item[1] as num).toDouble();
        list.add(LatLng(lat, lng));
      }
    }
    return list;
  }

  static List<RouteStepItem> _parseSteps(
    Map<String, dynamic> routeJson,
    ParkingSpace? destinationSpace,
  ) {
    final steps = <RouteStepItem>[];
    final legs = routeJson['legs'];
    if (legs is List && legs.isNotEmpty) {
      final leg = legs[0] as Map<String, dynamic>;
      final rawSteps = leg['steps'];
      if (rawSteps is List) {
        for (final raw in rawSteps) {
          if (raw is Map<String, dynamic>) {
            final maneuver = raw['maneuver'] as Map<String, dynamic>?;
            final type = maneuver?['type']?.toString() ?? '';
            final modifier = maneuver?['modifier']?.toString() ?? '';
            final name = raw['name']?.toString().trim() ?? '';
            final dist = (raw['distance'] as num?)?.toDouble();

            var instruction = _buildManeuverText(type, modifier, name);
            if (instruction.isEmpty) continue;

            IconData icon = Icons.straight_rounded;
            if (modifier.contains('left')) {
              icon = Icons.turn_left_rounded;
            } else if (modifier.contains('right')) {
              icon = Icons.turn_right_rounded;
            } else if (type == 'arrive') {
              icon = Icons.local_parking_rounded;
            } else if (type == 'depart') {
              icon = Icons.trip_origin_rounded;
            }

            steps.add(RouteStepItem(
              instruction: instruction,
              streetName: name.isNotEmpty ? name : null,
              distanceMeters: dist,
              icon: icon,
            ));
          }
        }
      }
    }

    if (steps.isEmpty) {
      final destName = destinationSpace?.name ?? 'parking destination';
      steps.addAll([
        const RouteStepItem(
          instruction: 'Depart from your current location',
          icon: Icons.trip_origin_rounded,
        ),
        const RouteStepItem(
          instruction: 'Follow the highlighted road route',
          icon: Icons.directions_car_rounded,
        ),
        RouteStepItem(
          instruction: 'Arrive at $destName and proceed to designated bay',
          icon: Icons.local_parking_rounded,
        ),
      ]);
    }

    return steps;
  }

  static String _buildManeuverText(String type, String modifier, String name) {
    if (type == 'depart') {
      return name.isNotEmpty ? 'Head towards $name' : 'Start trip from current position';
    }
    if (type == 'arrive') {
      return 'Arrive at parking entrance';
    }
    if (type == 'turn') {
      if (modifier.isNotEmpty) {
        return 'Turn $modifier${name.isNotEmpty ? ' onto $name' : ''}';
      }
      return 'Turn${name.isNotEmpty ? ' onto $name' : ''}';
    }
    if (type == 'new name' || type == 'continue') {
      return 'Continue on ${name.isNotEmpty ? name : 'road'}';
    }
    return name.isNotEmpty ? 'Continue towards $name' : 'Follow route';
  }

  static String formatModeEta(double distanceKm, NavigationTransportMode mode) {
    final speedKmh = switch (mode) {
      NavigationTransportMode.car => 24.0,
      NavigationTransportMode.motorcycle => 32.0,
      NavigationTransportMode.walking => 4.8,
      NavigationTransportMode.bicycle => 14.0,
    };
    final mins = math.max(1, (distanceKm / speedKmh * 60.0).round());
    if (mins < 60) return '$mins min';
    final hrs = mins ~/ 60;
    final rem = mins % 60;
    return '$hrs hr${hrs > 1 ? 's' : ''}${rem > 0 ? ' $rem min' : ''}';
  }

  static NavigationRouteData generateFallbackRoute({
    required LatLng origin,
    required LatLng destination,
    ParkingSpace? destinationSpace,
    NavigationTransportMode mode = NavigationTransportMode.car,
  }) {
    final latDiff = destination.latitude - origin.latitude;
    final lngDiff = destination.longitude - origin.longitude;

    // Realistic street-grid road waypoints with smooth turns
    final primary = <LatLng>[
      origin,
      LatLng(origin.latitude + latDiff * 0.12, origin.longitude + lngDiff * 0.02),
      LatLng(origin.latitude + latDiff * 0.28, origin.longitude + lngDiff * 0.06),
      LatLng(origin.latitude + latDiff * 0.45, origin.longitude + lngDiff * 0.22),
      LatLng(origin.latitude + latDiff * 0.62, origin.longitude + lngDiff * 0.58),
      LatLng(origin.latitude + latDiff * 0.78, origin.longitude + lngDiff * 0.82),
      LatLng(origin.latitude + latDiff * 0.92, origin.longitude + lngDiff * 0.96),
      destination,
    ];

    // Secondary alternative route path
    final alternative = <LatLng>[
      origin,
      LatLng(origin.latitude + latDiff * 0.05, origin.longitude + lngDiff * 0.35),
      LatLng(origin.latitude + latDiff * 0.22, origin.longitude + lngDiff * 0.75),
      LatLng(origin.latitude + latDiff * 0.55, origin.longitude + lngDiff * 0.92),
      LatLng(origin.latitude + latDiff * 0.85, origin.longitude + lngDiff * 0.97),
      destination,
    ];

    // Straight distance estimation with 1.25x road winding factor
    final straightKm = _haversineDistanceKm(origin, destination);
    final distanceKm = math.max(0.1, straightKm * 1.28);
    final durationMinutes = switch (mode) {
      NavigationTransportMode.car => math.max(1, (distanceKm / 24.0 * 60.0).round()),
      NavigationTransportMode.motorcycle => math.max(1, (distanceKm / 32.0 * 60.0).round()),
      NavigationTransportMode.walking => math.max(1, (distanceKm / 4.8 * 60.0).round()),
      NavigationTransportMode.bicycle => math.max(1, (distanceKm / 14.0 * 60.0).round()),
    };
    final etaText = _formatEta(durationMinutes, mode: mode);

    final altDistanceKm = distanceKm * 1.15;
    final altDurationMins = durationMinutes + 2;
    final altEtaText = _formatEta(altDurationMins, mode: mode);

    final destName = destinationSpace?.name ?? 'parking destination';
    final address = destinationSpace?.address ?? '';

    final steps = [
      const RouteStepItem(
        instruction: 'Depart from your current position',
        icon: Icons.trip_origin_rounded,
      ),
      RouteStepItem(
        instruction: mode == NavigationTransportMode.walking
            ? 'Walk towards ${address.isNotEmpty ? address : 'destination'}'
            : 'Drive towards ${address.isNotEmpty ? address : 'main road'}',
        distanceMeters: (distanceKm * 450).clamp(100, 2500),
        icon: Icons.turn_right_rounded,
      ),
      RouteStepItem(
        instruction: 'Continue straight along the navigation route',
        distanceMeters: (distanceKm * 550).clamp(150, 4000),
        icon: Icons.straight_rounded,
      ),
      RouteStepItem(
        instruction: 'Arrive at $destName entrance and present pass',
        icon: Icons.local_parking_rounded,
      ),
    ];

    return NavigationRouteData(
      primaryCoordinates: primary,
      alternativeCoordinates: alternative,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      etaText: etaText,
      steps: steps,
      primaryMidpoint: primary[primary.length ~/ 2],
      alternativeMidpoint: alternative[alternative.length ~/ 2],
      alternativeEtaText: altEtaText,
      alternativeDistanceKm: altDistanceKm,
      mode: mode,
      carEta: formatModeEta(distanceKm, NavigationTransportMode.car),
      motorcycleEta: formatModeEta(distanceKm, NavigationTransportMode.motorcycle),
      walkingEta: formatModeEta(distanceKm, NavigationTransportMode.walking),
      bicycleEta: formatModeEta(distanceKm, NavigationTransportMode.bicycle),
    );
  }

  static double _haversineDistanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.asin(math.sqrt(h));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);
  static double _rad2deg(double rad) => rad * (180.0 / math.pi);

  /// Computes compass bearing in degrees (0..360) from [from] to [to].
  static double computeBearing(LatLng from, LatLng to) {
    final lat1 = _deg2rad(from.latitude);
    final lat2 = _deg2rad(to.latitude);
    final dLon = _deg2rad(to.longitude - from.longitude);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final radians = math.atan2(y, x);
    final degrees = (_rad2deg(radians) + 360.0) % 360.0;
    return degrees;
  }

  /// Interpolates a [LatLng] along a polyline given a [fraction] between 0.0 and 1.0.
  static LatLng interpolatePosition(List<LatLng> coordinates, double fraction) {
    if (coordinates.isEmpty) return const LatLng(0, 0);
    if (coordinates.length == 1 || fraction <= 0.0) return coordinates.first;
    if (fraction >= 1.0) return coordinates.last;

    final segmentLengths = <double>[];
    double totalLength = 0.0;
    for (int i = 0; i < coordinates.length - 1; i++) {
      final len = _haversineDistanceKm(coordinates[i], coordinates[i + 1]);
      segmentLengths.add(len);
      totalLength += len;
    }

    if (totalLength <= 0.0) return coordinates.first;
    final targetDistance = totalLength * fraction;

    double accumulated = 0.0;
    for (int i = 0; i < segmentLengths.length; i++) {
      final segmentLen = segmentLengths[i];
      if (accumulated + segmentLen >= targetDistance || i == segmentLengths.length - 1) {
        final segmentFraction = segmentLen > 0.0
            ? (targetDistance - accumulated) / segmentLen
            : 0.0;
        final start = coordinates[i];
        final end = coordinates[i + 1];
        return LatLng(
          start.latitude + (end.latitude - start.latitude) * segmentFraction,
          start.longitude + (end.longitude - start.longitude) * segmentFraction,
        );
      }
      accumulated += segmentLen;
    }

    return coordinates.last;
  }

  /// Calculates real-time progress along the route for a given [progressFraction].
  static LiveNavigationProgress computeProgress({
    required NavigationRouteData routeData,
    required double progressFraction,
  }) {
    final coords = routeData.primaryCoordinates;
    final steps = routeData.steps;
    final clampedFraction = progressFraction.clamp(0.0, 1.0);

    final currentPos = interpolatePosition(coords, clampedFraction);
    final isArrived = clampedFraction >= 0.98;

    // Estimate bearing by looking slightly ahead along the polyline
    final aheadFraction = (clampedFraction + 0.04).clamp(0.0, 1.0);
    final aheadPos = interpolatePosition(coords, aheadFraction);
    final bearing = clampedFraction < 0.98
        ? computeBearing(currentPos, aheadPos)
        : 0.0;

    // Determine current active step
    final stepIndex = steps.isNotEmpty
        ? (clampedFraction * steps.length).floor().clamp(0, steps.length - 1)
        : 0;
    final currentStep = steps.isNotEmpty ? steps[stepIndex] : const RouteStepItem(instruction: 'Follow route');
    final nextStep = (stepIndex + 1 < steps.length) ? steps[stepIndex + 1] : null;

    final remainingDistanceKm = math.max(0.0, routeData.distanceKm * (1.0 - clampedFraction));
    final speedKmh = routeData.mode == NavigationTransportMode.motorcycle ? 32.0 : 26.0;
    final remainingMins = math.max(1, (remainingDistanceKm / speedKmh * 60.0).round());
    final remainingEtaText = isArrived ? 'Arrived' : _formatEta(remainingMins, mode: routeData.mode);

    return LiveNavigationProgress(
      currentPosition: currentPos,
      bearing: bearing,
      currentStepIndex: stepIndex,
      currentStep: currentStep,
      nextStep: nextStep,
      remainingDistanceKm: remainingDistanceKm,
      remainingDurationMinutes: remainingMins,
      remainingEtaText: remainingEtaText,
      currentSpeedKmh: isArrived ? 0.0 : speedKmh,
      isArrived: isArrived,
      progressFraction: clampedFraction,
    );
  }

  /// Generates a live stream of simulated progress updates along the route.
  static Stream<LiveNavigationProgress> simulateNavigationStream({
    required NavigationRouteData routeData,
    Duration tickInterval = const Duration(milliseconds: 300),
    double totalDurationSeconds = 12.0,
  }) async* {
    final totalTicks = math.max(10, (totalDurationSeconds * 1000 / tickInterval.inMilliseconds).round());
    for (int tick = 0; tick <= totalTicks; tick++) {
      final fraction = tick / totalTicks;
      yield computeProgress(routeData: routeData, progressFraction: fraction);
      if (tick < totalTicks) {
        await Future<void>.delayed(tickInterval);
      }
    }
  }

  static String _formatEta(int minutes, {NavigationTransportMode mode = NavigationTransportMode.car}) {
    final suffix = mode == NavigationTransportMode.walking
        ? 'walk'
        : mode == NavigationTransportMode.bicycle
            ? 'cycle'
            : 'drive';
    if (minutes < 1) return '< 1 min $suffix';
    if (minutes < 60) return '~$minutes min${minutes > 1 ? 's' : ''} $suffix';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return '~$hours hr${hours > 1 ? 's' : ''}${rem > 0 ? ' $rem min' : ''} $suffix';
  }
}
