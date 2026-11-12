import 'package:e_parada_mobile/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses reservation readiness returned by the API', () {
    final user = AuthUser.fromJson({
      'id': 12,
      'name': 'Driver One',
      'email': 'driver@example.test',
      'role': 'driver',
      'verification_status': 'approved',
      'email_verified': true,
      'has_approved_vehicle': true,
      'can_reserve': true,
      'can_manage_parking_spaces': false,
      'remaining_vehicle_slots': 2,
    });

    expect(user.role, 'driver');
    expect(user.emailVerified, true);
    expect(user.hasApprovedVehicle, true);
    expect(user.canReserve, true);
    expect(user.remainingVehicleSlots, 2);
  });

  test('recognizes parking-owner access', () {
    final user = AuthUser.fromJson({
      'id': 21,
      'name': 'Owner One',
      'email': 'owner@example.test',
      'role': 'parking_owner',
      'verification_status': 'approved',
      'email_verified': true,
      'has_approved_vehicle': false,
      'can_reserve': false,
      'can_manage_parking_spaces': true,
      'remaining_vehicle_slots': 0,
    });

    expect(user.isParkingOwner, true);
    expect(user.roleLabel, 'Parking owner');
    expect(user.canManageParkingSpaces, true);
  });

  test('recognizes administrator access', () {
    final user = AuthUser.fromJson({
      'id': 1,
      'name': 'Admin One',
      'email': 'admin@example.test',
      'role': 'admin',
      'verification_status': 'approved',
      'email_verified': true,
      'has_approved_vehicle': false,
      'can_reserve': false,
      'can_manage_parking_spaces': false,
      'remaining_vehicle_slots': 0,
    });

    expect(user.isAdmin, true);
    expect(user.roleLabel, 'Administrator');
  });

  test('tracks driver_only subtype and vehicle addition gating by verification', () {
    final pendingDriverOnly = AuthUser.fromJson({
      'id': 31,
      'name': 'Pending Driver',
      'email': 'pending-driver@example.test',
      'role': 'driver',
      'user_subtype': 'driver_only',
      'verification_status': 'pending',
      'email_verified': true,
      'has_approved_vehicle': false,
      'can_reserve': false,
      'can_add_vehicle': false,
      'can_manage_parking_spaces': false,
      'remaining_vehicle_slots': 3,
    });

    expect(pendingDriverOnly.isDriverOnly, true);
    expect(pendingDriverOnly.isAccountVerified, false);
    expect(pendingDriverOnly.canAddVehicle, false);

    final approvedDriverOnly = AuthUser.fromJson({
      'id': 32,
      'name': 'Approved Driver',
      'email': 'approved-driver@example.test',
      'role': 'driver',
      'user_subtype': 'driver_only',
      'verification_status': 'approved',
      'email_verified': true,
      'has_approved_vehicle': false,
      'can_reserve': false,
      'can_add_vehicle': true,
      'can_manage_parking_spaces': false,
      'remaining_vehicle_slots': 3,
    });

    expect(approvedDriverOnly.isDriverOnly, true);
    expect(approvedDriverOnly.isAccountVerified, true);
    expect(approvedDriverOnly.canAddVehicle, true);
  });
}
