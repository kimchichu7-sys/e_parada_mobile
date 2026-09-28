import 'package:e_parada_mobile/utils/registration_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('vehicle plate validation', () {
    test('accepts and normalizes four-wheeled plates', () {
      expect(
        RegistrationValidation.normalizePlate('abc-1234', 'Car'),
        'ABC 1234',
      );
      expect(RegistrationValidation.plate('ABC 1234', 'Car'), isNull);
      expect(RegistrationValidation.plate('AB 1234', 'Car'), isNotNull);
    });

    test('accepts all supported motorcycle formats', () {
      const plates = [
        'A 123 BC',
        'AB 123 C',
        '1 ABC 23',
        'A 1234 C',
        'A 1C 234',
        'A 12C 34',
      ];

      for (final plate in plates) {
        expect(
          RegistrationValidation.plate(
            plate,
            RegistrationValidation.motorcycleType,
          ),
          isNull,
          reason: plate,
        );
      }
    });
  });

  group('identity validation', () {
    test('requires realistic names matching backend rules', () {
      expect(RegistrationValidation.name('Maria Dela Cruz'), isNull);
      expect(RegistrationValidation.name("Anne O'Neil"), isNull);
      expect(RegistrationValidation.name('Jose P. Rizal'), isNull);
      expect(RegistrationValidation.name('Jean-Luc Picard'), isNull);
      expect(RegistrationValidation.name('123456'), isNotNull);
      expect(RegistrationValidation.name('A'), isNotNull);
      expect(RegistrationValidation.name('!@#\$%^'), isNotNull);
    });

    test('requires a complete valid email address and blocks disposable domains', () {
      expect(RegistrationValidation.email('user@gmail.com'), isNull);
      expect(RegistrationValidation.email('maria.cruz@outlook.ph'), isNull);
      expect(RegistrationValidation.email('user@gmail'), isNotNull);
      expect(RegistrationValidation.email('random text'), isNotNull);
      expect(RegistrationValidation.email('user..name@gmail.com'), isNotNull);
      expect(RegistrationValidation.email('user@mailinator.com'), isNotNull);
      expect(RegistrationValidation.email('temp@guerrillamail.com'), isNotNull);
      expect(RegistrationValidation.email('test@10minutemail.com'), isNotNull);
      expect(RegistrationValidation.email('test@tempmail.com'), isNotNull);
    });
  });
}
