import 'package:e_parada_mobile/utils/registration_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('vehicle plate validation', () {
    test('accepts and normalizes four-wheeled plates including legacy 3-digit format', () {
      expect(
        RegistrationValidation.normalizePlate('abc-1234', 'Car'),
        'ABC 1234',
      );
      expect(
        RegistrationValidation.normalizePlate('abc-123', 'Car'),
        'ABC 123',
      );
      expect(
        RegistrationValidation.normalizePlate('abc123', 'SUV/MPV'),
        'ABC 123',
      );
      expect(RegistrationValidation.plate('ABC 1234', 'Car'), isNull);
      expect(RegistrationValidation.plate('ABC 123', 'Car'), isNull);
      expect(RegistrationValidation.plate('abc-123', 'Pickup/Van'), isNull);
      expect(RegistrationValidation.plate('AB 1234', 'Car'), isNotNull);
      expect(RegistrationValidation.plate('ABC 12', 'Car'), isNotNull);
      expect(RegistrationValidation.plate('ABC 12345', 'Car'), isNotNull);
      expect(
        RegistrationValidation.plate(
          'ABC 123',
          RegistrationValidation.motorcycleType,
        ),
        isNotNull,
      );
    });

    test('accepts all supported motorcycle formats', () {
      const plates = [
        'A 123 BC',
        'AB 123 C',
        '1 ABC 23',
        '1ABC23',
        'A 1234 C',
        'A 1C 234',
        'A 12C 34',
        '12AB3C',
        'AB1C23',
        '1A2BC3',
        'A1B2C3',
        'A12B3C',
        '1AB23C',
        'A1B23C',
        'AB12C3',
        '1AB2C3',
        'A12BC3',
        'A1B234',
        '1A2B3C',
        'A12B34',
        'A123B4',
        '12ABC3',
        'A1BC23',
        '12-ab 3c',
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
