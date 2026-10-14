import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeotagHelper {
  static Future<LatLng?> extractCoordinates(Uint8List bytes) async {
    try {
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) return null;

      final latTag = tags['GPS GPSLatitude'];
      final latRefTag = tags['GPS GPSLatitudeRef'];
      final lngTag = tags['GPS GPSLongitude'];
      final lngRefTag = tags['GPS GPSLongitudeRef'];

      if (latTag == null || latRefTag == null || lngTag == null || lngRefTag == null) {
        return null;
      }

      final latValues = latTag.values.toList();
      final lngValues = lngTag.values.toList();

      if (latValues.length < 3 || lngValues.length < 3) {
        return null;
      }

      double toDegrees(List<dynamic> parts) {
        double parsePart(dynamic part) {
          if (part is Ratio) {
            return part.toDouble();
          } else if (part is num) {
            return part.toDouble();
          }
          final str = part.toString();
          if (str.contains('/')) {
            final split = str.split('/');
            final num = double.tryParse(split[0]) ?? 0.0;
            final den = double.tryParse(split[1]) ?? 1.0;
            return den != 0.0 ? num / den : 0.0;
          }
          return double.tryParse(str) ?? 0.0;
        }

        final d = parsePart(parts[0]);
        final m = parsePart(parts[1]);
        final s = parsePart(parts[2]);
        return d + (m / 60.0) + (s / 3600.0);
      }

      var lat = toDegrees(latValues);
      var lng = toDegrees(lngValues);

      final latRef = latRefTag.printable.trim().toUpperCase();
      final lngRef = lngRefTag.printable.trim().toUpperCase();

      if (latRef.startsWith('S')) {
        lat = -lat;
      }
      if (lngRef.startsWith('W')) {
        lng = -lng;
      }

      // Basic sanity check for valid Earth coordinates
      if (lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0 && (lat != 0.0 || lng != 0.0)) {
        return LatLng(lat, lng);
      }
    } catch (_) {
      // Ignored - fall back gracefully
    }
    return null;
  }
}
