import 'package:e_parada_mobile/models/admin_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses admin review models from API payloads', () {
    final user = AdminUserReview.fromJson({
      'id': 7,
      'name': 'Driver One',
      'email': 'driver@example.com',
      'role': 'driver',
      'verification_status': 'pending',
      'email_verified': true,
      'id_type': "Driver's License",
      'has_identity_document': true,
      'vehicles_count': 2,
    });
    final vehicle = AdminVehicleReview.fromJson({
      'id': 8,
      'driver_name': 'Driver One',
      'plate_number': 'ABC 1234',
      'vehicle_type': 'Car',
      'make': 'Toyota',
      'color': 'Blue',
      'model': 'Vios',
      'verification_status': 'pending',
      'has_photo': true,
    });
    final space = AdminParkingSpaceReview.fromJson({
      'id': 9,
      'owner_name': 'Owner One',
      'space_name': 'Campus Parking',
      'dimensions_sqm': 24,
      'vehicle_types': ['Car', 'SUV/MPV'],
      'vehicle_hourly_rates': {'Car': 50, 'SUV/MPV': '70'},
      'approval_status': 'pending',
      'is_available': true,
      'active_slots': 4,
    });

    expect(user.vehiclesCount, 2);
    expect(user.hasIdentityDocument, true);
    expect(vehicle.description, 'Car | Blue Toyota Vios');
    expect(space.vehicleTypes, ['Car', 'SUV/MPV']);
    expect(space.hourlyRates['SUV/MPV'], 70);
  });

  test('parses reservation support and activity models', () {
    final reservation = AdminReservationReview.fromJson({
      'id': 12,
      'backup_reference': 'RES-12',
      'driver_name': 'Driver One',
      'owner_name': 'Owner One',
      'parking_space_name': 'Campus Parking',
      'vehicle_label': 'ABC 1234 | Car',
      'schedule': 'Aug 15, 2026 09:00 to Aug 15, 2026 10:00',
      'status': 'approved',
      'payment_status': 'paid',
      'total_amount': '50.00',
      'dispute_status': 'under_review',
    });
    final support = AdminSupportRequest.fromJson({
      'id': 3,
      'name': 'Driver One',
      'email': 'driver@example.com',
      'category': 'reservation',
      'subject': 'QR issue',
      'message': 'The code did not scan.',
      'status': 'open',
    });
    final qr = AdminQrLog.fromJson({
      'id': 4,
      'reservation_id': 12,
      'backup_reference': 'RES-12',
      'parking_space_id': 9,
      'parking_space_name': 'Campus Parking',
      'lookup_method': 'backup_reference',
      'event_type': 'entry_recorded',
      'was_successful': true,
    });
    final audit = AdminAuditLog.fromJson({
      'id': 5,
      'action': 'updated',
      'description': 'Support request reviewed.',
      'actor_name': 'Admin',
      'subject_type': 'SupportRequest',
      'subject_id': 3,
      'parking_space_id': null,
      'parking_space_name': null,
    });

    expect(reservation.totalAmount, 50);
    expect(reservation.disputeStatus, 'under_review');
    expect(support.subject, 'QR issue');
    expect(qr.wasSuccessful, true);
    expect(qr.parkingSpaceId, 9);
    expect(audit.subjectId, 3);
    expect(audit.parkingSpaceName, 'Platform activity');
  });
}
