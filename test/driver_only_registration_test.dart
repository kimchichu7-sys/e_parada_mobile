import 'package:e_parada_mobile/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Driver Only registration option hides vehicle submission fields and shows deferred vehicle guidance',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );
      await tester.pumpAndSettle();

      // Scroll down to reveal vehicle section in ListView for default Owner & Driver.
      await tester.scrollUntilVisible(
        find.text('First vehicle'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('First vehicle'), findsOneWidget);

      // Scroll back to registration options and switch to 1. Driver Only.
      final driverOnlyFinder = find.text('1. Driver Only');
      await tester.scrollUntilVisible(
        driverOnlyFinder,
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(driverOnlyFinder);
      await tester.pumpAndSettle();
      await tester.tap(driverOnlyFinder);
      await tester.pumpAndSettle();

      final deferredFinder = find.textContaining(
        'After your email and account are verified',
      );
      await tester.scrollUntilVisible(
        deferredFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(deferredFinder, findsOneWidget);

      // Scrolling down confirms First vehicle is not built at all for Driver Only.
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(find.text('First vehicle'), findsNothing);

      // Scroll back up and switch to 2. Vehicle Owner Only; First vehicle returns.
      final ownerOnlyFinder = find.text('2. Vehicle Owner Only');
      await tester.scrollUntilVisible(
        ownerOnlyFinder,
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(ownerOnlyFinder);
      await tester.pumpAndSettle();
      await tester.tap(ownerOnlyFinder);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('First vehicle'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('First vehicle'), findsOneWidget);
    },
  );
}
