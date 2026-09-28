import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum AlertType {
  arrivalReminder,
  checkpointScan,
  overstayWarning,
}

class ReservationAlert {
  const ReservationAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.reservationRef,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final AlertType type;
  final DateTime timestamp;
  final String reservationRef;
  final bool isRead;

  ReservationAlert copyWith({bool? isRead}) {
    return ReservationAlert(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      reservationRef: reservationRef,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'reservation_ref': reservationRef,
        'is_read': isRead,
      };

  factory ReservationAlert.fromJson(Map<String, dynamic> json) {
    return ReservationAlert(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.arrivalReminder,
      ),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      reservationRef: json['reservation_ref']?.toString() ?? '',
      isRead: json['is_read'] == true,
    );
  }
}

class ReservationReminderService {
  static const _storageKey = 'cached_reservation_alerts_v1';

  static ReservationAlert createArrivalReminder({
    required String spaceName,
    required String reservationRef,
    required DateTime scheduledStart,
  }) {
    final timeStr = '${scheduledStart.hour.toString().padLeft(2, '0')}:${scheduledStart.minute.toString().padLeft(2, '0')}';
    return ReservationAlert(
      id: 'REM-ARR-$reservationRef-${DateTime.now().millisecondsSinceEpoch}',
      title: '⏰ Parking Arrival Reminder',
      message: 'Your reservation at $spaceName (Ref: $reservationRef) begins at $timeStr (in ~15 mins). Tap to view QR.',
      type: AlertType.arrivalReminder,
      timestamp: DateTime.now(),
      reservationRef: reservationRef,
    );
  }

  static ReservationAlert createCheckpointConfirmation({
    required String spaceName,
    required String reservationRef,
    required bool isEntry,
    required DateTime time,
  }) {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return ReservationAlert(
      id: 'REM-CHK-$reservationRef-${DateTime.now().millisecondsSinceEpoch}',
      title: isEntry ? '🏁 Check-In Verified' : '🏁 Check-Out Completed',
      message: isEntry
          ? 'Check-in recorded at $spaceName ($timeStr). Your 15-minute billing grace period is active.'
          : 'Check-out recorded at $spaceName ($timeStr). Digital receipt has been generated.',
      type: AlertType.checkpointScan,
      timestamp: DateTime.now(),
      reservationRef: reservationRef,
    );
  }

  static ReservationAlert createOverstayWarning({
    required String spaceName,
    required String reservationRef,
    required int overstayMinutes,
    required double overstayFee,
  }) {
    return ReservationAlert(
      id: 'REM-OVS-$reservationRef-${DateTime.now().millisecondsSinceEpoch}',
      title: '⚠️ Overstay Grace Window Alert',
      message: 'Your scheduled departure time for $reservationRef at $spaceName has passed ($overstayMinutes mins overstay, surcharge: ₱${overstayFee.toStringAsFixed(2)}). Please vacate promptly.',
      type: AlertType.overstayWarning,
      timestamp: DateTime.now(),
      reservationRef: reservationRef,
    );
  }

  static Future<List<ReservationAlert>> fetchAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];
    return rawList
        .map((item) {
          try {
            return ReservationAlert.fromJson(jsonDecode(item) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<ReservationAlert>()
        .toList();
  }

  static Future<void> saveAlert(ReservationAlert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await fetchAlerts();
    existing.insert(0, alert);
    final encoded = existing.take(30).map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  static Future<void> markAlertAsRead(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await fetchAlerts();
    final updated = existing.map((a) => a.id == alertId ? a.copyWith(isRead: true) : a).toList();
    final encoded = updated.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  static Future<void> clearAllAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
