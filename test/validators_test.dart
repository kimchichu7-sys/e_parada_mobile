import 'package:e_parada_mobile/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators Security Suite', () {
    test('validateEmail validates RFC compliant emails', () {
      expect(Validators.validateEmail('driver@eparada.ph'), isNull);
      expect(Validators.validateEmail(''), 'Email address is required.');
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
    });

    test('validatePhPhone validates Philippine mobile formats', () {
      expect(Validators.validatePhPhone('09171234567'), isNull);
      expect(Validators.validatePhPhone('+639171234567'), isNull);
      expect(Validators.validatePhPhone('0912-345-6789'), isNull);
      expect(Validators.validatePhPhone('08123456789'), isNotNull);
      expect(Validators.validatePhPhone('12345'), isNotNull);
    });

    test('validateStrongPassword enforces 8+ chars, upper, lower, digit, symbol', () {
      expect(Validators.validateStrongPassword('ValidPass123!'), isNull);
      expect(Validators.validateStrongPassword('short1!'), isNotNull);
      expect(Validators.validateStrongPassword('nouppercase123!'), isNotNull);
      expect(Validators.validateStrongPassword('NOLOWERCASE123!'), isNotNull);
      expect(Validators.validateStrongPassword('NoDigitsHere!'), isNotNull);
      expect(Validators.validateStrongPassword('NoSpecialChar123'), isNotNull);
    });

    test('validateLicensePlate accepts valid 4-wheel and 2-wheel plates', () {
      expect(Validators.validateLicensePlate('ABC 1234'), isNull);
      expect(Validators.validateLicensePlate('ABC1234'), isNull);
      expect(Validators.validateLicensePlate('123 ABC'), isNull);
      expect(Validators.validateLicensePlate('AB 12345'), isNull);
      expect(Validators.validateLicensePlate('INVALID PLATE 999'), isNotNull);
    });

    test('validateDimension validates positive meters and bounds', () {
      expect(Validators.validateDimension('2.5', label: 'Height'), isNull);
      expect(Validators.validateDimension('0', label: 'Height'), isNotNull);
      expect(Validators.validateDimension('-1.5', label: 'Height'), isNotNull);
      expect(Validators.validateDimension('30.0', label: 'Height'), isNotNull);
      expect(Validators.validateDimension('abc', label: 'Height'), isNotNull);
    });

    test('sanitizeInput strips malicious script and html tags', () {
      expect(Validators.sanitizeInput('<script>alert("xss")</script>Hello'), 'alert(xss)Hello');
      expect(Validators.sanitizeInput('<b>Bold Text</b>'), 'Bold Text');
      expect(Validators.sanitizeInput('Clean Text'), 'Clean Text');
    });

    test('formatReservationNumber ensures 8-digit pseudo-random numbers for RES and EP references', () {
      expect(Validators.formatReservationNumber('RES-9'), 'RES-48884948');
      expect(Validators.formatReservationNumber('EP-9'), 'EP-48884948');
      expect(Validators.formatReservationNumber('9'), 'EP-48884948');
      expect(Validators.formatReservationNumber('', id: 9), 'EP-48884948');
      expect(Validators.formatReservationNumber('EP-10293847'), 'EP-10293847');
      expect(Validators.formatReservationNumber('RES-10293847'), 'RES-10293847');
    });
  });
}
