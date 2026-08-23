class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.verificationStatus,
    required this.emailVerified,
    required this.hasApprovedVehicle,
    required this.canReserve,
    required this.canManageParkingSpaces,
    required this.remainingVehicleSlots,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String verificationStatus;
  final bool emailVerified;
  final bool hasApprovedVehicle;
  final bool canReserve;
  final bool canManageParkingSpaces;
  final int remainingVehicleSlots;

  bool get isDriver => role == 'driver';
  bool get isParkingOwner => role == 'parking_owner';
  bool get isAdmin => role == 'admin';

  String get roleLabel => switch (role) {
    'admin' => 'Administrator',
    'parking_owner' => 'Parking owner',
    _ => 'Driver',
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      verificationStatus: json['verification_status']?.toString() ?? 'pending',
      emailVerified: json['email_verified'] == true,
      hasApprovedVehicle: json['has_approved_vehicle'] == true,
      canReserve: json['can_reserve'] == true,
      canManageParkingSpaces: json['can_manage_parking_spaces'] == true,
      remainingVehicleSlots:
          (json['remaining_vehicle_slots'] as num?)?.toInt() ?? 0,
    );
  }
}
