import 'package:e_parada_mobile/models/driver_reservation.dart';
import 'package:e_parada_mobile/models/reservation_availability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('driver reservation parses actions and backup credential', () {
    final reservation = DriverReservation.fromJson({
      'id': 42,
      'backup_reference': 'RES-42',
      'qr_code': 'EPARADA-ABC',
      'parking_space': {
        'id': 8,
        'name': 'Campus Parking',
        'address': 'Calamba, Laguna',
      },
      'slot': {'id': 3, 'label': 'Slot 3'},
      'vehicle': {'id': 4, 'plate_number': 'ABC 1234', 'vehicle_type': 'Car'},
      'reservation_date': '2026-08-16',
      'end_date': '2026-08-16',
      'start_time': '09:00',
      'end_time': '10:00',
      'status': 'approved',
      'payment_status': 'unpaid',
      'feedback': {'rating': 5, 'comment': 'Great parking.'},
      'extension': {'status': 'pending'},
      'overstay': {'status': 'normal', 'minutes': 0, 'amount': 0},
      'actions': {
        'can_cancel': true,
        'can_extend': false,
        'can_submit_payment': false,
        'can_reschedule': true,
        'can_submit_feedback': true,
      },
    });

    expect(reservation.backupReference, 'RES-13814273');
    expect(reservation.hasCredential, true);
    expect(reservation.slotLabel, 'Slot 3');
    expect(reservation.plateNumber, 'ABC 1234');
    expect(reservation.canCancel, true);
    expect(reservation.vehicleId, 4);
    expect(reservation.canReschedule, true);
    expect(reservation.canSubmitFeedback, true);
    expect(reservation.feedbackRating, 5);
    expect(reservation.extensionStatus, 'pending');
  });

  test('availability identifies selectable slots', () {
    final availability = ReservationAvailability.fromJson({
      'parking_space': {
        'operating_hours': '8:00 AM - 8:00 PM',
        'hourly_rate': 50,
      },
      'slots': [
        {
          'id': 1,
          'label': 'A1',
          'supported_vehicle_types': ['Car'],
          'is_available': true,
        },
        {
          'id': 2,
          'label': 'A2',
          'supported_vehicle_types': ['Car'],
          'is_available': false,
        },
      ],
    });

    expect(availability.operatingHours, '8:00 AM - 8:00 PM');
    expect(availability.hourlyRate, 50);
    expect(availability.slots.length, 2);
    expect(availability.slots.first.isAvailable, true);
    expect(availability.slots.last.isAvailable, false);
  });
}
