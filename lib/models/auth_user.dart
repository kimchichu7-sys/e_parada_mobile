class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.userSubtype = 'owner_driver',
    required this.verificationStatus,
    required this.emailVerified,
    this.termsAccepted = true,
    required this.hasApprovedVehicle,
    required this.canReserve,
    this.canAddVehicle = false,
    required this.canManageParkingSpaces,
    required this.remainingVehicleSlots,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String userSubtype;
  final String verificationStatus;
  final bool emailVerified;
  final bool termsAccepted;
  final bool hasApprovedVehicle;
  final bool canReserve;
  final bool canAddVehicle;
  final bool canManageParkingSpaces;
  final int remainingVehicleSlots;

  bool get isDriver => role == 'driver';
  bool get isDriverOnly => userSubtype == 'driver_only';
  bool get isAccountVerified =>
      emailVerified && verificationStatus == 'approved';
  bool get isParkingOwner => role == 'parking_owner';
  bool get isAdmin => role == 'admin';

  String get roleLabel => switch (role) {
    'admin' => 'Administrator',
    'parking_owner' => 'Parking owner',
    _ => 'Driver',
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final role = json['role']?.toString() ?? '';
    final verificationStatus =
        json['verification_status']?.toString() ?? 'pending';
    final emailVerified = json['email_verified'] == true;
    final remainingSlots =
        (json['remaining_vehicle_slots'] as num?)?.toInt() ?? 0;

    return AuthUser(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: role,
      userSubtype:
          json['user_subtype']?.toString() ??
          (role == 'parking_owner' ? 'parking_provider' : 'owner_driver'),
      verificationStatus: verificationStatus,
      emailVerified: emailVerified,
      termsAccepted: json.containsKey('terms_accepted')
          ? json['terms_accepted'] == true
          : true,
      hasApprovedVehicle: json['has_approved_vehicle'] == true,
      canReserve: json['can_reserve'] == true,
      canAddVehicle: json.containsKey('can_add_vehicle')
          ? json['can_add_vehicle'] == true
          : (role == 'driver' &&
                emailVerified &&
                verificationStatus == 'approved' &&
                remainingSlots > 0),
      canManageParkingSpaces: json['can_manage_parking_spaces'] == true,
      remainingVehicleSlots: remainingSlots,
    );
  }
}
