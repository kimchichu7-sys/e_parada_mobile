import 'package:e_parada_mobile/screens/qr_scanner_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('firstUsableQrValue ignores null and blank scanner values', () {
    expect(
      firstUsableQrValue([null, '', '   ', '  EPARADA-ABC123  ', 'later']),
      'EPARADA-ABC123',
    );
  });

  test('firstUsableQrValue returns null when no credential was read', () {
    expect(firstUsableQrValue([null, '', '  ']), isNull);
  });

  test('scanner error explains Windows camera contention', () {
    expect(
      scannerErrorMessage('NotReadableError: Could not start video source'),
      contains('Close other E-Parada scanner tabs'),
    );
  });
}
