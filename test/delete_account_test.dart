import 'package:e_parada_mobile/services/auth_service.dart';
import 'package:e_parada_mobile/widgets/delete_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'fake-sample-token-12345',
      'user_id': 99,
      'user_name': 'Test User',
      'user_email': 'testuser@example.com',
      'user_role': 'driver',
    });
  });

  testWidgets('DeleteAccountDialog renders warning, password field, and confirmation input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DeleteAccountDialog.show(
                context,
                userEmail: 'testuser@example.com',
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Warning: This action is permanent'), findsOneWidget);
    expect(find.text('Account: testuser@example.com'), findsOneWidget);
    expect(find.text('Enter your current password'), findsOneWidget);
    expect(find.text('Type DELETE below to confirm permanent deletion:'), findsOneWidget);

    // Delete button should initially be disabled or require DELETE confirmation
    final deleteButtonFinder = find.widgetWithText(FilledButton, 'Permanently Delete');
    expect(deleteButtonFinder, findsOneWidget);
    final FilledButton buttonWidget = tester.widget(deleteButtonFinder);
    expect(buttonWidget.onPressed, isNull);

    // Enter confirmation text
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.pumpAndSettle();

    final FilledButton activeDeleteButton = tester.widget(deleteButtonFinder);
    expect(activeDeleteButton.onPressed, isNotNull);

    // Test Cancel button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Account'), findsNothing);
  });

  test('AuthService.clearSession removes all auth and cached user keys', () async {
    expect(await AuthService.isLoggedIn(), isTrue);
    expect(await AuthService.authToken(), equals('fake-sample-token-12345'));

    await AuthService.clearSession();

    expect(await AuthService.isLoggedIn(), isFalse);
    expect(await AuthService.authToken(), isNull);
  });
}
