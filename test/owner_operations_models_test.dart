import 'package:e_parada_mobile/models/checkpoint_transaction.dart';
import 'package:e_parada_mobile/models/owner_parking_space.dart';
import 'package:e_parada_mobile/models/owner_reservation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('owner parking space parses operating state and counts', () {
    final space = OwnerParkingSpace.fromJson({
      'id': 7,
      'space_name': 'Milagrosa Parking',
      'address': 'Calamba, Laguna',
      'approval_status': 'approved',
      'is_available': true,
      'is_open_now': true,
      'operating_hours': '8:00 AM - 9:00 PM',
      'active_slots_count': 6,
      'pending_reservations_count': 2,
      'latitude': '14.2117',
      'longitude': '121.1653',
      'vehicle_types': ['Car', 'SUV/MPV'],
      'dimensions_sqm': '120.50',
      'description': 'Covered parking near the city center.',
      'image_urls': ['http://127.0.0.1:8000/storage/parking-spaces/one.jpg'],
      'is_open_24_hours': false,
      'opening_time': '08:00',
      'closing_time': '21:00',
      'overstay_grace_minutes': 30,
      'abandoned_after_hours': 48,
      'total_slots': 2,
      'slots': [
        {
          'id': 1,
          'slot_number': 1,
          'slot_label': 'Slot 1',
          'supported_vehicle_types': ['Car'],
          'is_active': true,
        },
        {
          'id': 2,
          'slot_number': 2,
          'slot_label': 'Slot 2',
          'supported_vehicle_types': ['Car', 'SUV/MPV'],
          'is_active': true,
        },
      ],
    });

    expect(space.id, 7);
    expect(space.isOpenNow, isTrue);
    expect(space.activeSlotsCount, 6);
    expect(space.pendingReservationsCount, 2);
    expect(space.latitude, 14.2117);
    expect(space.vehicleTypes, ['Car', 'SUV/MPV']);
    expect(space.dimensionsSquareMeters, 120.5);
    expect(space.isOpen24Hours, isFalse);
    expect(space.abandonedAfterHours, 48);
    expect(space.slots, hasLength(2));
    expect(space.slots.last.supportedVehicleTypes, ['Car', 'SUV/MPV']);
  });

  test('owner reservation exposes driver vehicle and backup reference', () {
    final reservation = OwnerReservation.fromJson({
      'id': 12,
      'backup_reference': 'RES-12',
      'driver': {'name': 'Driver One', 'email': 'driver@example.com'},
      'vehicle': {
        'plate_number': 'ABC 1234',
        'vehicle_type': 'Car',
        'color': 'White',
        'make': 'Toyota',
        'model': 'Vios',
      },
      'parking_space': {'id': 4, 'space_name': 'Owner Space'},
      'slot_label': 'Slot 2',
      'reservation_date': '2026-08-15',
      'end_date': '2026-08-15',
      'start_time': '09:00',
      'end_time': '10:00',
      'status': 'pending',
      'payment_status': 'unpaid',
      'has_payment_proof': false,
      'can_cancel': true,
      'can_mark_paid': false,
    });

    expect(reservation.backupReference, 'RES-12');
    expect(reservation.isPending, isTrue);
    expect(reservation.vehicleLabel, contains('ABC 1234'));
    expect(reservation.vehicleLabel, contains('Toyota Vios'));
  });

  test(
    'checkpoint log parses audit result without exposing raw credential',
    () {
      final transaction = CheckpointTransaction.fromJson({
        'id': 5,
        'reservation_id': 12,
        'backup_reference': 'RES-12',
        'parking_space_id': 8,
        'parking_space_name': 'Owner Space',
        'driver_name': 'Driver One',
        'lookup_method': 'reservation_id',
        'event_type': 'entry_recorded',
        'was_successful': true,
        'identifier_suffix': 'RES12',
        'created_at': '2026-08-15T10:00:00+08:00',
      });

      expect(transaction.wasSuccessful, isTrue);
      expect(transaction.eventLabel, 'Entry Recorded');
      expect(transaction.backupReference, 'RES-12');
      expect(transaction.parkingSpaceId, 8);
    },
  );
}
