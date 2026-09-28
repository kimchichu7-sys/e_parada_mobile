import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_parada_mobile/services/paymongo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PayMongoSourceResult parses JSON response with attributes and centavos', () {
    final result = PayMongoSourceResult.fromJson({
      'data': {
        'id': 'src_1234567890abcdef',
        'type': 'source',
        'attributes': {
          'amount': 4500,
          'currency': 'PHP',
          'status': 'pending',
          'redirect': {
            'checkout_url': 'https://test-sources.paymongo.com/sources?id=src_1234567890abcdef',
            'success': 'https://e-parada.ph/payment-success',
            'failed': 'https://e-parada.ph/payment-failed',
          },
        },
      },
    });

    expect(result.id, 'src_1234567890abcdef');
    expect(result.type, 'source');
    expect(result.amountCentavos, 4500);
    expect(result.amountPhp, 45.0);
    expect(result.currency, 'PHP');
    expect(result.isPending, isTrue);
    expect(result.isChargeable, isFalse);
    expect(result.checkoutUrl, contains('test-sources.paymongo.com'));
  });

  test('PayMongoService creates simulation source when in simulation mode', () async {
    await PayMongoService.saveSettings(
      environment: PayMongoEnvironment.simulation,
    );

    final source = await PayMongoService.createGcashSource(
      amountPhp: 60.0,
      description: 'E-Parada Test Parking',
      customerPhone: '09171234567',
    );

    expect(source.id, startsWith('src_sim_'));
    expect(source.amountCentavos, 6000);
    expect(source.amountPhp, 60.0);
    expect(source.isSimulated, isTrue);
  });

  test('PayMongoService saves and restores custom API keys', () async {
    await PayMongoService.saveSettings(
      publicKey: 'pk_live_custom123456',
      environment: PayMongoEnvironment.live,
    );

    expect(PayMongoService.activePublicKey, 'pk_live_custom123456');
    expect(PayMongoService.hasCustomKey, isTrue);
    expect(PayMongoService.isLive, isTrue);

    await PayMongoService.saveSettings(
      publicKey: '',
      environment: PayMongoEnvironment.sandbox,
    );

    expect(PayMongoService.activePublicKey, '');
    expect(PayMongoService.hasCustomKey, isFalse);
    expect(PayMongoService.isSandbox, isTrue);
  });
}
