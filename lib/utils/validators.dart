class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static final RegExp _phPhoneRegex = RegExp(
    r'^(09|\+639)\d{9}$',
  );

  static final RegExp _plate4WheelRegex = RegExp(
    r'^[A-Z]{3}\s?\d{3,4}$',
    caseSensitive: false,
  );

  static final RegExp _plate2WheelRegex = RegExp(
    r'^(\d{3}\s?[A-Z]{3}|[A-Z]{2}\s?\d{4,5})$',
    caseSensitive: false,
  );

  /// Validates email address format strictly
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g., name@domain.com).';
    }
    return null;
  }

  /// Validates Philippine mobile number (09XXXXXXXXX or +639XXXXXXXXX)
  static String? validatePhPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required.';
    }
    final sanitized = value.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (!_phPhoneRegex.hasMatch(sanitized)) {
      return 'Enter a valid 11-digit Philippine mobile number (e.g., 09123456789).';
    }
    return null;
  }

  /// Validates strong password security requirements:
  /// - Min 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 number
  /// - At least 1 special character
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter (A-Z).';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter (a-z).';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number (0-9).';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$%^&*).';
    }
    return null;
  }

  /// Validates standard Philippine LTO License Plate formats
  static String? validateLicensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plate number is required.';
    }
    final normalized = value.trim().toUpperCase();
    if (!_plate4WheelRegex.hasMatch(normalized) &&
        !_plate2WheelRegex.hasMatch(normalized)) {
      return 'Enter a valid Philippine plate (e.g., ABC 1234 or 123 ABC).';
    }
    return null;
  }

  /// Validates physical dimension (height, width, length in meters)
  static String? validateDimension(String? value, {String label = 'Dimension'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive number for $label.';
    }
    if (parsed > 25.0) {
      return '$label cannot exceed 25.0 meters.';
    }
    return null;
  }

  /// Sanitizes text input by stripping hazardous script or HTML tags
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true), '')
        .replaceAll(RegExp(r'[<>\"]'), '')
        .trim();
  }

  /// Formats reservation reference to ensure a randomized/pseudo-random 8-digit numeric sequence (e.g. RES-50549473 or EP-48884948).
  static String formatReservationNumber(String? value, {int id = 0}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      final seed = id > 0 ? id : 1;
      final num =
          ((seed * 1664525 + 1013904223).abs() % 90000000) + 10000000;
      return 'EP-$num';
    }
    final match = RegExp(r'^([A-Za-z]+[\s\-_]*)?(\d+)$').firstMatch(text);
    if (match != null) {
      final rawPrefix = match.group(1);
      final prefix = rawPrefix == null || rawPrefix.isEmpty
          ? 'EP-'
          : rawPrefix.trim().replaceAll(RegExp(r'\s+'), '');
      final normalizedPrefix =
          prefix.endsWith('-') || prefix.endsWith('_') ? prefix : '$prefix-';
      final numStr = match.group(2)!;
      if (numStr.length >= 8) {
        return '$normalizedPrefix$numStr';
      }
      final parsed = int.tryParse(numStr) ?? (id > 0 ? id : 1);
      final generated =
          ((parsed * 1664525 + 1013904223).abs() % 90000000) + 10000000;
      return '$normalizedPrefix$generated';
    }
    return text;
  }
}
