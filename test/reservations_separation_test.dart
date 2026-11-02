import 'package:flutter_test/flutter_test.dart';
import 'package:e_parada_mobile/models/driver_reservation.dart';

void main() {
  group('DriverReservation Categorization Logic', () {
    DriverReservation createReservation(int id, String status) {
      return DriverReservation.fromJson({
        'id': id,
        'status': status,
        'reservation_date': '2026-11-02',
        'end_date': '2026-11-02',
        'start_time': '10:00',
        'end_time': '12:00',
        'payment_status': 'paid',
        'parking_space': {
          'id': 1,
          'name': 'Test Space $id',
          'address': 'Test Address',
        },
        'vehicle': {
          'id': 1,
          'plate_number': 'ABC-$id',
          'vehicle_type': 'Car',
        },
      });
    }

    test('separates active, pending, and history transactions correctly', () {
      final reservations = [
        createReservation(1, 'approved'),
        createReservation(2, 'pending'),
        createReservation(3, 'completed'),
        createReservation(4, 'cancelled'),
        createReservation(5, 'rejected'),
        createReservation(6, 'approved'),
      ];

      final active = reservations
          .where((r) => r.status.trim().toLowerCase() == 'approved')
          .toList();
      final pending = reservations
          .where((r) => r.status.trim().toLowerCase() == 'pending')
          .toList();
      final history = reservations.where((r) {
        final status = r.status.trim().toLowerCase();
        return status == 'completed' ||
            status == 'cancelled' ||
            status == 'rejected';
      }).toList();

      expect(active.length, 2);
      expect(active.map((r) => r.id), containsAll([1, 6]));

      expect(pending.length, 1);
      expect(pending.first.id, 2);

      expect(history.length, 3);
      expect(history.map((r) => r.id), containsAll([3, 4, 5]));
    });

    test('handles whitespace and case insensitivity in reservation status', () {
      final reservations = [
        createReservation(1, ' Approved '),
        createReservation(2, 'PENDING'),
        createReservation(3, 'Completed'),
        createReservation(4, 'CANCELLED'),
        createReservation(5, ' Rejected '),
      ];

      final active = reservations
          .where((r) => r.status.trim().toLowerCase() == 'approved')
          .toList();
      final pending = reservations
          .where((r) => r.status.trim().toLowerCase() == 'pending')
          .toList();
      final history = reservations.where((r) {
        final status = r.status.trim().toLowerCase();
        return status == 'completed' ||
            status == 'cancelled' ||
            status == 'rejected';
      }).toList();

      expect(active.length, 1);
      expect(pending.length, 1);
      expect(history.length, 3);
    });
  });
}
