import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver_reservation.dart';

class OfflinePassData {
  const OfflinePassData({
    required this.id,
    required this.backupReference,
    required this.qrCode,
    required this.parkingSpaceName,
    required this.parkingSpaceAddress,
    required this.ownerName,
    required this.plateNumber,
    required this.vehicleType,
    required this.slotLabel,
    required this.scheduleLabel,
    required this.status,
    required this.cachedAt,
  });

  final int id;
  final String backupReference;
  final String qrCode;
  final String parkingSpaceName;
  final String parkingSpaceAddress;
  final String ownerName;
  final String plateNumber;
  final String vehicleType;
  final String slotLabel;
  final String scheduleLabel;
  final String status;
  final DateTime cachedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'backup_reference': backupReference,
        'qr_code': qrCode,
        'parking_space_name': parkingSpaceName,
        'parking_space_address': parkingSpaceAddress,
        'owner_name': ownerName,
        'plate_number': plateNumber,
        'vehicle_type': vehicleType,
        'slot_label': slotLabel,
        'schedule_label': scheduleLabel,
        'status': status,
        'cached_at': cachedAt.toIso8601String(),
      };

  factory OfflinePassData.fromJson(Map<String, dynamic> json) {
    return OfflinePassData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      backupReference: json['backup_reference']?.toString() ?? '',
      qrCode: json['qr_code']?.toString() ?? '',
      parkingSpaceName: json['parking_space_name']?.toString() ?? '',
      parkingSpaceAddress: json['parking_space_address']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      slotLabel: json['slot_label']?.toString() ?? '',
      scheduleLabel: json['schedule_label']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      cachedAt: DateTime.tryParse(json['cached_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory OfflinePassData.fromDriverReservation(DriverReservation res) {
    return OfflinePassData(
      id: res.id,
      backupReference: res.backupReference.isNotEmpty ? res.backupReference : 'RES-${res.id}',
      qrCode: res.qrCode,
      parkingSpaceName: res.parkingSpaceName,
      parkingSpaceAddress: res.parkingSpaceAddress,
      ownerName: res.ownerName,
      plateNumber: res.plateNumber,
      vehicleType: res.vehicleType,
      slotLabel: res.slotLabel,
      scheduleLabel: res.scheduleLabel,
      status: res.status,
      cachedAt: DateTime.now(),
    );
  }
}

class OfflineParkingPassService {
  static const _storageKey = 'cached_offline_parking_passes_v1';

  static Future<void> cacheReservations(List<DriverReservation> reservations) async {
    final active = reservations
        .where((r) =>
            r.status == 'approved' ||
            r.status == 'pending' ||
            (r.timeIn != null && r.timeOut == null))
        .map((r) => OfflinePassData.fromDriverReservation(r))
        .toList();

    if (active.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = active.map((pass) => jsonEncode(pass.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  static Future<List<OfflinePassData>> getOfflinePasses() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];
    return rawList
        .map((item) {
          try {
            return OfflinePassData.fromJson(jsonDecode(item) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<OfflinePassData>()
        .toList();
  }

  static Future<OfflinePassData?> getLatestActivePass() async {
    final passes = await getOfflinePasses();
    if (passes.isEmpty) return null;
    return passes.first;
  }

  static Future<void> clearPasses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
