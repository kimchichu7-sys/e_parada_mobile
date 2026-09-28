import 'package:e_parada_mobile/services/wallet_service.dart';
import 'package:e_parada_mobile/widgets/driver_wallet_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await WalletService.resetForTest();
  });

  group('WalletService Unit Tests', () {
    test('initializes with default 500 PHP welcome bonus', () async {
      final balance = await WalletService.getBalance();
      expect(balance, equals(500.0));
      expect(WalletService.transactionsNotifier.value.isNotEmpty, isTrue);
      expect(
        WalletService.transactionsNotifier.value.first.type,
        equals(WalletTransactionType.topUp),
      );
    });

    test('topUp adds balance and records transaction', () async {
      final success = await WalletService.topUp(
        amount: 300.0,
        method: 'GCash',
      );
      expect(success, isTrue);
      expect(WalletService.balanceNotifier.value, equals(800.0));
      expect(
        WalletService.transactionsNotifier.value.first.description,
        contains('GCash'),
      );
    });

    test('deduct reduces balance when sufficient funds exist', () async {
      final success = await WalletService.deduct(
        amount: 150.0,
        description: 'Parking at SM Megamall',
        reference: 'RES-TEST1234',
      );
      expect(success, isTrue);
      expect(WalletService.balanceNotifier.value, equals(350.0));
      expect(
        WalletService.transactionsNotifier.value.first.reference,
        equals('RES-TEST1234'),
      );
    });

    test('deduct fails when balance is insufficient', () async {
      final success = await WalletService.deduct(
        amount: 1000.0,
        description: 'Large parking payment',
        reference: 'RES-FAIL',
      );
      expect(success, isFalse);
      expect(WalletService.balanceNotifier.value, equals(500.0));
    });
  });

  group('DriverWalletDialog Widget Tests', () {
    testWidgets('renders balance, preset chips, and payment method options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverWalletDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('E-Parada Wallet'), findsOneWidget);
      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('₱500.00'), findsOneWidget);
      expect(find.text('₱100'), findsOneWidget);
      expect(find.text('₱300'), findsOneWidget);
      expect(find.text('₱500'), findsOneWidget);
      expect(find.text('₱1000'), findsOneWidget);
      expect(find.text('GCash'), findsOneWidget);
      expect(find.text('Maya'), findsOneWidget);
    });
  });
}
