class RegistrationValidation {
  static const motorcycleType = 'Motorcycle/E-bicycle';

  static const blockedEmailDomains = <String>{
    'mailinator.com',
    'guerrillamail.com',
    '10minutemail.com',
    'tempmail.com',
    'temp-mail.org',
    'yopmail.com',
  };

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2 ||
        !RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿÑñ]").hasMatch(name) ||
        !RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÑñ .'-]+$").hasMatch(name)) {
      return 'Enter your real name using letters, spaces, apostrophes, periods, or hyphens only.';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) {
      return 'Enter a complete email address such as name@gmail.com.';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Enter a real email address with a valid domain, such as name@gmail.com.';
    }

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length < 2 ||
        localPart.contains('..') ||
        !RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(localPart) ||
        !RegExp(r"^(?=.{4,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$")
            .hasMatch(domain)) {
      return 'Enter a real email address with a valid domain, such as name@gmail.com.';
    }

    if (blockedEmailDomains.contains(domain)) {
      return 'Temporary or disposable email addresses are not allowed.';
    }

    return null;
  }

  static String? plate(String? value, String vehicleType) {
    if (RegExp(r'[^A-Za-z0-9 -]').hasMatch(value ?? '')) {
      return plateHint(vehicleType);
    }

    final normalized = normalizePlate(value ?? '', vehicleType);
    final valid = vehicleType == motorcycleType
        ? RegExp(
            r'^(?:[A-Z] \d{3} [A-Z]{2}|[A-Z]{2} \d{3} [A-Z]|\d [A-Z]{3} \d{2}|[A-Z] \d{4} [A-Z]|[A-Z] \d[A-Z] \d{3}|[A-Z] \d{2}[A-Z] \d{2})$',
          ).hasMatch(normalized)
        : RegExp(r'^[A-Z]{3} \d{4}$').hasMatch(normalized);

    return valid ? null : plateHint(vehicleType);
  }

  static String plateHint(String vehicleType) {
    return vehicleType == motorcycleType
        ? 'Use A 123 BC, AB 123 C, 1 ABC 23, A 1234 C, A 1C 234, or A 12C 34.'
        : 'Use three letters and four digits, for example ABC 1234.';
  }

  static String normalizePlate(String value, String vehicleType) {
    final compact = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (vehicleType == motorcycleType) {
      final formats = <(RegExp, String Function(Match))>[
        (
          RegExp(r'^([A-Z])(\d{3})([A-Z]{2})$'),
          (m) => '${m[1]} ${m[2]} ${m[3]}',
        ),
        (
          RegExp(r'^([A-Z]{2})(\d{3})([A-Z])$'),
          (m) => '${m[1]} ${m[2]} ${m[3]}',
        ),
        (RegExp(r'^(\d)([A-Z]{3})(\d{2})$'), (m) => '${m[1]} ${m[2]} ${m[3]}'),
        (RegExp(r'^([A-Z])(\d{4})([A-Z])$'), (m) => '${m[1]} ${m[2]} ${m[3]}'),
        (
          RegExp(r'^([A-Z])(\d[A-Z])(\d{3})$'),
          (m) => '${m[1]} ${m[2]} ${m[3]}',
        ),
        (
          RegExp(r'^([A-Z])(\d{2}[A-Z])(\d{2})$'),
          (m) => '${m[1]} ${m[2]} ${m[3]}',
        ),
      ];
      for (final format in formats) {
        final match = format.$1.firstMatch(compact);
        if (match != null) return format.$2(match);
      }
    } else {
      final match = RegExp(r'^([A-Z]{3})(\d{4})$').firstMatch(compact);
      if (match != null) return '${match[1]} ${match[2]}';
    }

    return value.toUpperCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
