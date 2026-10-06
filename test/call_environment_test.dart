import 'package:e_parada_mobile/services/call_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('callPreflightMessage', () {
    test('allows native apps', () {
      expect(
        callPreflightMessage(
          isWeb: false,
          pageUri: Uri.parse('http://192.168.1.8:53730'),
        ),
        isNull,
      );
    });

    test('allows secure web origins', () {
      expect(
        callPreflightMessage(
          isWeb: true,
          pageUri: Uri.parse('https://e-parada.test'),
        ),
        isNull,
      );
    });

    test('allows localhost for desktop development', () {
      expect(
        callPreflightMessage(
          isWeb: true,
          pageUri: Uri.parse('http://localhost:53730'),
        ),
        isNull,
      );
    });

    test('blocks insecure local-network web origins', () {
      expect(
        callPreflightMessage(
          isWeb: true,
          pageUri: Uri.parse('http://192.168.100.205:53730'),
        ),
        contains('HTTPS'),
      );
    });
  });

  test('turns permission failures into actionable guidance', () {
    expect(
      callSetupErrorMessage(Exception('NotAllowedError: Permission denied')),
      contains('Allow microphone access'),
    );
    expect(
      callSetupErrorMessage(Exception('PlatformException(getUserMedia, Failed to create new track., null, null)')),
      contains('Allow microphone access'),
    );
    expect(
      callSetupErrorMessage(Exception('java.lang.SecurityException: Need android.permission.BLUETOOTH_CONNECT')),
      contains('Allow microphone access'),
    );
  });
}
